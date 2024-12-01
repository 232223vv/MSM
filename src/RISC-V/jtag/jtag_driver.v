module jtag_driver #(//本模块完成JTAG TAP维护，输出DMI
    parameter DMI_ADDR_BITS = 6,
    parameter DMI_DATA_BITS = 32,
    parameter DMI_OP_BITS = 2,
    parameter DM_RESP_BITS = 40,
    parameter DTM_REQ_BITS = 40
)(
    input  wire rst_n,
    //JTAG
    input  wire jtag_TCK,
    input  wire jtag_TDI,
    input  wire jtag_TMS,
    output reg  jtag_TDO,
    //dm->dtm
    input  wire dm_resp_i,
    input  wire [DM_RESP_BITS - 1:0] dm_resp_data_i,
    output wire dtm_ack_o,
    //dtm->dm
    input  wire dm_ack_i,
    output wire dtm_req_valid_o,
    output wire [DTM_REQ_BITS - 1:0] dtm_req_data_o
);


localparam IDCODE_VERSION  = 4'h1;//IDCODE[31:28]
localparam IDCODE_PART_NUMBER = 16'he200;//IDCODE[27:12]
localparam IDCODE_MANUFLD = 11'h537;//IDCODE[11:1]
//IDCODE[1]=1

localparam IR_BITS = 5;//IR寄存器位宽，最多可寻址2^5=32个DR
localparam DTM_VERSION  = 4'h1;//dtmcs[3:0]spec 0.13版本


localparam SHIFT_REG_BITS = DTM_REQ_BITS;//移位寄存器位宽

//JTAG TAP状态机
localparam TEST_LOGIC_RESET  = 4'h0;
localparam RUN_TEST_IDLE     = 4'h1;
localparam SELECT_DR         = 4'h2;
localparam CAPTURE_DR        = 4'h3;
localparam SHIFT_DR          = 4'h4;
localparam EXIT1_DR          = 4'h5;
localparam PAUSE_DR          = 4'h6;
localparam EXIT2_DR          = 4'h7;
localparam UPDATE_DR         = 4'h8;
localparam SELECT_IR         = 4'h9;
localparam CAPTURE_IR        = 4'hA;
localparam SHIFT_IR          = 4'hB;
localparam EXIT1_IR          = 4'hC;
localparam PAUSE_IR          = 4'hD;
localparam EXIT2_IR          = 4'hE;
localparam UPDATE_IR         = 4'hF;

//DTM DR 地址
localparam REG_BYPASS       = 5'b11111;
localparam REG_IDCODE       = 5'b00001;
localparam REG_DMI          = 5'b10001;
localparam REG_DTMCS        = 5'b10000;

reg[IR_BITS - 1:0] ir_reg;//IR寄存器
reg[SHIFT_REG_BITS - 1:0] shift_reg;
reg[3:0] jtag_state;
wire is_busy;
reg sticky_busy;//清除出错
reg dtm_req_valid;//dmi请求
reg[DTM_REQ_BITS - 1:0] dtm_req_data;
reg[DM_RESP_BITS - 1:0] dm_resp_data;
reg dm_is_busy;//dmi繁忙

wire[5:0] addr_bits = DMI_ADDR_BITS[5:0];
wire [SHIFT_REG_BITS - 1:0] busy_response;
wire [SHIFT_REG_BITS - 1:0] none_busy_response;
wire[31:0] idcode;
wire[31:0] dtmcs;
wire[1:0] dmi_stat;
wire dtm_reset;
wire tx_idle;
wire rx_valid;
wire[DM_RESP_BITS - 1:0] rx_data;
wire tx_valid;
wire[DTM_REQ_BITS - 1:0] tx_data;

assign dtm_reset = shift_reg[16];
assign idcode = {IDCODE_VERSION, IDCODE_PART_NUMBER, IDCODE_MANUFLD, 1'h1};
assign dtmcs = {14'b0,
                1'b0,  // dmihardreset
                1'b0,  // dmireset
                1'b0,
                3'h5,  // idle，在Run-Test-Idle状态停留的时钟周期数
                dmi_stat,      // dmistat
                addr_bits,    // abits，dmi寄存器的address域位宽
                DTM_VERSION}; // spec version 0.13

assign busy_response = {{(DMI_ADDR_BITS + DMI_DATA_BITS){1'b0}}, {(DMI_OP_BITS){1'b1}}};  // op = 2'b11
assign none_busy_response = dm_resp_data;
assign is_busy = sticky_busy | dm_is_busy;
assign dmi_stat = is_busy ? 2'b01 : 2'b00;

//TAP状态转移
always @(posedge jtag_TCK or negedge rst_n) begin
    if (!rst_n) begin
        jtag_state <= TEST_LOGIC_RESET;
    end else begin
        case (jtag_state)
            TEST_LOGIC_RESET  : jtag_state <= jtag_TMS ? TEST_LOGIC_RESET : RUN_TEST_IDLE;
            RUN_TEST_IDLE     : jtag_state <= jtag_TMS ? SELECT_DR        : RUN_TEST_IDLE;
            SELECT_DR         : jtag_state <= jtag_TMS ? SELECT_IR        : CAPTURE_DR;
            CAPTURE_DR        : jtag_state <= jtag_TMS ? EXIT1_DR         : SHIFT_DR;
            SHIFT_DR          : jtag_state <= jtag_TMS ? EXIT1_DR         : SHIFT_DR;
            EXIT1_DR          : jtag_state <= jtag_TMS ? UPDATE_DR        : PAUSE_DR;
            PAUSE_DR          : jtag_state <= jtag_TMS ? EXIT2_DR         : PAUSE_DR;
            EXIT2_DR          : jtag_state <= jtag_TMS ? UPDATE_DR        : SHIFT_DR;
            UPDATE_DR         : jtag_state <= jtag_TMS ? SELECT_DR        : RUN_TEST_IDLE;
            SELECT_IR         : jtag_state <= jtag_TMS ? TEST_LOGIC_RESET : CAPTURE_IR;
            CAPTURE_IR        : jtag_state <= jtag_TMS ? EXIT1_IR         : SHIFT_IR;
            SHIFT_IR          : jtag_state <= jtag_TMS ? EXIT1_IR         : SHIFT_IR;
            EXIT1_IR          : jtag_state <= jtag_TMS ? UPDATE_IR        : PAUSE_IR;
            PAUSE_IR          : jtag_state <= jtag_TMS ? EXIT2_IR         : PAUSE_IR;
            EXIT2_IR          : jtag_state <= jtag_TMS ? UPDATE_IR        : SHIFT_IR;
            UPDATE_IR         : jtag_state <= jtag_TMS ? SELECT_DR        : RUN_TEST_IDLE; 
        endcase
    end
end

// IR or DR shift
always @(posedge jtag_TCK) begin
    case (jtag_state)
        // IR
        CAPTURE_IR: shift_reg <= {{(SHIFT_REG_BITS - 1){1'b0}}, 1'b1}; //JTAG spec says it must be b01
        SHIFT_IR  : shift_reg <= {{(SHIFT_REG_BITS - IR_BITS){1'b0}}, jtag_TDI, shift_reg[IR_BITS - 1:1]}; // right shift 1 bit
        // DR
        CAPTURE_DR: case (ir_reg) 
                        REG_BYPASS     : shift_reg <= {(SHIFT_REG_BITS){1'b0}};
                        REG_IDCODE     : shift_reg <= {{(SHIFT_REG_BITS - DMI_DATA_BITS){1'b0}}, idcode};
                        REG_DTMCS      : shift_reg <= {{(SHIFT_REG_BITS - DMI_DATA_BITS){1'b0}}, dtmcs};
                        REG_DMI        : shift_reg <=  is_busy ? busy_response : none_busy_response;
                        default:
                            shift_reg <= {(SHIFT_REG_BITS){1'b0}};
                    endcase
        SHIFT_DR  : case (ir_reg) 
                        REG_BYPASS     : shift_reg <= {{(SHIFT_REG_BITS - 1){1'b0}}, jtag_TDI}; // in = out
                        REG_IDCODE     : shift_reg <= {{(SHIFT_REG_BITS - DMI_DATA_BITS){1'b0}}, jtag_TDI, shift_reg[31:1]}; // right shift 1 bit
                        REG_DTMCS      : shift_reg <= {{(SHIFT_REG_BITS - DMI_DATA_BITS){1'b0}}, jtag_TDI, shift_reg[31:1]}; // right shift 1 bit
                        REG_DMI        : shift_reg <= {jtag_TDI, shift_reg[SHIFT_REG_BITS - 1:1]}; // right shift 1 bit
                        default:
                            shift_reg <= {{(SHIFT_REG_BITS - 1){1'b0}} , jtag_TDI};
                    endcase 
    endcase
end

//开始访问DM
always @(posedge jtag_TCK or negedge rst_n) begin
    if (!rst_n) begin
        dtm_req_valid <= 1'b0;
        dtm_req_data <= {DTM_REQ_BITS{1'b0}};
    end else begin
        if (jtag_state == UPDATE_DR) begin
            if (ir_reg == REG_DMI) begin
                // if DM can be access
                if (!is_busy & tx_idle) begin
                    dtm_req_valid <= 1'b1;
                    dtm_req_data <= shift_reg;
                end
            end
        end else begin
            dtm_req_valid <= 1'b0;
        end
    end
end

assign tx_valid = dtm_req_valid;
assign tx_data = dtm_req_data;

//清除出错
always @ (posedge jtag_TCK or negedge rst_n) begin
    if (!rst_n) begin
        sticky_busy <= 1'b0;
    end else begin
        if (jtag_state == UPDATE_DR) begin
            if (ir_reg == REG_DTMCS & dtm_reset) begin
                sticky_busy <= 1'b0;
            end
        end else if (jtag_state == CAPTURE_DR) begin
            if (ir_reg == REG_DMI) begin
                sticky_busy <= is_busy;
            end
        end
    end
end

//接收DM返回的数据
always @ (posedge jtag_TCK or negedge rst_n) begin
    if (!rst_n) begin
        dm_resp_data <= {DM_RESP_BITS{1'b0}};
    end else begin
        if (rx_valid) begin
            dm_resp_data <= rx_data;
        end
    end
end

//DM发送繁忙
always @ (posedge jtag_TCK or negedge rst_n) begin
    if (!rst_n) begin
        dm_is_busy <= 1'b0;
    end else begin
        if (dtm_req_valid) begin
            dm_is_busy <= 1'b1;
        end else if (rx_valid) begin
            dm_is_busy <= 1'b0;
        end
    end
end

//TAP复位
always @(negedge jtag_TCK) begin
    if (jtag_state == TEST_LOGIC_RESET) begin
        ir_reg <= REG_IDCODE;
    end else if (jtag_state == UPDATE_IR) begin
        ir_reg <= shift_reg[IR_BITS - 1:0];
    end
end

//TDO输出
always @(negedge jtag_TCK) begin
    if (jtag_state == SHIFT_IR) begin
        jtag_TDO <= shift_reg[0];
    end else if (jtag_state == SHIFT_DR) begin
        jtag_TDO <= shift_reg[0];
    end else begin
        jtag_TDO <= 1'b0;
    end
end

//跨时钟域的DMI
full_handshake_tx #(
    .DW(DTM_REQ_BITS)
) tx(
    .clk(jtag_TCK),
    .rst_n(rst_n),
    .ack_i(dm_ack_i),
    .req_i(tx_valid),
    .req_data_i(tx_data),
    .idle_o(tx_idle),
    .req_o(dtm_req_valid_o),
    .req_data_o(dtm_req_data_o)
);

full_handshake_rx #(
    .DW(DM_RESP_BITS)
) rx(
    .clk(jtag_TCK),
    .rst_n(rst_n),
    .req_i(dm_resp_i),
    .req_data_i(dm_resp_data_i),
    .ack_o(dtm_ack_o),
    .recv_data_o(rx_data),
    .recv_rdy_o(rx_valid)
);

endmodule

/*
"jtag_drive.v is licensed under Apache-2.0 (http://www.apache.org/licenses/LICENSE-2.0)
   by Blue Liang, liangkangnan@163.com.
*/