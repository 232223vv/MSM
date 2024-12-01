`include "source\rtl\defines.v"
module sparrow_soc (
    //公共接口
    input  wire clk,    //时钟输入
    input  wire hard_rst_n,  //来自外部的复位信号，低电平有效
    output wire core_active,//处理器活动指示，以肉眼可见速度翻转

    input [7:0] key_in,
    output [7:0] key,

    //JTAG接口
    input  wire JTAG_TMS,
    input  wire JTAG_TDI,
    output wire JTAG_TDO,
    input  wire JTAG_TCK, //即使没有JTAG，也保留这个接口，使得约束可以通用

    //SD、TF卡接口
    output wire       sd_clk,
    inout             sd_cmd,
    input  wire [3:0] sd_dat,//需要上拉

    //FPIOA
    inout  wire [15:0] fpioa//处理器IO接口

);

assign key = sram_icb_rsp_rdata[7:0];

//*********************************
//           定义总线线网
//
//m0
wire                 jtag_icb_cmd_valid;
wire                 jtag_icb_cmd_ready;
wire [`MemAddrBus]   jtag_icb_cmd_addr ;
wire                 jtag_icb_cmd_read ;
wire [`MemBus]       jtag_icb_cmd_wdata;
wire [3:0]           jtag_icb_cmd_wmask;
wire                 jtag_icb_rsp_valid;
wire                 jtag_icb_rsp_ready;
wire                 jtag_icb_rsp_err  ;
wire [`MemBus]       jtag_icb_rsp_rdata;
//m1
wire                 core_icb_cmd_valid;
wire                 core_icb_cmd_ready;
wire [`MemAddrBus]   core_icb_cmd_addr ;
wire                 core_icb_cmd_read ;
wire [`MemBus]       core_icb_cmd_wdata;
wire [3:0]           core_icb_cmd_wmask;
wire                 core_icb_rsp_valid;
wire                 core_icb_rsp_ready;
wire                 core_icb_rsp_err  ;
wire [`MemBus]       core_icb_rsp_rdata;
//s0
wire                 iram_icb_cmd_valid;
wire                 iram_icb_cmd_ready;
wire [`MemAddrBus]   iram_icb_cmd_addr ;
wire                 iram_icb_cmd_read ;
wire [`MemBus]       iram_icb_cmd_wdata;
wire [3:0]           iram_icb_cmd_wmask;
wire                 iram_icb_rsp_valid;
wire                 iram_icb_rsp_ready;
wire                 iram_icb_rsp_err  ;
wire [`MemBus]       iram_icb_rsp_rdata;
//s1
wire                 sram_icb_cmd_valid;
wire                 sram_icb_cmd_ready;
wire [`MemAddrBus]   sram_icb_cmd_addr ;
wire                 sram_icb_cmd_read ;
wire [`MemBus]       sram_icb_cmd_wdata;
wire [3:0]           sram_icb_cmd_wmask;
wire                 sram_icb_rsp_valid;
wire                 sram_icb_rsp_ready;
wire                 sram_icb_rsp_err  ;
wire [`MemBus]       sram_icb_rsp_rdata;
//s2
wire                 sysp_icb_cmd_valid;
wire                 sysp_icb_cmd_ready;
wire [`MemAddrBus]   sysp_icb_cmd_addr ;
wire                 sysp_icb_cmd_read ;
wire [`MemBus]       sysp_icb_cmd_wdata;
wire [3:0]           sysp_icb_cmd_wmask;
wire                 sysp_icb_rsp_valid;
wire                 sysp_icb_rsp_ready;
wire                 sysp_icb_rsp_err  ;
wire [`MemBus]       sysp_icb_rsp_rdata;
//s3
wire                 plic_icb_cmd_valid;
wire                 plic_icb_cmd_ready;
wire [`MemAddrBus]   plic_icb_cmd_addr ;
wire                 plic_icb_cmd_read ;
wire [`MemBus]       plic_icb_cmd_wdata;
wire [3:0]           plic_icb_cmd_wmask;
wire                 plic_icb_rsp_valid;
wire                 plic_icb_rsp_ready;
wire                 plic_icb_rsp_err  ;
wire [`MemBus]       plic_icb_rsp_rdata;
//s4
wire                 sdrd_icb_cmd_valid;
wire                 sdrd_icb_cmd_ready;
wire [`MemAddrBus]   sdrd_icb_cmd_addr ;
wire                 sdrd_icb_cmd_read ;
wire [`MemBus]       sdrd_icb_cmd_wdata;
wire [3:0]           sdrd_icb_cmd_wmask;
wire                 sdrd_icb_rsp_valid;
wire                 sdrd_icb_rsp_ready;
wire                 sdrd_icb_rsp_err  ;
wire [`MemBus]       sdrd_icb_rsp_rdata;

//其他信号
wire halt_req;
wire jtag_rst_en;
wire [4:0]core_ex_trap_id;//中断源ID
wire [3:0]irq_fpioa_eli;
wire [15:0]plic_irq_port;
wire inst_req;//取指请求
wire [`InstAddrBus] inst_addr;//取指地址
wire inst_ack;//取指响应
wire [`InstBus] inst_data;//取指数据

//
//           定义线网
//*********************************

//小麻雀内核
core inst_core
(
    .clk              (clk),
    .rst_n            (rst_n),
    .halt_req_i       (halt_req),
    .hx_valid         (hx_valid),
    .soft_rst         (soft_rst_en),

//外部中断
    .core_ex_trap_valid_i   (core_ex_trap_valid),
    .core_ex_trap_id_i      (core_ex_trap_id),
    .core_ex_trap_ready_o   (core_ex_trap_ready),
    .core_ex_trap_cplet_o   (),
    .core_ex_trap_cplet_id_o(),

//m1 内核
    .core_icb_cmd_valid (core_icb_cmd_valid),
    .core_icb_cmd_ready (core_icb_cmd_ready),
    .core_icb_cmd_addr  (core_icb_cmd_addr ),
    .core_icb_cmd_read  (core_icb_cmd_read ),
    .core_icb_cmd_wdata (core_icb_cmd_wdata),
    .core_icb_cmd_wmask (core_icb_cmd_wmask),
    .core_icb_rsp_valid (core_icb_rsp_valid),
    .core_icb_rsp_ready (core_icb_rsp_ready),
    .core_icb_rsp_err   (core_icb_rsp_err  ),
    .core_icb_rsp_rdata (core_icb_rsp_rdata),
    .if_req_o           (inst_req),
    .if_addr_o          (inst_addr), 
    .if_ack_i           (inst_ack),
    .if_data_i          (inst_data)
    /*
//s0 iram指令存储器
    .iram_icb_cmd_valid (iram_icb_cmd_valid),
    .iram_icb_cmd_ready (iram_icb_cmd_ready),
    .iram_icb_cmd_addr  (iram_icb_cmd_addr ),
    .iram_icb_cmd_read  (iram_icb_cmd_read ),
    .iram_icb_cmd_wdata (iram_icb_cmd_wdata),
    .iram_icb_cmd_wmask (iram_icb_cmd_wmask),
    .iram_icb_rsp_valid (iram_icb_rsp_valid),
    .iram_icb_rsp_ready (iram_icb_rsp_ready),
    .iram_icb_rsp_err   (iram_icb_rsp_err  ),
    .iram_icb_rsp_rdata (iram_icb_rsp_rdata)
    */
);

`ifdef JTAG_DBG_MODULE
//JTAG模块
jtag_top inst_jtag_top
(
    .clk              (clk),
    .jtag_rst_n       (rst_n),
    .jtag_pin_TCK     (JTAG_TCK),
    .jtag_pin_TMS     (JTAG_TMS),
    .jtag_pin_TDI     (JTAG_TDI),
    .jtag_pin_TDO     (JTAG_TDO),
    .reg_we_o         (),
    .reg_addr_o       (),
    .reg_wdata_o      (),
    .reg_rdata_i      (32'b0),
    //m0 jtag
    .jtag_icb_cmd_valid (jtag_icb_cmd_valid),
    .jtag_icb_cmd_ready (jtag_icb_cmd_ready),
    .jtag_icb_cmd_addr  (jtag_icb_cmd_addr ),
    .jtag_icb_cmd_read  (jtag_icb_cmd_read ),
    .jtag_icb_cmd_wdata (jtag_icb_cmd_wdata),
    .jtag_icb_cmd_wmask (jtag_icb_cmd_wmask),
    .jtag_icb_rsp_valid (jtag_icb_rsp_valid),
    .jtag_icb_rsp_ready (jtag_icb_rsp_ready),
    .jtag_icb_rsp_err   (jtag_icb_rsp_err  ),
    .jtag_icb_rsp_rdata (jtag_icb_rsp_rdata),
    .halt_req_o       (halt_req),
    .reset_req_o      (jtag_rst_en)
);
`else //禁用jtag
    assign halt_req = 1'b0;
    assign jtag_rst_en = 1'b0;
    assign jtag_icb_cmd_valid = 1'b0;
    assign jtag_icb_cmd_addr  = 32'b0;
    assign jtag_icb_cmd_read  = 1'b0;
    assign jtag_icb_cmd_wdata = 32'b0;
    assign jtag_icb_cmd_wmask = 4'b0;
    assign jtag_icb_rsp_ready = 1'b1;
	assign JTAG_TDO = 1'b0;
`endif

//s0 iram外设，指令存储器
iram inst_iram
(
    .clk                (clk),
    .rst_n              (rst_n),
    .inst_addr_i        (inst_addr),//指令地址
    .inst_req_i         (inst_req),//取指请求
    .inst_data_o        (inst_data),//指令
    .inst_ack_o         (inst_ack),//取指响应
    .iram_icb_cmd_valid (iram_icb_cmd_valid),
    .iram_icb_cmd_ready (iram_icb_cmd_ready),
    .iram_icb_cmd_addr  (iram_icb_cmd_addr ),
    .iram_icb_cmd_read  (iram_icb_cmd_read ),
    .iram_icb_cmd_wdata (iram_icb_cmd_wdata),
    .iram_icb_cmd_wmask (iram_icb_cmd_wmask),
    .iram_icb_rsp_valid (iram_icb_rsp_valid),
    .iram_icb_rsp_ready (iram_icb_rsp_ready),
    .iram_icb_rsp_err   (iram_icb_rsp_err  ),
    .iram_icb_rsp_rdata (iram_icb_rsp_rdata)
);

//s1 sram外设
sram inst_sram
(
    .clk              (clk),
    .rst_n            (rst_n),

    .key_in(key_in),

    .sram_icb_cmd_valid (sram_icb_cmd_valid),
    .sram_icb_cmd_ready (sram_icb_cmd_ready),
    .sram_icb_cmd_addr  (sram_icb_cmd_addr ),
    .sram_icb_cmd_read  (sram_icb_cmd_read ),
    .sram_icb_cmd_wdata (sram_icb_cmd_wdata),
    .sram_icb_cmd_wmask (sram_icb_cmd_wmask),
    .sram_icb_rsp_valid (sram_icb_rsp_valid),
    .sram_icb_rsp_ready (sram_icb_rsp_ready),
    .sram_icb_rsp_err   (sram_icb_rsp_err  ),
    .sram_icb_rsp_rdata (sram_icb_rsp_rdata)
);

//s2 sys_perip系统外设
sys_perip inst_sys_perip
(
    .clk               (clk),
    .rst_n             (rst_n),

    .fpioa             (fpioa),

    .irq_fpioa_eli  (irq_fpioa_eli),    //FPIOA端口外部连线中断
    .irq_spi0_end   (irq_spi0_end),           //SPI收发结束中断
    .irq_timer0_of  (irq_timer0_of),      //定时器溢出中断
    .irq_uart0_tx   (irq_uart0_tx),  //uart tx发送完成中断
    .irq_uart0_rx   (irq_uart0_rx),   //uart rx接收数据中断
    .irq_uart1_tx   (irq_uart1_tx),  //uart tx发送完成中断
    .irq_uart1_rx   (irq_uart1_rx),   //uart rx接收数据中断

    .sysp_icb_cmd_valid (sysp_icb_cmd_valid),
    .sysp_icb_cmd_ready (sysp_icb_cmd_ready),
    .sysp_icb_cmd_addr  (sysp_icb_cmd_addr ),
    .sysp_icb_cmd_read  (sysp_icb_cmd_read ),
    .sysp_icb_cmd_wdata (sysp_icb_cmd_wdata),
    .sysp_icb_cmd_wmask (sysp_icb_cmd_wmask),
    .sysp_icb_rsp_valid (sysp_icb_rsp_valid),
    .sysp_icb_rsp_ready (sysp_icb_rsp_ready),
    .sysp_icb_rsp_err   (sysp_icb_rsp_err  ),
    .sysp_icb_rsp_rdata (sysp_icb_rsp_rdata)
);

//s3 PLIC
assign plic_irq_port[0] = 1'b0;//中断源ID0 保留，不可以使用
assign plic_irq_port[1] = irq_fpioa_eli[0];
assign plic_irq_port[2] = irq_fpioa_eli[1];
assign plic_irq_port[3] = irq_fpioa_eli[2];
assign plic_irq_port[4] = irq_fpioa_eli[3];
assign plic_irq_port[5] = irq_uart0_tx;
assign plic_irq_port[6] = irq_uart0_rx;
assign plic_irq_port[7] = irq_uart1_tx;
assign plic_irq_port[8] = irq_uart1_rx;
assign plic_irq_port[9] = irq_timer0_of;
assign plic_irq_port[10] = irq_spi0_end;
assign plic_irq_port[11] = 1'b0;
assign plic_irq_port[12] = 1'b0;
assign plic_irq_port[13] = 1'b0;
assign plic_irq_port[14] = 1'b0;
assign plic_irq_port[15] = 1'b0;
plic inst_plic
(
    .clk                  (clk),
    .rst_n                (rst_n),

    .plic_icb_cmd_valid   (plic_icb_cmd_valid),
    .plic_icb_cmd_ready   (plic_icb_cmd_ready),
    .plic_icb_cmd_addr    (plic_icb_cmd_addr ),
    .plic_icb_cmd_read    (plic_icb_cmd_read ),
    .plic_icb_cmd_wdata   (plic_icb_cmd_wdata),
    .plic_icb_cmd_wmask   (plic_icb_cmd_wmask),
    .plic_icb_rsp_valid   (plic_icb_rsp_valid),
    .plic_icb_rsp_ready   (plic_icb_rsp_ready),
    .plic_icb_rsp_err     (plic_icb_rsp_err  ),
    .plic_icb_rsp_rdata   (plic_icb_rsp_rdata),

    .plic_irq_port        (plic_irq_port),

    .core_ex_trap_valid_o (core_ex_trap_valid),
    .core_ex_trap_id_o    (core_ex_trap_id),
    .core_ex_trap_ready_i (core_ex_trap_ready)
);

//s4
sdrd inst_sdrd
(
    .clk                (clk),
    .rst_n              (rst_n),

    .sdrd_icb_cmd_valid (sdrd_icb_cmd_valid),
    .sdrd_icb_cmd_ready (sdrd_icb_cmd_ready),
    .sdrd_icb_cmd_addr  (sdrd_icb_cmd_addr),
    .sdrd_icb_cmd_read  (sdrd_icb_cmd_read),
    .sdrd_icb_cmd_wdata (sdrd_icb_cmd_wdata),
    .sdrd_icb_cmd_wmask (sdrd_icb_cmd_wmask),
    .sdrd_icb_rsp_valid (sdrd_icb_rsp_valid),
    .sdrd_icb_rsp_ready (sdrd_icb_rsp_ready),
    .sdrd_icb_rsp_err   (sdrd_icb_rsp_err),
    .sdrd_icb_rsp_rdata (sdrd_icb_rsp_rdata),

    .sd_clk             (sd_clk),
    .sd_cmd             (sd_cmd),
    .sd_dat             (sd_dat)
);


//2主8从ICB总线桥
icb_2m8s inst_icb_2m8s
(
    .clk              (clk),
    
    .m0_icb_cmd_valid (jtag_icb_cmd_valid),
    .m0_icb_cmd_ready (jtag_icb_cmd_ready),
    .m0_icb_cmd_addr  (jtag_icb_cmd_addr ),
    .m0_icb_cmd_read  (jtag_icb_cmd_read ),
    .m0_icb_cmd_wdata (jtag_icb_cmd_wdata),
    .m0_icb_cmd_wmask (jtag_icb_cmd_wmask),
    .m0_icb_rsp_valid (jtag_icb_rsp_valid),
    .m0_icb_rsp_ready (jtag_icb_rsp_ready),
    .m0_icb_rsp_err   (jtag_icb_rsp_err  ),
    .m0_icb_rsp_rdata (jtag_icb_rsp_rdata),

    .m1_icb_cmd_valid (core_icb_cmd_valid),
    .m1_icb_cmd_ready (core_icb_cmd_ready),
    .m1_icb_cmd_addr  (core_icb_cmd_addr ),
    .m1_icb_cmd_read  (core_icb_cmd_read ),
    .m1_icb_cmd_wdata (core_icb_cmd_wdata),
    .m1_icb_cmd_wmask (core_icb_cmd_wmask),
    .m1_icb_rsp_valid (core_icb_rsp_valid),
    .m1_icb_rsp_ready (core_icb_rsp_ready),
    .m1_icb_rsp_err   (core_icb_rsp_err  ),
    .m1_icb_rsp_rdata (core_icb_rsp_rdata),

    .s0_icb_cmd_valid (iram_icb_cmd_valid),
    .s0_icb_cmd_ready (iram_icb_cmd_ready),
    .s0_icb_cmd_addr  (iram_icb_cmd_addr ),
    .s0_icb_cmd_read  (iram_icb_cmd_read ),
    .s0_icb_cmd_wdata (iram_icb_cmd_wdata),
    .s0_icb_cmd_wmask (iram_icb_cmd_wmask),
    .s0_icb_rsp_valid (iram_icb_rsp_valid),
    .s0_icb_rsp_ready (iram_icb_rsp_ready),
    .s0_icb_rsp_err   (iram_icb_rsp_err  ),
    .s0_icb_rsp_rdata (iram_icb_rsp_rdata),

    .s1_icb_cmd_valid (sram_icb_cmd_valid),
    .s1_icb_cmd_ready (sram_icb_cmd_ready),
    .s1_icb_cmd_addr  (sram_icb_cmd_addr ),
    .s1_icb_cmd_read  (sram_icb_cmd_read ),
    .s1_icb_cmd_wdata (sram_icb_cmd_wdata),
    .s1_icb_cmd_wmask (sram_icb_cmd_wmask),
    .s1_icb_rsp_valid (sram_icb_rsp_valid),
    .s1_icb_rsp_ready (sram_icb_rsp_ready),
    .s1_icb_rsp_err   (sram_icb_rsp_err  ),
    .s1_icb_rsp_rdata (sram_icb_rsp_rdata),

    .s2_icb_cmd_valid (sysp_icb_cmd_valid),
    .s2_icb_cmd_ready (sysp_icb_cmd_ready),
    .s2_icb_cmd_addr  (sysp_icb_cmd_addr ),
    .s2_icb_cmd_read  (sysp_icb_cmd_read ),
    .s2_icb_cmd_wdata (sysp_icb_cmd_wdata),
    .s2_icb_cmd_wmask (sysp_icb_cmd_wmask),
    .s2_icb_rsp_valid (sysp_icb_rsp_valid),
    .s2_icb_rsp_ready (sysp_icb_rsp_ready),
    .s2_icb_rsp_err   (sysp_icb_rsp_err  ),
    .s2_icb_rsp_rdata (sysp_icb_rsp_rdata),

    .s3_icb_cmd_valid (plic_icb_cmd_valid),
    .s3_icb_cmd_ready (plic_icb_cmd_ready),
    .s3_icb_cmd_addr  (plic_icb_cmd_addr ),
    .s3_icb_cmd_read  (plic_icb_cmd_read ),
    .s3_icb_cmd_wdata (plic_icb_cmd_wdata),
    .s3_icb_cmd_wmask (plic_icb_cmd_wmask),
    .s3_icb_rsp_valid (plic_icb_rsp_valid),
    .s3_icb_rsp_ready (plic_icb_rsp_ready),
    .s3_icb_rsp_err   (plic_icb_rsp_err  ),
    .s3_icb_rsp_rdata (plic_icb_rsp_rdata),

    .s4_icb_cmd_valid (sdrd_icb_cmd_valid),
    .s4_icb_cmd_ready (sdrd_icb_cmd_ready),
    .s4_icb_cmd_addr  (sdrd_icb_cmd_addr ),
    .s4_icb_cmd_read  (sdrd_icb_cmd_read ),
    .s4_icb_cmd_wdata (sdrd_icb_cmd_wdata),
    .s4_icb_cmd_wmask (sdrd_icb_cmd_wmask),
    .s4_icb_rsp_valid (sdrd_icb_rsp_valid),
    .s4_icb_rsp_ready (sdrd_icb_rsp_ready),
    .s4_icb_rsp_err   (sdrd_icb_rsp_err  ),
    .s4_icb_rsp_rdata (sdrd_icb_rsp_rdata),

    .s5_icb_cmd_valid (                ),
    .s5_icb_cmd_ready (1'b0            ),
    .s5_icb_cmd_addr  (                ),
    .s5_icb_cmd_read  (                ),
    .s5_icb_cmd_wdata (                ),
    .s5_icb_cmd_wmask (                ),
    .s5_icb_rsp_valid (1'b0            ),
    .s5_icb_rsp_ready (                ),
    .s5_icb_rsp_err   (1'b0            ),
    .s5_icb_rsp_rdata (32'h0           ),

    .s6_icb_cmd_valid (                ),
    .s6_icb_cmd_ready (1'b0            ),
    .s6_icb_cmd_addr  (                ),
    .s6_icb_cmd_read  (                ),
    .s6_icb_cmd_wdata (                ),
    .s6_icb_cmd_wmask (                ),
    .s6_icb_rsp_valid (1'b0            ),
    .s6_icb_rsp_ready (                ),
    .s6_icb_rsp_err   (1'b0            ),
    .s6_icb_rsp_rdata (32'h0           ),

    .s7_icb_cmd_valid (                ),
    .s7_icb_cmd_ready (1'b0            ),
    .s7_icb_cmd_addr  (                ),
    .s7_icb_cmd_read  (                ),
    .s7_icb_cmd_wdata (                ),
    .s7_icb_cmd_wmask (                ),
    .s7_icb_rsp_valid (1'b0            ),
    .s7_icb_rsp_ready (                ),
    .s7_icb_rsp_err   (1'b0            ),
    .s7_icb_rsp_rdata (32'h0           )
);

//复位控制器
rstc inst_rstc
(
    .clk         (clk),
    .hard_rst_n  (hard_rst_n),
    .soft_rst_en (soft_rst_en),
    .jtag_rst_en (jtag_rst_en),
    .rst_n       (rst_n)
);

//处理器活动指示，只要指令流不停，灯就在闪
reg [clogb2(`CPU_CLOCK_HZ/4)-1:0]hx_cnt;//计数器
reg active_reg;//状态翻转
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        hx_cnt <= 0;
        active_reg <= 1'b1;
    end 
    else begin
        if (hx_valid == 1'b1) begin
            if(hx_cnt < `CPU_CLOCK_HZ/4) begin
                hx_cnt <= hx_cnt + 1'b1;
            end
            else begin
                hx_cnt <= 0;
                active_reg <= ~active_reg;
            end
        end
    end
end
assign core_active = active_reg;//硬连线

//计算log2，得到地址位宽，如clogb2(RAM_DEPTH-1)
function integer clogb2;
    input integer depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1)
            depth = depth >> 1;
endfunction

endmodule