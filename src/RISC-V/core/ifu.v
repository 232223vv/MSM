`include "source\rtl\defines.v"

//取指模块
module ifu(

    input wire clk,
    input wire rst_n,

    //与译码执行单元交互
    input wire [`InstAddrBus] pc_n_i,//取指地址
    input wire inst_nxt_i,//取下一条指令
    //取指结果
    output reg  [`InstAddrBus] pc_o,//当前指令地址
    output wire [`InstBus] inst_o,//当前指令
    output wire inst_valid_o,//指令有效

    //与指令存储器交互
    output wire if_req_o,//取指请求
    output wire [`InstAddrBus] if_addr_o,//取指地址
    input wire if_ack_i,//取指响应
    input wire [`InstBus] if_data_i//取指数据
);
/*
req     |__111___1111_____1XX
ack     |_____1___1111_____1X
if_wait |___111___1111_____1X
inst    |BBBNNIBBBIIIIBBBBBIX
B:inst_buffer 输出缓存的指令
N:inst_nop    原地跳转，无效指令
I:inst_input  当前拍取指取出的指令
*/
reg if_wait;//等待指令取出，被if_ack_i mux
reg  [`InstBus] inst_buffer;//缓存的指令
wire [`InstBus] inst_nop = 32'h0000_006f;//原地跳转指令 jal x0,0
wire [`InstBus] inst_input = if_data_i;//取指数据

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        if_wait <= 1'b1;
    end
    else begin
        if (if_req_o) begin//要取下一条指令
            if_wait <= 1'b1;
        end
        else begin//还在当前指令
            if (if_ack_i) begin//指令取出来了
                if_wait <= 1'b0;
            end
        end
    end
end

always @(posedge clk) begin
    if (if_ack_i) begin//指令取出来了
        inst_buffer <= inst_input;
    end
end


//PC
wire [31:0] rst_addr = `RstPC;//复位地址
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        pc_o <= rst_addr;
    end
    else begin
        if(if_req_o) begin
            pc_o <= if_addr_o;
        end
        else begin
            pc_o <= pc_o;
        end
    end
end


assign inst_o = if_ack_i ? inst_input :  //取出了最新的指令
                if_wait  ? inst_nop   :  //等指令取出
                inst_buffer;             //指令正在执行
assign inst_valid_o = if_ack_i & if_wait;
assign if_req_o = inst_nxt_i;// | ~rst_n;
assign if_addr_o = pc_n_i;

endmodule
