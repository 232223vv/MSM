module uart_frames_transmit(
	input [7:0]uart_data,
	input clk,
    input rst_n,
    input uart_end,
    output  [7:0]wr_data,
    output wr_en,
    output [16:0] wr_addr
    
	);
	

assign wr_data=uart_data;
reg [3:0]uart_end_cnt;
reg uart_end_r;
reg [17:0]fram_rduart_tim;
 
reg error_interrupt;
reg fram_rddata_flag;
reg[3:0]fram_rddata_flag_cnt;
wire uart_end_flag;
wire fram_state;
assign fram_state=(fram_rddata_flag_cnt>=4'd1 && fram_rddata_flag_cnt<=4'd8)?1'b1:1'b0;
	//*****uart transimit 1 bytes end flag******//
assign uart_end_flag=(!uart_end_r & uart_end)? 1'b1:1'b0;
always @(posedge clk or negedge rst_n) begin
		if(~rst_n) uart_end_r<=0;
		else uart_end_r<=uart_end;
		end		
always @(posedge clk or negedge rst_n) begin
		if(~rst_n) uart_end_cnt<=0;
		else if(uart_end_flag) uart_end_cnt<=uart_end_cnt+1'b1;
		else uart_end_cnt<=uart_end_cnt;
		end
	//*****time counter of register input data ******//
always @(posedge clk or negedge rst_n) begin
		if(~rst_n) fram_rduart_tim<=0;
		else if(fram_rduart_tim>=100560) fram_rduart_tim<=0; 
		else if(uart_end_flag) fram_rduart_tim<=18'd1;
		else if(fram_rduart_tim>0) fram_rduart_tim<=fram_rduart_tim+1'b1;		
		else fram_rduart_tim<=0;
		end
always @(posedge clk or negedge rst_n) begin
		if(~rst_n)  fram_rddata_flag<=0; 
		else if(fram_rduart_tim==20000) fram_rddata_flag<=1; // reader uart data at 20000*20ns after flag=1 
		else fram_rddata_flag<=0; 
		end
always @(posedge clk or negedge rst_n) begin
		if(~rst_n) fram_rddata_flag_cnt<=0;
		else if(error_interrupt) fram_rddata_flag_cnt<=0;
		else if(fram_rddata_flag_cnt<4'd8)
			if(fram_rddata_flag) fram_rddata_flag_cnt<=fram_rddata_flag_cnt+1'b1;
			else fram_rddata_flag_cnt<=fram_rddata_flag_cnt;
		else fram_rddata_flag_cnt<=0;
		end	
	//*****uart transmition interrupt request******//
always @(posedge clk or negedge rst_n) begin
		if(~rst_n)	error_interrupt<=0;
		else if(fram_rduart_tim==100560 && fram_rddata_flag_cnt!=4'd8) error_interrupt<=1;
		else error_interrupt<=0;
		end
	//*****frames transmit flag******//		
reg fram_rddata_flag_r;
always @(posedge clk or negedge rst_n) begin
		if(~rst_n) fram_rddata_flag_r<=0;
		else fram_rddata_flag_r<=fram_rddata_flag;
		end 

/*always @(posedge clk or negedge rst_n) begin
		if(~rst_n)	begin
			fram_data<=0;
			end
		else if (error_interrupt) fram_data<=0;
		else if(fram_state && fram_rddata_flag_r)  fram_data<={fram_data[55:0],uart_data};	
		else fram_data<= fram_data;
		end*/
reg [7:0] q;
reg [16:0] wr_addr_temp;
always @(posedge clk) begin
    if(!rst_n)
        wr_addr_temp<=17'b0;
    else if(wr_addr_temp>=17'd131071)
        wr_addr_temp<=17'd131071;
    else if(uart_end_flag)
        wr_addr_temp<=wr_addr_temp+1'b1;
    else
        wr_addr_temp<=wr_addr_temp;
end
assign wr_addr=wr_addr_temp;
reg wr_en_temp;
always @(posedge clk) begin
    if(!rst_n)
        wr_en_temp<=1'b0;
    else if(uart_end_flag)
        wr_en_temp<=1'b1;
    else 
        wr_en_temp<=wr_en_temp;
end

assign wr_en=wr_en_temp;
/*la_uart_ram la_uart_ram_inst (
  .wr_data(uart_data),    // input [7:0]
  .wr_addr(wr_addr),    // input [17:0]
  .wr_en(wr_en),        // input
  .wr_clk(clk),      // input
  .wr_rst(addr_reset),      // input
  .rd_addr(rd_addr),    // input [16:0]
  .rd_data(la_data),    // output [7:0]
  .rd_clk(rd_clk),      // input
  .rd_rst(addr_reset)       // input
);
*/
        

 
endmodule