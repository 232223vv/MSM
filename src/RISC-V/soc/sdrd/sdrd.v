`include "source\rtl\defines.v"
module sdrd (
	input clk,
	input rst_n,

    //ICB Slave
    input  wire                 sdrd_icb_cmd_valid,//cmd有效
    output wire                 sdrd_icb_cmd_ready,//cmd准备好
    input  wire [`MemAddrBus]   sdrd_icb_cmd_addr ,//cmd地址
    input  wire                 sdrd_icb_cmd_read ,//cmd读使能
    input  wire [`MemBus]       sdrd_icb_cmd_wdata,//cmd写数据
    input  wire [3:0]           sdrd_icb_cmd_wmask,//cmd写选通
    output reg                  sdrd_icb_rsp_valid,//rsp有效
    input  wire                 sdrd_icb_rsp_ready,//rsp准备好
    output wire                 sdrd_icb_rsp_err  ,//rsp错误
    output wire [`MemBus]       sdrd_icb_rsp_rdata,//rsp读数据

    //SD、TF卡接口
    output wire       sd_clk,
    inout             sd_cmd,
    input  wire [3:0] sd_dat
);
/*
SD/TF读卡器
仅使用1-bit SD模式，包含了clk,cmd,dat0引脚。
dat 1-3用不到，必须外部上拉到高电平。
以扇区为最小访问单位，总线写触发一次扇区访问，扇区号为写入值。1扇区=512字节
访问期间，扇区数据写入缓冲区。总线读可以访问缓冲区buffer，总线地址/4 = 缓冲区读地址，读取的数据低8位有效
总线读返回的32bit数据:
[31:25]保留，读恒为0
[24]外设繁忙，1繁忙，0可以读取缓冲区
[23:22]保留，读恒为0
[21:20]SD卡类型
[19:16]SD卡初始化状态
[15:8]保留，读恒为0
[7:0]缓冲区数据
其中，只有[7:0]缓冲区数据会随地址而变化
*/
reg [31:0] rd_sector;//访问的扇区号
reg [7:0] buffer [511:0];//扇区数据缓冲区，是一个伪双端存储器
reg [7:0] buffer_dout;//缓冲区读出
reg sdrd_stat;//sdrd状态机，0:空闲，1:等待访问完成

wire rstart;//开始访问扇区，期间持续拉高
wire [ 3:0] card_stat;//SD卡初始化状态，[0,7]初始化中，8空闲，9工作中
wire [ 1:0] card_type;//SD卡类型，0=UNKNOWN, 01=SDv1, 10=SDv2, 11=SDHCv2
wire rbusy;//拉高即工作中
wire rdone;//本次访问完成
wire [8:0] outaddr;
wire [7:0] outbyte;
wire outen;

wire icb_whsk = sdrd_icb_cmd_valid & ~sdrd_icb_cmd_read;//写握手
wire icb_rhsk = sdrd_icb_cmd_valid & sdrd_icb_cmd_read;//读握手
wire [8:0] buffer_addr = sdrd_icb_cmd_addr[10:2];//缓冲区读地址，总线读地址[10:2]对应缓冲区读地址[8:0]
assign sdrd_icb_cmd_ready = 1'b1;
assign sdrd_icb_rsp_err   = 1'b0;
//读响应控制
always @(posedge clk or negedge rst_n)
if (~rst_n)
    sdrd_icb_rsp_valid <= 1'b0;
else begin
    if (icb_rhsk)
        sdrd_icb_rsp_valid <=1'b1;
    else if (sdrd_icb_rsp_valid & sdrd_icb_rsp_ready)
        sdrd_icb_rsp_valid <=1'b0;
    else
        sdrd_icb_rsp_valid <= sdrd_icb_rsp_valid;
end
//总线写，任何地址都是写扇区号，并触发一次扇区访问
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        rd_sector <= 32'd0;
    end
    else begin
        if (icb_whsk) begin
            rd_sector <= sdrd_icb_cmd_wdata;
        end
    end
end
//总线读扇区数据缓冲区
always @(posedge clk) begin
    if (icb_rhsk) begin
        buffer_dout <= buffer[buffer_addr];
    end
end
//外设写扇区数据缓冲区
always @(posedge clk) begin
    if (outen) begin
        buffer[outaddr] <= outbyte;
    end
end
assign sdrd_icb_rsp_rdata[31:25] = 7'd0;
assign sdrd_icb_rsp_rdata[24]    = rbusy;
assign sdrd_icb_rsp_rdata[23:22] = 2'b00;
assign sdrd_icb_rsp_rdata[21:20] = card_type;
assign sdrd_icb_rsp_rdata[19:16] = card_stat;
assign sdrd_icb_rsp_rdata[15:8]  = 8'd0;
assign sdrd_icb_rsp_rdata[7:0]   = buffer_dout;

//sdrd状态机
always @(posedge clk or negedge rst_n)
if (~rst_n)
    sdrd_stat <= 1'b0;
else begin
    if (sdrd_stat == 1'b0) begin //空闲
        if(icb_whsk) //总线写
            sdrd_stat <= 1'b1; //开始访问
    end
    else begin //等待访问结束
        if(rdone & card_stat==4'hA) //扇区访问结束
            sdrd_stat <= 1'b0; //恢复空闲
    end
end
assign rstart = sdrd_stat;

localparam SDRD_CLK_DIV = (`CPU_CLOCK_HZ<25_000_000) ? 3'd0 : // when clk =   0~ 25MHz , set CLK_DIV = 3'd0
                          (`CPU_CLOCK_HZ>=25_000_000 && `CPU_CLOCK_HZ<50_000_000)   ? 3'd1 : // when clk =  25~ 50MHz , set CLK_DIV = 3'd1
                          (`CPU_CLOCK_HZ>=50_000_000 && `CPU_CLOCK_HZ<100_000_000)  ? 3'd2 : // when clk =  50~100MHz , set CLK_DIV = 3'd2
                          (`CPU_CLOCK_HZ>=100_000_000 && `CPU_CLOCK_HZ<200_000_000) ? 3'd3 : // when clk = 100~200MHz , set CLK_DIV = 3'd3
                          (`CPU_CLOCK_HZ>=200_000_000 && `CPU_CLOCK_HZ<400_000_000) ? 3'd4 : // when clk = 200~400MHz , set CLK_DIV = 3'd4
                          (`CPU_CLOCK_HZ>=400_000_000 && `CPU_CLOCK_HZ<800_000_000) ? 3'd5 : // when clk = 400~800MHz , set CLK_DIV = 3'd5
                          (`CPU_CLOCK_HZ>=800_000_000 && `CPU_CLOCK_HZ<1600_000_000) ? 3'd6 : // when clk = 800~1600MHz , set CLK_DIV = 3'd6
                          3'd7;//clk>1.6GHz 设置分频系数

sd_reader #(
`ifdef HDL_SIM
    .CLK_DIV(0),
    .SIMULATE(1)
`else 
    .CLK_DIV(SDRD_CLK_DIV),
    .SIMULATE(0)
`endif
) inst_sd_reader (
    .rst_n     (rst_n),
    .clk       (clk),

    .sdclk     (sd_clk),
    .sdcmd     (sd_cmd),
    .sddat0    (sd_dat[0]),

    .card_stat (card_stat),
    .card_type (card_type),

    .rstart    (rstart),
    .rsector   (rd_sector),
    .rbusy     (rbusy),
    .rdone     (rdone),

    .outen     (outen),
    .outaddr   (outaddr),
    .outbyte   (outbyte)
);

endmodule

