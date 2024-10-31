`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/24 19:08:33
// Design Name: 
// Module Name: sample
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sample(
   input clk_50M, //系统时钟 50MHZ
input rst_n, //
input clk_sample, //时钟使能
input act, //启动触发
input [3:0]channel_sel, //通道选择
input [2:0]mode_sel, //模式选择
input [7:0]data_in, //被测信号输入
//----------------模块输出端口----------------
output [16:0]wr_addr, //写 RAM 地址
output [7:0]wr_data, //写 RAM 数据
output  wren //写使能

);
//----------------模块输入端口----------------

//----------------I/O 寄存器----------------
reg [7:0]data_r1; //输入信号同步寄存器
reg [7:0]data_r2;
reg [16:0]wr_addr_temp = 17'd0;
//----------------内部寄存器----------------
reg trigger = 0; //触发标志
reg wren_temp = 0; //写 RAM
reg act_r = 0; //开始采集
reg [7:0]trigger_dat; //触发条件比较数据
//----------------内部连线----------------
wire [7:0] s_posedge; //上升沿标志
wire [7:0] s_negedge; //下降沿标志
wire [7:0] s_edge; //边沿标志
assign wr_data = data_r2; //采集数据输出至 RAM
assign wren=wren_temp;
assign wr_addr=wr_addr_temp;


//----------------同步输入信号----------------
always@(posedge clk_50M)
    if(clk_sample) begin
        data_r1<=data_in;//一级寄存器赋值
        data_r2<=data_r1;//二级寄存器赋值
    end
assign s_posedge=data_r1&~data_r2;//上升沿检测
assign s_negedge=~data_r1&data_r2;//下降沿检测
assign s_edge=data_r1^data_r2; //边沿检测
//----------------根据不同的触发模式选择触发数据（trigger_dat） ------

always@(mode_sel or s_posedge or s_negedge or s_edge or data_r2)
    begin
        case(mode_sel)
            3'd0:trigger_dat=~data_r2; //低电平触发
            3'd1:trigger_dat=data_r2; //高电平触发
            3'd2:trigger_dat=s_posedge; //上升沿触发
            3'd3:trigger_dat=s_negedge; //下降沿触发
            3'd4:trigger_dat=s_edge; //边沿触发
            3'd5:trigger_dat=10'h3ff; //边沿触发
        default:trigger_dat=10'h3ff;
    endcase
end
//----------------检测是否满足触发条件----------------

always@(posedge clk_50M) begin
    if(trigger_dat[channel_sel]&&clk_sample) begin
        trigger<=1;
    end
    else begin
        trigger<=0;
    end
end
//----------------保持单次触发状态，直到数据完毕----------------
always@(posedge clk_50M) begin
    if(act)
        act_r <= 1'b1;
    else if(wr_addr_temp == 17'd131071)
        act_r <= 1'b0;
    else
        act_r <= act_r;
end
//----------------产生写 RAM 地址----------------
always@(posedge clk_sample) begin
    if(wren_temp) begin
        if(wr_addr_temp != 17'd131071) begin
            wr_addr_temp <= wr_addr_temp + 1'b1;
        end
        else begin
            wr_addr_temp <= wr_addr_temp;
        end
    end
    else if(act) begin
        wr_addr_temp <= wr_addr_temp;
    end
    else begin
        wr_addr_temp <= 17'd0;
    end
end


reg flag;
always@(posedge clk_50M) begin
    if(!rst_n) begin
        flag <= 1'b0;
    end
    else if (wr_addr_temp == 17'd131071) begin
        flag <= 1'b1;
    end
    else begin
        flag <= flag;    
    end
end
//----------------检查写 RAM 条件是否满足----------------
always@(posedge clk_50M) begin
    if(wr_addr_temp == 17'd131071)
        wren_temp <= 1'b0;
    else if(act && trigger)
        wren_temp <= 1'b1;
    else 
        wren_temp <= wren_temp;
end
endmodule

