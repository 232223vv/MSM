module la_top(
    input clk_50M,
    input rst_n,
    input [7:0] pmod_in,
    input  uart_in,
    input rd_clk,
    input [16:0] rd_addr,
    input la_mode,
    input en,
    input [2:0] mode_sel,
    input [3:0] channel_sel,
    input [3:0] div_sel,
    output [7:0] data_out,
    output uart_tx
   );
   reg uart_in_1;
   wire [7:0] uart_data_out;
   wire [7:0] pmod_data_out;
   /*assign data_out=(la_mode)?pmod_data_out:uart_data_out;*/
    always @(posedge clk_50M) begin
        if(!rst_n)
           uart_in_1<=1'b0;
        else if(en)
            uart_in_1<=uart_in;
        else
            uart_in_1<=uart_in_1;
    end
    wire [16:0] uart_wr_addr;
    wire [7:0] uart_wr_data;
    wire uart_wr_en;
    la_uart_top la_uart_top_inst(
        .clk_50M(clk_50M),
        .rst_n(rst_n),
        .uart_data(uart_in_1),
        .wr_addr(uart_wr_addr),
        .wr_data(uart_wr_data),
        .wr_en(uart_wr_en)
        );
    wire [16:0] pmod_wr_addr;
    wire [7:0] pmod_wr_data;
    wire pmod_wr_en;
    la_pmod_top la_pmod_top_inst(
        .clk_50M(clk_50M),
        .rst_n(rst_n),
        .channel_sel(channel_sel),
        .pmod_data_in(pmod_in),
        .act(en),
        .mode_sel(mode_sel),
        .wr_data(pmod_wr_data),
        .wr_addr(pmod_wr_addr),
        .wr_en(pmod_wr_en),
        .div_sel(div_sel)
    );
    wire [16:0] la_wr_addr;
    wire [7:0] la_wr_data;
    wire la_wr_en;
    assign la_wr_addr=(la_mode)? pmod_wr_addr:uart_wr_addr;
    assign la_wr_data=(la_mode)? pmod_wr_data:uart_wr_data;
    assign la_wr_en=(la_mode)? pmod_wr_en:uart_wr_en;
    la_ram1 la_ram1_inst (
  .wr_data(la_wr_data),    // input [7:0]
  .wr_addr(la_wr_addr),    // input [16:0]
  .wr_en(la_wr_en),        // input
  .wr_clk(clk_50M),      // input
  .wr_rst(!en),      // input
  .rd_addr(rd_addr),    // input [16:0]
  .rd_data(data_out),    // output [7:0]
  .rd_clk(rd_clk),      // input
  .rd_rst(!en)       // input
);
    rx_tx_gen rx_tx_gen_inst(
        .clk(clk_50M),
        .uart_rx(uart_in),
        .uart_tx(uart_tx)
    );
endmodule