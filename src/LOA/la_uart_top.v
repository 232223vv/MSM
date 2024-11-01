module la_uart_top(
    input clk_50M,
    input rst_n,
    input uart_data,
    output [16:0] wr_addr,
    output [7:0] wr_data,
    output wr_en
   );
    wire [7:0] uart_data_out;
    wire rev_end;
    wire rev_state;
   uart_ctrl inst_uart_ctrl(
        .clk(clk_50M),
        .rst_n(rst_n),   
	    .data_in(uart_data),
	    .uart_data_out(uart_data_out),
	    .rev_end(rev_end),
	    .rev_state(rev_state)
    );
    uart_frames_transmit uart_frames_transmit_inst(
        .uart_data(uart_data_out),
	    .clk(clk_50M),
        .rst_n(rst_n),
        .uart_end(rev_end),
        .wr_addr(wr_addr),
        .wr_en(wr_en),
	    .wr_data(wr_data)
    );
endmodule