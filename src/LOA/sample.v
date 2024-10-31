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
   input clk_50M, //ϵͳʱ�� 50MHZ
input rst_n, //
input clk_sample, //ʱ��ʹ��
input act, //��������
input [3:0]channel_sel, //ͨ��ѡ��
input [2:0]mode_sel, //ģʽѡ��
input [7:0]data_in, //�����ź�����
//----------------ģ������˿�----------------
output [16:0]wr_addr, //д RAM ��ַ
output [7:0]wr_data, //д RAM ����
output  wren //дʹ��

);
//----------------ģ������˿�----------------

//----------------I/O �Ĵ���----------------
reg [7:0]data_r1; //�����ź�ͬ���Ĵ���
reg [7:0]data_r2;
reg [16:0]wr_addr_temp = 17'd0;
//----------------�ڲ��Ĵ���----------------
reg trigger = 0; //������־
reg wren_temp = 0; //д RAM
reg act_r = 0; //��ʼ�ɼ�
reg [7:0]trigger_dat; //���������Ƚ�����
//----------------�ڲ�����----------------
wire [7:0] s_posedge; //�����ر�־
wire [7:0] s_negedge; //�½��ر�־
wire [7:0] s_edge; //���ر�־
assign wr_data = data_r2; //�ɼ���������� RAM
assign wren=wren_temp;
assign wr_addr=wr_addr_temp;


//----------------ͬ�������ź�----------------
always@(posedge clk_50M)
    if(clk_sample) begin
        data_r1<=data_in;//һ���Ĵ�����ֵ
        data_r2<=data_r1;//�����Ĵ�����ֵ
    end
assign s_posedge=data_r1&~data_r2;//�����ؼ��
assign s_negedge=~data_r1&data_r2;//�½��ؼ��
assign s_edge=data_r1^data_r2; //���ؼ��
//----------------���ݲ�ͬ�Ĵ���ģʽѡ�񴥷����ݣ�trigger_dat�� ------

always@(mode_sel or s_posedge or s_negedge or s_edge or data_r2)
    begin
        case(mode_sel)
            3'd0:trigger_dat=~data_r2; //�͵�ƽ����
            3'd1:trigger_dat=data_r2; //�ߵ�ƽ����
            3'd2:trigger_dat=s_posedge; //�����ش���
            3'd3:trigger_dat=s_negedge; //�½��ش���
            3'd4:trigger_dat=s_edge; //���ش���
            3'd5:trigger_dat=10'h3ff; //���ش���
        default:trigger_dat=10'h3ff;
    endcase
end
//----------------����Ƿ����㴥������----------------

always@(posedge clk_50M) begin
    if(trigger_dat[channel_sel]&&clk_sample) begin
        trigger<=1;
    end
    else begin
        trigger<=0;
    end
end
//----------------���ֵ��δ���״̬��ֱ���������----------------
always@(posedge clk_50M) begin
    if(act)
        act_r <= 1'b1;
    else if(wr_addr_temp == 17'd131071)
        act_r <= 1'b0;
    else
        act_r <= act_r;
end
//----------------����д RAM ��ַ----------------
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
//----------------���д RAM �����Ƿ�����----------------
always@(posedge clk_50M) begin
    if(wr_addr_temp == 17'd131071)
        wren_temp <= 1'b0;
    else if(act && trigger)
        wren_temp <= 1'b1;
    else 
        wren_temp <= wren_temp;
end
endmodule

