`include "source\rtl\defines.v"
module iram (
    input wire clk,
    input wire rst_n,

    //取指端口
    input wire [`InstAddrBus] inst_addr_i,//指令地址
    input wire inst_req_i,//取指请求
    output wire [`InstBus] inst_data_o,//指令
    output wire inst_ack_o,//取指响应

    //ICB Slave iram
    input  wire                 iram_icb_cmd_valid,//cmd有效
    output wire                 iram_icb_cmd_ready,//cmd准备好
    input  wire [`MemAddrBus]   iram_icb_cmd_addr ,//cmd地址
    input  wire                 iram_icb_cmd_read ,//cmd读使能
    input  wire [`MemBus]       iram_icb_cmd_wdata,//cmd写数据
    input  wire [3:0]           iram_icb_cmd_wmask,//cmd写选通
    output reg                  iram_icb_rsp_valid,//rsp有效
    input  wire                 iram_icb_rsp_ready,//rsp准备好
    output wire                 iram_icb_rsp_err  ,//rsp错误
    output wire [`MemBus]       iram_icb_rsp_rdata//rsp读数据
);
/* iram是指令存储器，本体是单端口RAM模型，仲裁出ICB总线和取指端口
*/


//状态机仲裁取指和ICB总线访问
reg iram_fsm;//iram状态机，0:正常取指，1:ICB总线访问
reg icb_write;//与状态机同步更新icb是否为写操作
reg iram_fsm_nxt;
wire icb_whsk = iram_icb_cmd_valid & ~iram_icb_cmd_read;//写握手
wire icb_rhsk = iram_icb_cmd_valid & iram_icb_cmd_read;//读握手


wire [`MemBus]ram_dout;
wire [3:0]ram_wem = iram_icb_cmd_wmask;//直连ICB
wire [`MemBus]dinb = iram_icb_cmd_wdata;//直连ICB
wire [clogb2(`IRamSize-1)-1:0]ram_addr = iram_icb_cmd_valid ? iram_icb_cmd_addr[31:2] : inst_addr_i[31:2];//ICB优先
wire ram_we = iram_icb_cmd_valid &  ~iram_icb_cmd_read;//写
wire ram_en = iram_icb_cmd_valid | (~iram_fsm_nxt & inst_req_i);//ICB访问 或 取指请求

reg rst_r;
always @(posedge clk or negedge rst_n)
    if (~rst_n) begin
        iram_fsm <= 1'b1;
        icb_write <= 1'b0;
        rst_r <= 1'b0;
    end
    else begin
        rst_r <= 1'b1;
        iram_fsm <= iram_fsm_nxt;
        if (iram_icb_cmd_valid) begin
            icb_write <= ram_we;
        end
end

always @(*) begin
    if (~rst_r) begin
        iram_fsm_nxt = 1'b0;
    end
    else begin
        if (iram_fsm == 1'b0) begin //fsm=0 取指
            iram_fsm_nxt = iram_icb_cmd_valid;
        end
        else begin//fsm=1 ICB
            if (icb_write) begin //ICB写无需等rsp
                iram_fsm_nxt = 1'b0;
            end
            else begin //ICB读
                if (iram_icb_rsp_ready) begin//icb读响应
                    iram_fsm_nxt = 1'b0;
                end 
                else begin //等待
                    iram_fsm_nxt = 1'b1;
                end
            end
        end
    end
end

always @(posedge clk or negedge rst_n)//读响应控制
if (~rst_n)
    iram_icb_rsp_valid <=1'b0;
else begin
    if (icb_rhsk)
        iram_icb_rsp_valid <=1'b1;
    else if (iram_icb_rsp_valid & iram_icb_rsp_ready)
        iram_icb_rsp_valid <=1'b0;
    else
        iram_icb_rsp_valid <= iram_icb_rsp_valid;
end
assign inst_ack_o = ~iram_fsm;//ICB下一状态不能取指
assign inst_data_o = ram_dout;//icb访问期间，用指令缓存
assign iram_icb_rsp_err = ram_addr > (`IRamSize-1);
assign iram_icb_cmd_ready = 1'b1;//读立即rdy，写延迟1周期
assign iram_icb_rsp_rdata = ram_dout;


//RAM建模
reg [31:0] RAM [0:`IRamSize-1];
reg [31:0] ram_dout_r;
wire [3:0] ram_webyte = {4{ram_we}} & ram_wem;
always @(posedge clk) begin
    if (ram_en) begin
        ram_dout_r <= RAM[ram_addr];
`ifdef IRAM_SPRAM_W4B
        if(ram_we)
            RAM[ram_addr] <= dinb;
`else
        if(ram_webyte[0])
            RAM[ram_addr][7:0] <= dinb[7:0];
        if(ram_webyte[1])
            RAM[ram_addr][15:8] <= dinb[15:8];
        if(ram_webyte[2])
            RAM[ram_addr][23:16] <= dinb[23:16];
        if(ram_webyte[3])
            RAM[ram_addr][31:24] <= dinb[31:24];
`endif
    end
end
assign ram_dout = ram_dout_r;

`ifndef HDL_SIM //不是仿真
`ifdef PROG_IN_FPGA //开启宏写入FPGA
initial begin
    $readmemh (`PROG_FPGA_PATH, RAM);//bin -> txt -> RTL
end
`endif
`endif

function integer clogb2;
    input integer depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1)
            depth = depth >> 1;
endfunction



endmodule