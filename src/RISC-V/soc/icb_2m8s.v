`include "source\rtl\defines.v"
module icb_2m8s (
    input clk,
    //ICB总线桥，2主8从，带优先级
    //m0优先
    input  wire                 m0_icb_cmd_valid,
    output wire                 m0_icb_cmd_ready,
    input  wire [`MemAddrBus]   m0_icb_cmd_addr ,
    input  wire                 m0_icb_cmd_read ,
    input  wire [`MemBus]       m0_icb_cmd_wdata,
    input  wire [3:0]           m0_icb_cmd_wmask,
    output wire                 m0_icb_rsp_valid,
    input  wire                 m0_icb_rsp_ready,
    output wire                 m0_icb_rsp_err  ,
    output wire [`MemBus]       m0_icb_rsp_rdata,
    //m1其次
    input  wire                 m1_icb_cmd_valid,
    output wire                 m1_icb_cmd_ready,
    input  wire [`MemAddrBus]   m1_icb_cmd_addr ,
    input  wire                 m1_icb_cmd_read ,
    input  wire [`MemBus]       m1_icb_cmd_wdata,
    input  wire [3:0]           m1_icb_cmd_wmask,
    output wire                 m1_icb_rsp_valid,
    input  wire                 m1_icb_rsp_ready,
    output wire                 m1_icb_rsp_err  ,
    output wire [`MemBus]       m1_icb_rsp_rdata,
    //s0
    output wire                 s0_icb_cmd_valid,
    input  wire                 s0_icb_cmd_ready,
    output wire [`MemAddrBus]   s0_icb_cmd_addr ,
    output wire                 s0_icb_cmd_read ,
    output wire [`MemBus]       s0_icb_cmd_wdata,
    output wire [3:0]           s0_icb_cmd_wmask,
    input  wire                 s0_icb_rsp_valid,
    output wire                 s0_icb_rsp_ready,
    input  wire                 s0_icb_rsp_err  ,
    input  wire [`MemBus]       s0_icb_rsp_rdata,
    //s1
    output wire                 s1_icb_cmd_valid,
    input  wire                 s1_icb_cmd_ready,
    output wire [`MemAddrBus]   s1_icb_cmd_addr ,
    output wire                 s1_icb_cmd_read ,
    output wire [`MemBus]       s1_icb_cmd_wdata,
    output wire [3:0]           s1_icb_cmd_wmask,
    input  wire                 s1_icb_rsp_valid,
    output wire                 s1_icb_rsp_ready,
    input  wire                 s1_icb_rsp_err  ,
    input  wire [`MemBus]       s1_icb_rsp_rdata,
    //s2
    output wire                 s2_icb_cmd_valid,
    input  wire                 s2_icb_cmd_ready,
    output wire [`MemAddrBus]   s2_icb_cmd_addr ,
    output wire                 s2_icb_cmd_read ,
    output wire [`MemBus]       s2_icb_cmd_wdata,
    output wire [3:0]           s2_icb_cmd_wmask,
    input  wire                 s2_icb_rsp_valid,
    output wire                 s2_icb_rsp_ready,
    input  wire                 s2_icb_rsp_err  ,
    input  wire [`MemBus]       s2_icb_rsp_rdata,
    //s3
    output wire                 s3_icb_cmd_valid,
    input  wire                 s3_icb_cmd_ready,
    output wire [`MemAddrBus]   s3_icb_cmd_addr ,
    output wire                 s3_icb_cmd_read ,
    output wire [`MemBus]       s3_icb_cmd_wdata,
    output wire [3:0]           s3_icb_cmd_wmask,
    input  wire                 s3_icb_rsp_valid,
    output wire                 s3_icb_rsp_ready,
    input  wire                 s3_icb_rsp_err  ,
    input  wire [`MemBus]       s3_icb_rsp_rdata,
    //s4
    output wire                 s4_icb_cmd_valid,
    input  wire                 s4_icb_cmd_ready,
    output wire [`MemAddrBus]   s4_icb_cmd_addr ,
    output wire                 s4_icb_cmd_read ,
    output wire [`MemBus]       s4_icb_cmd_wdata,
    output wire [3:0]           s4_icb_cmd_wmask,
    input  wire                 s4_icb_rsp_valid,
    output wire                 s4_icb_rsp_ready,
    input  wire                 s4_icb_rsp_err  ,
    input  wire [`MemBus]       s4_icb_rsp_rdata,
    //s5
    output wire                 s5_icb_cmd_valid,
    input  wire                 s5_icb_cmd_ready,
    output wire [`MemAddrBus]   s5_icb_cmd_addr ,
    output wire                 s5_icb_cmd_read ,
    output wire [`MemBus]       s5_icb_cmd_wdata,
    output wire [3:0]           s5_icb_cmd_wmask,
    input  wire                 s5_icb_rsp_valid,
    output wire                 s5_icb_rsp_ready,
    input  wire                 s5_icb_rsp_err  ,
    input  wire [`MemBus]       s5_icb_rsp_rdata,
    //s6
    output wire                 s6_icb_cmd_valid,
    input  wire                 s6_icb_cmd_ready,
    output wire [`MemAddrBus]   s6_icb_cmd_addr ,
    output wire                 s6_icb_cmd_read ,
    output wire [`MemBus]       s6_icb_cmd_wdata,
    output wire [3:0]           s6_icb_cmd_wmask,
    input  wire                 s6_icb_rsp_valid,
    output wire                 s6_icb_rsp_ready,
    input  wire                 s6_icb_rsp_err  ,
    input  wire [`MemBus]       s6_icb_rsp_rdata,
    //s7
    output wire                 s7_icb_cmd_valid,
    input  wire                 s7_icb_cmd_ready,
    output wire [`MemAddrBus]   s7_icb_cmd_addr ,
    output wire                 s7_icb_cmd_read ,
    output wire [`MemBus]       s7_icb_cmd_wdata,
    output wire [3:0]           s7_icb_cmd_wmask,
    input  wire                 s7_icb_rsp_valid,
    output wire                 s7_icb_rsp_ready,
    input  wire                 s7_icb_rsp_err  ,
    input  wire [`MemBus]       s7_icb_rsp_rdata
);

//------------- m0/m1 <-> master ------------
wire                 master_icb_cmd_valid;
wire                 master_icb_cmd_ready;
wire [`MemAddrBus]   master_icb_cmd_addr ;
wire                 master_icb_cmd_read ;
wire [`MemBus]       master_icb_cmd_wdata;
wire [3:0]           master_icb_cmd_wmask;
wire                 master_icb_rsp_valid;
wire                 master_icb_rsp_ready;
wire                 master_icb_rsp_err  ;
wire [`MemBus]       master_icb_rsp_rdata;

//优先级仲裁
`ifdef JTAG_DBG_MODULE
wire master_sel = m0_icb_cmd_valid ? 1'b0 : 1'b1;//m0发出请求，总线立即服务于m0，忽略m1
reg master_sel_rb;//选择读返回的m0/1接口
always @(posedge clk) begin
    if (master_icb_cmd_valid & master_icb_cmd_ready & master_icb_cmd_read) begin//读请求握手成功
        master_sel_rb <= master_sel;//记录读请求来源
    end
    else begin
    end
end
`else
wire master_sel = 1'b1;//仅m1(core)访问
wire master_sel_rb = 1'b1;//仅m1(core)访问
`endif



assign master_icb_cmd_valid = master_sel ? m1_icb_cmd_valid : m0_icb_cmd_valid;
assign master_icb_cmd_addr  = master_sel ? m1_icb_cmd_addr  : m0_icb_cmd_addr ;
assign master_icb_cmd_read  = master_sel ? m1_icb_cmd_read  : m0_icb_cmd_read ;
assign master_icb_cmd_wdata = master_sel ? m1_icb_cmd_wdata : m0_icb_cmd_wdata;
assign master_icb_cmd_wmask = master_sel ? m1_icb_cmd_wmask : m0_icb_cmd_wmask;

assign m0_icb_cmd_ready = (master_sel==1'b0) & master_icb_cmd_ready;
assign m1_icb_cmd_ready = (master_sel==1'b1) & master_icb_cmd_ready;


assign master_icb_rsp_ready = master_sel_rb ? m1_icb_rsp_ready : m0_icb_rsp_ready;

assign m0_icb_rsp_valid = (master_sel_rb==1'b0) & master_icb_rsp_valid;
assign m1_icb_rsp_valid = (master_sel_rb==1'b1) & master_icb_rsp_valid;

assign m0_icb_rsp_err   = (master_sel_rb==1'b0) & master_icb_rsp_err  ;
assign m1_icb_rsp_err   = (master_sel_rb==1'b1) & master_icb_rsp_err  ;

assign m0_icb_rsp_rdata = master_icb_rsp_rdata;
assign m1_icb_rsp_rdata = master_icb_rsp_rdata;

//------------- m0/m1 <-> master ------------


//------------- slave <-> master ------------
//8个从机slave接口，通过地址的高3位[31:29]进行选择
wire [7:0]cmd_sel;//cmd通道选择，独热码
reg [7:0]rsp_sel;//rsp通道选择，独热码

always @(posedge clk) begin
    if(master_icb_cmd_valid & master_icb_cmd_read & master_icb_cmd_ready)//读握手成功
        rsp_sel <= cmd_sel;//更新
end
//总线译码
assign cmd_sel[0] = master_icb_cmd_addr[31:29] == 3'd0  ? 1'b1 : 1'b0;
assign cmd_sel[1] = master_icb_cmd_addr[31:29] == 3'd1  ? 1'b1 : 1'b0;
assign cmd_sel[2] = master_icb_cmd_addr[31:29] == 3'd2  ? 1'b1 : 1'b0;
assign cmd_sel[3] = master_icb_cmd_addr[31:29] == 3'd3  ? 1'b1 : 1'b0;
assign cmd_sel[4] = master_icb_cmd_addr[31:29] == 3'd4  ? 1'b1 : 1'b0;
assign cmd_sel[5] = master_icb_cmd_addr[31:29] == 3'd5  ? 1'b1 : 1'b0;
assign cmd_sel[6] = master_icb_cmd_addr[31:29] == 3'd6  ? 1'b1 : 1'b0;
assign cmd_sel[7] = master_icb_cmd_addr[31:29] == 3'd7  ? 1'b1 : 1'b0;

//-------cmd------------
assign s0_icb_cmd_valid = {1{cmd_sel[0]}} & master_icb_cmd_valid;
assign s1_icb_cmd_valid = {1{cmd_sel[1]}} & master_icb_cmd_valid;
assign s2_icb_cmd_valid = {1{cmd_sel[2]}} & master_icb_cmd_valid;
assign s3_icb_cmd_valid = {1{cmd_sel[3]}} & master_icb_cmd_valid;
assign s4_icb_cmd_valid = {1{cmd_sel[4]}} & master_icb_cmd_valid;
assign s5_icb_cmd_valid = {1{cmd_sel[5]}} & master_icb_cmd_valid;
assign s6_icb_cmd_valid = {1{cmd_sel[6]}} & master_icb_cmd_valid;
assign s7_icb_cmd_valid = {1{cmd_sel[7]}} & master_icb_cmd_valid;

assign master_icb_cmd_ready = {1{cmd_sel[0]}} & s0_icb_cmd_ready
                            | {1{cmd_sel[1]}} & s1_icb_cmd_ready
                            | {1{cmd_sel[2]}} & s2_icb_cmd_ready
                            | {1{cmd_sel[3]}} & s3_icb_cmd_ready
                            | {1{cmd_sel[4]}} & s4_icb_cmd_ready
                            | {1{cmd_sel[5]}} & s5_icb_cmd_ready
                            | {1{cmd_sel[6]}} & s6_icb_cmd_ready
                            | {1{cmd_sel[7]}} & s7_icb_cmd_ready
                            ;

assign s0_icb_cmd_addr  = master_icb_cmd_addr ;
assign s1_icb_cmd_addr  = master_icb_cmd_addr ;
assign s2_icb_cmd_addr  = master_icb_cmd_addr ;
assign s3_icb_cmd_addr  = master_icb_cmd_addr ;
assign s4_icb_cmd_addr  = master_icb_cmd_addr ;
assign s5_icb_cmd_addr  = master_icb_cmd_addr ;
assign s6_icb_cmd_addr  = master_icb_cmd_addr ;
assign s7_icb_cmd_addr  = master_icb_cmd_addr ;
assign s0_icb_cmd_read  = master_icb_cmd_read ;

assign s1_icb_cmd_read  = master_icb_cmd_read ;
assign s2_icb_cmd_read  = master_icb_cmd_read ;
assign s3_icb_cmd_read  = master_icb_cmd_read ;
assign s4_icb_cmd_read  = master_icb_cmd_read ;
assign s5_icb_cmd_read  = master_icb_cmd_read ;
assign s6_icb_cmd_read  = master_icb_cmd_read ;
assign s7_icb_cmd_read  = master_icb_cmd_read ;

assign s0_icb_cmd_wdata = master_icb_cmd_wdata;
assign s1_icb_cmd_wdata = master_icb_cmd_wdata;
assign s2_icb_cmd_wdata = master_icb_cmd_wdata;
assign s3_icb_cmd_wdata = master_icb_cmd_wdata;
assign s4_icb_cmd_wdata = master_icb_cmd_wdata;
assign s5_icb_cmd_wdata = master_icb_cmd_wdata;
assign s6_icb_cmd_wdata = master_icb_cmd_wdata;
assign s7_icb_cmd_wdata = master_icb_cmd_wdata;

assign s0_icb_cmd_wmask = master_icb_cmd_wmask;
assign s1_icb_cmd_wmask = master_icb_cmd_wmask;
assign s2_icb_cmd_wmask = master_icb_cmd_wmask;
assign s3_icb_cmd_wmask = master_icb_cmd_wmask;
assign s4_icb_cmd_wmask = master_icb_cmd_wmask;
assign s5_icb_cmd_wmask = master_icb_cmd_wmask;
assign s6_icb_cmd_wmask = master_icb_cmd_wmask;
assign s7_icb_cmd_wmask = master_icb_cmd_wmask;

//-------rsp------------
assign master_icb_rsp_valid = {1{rsp_sel[0]}} & s0_icb_rsp_valid
                            | {1{rsp_sel[1]}} & s1_icb_rsp_valid
                            | {1{rsp_sel[2]}} & s2_icb_rsp_valid
                            | {1{rsp_sel[3]}} & s3_icb_rsp_valid
                            | {1{rsp_sel[4]}} & s4_icb_rsp_valid
                            | {1{rsp_sel[5]}} & s5_icb_rsp_valid
                            | {1{rsp_sel[6]}} & s6_icb_rsp_valid
                            | {1{rsp_sel[7]}} & s7_icb_rsp_valid
                            ;

assign s0_icb_rsp_ready = {1{rsp_sel[0]}} & master_icb_rsp_ready;
assign s1_icb_rsp_ready = {1{rsp_sel[1]}} & master_icb_rsp_ready;
assign s2_icb_rsp_ready = {1{rsp_sel[2]}} & master_icb_rsp_ready;
assign s3_icb_rsp_ready = {1{rsp_sel[3]}} & master_icb_rsp_ready;
assign s4_icb_rsp_ready = {1{rsp_sel[4]}} & master_icb_rsp_ready;
assign s5_icb_rsp_ready = {1{rsp_sel[5]}} & master_icb_rsp_ready;
assign s6_icb_rsp_ready = {1{rsp_sel[6]}} & master_icb_rsp_ready;
assign s7_icb_rsp_ready = {1{rsp_sel[7]}} & master_icb_rsp_ready;

assign master_icb_rsp_err = {1{rsp_sel[0]}} & s0_icb_rsp_err
                            | {1{rsp_sel[1]}} & s1_icb_rsp_err
                            | {1{rsp_sel[2]}} & s2_icb_rsp_err
                            | {1{rsp_sel[3]}} & s3_icb_rsp_err
                            | {1{rsp_sel[4]}} & s4_icb_rsp_err
                            | {1{rsp_sel[5]}} & s5_icb_rsp_err
                            | {1{rsp_sel[6]}} & s6_icb_rsp_err
                            | {1{rsp_sel[7]}} & s7_icb_rsp_err
                            ;

assign master_icb_rsp_rdata = {32{rsp_sel[0]}} & s0_icb_rsp_rdata
                            | {32{rsp_sel[1]}} & s1_icb_rsp_rdata
                            | {32{rsp_sel[2]}} & s2_icb_rsp_rdata
                            | {32{rsp_sel[3]}} & s3_icb_rsp_rdata
                            | {32{rsp_sel[4]}} & s4_icb_rsp_rdata
                            | {32{rsp_sel[5]}} & s5_icb_rsp_rdata
                            | {32{rsp_sel[6]}} & s6_icb_rsp_rdata
                            | {32{rsp_sel[7]}} & s7_icb_rsp_rdata
                            ;
endmodule