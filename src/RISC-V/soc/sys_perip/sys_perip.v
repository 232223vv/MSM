//系统外设system peripheral
`include "source\rtl\defines.v"
module sys_perip (
	input clk,
	input rst_n,

    //处理器IO接口
    inout wire [`FPIOA_PORT_NUM-1:0] fpioa,

    //sys_perip中断接口
    output wire [3:0]irq_fpioa_eli,    //FPIOA端口外部连线中断
    output wire irq_spi0_end,           //SPI收发结束中断
    output wire irq_timer0_of,      //定时器溢出中断
    output wire irq_uart0_tx,  //uart tx发送完成中断
    output wire irq_uart0_rx,   //uart rx接收数据中断
    output wire irq_uart1_tx,  //uart tx发送完成中断
    output wire irq_uart1_rx,   //uart rx接收数据中断

    //ICB Slave sysp
    input  wire                 sysp_icb_cmd_valid,//cmd有效
    output wire                 sysp_icb_cmd_ready,//cmd准备好
    input  wire [`MemAddrBus]   sysp_icb_cmd_addr ,//cmd地址
    input  wire                 sysp_icb_cmd_read ,//cmd读使能
    input  wire [`MemBus]       sysp_icb_cmd_wdata,//cmd写数据
    input  wire [3:0]           sysp_icb_cmd_wmask,//cmd写选通
    output reg                  sysp_icb_rsp_valid,//rsp有效
    input  wire                 sysp_icb_rsp_ready,//rsp准备好
    output wire                 sysp_icb_rsp_err  ,//rsp错误
    output wire [`MemBus]       sysp_icb_rsp_rdata//rsp读数据
	
);

//---------总线交互--------
//写
wire icb_whsk = sysp_icb_cmd_valid & ~sysp_icb_cmd_read;//写握手
wire icb_rhsk = sysp_icb_cmd_valid & sysp_icb_cmd_read;//读握手
wire [7:0] waddr = {sysp_icb_cmd_addr[7:2], 2'b00};//写地址，屏蔽低位，字节选通替代
wire [7:0] raddr = {sysp_icb_cmd_addr[7:2], 2'b00};//读地址，屏蔽低位，译码执行部分替代
wire [`MemBus]din = sysp_icb_cmd_wdata;//写数据
wire [3:0]sel = sysp_icb_cmd_wmask;//写选通
wire we = ~sysp_icb_cmd_read;//写使能
wire rd = icb_rhsk;//读使能
wire [`MemBus]dout;//读数据
assign sysp_icb_cmd_ready = 1'b1;
assign sysp_icb_rsp_err   = 1'b0;
assign sysp_icb_rsp_rdata = dout;

always @(posedge clk or negedge rst_n)//读响应控制
if (~rst_n)
    sysp_icb_rsp_valid <=1'b0;
else begin
    if (icb_rhsk)
        sysp_icb_rsp_valid <=1'b1;
    else if (sysp_icb_rsp_valid & sysp_icb_rsp_ready)
        sysp_icb_rsp_valid <=1'b0;
    else
        sysp_icb_rsp_valid <= sysp_icb_rsp_valid;
end

//---------总线交互--------
// addr[27:0]: 000_0000_0000_0SXX
// S[3:0]: 选择16个外设
// XX[7:0]: 每个外设可使用8b地址宽度，最大支持256/4=64个寄存器
//写通道处理
wire [15:0]we_en;
genvar i;
generate
    for (i = 0; i<16; i=i+1) begin: we_gen
        assign we_en[i] = (sysp_icb_cmd_addr[11:8] == i)? icb_whsk : 1'b0;
    end
endgenerate

//读通道处理
wire [15:0]rd_en;
generate
for (i = 0; i<16; i=i+1) begin: rd_gen
    assign rd_en[i] = (sysp_icb_cmd_addr[11:8] == i)? icb_rhsk : 1'b0;
end
endgenerate
reg [15:0]rd_en_r;
always @(posedge clk ) begin
    if(icb_rhsk)
        rd_en_r <= rd_en;
    else
        rd_en_r <= rd_en_r;
end
wire [`MemBus]data_o[0:15];
assign dout = {32{rd_en_r[0]}} & data_o[0]
            | {32{rd_en_r[1]}} & data_o[1]
            | {32{rd_en_r[2]}} & data_o[2]
            | {32{rd_en_r[3]}} & data_o[3]
            | {32{rd_en_r[4]}} & data_o[4]
            | {32{rd_en_r[5]}} & data_o[5]
            | {32{rd_en_r[6]}} & data_o[6]
            | {32{rd_en_r[7]}} & data_o[7]
            | {32{rd_en_r[8]}} & data_o[8]
            | {32{rd_en_r[9]}} & data_o[9]
            | {32{rd_en_r[10]}} & data_o[10]
            | {32{rd_en_r[11]}} & data_o[11]
            | {32{rd_en_r[12]}} & data_o[12]
            | {32{rd_en_r[13]}} & data_o[13]
            | {32{rd_en_r[14]}} & data_o[14]
            | {32{rd_en_r[15]}} & data_o[15];


//0 uart0
uart inst_uart0
(
    .clk     (clk),
    .rst_n   (rst_n),

    .waddr_i (waddr[7:0]),
    .data_i  (din),
    .sel_i   (sel),
    .we_i    (we_en[0]),
    .raddr_i (raddr),
    .rd_i    (rd_en[0]),
    .data_o  (data_o[0]),

    .tx_pin  (uart0_tx),
    .rx_pin  (uart0_rx),

    .irq_uart_tx (irq_uart0_tx),
    .irq_uart_rx (irq_uart0_rx)
);
//1 uart1
uart inst_uart1
(
    .clk     (clk),
    .rst_n   (rst_n),

    .waddr_i (waddr),
    .data_i  (din),
    .sel_i   (sel),
    .we_i    (we_en[1]),
    .raddr_i (raddr),
    .rd_i    (rd_en[1]),
    .data_o  (data_o[1]),

    .tx_pin  (uart1_tx),
    .rx_pin  (uart1_rx),

    .irq_uart_tx (irq_uart1_tx),
    .irq_uart_rx (irq_uart1_rx)
);
//2 spi0
spi inst_spi0
(
    .clk      (clk),
    .rst_n    (rst_n),

    .waddr_i  (waddr),
    .data_i   (din),
    .sel_i    (sel),
    .we_i     (we_en[2]),
    .raddr_i  (raddr),
    .rd_i     (rd_en[2]),
    .data_o   (data_o[2]),

    .spi_mosi (spi0_mosi),
    .spi_miso (spi0_miso),
    .spi_cs   (spi0_cs  ),
    .spi_clk  (spi0_clk ),

    .irq_spi_end (irq_spi0_end)
);

//3
timer inst_timer0
(
    .clk            (clk),
    .rst_n          (rst_n),

    .waddr_i        (waddr),
    .data_i         (din),
    .sel_i          (sel),
    .we_i           (we_en[3]),
    .raddr_i        (raddr),
    .rd_i           (rd_en[3]),
    .data_o         (data_o[3]),

    .timer_cmpo_p   (timer0_cmpo_p),
    .timer_cmpo_n   (timer0_cmpo_n),
    .timer_capi     (timer0_capi),

    .irq_timer_of   (irq_timer0_of)
);

/*
AAA inst_AAA
(
    .clk           (clk),
    .rst_n         (rst_n),

    .waddr_i       (waddr),
    .data_i        (din),
    .sel_i         (sel),
    .we_i          (we_en[4]),
    .raddr_i       (raddr),
    .rd_i          (rd_en[4]),
    .data_o        (data_o[4])
);
*/
assign data_o[4]=0;
assign data_o[5]=0;
assign data_o[6]=0;
assign data_o[7]=0;
assign data_o[8]=0;
assign data_o[9]=0;
assign data_o[10]=0;
assign data_o[11]=0;
assign data_o[12]=0;
assign data_o[13]=0;
assign data_o[14]=0;
//15 fpioa
fpioa inst_fpioa
(
    .clk      (clk),
    .rst_n    (rst_n),

    .waddr_i  (waddr),
    .data_i   (din),
    .sel_i    (sel),
    .we_i     (we_en[15]),
    .raddr_i  (raddr),
    .rd_i     (rd_en[15]),
    .data_o   (data_o[15]),
    //外设接口
    .SPI0_SCK  (spi0_clk),
    .SPI0_MOSI (spi0_mosi),
    .SPI0_MISO (spi0_miso),
    .SPI0_CS   (spi0_cs),
    .UART0_TX  (uart0_tx),
    .UART0_RX  (uart0_rx),
    .UART1_TX  (uart1_tx),
    .UART1_RX  (uart1_rx),
    .TIMER0_CMPO_N  (timer0_cmpo_p),
    .TIMER0_CMPO_P  (timer0_cmpo_n),
    .TIMER0_CAPI    (timer0_capi),
    //FPIOA
    .fpioa     (fpioa),

    .irq_fpioa_eli (irq_fpioa_eli)
);

endmodule