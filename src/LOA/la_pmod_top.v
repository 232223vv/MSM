module la_pmod_top(
    input clk_50M,
    input rst_n,
    input [3:0] channel_sel,
    input [7:0] pmod_data_in,
    input [16:0] rd_addr,
    input rd_clk,
    input act,
    input [2:0] mode_sel,
    output [7:0] la_data,
    input [3:0] div_sel
   );
    wire clk_sample;
    wire [16:0] wr_addr;
    wire [7:0] wr_data;
    wire wr_en;
    
    assign wenled = wr_en;
   div_freq div_freq_inst(
        .clk_50M(clk_50M),
        .rst_n(rst_n),
        .clk(clk_sample),
        .sel(div_sel)
    );
    sample sample_inst(
        .clk_50M(clk_50M),
        .rst_n(rst_n),
        .clk_sample(clk_sample),
        .act(act),
        .channel_sel(channel_sel),
        .mode_sel(mode_sel),
        .data_in(pmod_data_in),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .wren(wr_en),
        .actled(actled)
    );
    la_ram ram_la (
      .wr_data(wr_data),    // input [7:0]
      .wr_addr(wr_addr),    // input [16:0]
      .wr_en(wr_en),        // input
      .wr_clk(clk_sample),      // input
      .wr_rst(!rst_n),      // input
      .rd_addr(rd_addr),    // input [16:0]
      .rd_data(la_data),    // output [7:0]
      .rd_clk(rd_clk),      // input
      .rd_rst(!rst_n)       // input
    );


endmodule