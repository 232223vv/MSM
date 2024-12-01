`include "source\rtl\defines.v"
module sram (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	
	input [7:0] key_in,

    //ICB Slave sram
    input  wire                 sram_icb_cmd_valid,//cmd有效
    output wire                 sram_icb_cmd_ready,//cmd准备 ?
    input  wire [`MemAddrBus]   sram_icb_cmd_addr ,//cmd地址
    input  wire                 sram_icb_cmd_read ,//cmd读使 ?
    input  wire [`MemBus]       sram_icb_cmd_wdata,//cmd写数 ?
    input  wire [3:0]           sram_icb_cmd_wmask,//cmd写 ?  ??
    output reg                  sram_icb_rsp_valid,//rsp有效
    input  wire                 sram_icb_rsp_ready,//rsp准备 ?
    output wire                 sram_icb_rsp_err  ,//rsp错误
    output wire [`MemBus]       sram_icb_rsp_rdata//rsp读数 ?
	
);


//ICB总线交互
wire [clogb2(`SRamSize-1)-1:0]addr;
wire we,en;
wire [3:0] wem;
wire [`MemBus]dout;
wire [`MemBus]din;
wire icb_whsk = sram_icb_cmd_valid & ~sram_icb_cmd_read;//写握 ?
wire icb_rhsk = sram_icb_cmd_valid & sram_icb_cmd_read;//读握 ?

localparam [clogb2(`SRamSize-1)-1:0] addr_zero0 = 0;

always @(posedge clk or negedge rst_n)//读响应控 ?
if (~rst_n)
    sram_icb_rsp_valid <=1'b0;
else begin
    if (icb_rhsk)
        sram_icb_rsp_valid <=1'b1;
    else if (sram_icb_rsp_valid & sram_icb_rsp_ready)
        sram_icb_rsp_valid <=1'b0;
    else
        sram_icb_rsp_valid <= sram_icb_rsp_valid;
end

assign sram_icb_cmd_ready = 1'b1;
assign sram_icb_rsp_err = addr > (`SRamSize-1);
assign sram_icb_rsp_rdata = dout;
assign addr = sram_icb_cmd_addr[31:2];
assign we = icb_whsk;
assign wem = sram_icb_cmd_wmask;
assign din = sram_icb_cmd_wdata;
assign en = sram_icb_cmd_valid;

//RTL SRAM
parameter RAM_WIDTH = 32;//RAM数据位宽
parameter RAM_DEPTH = `SRamSize;//RAM深度
reg [7:0] BRAM0 [0:RAM_DEPTH-1];
reg [7:0] BRAM1 [0:RAM_DEPTH-1];
reg [7:0] BRAM2 [0:RAM_DEPTH-1];
reg [7:0] BRAM3 [0:RAM_DEPTH-1];
reg [7:0] dout0;
reg [7:0] dout1;
reg [7:0] dout2;
reg [7:0] dout3;

always @(posedge clk)
    if (en) begin
        if(sram_icb_cmd_addr != 32'h2000_0000) begin
            if(we&wem[0])
                BRAM0[addr] <= din[7:0];
            dout0 <= BRAM0[addr];
        end
        else begin
            if(we&wem[0])
                BRAM0[addr] <= key_in;
            dout0 <= key_in;
        end
    end

always @(posedge clk)
    if (en) begin
        if(sram_icb_cmd_addr != 32'h2000_0000) begin
            if(we&wem[1])
                BRAM1[addr] <= din[15:8];
            dout1 <= BRAM1[addr];
        end
        else begin
            if(we&wem[1])
                BRAM1[addr] <= key_in;
            dout1 <= key_in;
        end
    end

always @(posedge clk)
    if (en) begin
        if(sram_icb_cmd_addr != 32'h2000_0000) begin
            if(we&wem[2])
                BRAM2[addr] <= din[23:16];
            dout2 <= BRAM2[addr];
        end
        else begin
            if(we&wem[2])
                BRAM2[addr] <= key_in;
            dout2 <= key_in;
        end
    end

always @(posedge clk)
    if (en) begin
        if(sram_icb_cmd_addr != 32'h2000_0000) begin
            if(we&wem[3])
                BRAM3[addr] <= din[31:24];
            dout3 <= BRAM3[addr];
        end
        else begin
            if(we&wem[3])
                BRAM3[addr] <= key_in;
            dout3 <= key_in;
        end
    end

// assign dout = (sram_icb_cmd_addr == 32'h2000_0000) ? {4{key_in}} : {dout3, dout2, dout1, dout0};
    assign dout = {dout3, dout2, dout1, dout0};
function integer clogb2;
    input integer depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1)
            depth = depth >> 1;
endfunction

endmodule