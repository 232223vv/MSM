module data_samp(
	input clk,
    input rst_n,
	input clk_bps,
	input data_in,
	output reg uart_data_in,
	output start_flag);
 
	// input data register
reg [1:0]data_in_r;
reg [3:0]uart_data_in_r;
reg [9:0]samp_rate_cnt;
reg [4:0]samp_cnt;
reg clk_bps_r;
reg clk_samp;
reg samp_state;
wire samp_start_flag;
wire data_samp_end;
parameter t_9600_cnt  =5028,   //9600 bps
			 t_19200_cnt =2604,   //19200 bps
			 t_38400_cnt =1302,   
			 t_57600_cnt =868,
			 t_115200_cnt=434;
 
assign samp_start_flag =(~clk_bps_r && clk_bps)?1'b1:1'b0;	
assign start_flag=(data_in_r[1] && ~data_in_r[0])? 1'b1:1'b0;   // negedge data
assign data_samp_end=(samp_cnt==7)?1'b1:1'b0;  
 
always @(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		data_in_r[1]<=0;
		data_in_r[0]<=0;
		end
	else begin
		data_in_r[0]<=data_in;
		data_in_r[1]<=data_in_r[0];
		end
	end
	//one bit' sample rate	
always @(posedge clk or negedge rst_n)begin
	if(~rst_n)clk_bps_r<=0;
	else clk_bps_r<=clk_bps;
	end
	
always @(posedge clk or negedge rst_n)begin
	if(~rst_n) samp_state<=0;
	else if(samp_start_flag) samp_state<=1;
	else if(data_samp_end) samp_state<=0;
	else samp_state<=samp_state;
	end
always @(posedge clk or negedge rst_n)begin
	if(~rst_n) samp_rate_cnt<=0;
	else if(samp_state)
		if(samp_rate_cnt==t_9600_cnt/7) samp_rate_cnt<=0;
		else samp_rate_cnt<=samp_rate_cnt+1'b1;  
	else samp_rate_cnt<=0;
	end
	
always @(posedge clk or negedge rst_n)begin
	if(~rst_n) samp_cnt<=0;
	else if (samp_state)
		if(clk_samp)samp_cnt<=samp_cnt+1'b1;
		else samp_cnt<=samp_cnt;
	else samp_cnt<=0;
	end
always @(posedge clk or negedge rst_n)begin
	if(~rst_n) clk_samp<=0;
	else if(samp_rate_cnt==t_9600_cnt/14) clk_samp<=1;
	else clk_samp<=0;
	end
	
always @(posedge clk or negedge rst_n)begin
	if(~rst_n)	begin
		uart_data_in_r<=0;
		end
	else if (samp_state)begin
		if (clk_samp)begin
			case(samp_cnt)
				1: begin uart_data_in_r <= uart_data_in_r+data_in_r[1]; end
				2: begin uart_data_in_r <= uart_data_in_r+data_in_r[1]; end
				3: begin uart_data_in_r <= uart_data_in_r+data_in_r[1]; end
				4: begin uart_data_in_r <= uart_data_in_r+data_in_r[1]; end
				5: begin uart_data_in_r <= uart_data_in_r+data_in_r[1]; end
				6: begin uart_data_in_r <= uart_data_in_r+data_in_r[1]; end
				default: ;
			endcase
		end
	end
	else uart_data_in_r<=0;
end 
always @(posedge clk or negedge rst_n)begin
	if(~rst_n)	uart_data_in<=0;
	else if(samp_cnt==6)
		if(uart_data_in_r[2]==1) uart_data_in<=1;
		else uart_data_in<=0;
	else uart_data_in<=uart_data_in;
	end
endmodule