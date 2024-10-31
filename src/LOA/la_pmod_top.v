module la_pmod_top(
    input clk_50M,
    input rst_n,
    input [3:0] channel_sel,
    input [7:0] pmod_data_in,
    /*input [16:0] rd_addr,
    input rd_clk,*/
    input act,
    input [2:0] mode_sel,
    
    input [3:0] div_sel,
    output [7:0] wr_data,
    output  wr_en,
    output [16:0] wr_addr
    
   );
    wire clk_sample;
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
        .wren(wr_en)
        
    );
endmodule