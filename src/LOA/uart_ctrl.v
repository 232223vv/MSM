
module uart_ctrl(
	input clk,
    input rst_n,   //clk=50M
	input data_in,
	output [7:0]uart_data_out,
	output wire rev_end,
	output reg rev_state);
	
reg [12:0]bps_cnt;
reg clk_bps;
reg [4:0]clk_bps_cnt;
reg error_state;
reg [7:0]uart_data_out_r;
wire uart_data_in;
wire start_flag;
assign uart_data_out=(rev_end)? uart_data_out_r:8'dZ;
assign rev_end=(clk_bps_cnt==11)?1'b1:1'b0;
/***********bps generate********************/
	// different bps' timepiece 
parameter t_9600_cnt  =5028,   //9600 bps
			 t_19200_cnt =2604,   //19200 bps
			 t_38400_cnt =1302,   
			 t_57600_cnt =868,
			 t_115200_cnt=434;
       				
always @(posedge clk or negedge rst_n)begin
	if(~rst_n)  bps_cnt<=0;
	else if (rev_state)
		if (bps_cnt==t_9600_cnt-1) bps_cnt<=0;
		else bps_cnt<=bps_cnt+1'b1;
	else bps_cnt<=0;
	end
		 
always @(posedge clk or negedge rst_n)begin
	if(~rst_n) clk_bps<=0;
	else if (rev_state)
		if(bps_cnt==1) clk_bps<=1;
		else  clk_bps<=0;
	else  clk_bps<=clk_bps;
	end
always@(posedge clk or negedge rst_n)begin
	if(~rst_n) clk_bps_cnt<=0;
	else if (rev_state)
		if(clk_bps) clk_bps_cnt<=clk_bps_cnt+1'b1;
		else clk_bps_cnt<=clk_bps_cnt;
	else clk_bps_cnt<=0;
	end
		
/************bps generate end *****************/
 
	
always @(posedge clk or negedge rst_n)begin
	if(~rst_n) rev_state<=0;
	else if(start_flag) rev_state<=1;
	else if(rev_end) rev_state<=0;
	else rev_state<=rev_state;
	end
	
/********************protol process***************************/
always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin	
		error_state<=0;
		end
	else if (rev_state)begin
		case(clk_bps_cnt)
			1:begin
				if (uart_data_in==0) error_state<=0;
				else error_state<=1;
		   end
		   2:begin
				uart_data_out_r[0]<=uart_data_in;
				error_state<=0;
		   end
		   3:begin
				uart_data_out_r[1]<=uart_data_in;
		   end
		   4:begin
				uart_data_out_r[2]<=uart_data_in;
		   end
		   5:begin
				uart_data_out_r[3]<=uart_data_in;
		   end
			6:begin
				uart_data_out_r[4]<=uart_data_in;
		   end
			7:begin
				uart_data_out_r[5]<=uart_data_in;
		   end
			8:begin
				uart_data_out_r[6]<=uart_data_in;
		   end
			9:begin
				uart_data_out_r[7]<=uart_data_in;
		   end
			10:begin
				if (uart_data_in==1) error_state<=0;
				else error_state<=1;
				
		   end
			default:;
		
		endcase
		end
	end
 data_samp data_samp(
	.clk(clk),
	.rst_n(rst_n),
	.data_in(data_in),
	.clk_bps(clk_bps),
	.uart_data_in(uart_data_in),
	.start_flag(start_flag));
endmodule