`include "source\rtl\defines.v"
//现场可编程IO阵列
module fpioa (
    input wire clk,
    input wire rst_n,

    input wire[7:0] waddr_i,
    input wire[`MemBus] data_i,
    input wire[3:0] sel_i,
    input wire we_i,
    input wire[7:0] raddr_i,
    input wire rd_i,
    output reg[`MemBus] data_o,
    //通信接口
    input  wire SPI0_SCK ,
    input  wire SPI0_MOSI,
    output wire SPI0_MISO,
    input  wire SPI0_CS  ,
    input  wire UART0_TX ,
    output wire UART0_RX ,
    input  wire UART1_TX ,
    output wire UART1_RX ,
    input  wire TIMER0_CMPO_N,
    input  wire TIMER0_CMPO_P,
    output wire TIMER0_CAPI  ,

    output wire [3:0]irq_fpioa_eli,    //FPIOA端口外部连线中断

    //FPIOA
    inout wire [`FPIOA_PORT_NUM-1:0] fpioa//处理器FPIOA接口
);

/*------------------------------
 * 线网配置方案
 * 32个FPIOA与128个外设输入端口和128个外设输出端口互联，形成现场可编程IO整列
 * 
 * 1. 输入数据: fpioa -> 外设输入
 * 32个FPIOA，通过128个32选1多路选择器，输出至唯一外设输入端口
 * 每个外设输入端口可连接至任意FPIOA
 * 
 * 2. 输出数据: 外设输出 -> fpioa
 * 128个外设输出端口，通过32个128选1多路选择器，输出至唯一FPIOA端口
 * 每个FPIOA可连接至任意外设输出端口
 * 
*/

// 寄存器(偏移)地址，从0x20开始
localparam FPIOA_NIO_DIN = 5'h0;//输入数据
localparam FPIOA_NIO_OPT = 5'h4;//输出数据
localparam FPIOA_NIO_MD0 = 5'h8;//模式位0(MODE0)
localparam FPIOA_NIO_MD1 = 5'hc;//模式位1(MODE1)
localparam FPIOA_IRQ_SET = 5'h10;



// 输入数据，只读，0x20
// [31:0]对应GPIO0-31的当前的高低电平
reg [31:0] fpioa_nio_din;

// 输出数据，读写，0x24
// [31:0]对应GPIO0-31的输出值
reg [31:0] fpioa_nio_opt;

/* 端口模式，读写
 * fpioa_nio_md0(MODE0)与fpioa_nio_md1(MODE1)共同决定GPIOx端口模式
 * | MODE1[x] | MODE0[x] | GPIOx  
 * |----------|----------|---------------
 * |    0     |    0     | 高阻输入
 * |    0     |    1     | 保留
 * |    1     |    0     | 推挽输出
 * |    1     |    1     | 开漏输出
 * |----------|----------|---------------*/
reg [31:0] fpioa_nio_md0;//0x28
reg [31:0] fpioa_nio_md1;//0x2c

/*
 * 外部连线中断触发模式寄存器，地址0x30
 * 仅低16位有效
 * 支持4个外部连线中断通道ELI0-ELI3 (Extern Line Interrupt)
 * 每个通道独立设置4种触发模式，支持多种模式同时启用
 * |                              对于中断通道ELI[x]                                     |
 * | fpioa_eli_md[x*4+3] | fpioa_eli_md[x*4+2] | fpioa_eli_md[x*4+1] | fpioa_eli_md[x*4] |
 * |---------------------|---------------------|---------------------|-------------------|
 * |    下降沿触发        |      上升沿触发     |      低电平触发      |      高电平触发    |
 * |---------------------|---------------------|---------------------|-------------------|*/
reg [15:0] fpioa_eli_md;

/*
 * 输出配置寄存器
 * 一个FPIOA端口对应一个5bit空间，可以连接至32个外设输出端口
 * 有如下映射关系：
 * 接口fpioa[x] 对应 fpioa_ot_reg[x] 
 * 选择当前fpioa[x]的输出信号来自哪一个外设 
 * 占用地址0x00-0x1F */
reg [4:0]fpioa_ot_reg[0:31];

/*
 * 输入配置寄存器
 * 一个外设输入端口对应一个5bit空间，可以连接至32个FPIOA
 * 有如下映射关系：
 * 外设输入端口[x] 对应 fpioa_in_reg[x]
 * 选择当前外设输入端口[x]的信号来自哪一个fpioa
 * 占用地址0x80-0xFF */
reg [4:0]fpioa_in_reg[0:31];


reg [31:0]fpioa_nio_oe ;//普通IO输出使能
reg [31:0]fpioa_nio_out;//普通IO实际输出数据

wire [`FPIOA_PORT_NUM-1:0]fpioa_oe,fpioa_ot;//FPIOA输出使能，输出数据
wire [31:0]fpioa_in;//FPIOA输入数据
wire [31:0]perips_in,perips_oe,perips_ot;//外设端口输入数据，输出使能，输出数据

wire [3:0]ELI_CH;//外部连线中断输入通道，支持4路

//外设端口perips_in/oe数据输入
localparam Enable = 1'b1;//开启
localparam Disable = 1'b0;//关闭



// 总线接口 写
always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        fpioa_ot_reg[ 0] <= 5'h0;
        fpioa_ot_reg[ 1] <= 5'h0;
        fpioa_ot_reg[ 2] <= 5'h0;
        fpioa_ot_reg[ 3] <= 5'h0;
        fpioa_ot_reg[ 4] <= 5'h0;
        fpioa_ot_reg[ 5] <= 5'h0;
        fpioa_ot_reg[ 6] <= 5'h0;
        fpioa_ot_reg[ 7] <= 5'h0;
        fpioa_ot_reg[ 8] <= 5'h0;
        fpioa_ot_reg[ 9] <= 5'h0;
        fpioa_ot_reg[10] <= 5'h0;
        fpioa_ot_reg[11] <= 5'h0;
        fpioa_ot_reg[12] <= 5'h0;
        fpioa_ot_reg[13] <= 5'h0;
        fpioa_ot_reg[14] <= 5'h0;
        fpioa_ot_reg[15] <= 5'h0;
        fpioa_ot_reg[16] <= 5'h0;
        fpioa_ot_reg[17] <= 5'h0;
        fpioa_ot_reg[18] <= 5'h0;
        fpioa_ot_reg[19] <= 5'h0;
        fpioa_ot_reg[20] <= 5'h0;
        fpioa_ot_reg[21] <= 5'h0;
        fpioa_ot_reg[22] <= 5'h0;
        fpioa_ot_reg[23] <= 5'h0;
        fpioa_ot_reg[24] <= 5'h0;
        fpioa_ot_reg[25] <= 5'h0;
        fpioa_ot_reg[26] <= 5'h0;
        fpioa_ot_reg[27] <= 5'h0;
        fpioa_ot_reg[28] <= 5'h0;
        fpioa_ot_reg[29] <= 5'h0;
        fpioa_ot_reg[30] <= 5'h0;
        fpioa_ot_reg[31] <= 5'h0;
        fpioa_nio_md0 <= 32'h0;
        fpioa_nio_md1 <= 32'h0;
        fpioa_eli_md <= 16'h0;
    end else begin
        if (we_i == 1'b1) begin
            if (waddr_i[7] == 1'b0) begin//0x00-0x7F
                if (waddr_i[5] == 1'b0) begin//0x00-0x1F
                    if(sel_i[0])
                        fpioa_ot_reg[waddr_i[4:0]  ] <= data_i[4:0];
                    if(sel_i[1])
                        fpioa_ot_reg[waddr_i[4:0]+1] <= data_i[12:8];
                    if(sel_i[2])
                        fpioa_ot_reg[waddr_i[4:0]+2] <= data_i[20:16];
                    if(sel_i[3])
                        fpioa_ot_reg[waddr_i[4:0]+3] <= data_i[28:24];
                end
                else begin//0x20-0x3F
                    case (waddr_i[4:0])
                        FPIOA_NIO_DIN: ;
                        FPIOA_NIO_OPT: fpioa_nio_opt <= data_i;
                        FPIOA_NIO_MD0: fpioa_nio_md0 <= data_i;
                        FPIOA_NIO_MD1: fpioa_nio_md1 <= data_i;
                        FPIOA_IRQ_SET: fpioa_eli_md  <= data_i[15:0];
                        default: ;
                    endcase
                end
            end
            else begin//0x80-0x9F
                if(sel_i[0])
                    fpioa_in_reg[waddr_i[4:0]  ] <= data_i[4:0];
                if(sel_i[1])
                    fpioa_in_reg[waddr_i[4:0]+1] <= data_i[12:8];
                if(sel_i[2])
                    fpioa_in_reg[waddr_i[4:0]+2] <= data_i[20:16];
                if(sel_i[3])
                    fpioa_in_reg[waddr_i[4:0]+3] <= data_i[28:24];
            end
        end 
		else begin

        end
    end
end

// 总线接口 读
always @ (posedge clk) begin
    if (rd_i == 1'b1) begin
        if (waddr_i[7] == 1'b0) begin
            if (waddr_i[5] == 1'b0) begin
                data_o <= {3'h0, fpioa_ot_reg[raddr_i[4:0]+3], 3'h0, fpioa_ot_reg[raddr_i[4:0]+2], 3'h0, fpioa_ot_reg[raddr_i[4:0]+1], 3'h0, fpioa_ot_reg[raddr_i[4:0]]};
            end
            else begin
                case (raddr_i[4:0])
                    FPIOA_NIO_DIN: data_o <= fpioa_nio_din;
                    FPIOA_NIO_OPT: data_o <= fpioa_nio_opt;
                    FPIOA_NIO_MD0: data_o <= fpioa_nio_md0;
                    FPIOA_NIO_MD1: data_o <= fpioa_nio_md1;
                    FPIOA_IRQ_SET: data_o <= {16'hffff, fpioa_eli_md};
                    default: ;
                endcase
            end
        end
        else begin
            data_o <= {3'h0, fpioa_in_reg[raddr_i[4:0]+3], 3'h0, fpioa_in_reg[raddr_i[4:0]+2], 3'h0, fpioa_in_reg[raddr_i[4:0]+1], 3'h0, fpioa_in_reg[raddr_i[4:0]]};
        end
            
    end
    else begin
        data_o <= data_o;
    end
end

//---------FPIOA数据交互-------------
genvar i;
generate//perips_ot,perips_oe连接至fpioa_ot,fpioa_oe
for ( i=0 ; i<`FPIOA_PORT_NUM ; i=i+1 ) begin: fpioa_o_gen
    assign fpioa_ot[i] = (fpioa_ot_reg[i]==7'h0) ? fpioa_nio_out[i] : perips_ot[fpioa_ot_reg[i]];//mux选择输出数据来源
    assign fpioa_oe[i] = (fpioa_ot_reg[i]==7'h0) ? fpioa_nio_oe [i] : perips_oe[fpioa_ot_reg[i]];//mux选择输出使能来源
    assign fpioa[i] = fpioa_oe[i] ? fpioa_ot[i] : 1'bz;//选择端口模式 输入输出控制
end
endgenerate

assign fpioa_in = {{(32-`FPIOA_PORT_NUM){1'b0}}, fpioa};//数据输入
generate//fpioa_in连接至perips_in
for ( i=0 ; i<32 ; i=i+1 ) begin: fpioa_i_gen
    assign perips_in[i] = fpioa_in[fpioa_in_reg[i]];
end
endgenerate

//---------FPIOA普通IO输入输出-------------
//输入打拍
reg [31:0] fpioa_nio_din_r;
always @(posedge clk) begin
	fpioa_nio_din_r <= fpioa_in;
    fpioa_nio_din <= fpioa_nio_din_r;
end

//输出模式、使能
generate
for (i=0; i<32; i=i+1) begin: nio_gen
    always @(*) begin
        case ({fpioa_nio_md1[i], fpioa_nio_md0[i]})
            2'b00: begin
                fpioa_nio_oe [i] = 1'b0;
                fpioa_nio_out[i] = 1'bx;
            end
            2'b01: begin
                fpioa_nio_oe [i] = 1'b0;
                fpioa_nio_out[i] = 1'bx;
            end
            2'b10: begin
                fpioa_nio_oe [i] = 1'b1;
                fpioa_nio_out[i] = fpioa_nio_opt[i];
            end
            2'b11: begin
                fpioa_nio_oe [i] = ~fpioa_nio_opt[i];
                fpioa_nio_out[i] = 1'b0;
            end
        endcase
    end
end
endgenerate


/*------------------------------
 * 外设输出端口布局
 * 最大支持256个外设端口，外设输出端口0恒为空端口
 * 端口布局由 [Number/编号] [Function/功能] [描述] 构成，布局列表如下：
 * | Number   | Function        | 描述                      
 * |----------|-----------------|------------------------------------
 * | 0        | FPIOA_NIO[x]    | FPIOA普通IO端口
 * | 1        | SPI0_SCK        | SPI0 SCK 时钟输出
 * | 2        | SPI0_MOSI       | SPI0 MOSI 数据输出
 * | 3        | SPI0_CS         | SPI0 CS 片选输出，低有效
 * | 4        |                 | 
 * | 5        |                 | 
 * | 6        |                 | 
 * | 7        | UART0_TX        | UART0 Tx 串口数据输出
 * | 8        | UART1_TX        | UART1 Tx 串口数据输出
 * | 9        | TIMER0_CMPO_N   | 定时器0比较输出-
 * | 10       | TIMER0_CMPO_P   | 定时器0比较输出+
 * | 11       |                 | 
 * | 12       |                 | 
 * | 13       |                 | 
 * | 14       |                 | 
 * | 15       |                 | 
 * | 16       |                 | 
 * | 17       |                 | 
 * | 18       |                 | 
 * | 19       |                 | 
 * | 20       |                 | 
 * | 21       |                 | 
 * | 22       |                 | 
 * | 23       |                 | 
 * | 24       |                 | 
 * | 25       |                 | 
 * | 26       |                 | 
 * | 27       |                 | 
 * | 28       |                 | 
 * | 29       |                 | 
 * | 30       |                 | 
 * | 31       |                 | 
 * |----------|-----------------|------------------------------------
 */

//外设端口perips_oe输出使能
assign perips_oe[0]  = Disable;
assign perips_oe[1]  = Enable;
assign perips_oe[2]  = Enable;
assign perips_oe[3]  = Enable;
assign perips_oe[6:4] = 0;
assign perips_oe[7]  = Enable;
assign perips_oe[8]  = Enable;
assign perips_oe[9]  = Enable;
assign perips_oe[10] = Enable;
assign perips_oe[31:11] = 0;


//外设端口perips_out输出数据
assign perips_ot[0]  = 1'b0;
assign perips_ot[1]  = SPI0_SCK ;
assign perips_ot[2]  = SPI0_MOSI;
assign perips_ot[3]  = SPI0_CS  ;
assign perips_ot[6:4] = 0;
assign perips_ot[7]  = UART0_TX ;
assign perips_ot[8]  = UART1_TX ;
assign perips_ot[9]  = TIMER0_CMPO_N;
assign perips_ot[10] = TIMER0_CMPO_P;
assign perips_ot[31:11] = 0;


/*------------------------------
 * 外设输入端口布局
 * 最大支持128个外设输入端口
 * 端口布局由 [Number/编号] [Function/功能] [描述] 构成，布局列表如下：
 * | Number   | Function        | 描述                      
 * |----------|-----------------|------------------------------------
 * | 0        | SPI0_MISO       | SPI0 MISO 数据输入
 * | 1        |                 | 
 * | 2        | UART0_RX        | UART0 Rx 串口数据输入
 * | 3        | UART1_RX        | UART1 Rx 串口数据输入
 * | 4        | ELI_CH0         | 外部连线中断通道0
 * | 5        | ELI_CH1         | 外部连线中断通道1
 * | 6        | ELI_CH2         | 外部连线中断通道2
 * | 7        | ELI_CH3         | 外部连线中断通道3
 * | 8        | TIMER0_CAPI     | 定时器0输入捕获
 * | 9        |                 | 
 * | 10       |                 | 
 * | 11       |                 | 
 * | 12       |                 | 
 * | 13       |                 | 
 * | 14       |                 | 
 * | 15       |                 | 
 * | 16       |                 | 
 * | 17       |                 | 
 * | 18       |                 | 
 * | 19       |                 | 
 * | 20       |                 | 
 * | 21       |                 | 
 * | 22       |                 | 
 * | 23       |                 | 
 * | 24       |                 | 
 * | 25       |                 | 
 * | 26       |                 | 
 * | 27       |                 | 
 * | 28       |                 | 
 * | 29       |                 | 
 * | 30       |                 | 
 * | 31       |                 | 
 * |----------|-----------------|------------------------------------
 */
//assign = perips_in[0];
assign SPI0_MISO = perips_in[0];
assign UART0_RX  = perips_in[2];
assign UART1_RX  = perips_in[3];
assign ELI_CH    = perips_in[7:4];
assign TIMER0_CAPI = perips_in[8];

//外部连线中断仲裁
reg [3:0]eli_r,eli_rr;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        eli_r <= 4'h0;
        eli_rr <= 4'h0;
    end
    else begin
        eli_r <= ELI_CH;
        eli_rr <= eli_r;
    end
end
/*
 * 外部连线中断触发模式寄存器，地址0x30
 * 仅低16位有效
 * 支持4个外部连线中断通道ELI0-ELI3 (Extern Line Interrupt)
 * 每个通道独立设置4种触发模式，支持多种模式同时启用
 * |                              对于中断通道ELI[x]                                     |
 * | fpioa_eli_md[x*4+3] | fpioa_eli_md[x*4+2] | fpioa_eli_md[x*4+1] | fpioa_eli_md[x*4] |
 * |---------------------|---------------------|---------------------|-------------------|
 * |    下降沿触发        |      上升沿触发     |      低电平触发      |      高电平触发    |
 * |---------------------|---------------------|---------------------|-------------------|
 reg [15:0] fpioa_eli_md;
 */

generate//ELI仲裁
for ( i=0 ; i<4 ; i=i+1 ) begin: eli_gen
    assign irq_fpioa_eli[i] = (fpioa_eli_md[i*4] & eli_rr[i]) | (fpioa_eli_md[i*4+1] & ~eli_rr[i]) | (fpioa_eli_md[i*4+2] & (eli_r[i] & ~eli_rr[i])) | (fpioa_eli_md[i*4+3] & (~eli_r[i] & eli_rr[i]));
end
endgenerate
endmodule