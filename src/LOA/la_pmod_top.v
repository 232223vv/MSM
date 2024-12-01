/*module la_pmod_top(
    input clk_50M,
    input rst_n,
    input [3:0] channel_sel,
    input [7:0] pmod_data_in,
    input [14:0] rd_addr,
    input [10:0] rd_addr_cons,
    input rd_clk,
    input act,
    input [2:0] mode_sel,
    input [1:0] cnt_loa,
    output [7:0] la_data,
    output [7:0] la_data_cons,
    input [3:0] div_sel
   );
    wire clken;
    wire clk_ram;
    wire clk_addr;
    wire [14:0] wr_addr;
    wire [10:0] wr_addr_cons;
    wire [7:0] wr_data;
    wire wr_en;
    
   div_freq sample(
        .clk_50M(clk_50M),
        .rst_n(rst_n),
        .clken(clken),
        .sel(div_sel)
    );

    sample sample_inst(
        .clk_50M(clk_50M),
        .rst_n(rst_n),
        .clken(clken),
        .act(act),
        .channel_sel(channel_sel),
        .mode_sel(mode_sel),
        .data_in(pmod_data_in),
        .cnt_loa(cnt_loa),
        .wr_addr(wr_addr),
        .wr_addr_cons(wr_addr_cons),
        .wr_data(wr_data),
        .wren(wr_en)
    );

    la_ram ram_la (
      .wr_data(wr_data),    // input [7:0]
      .wr_addr(wr_addr),    // input [14:0]
      .wr_en((wr_en && (cnt_loa == 2'd0))),        // input
      .wr_clk(clken),     // input
      .wr_rst(!act),      // input
      .rd_addr(rd_addr),    // input [14:0]
      .rd_data(la_data),    // output [7:0]
      .rd_clk(rd_clk),      // input
      .rd_rst(!rst_n)       // input
    );

    la_constant_ram ram_constant_la (
      .wr_data(wr_data),    // input [7:0]
      .wr_addr(wr_addr_cons),    // input [10:0]
      .wr_en((wr_en && (cnt_loa == 2'd1))),        // input
      .wr_clk(clken),      // input
      .wr_rst(!act),      // input
      .rd_addr(rd_addr_cons),    // input [10:0]
      .rd_data(la_data_cons),    // output [7:0]
      .rd_clk(rd_clk),      // input
      .rd_rst(!rst_n)       // input
    );

endmodule*/
module la_pmod_top(
    input clk_50M,
    input rst_n,
    input [3:0] channel_sel,
    input [7:0] pmod_data_in,
    input [14:0] rd_addr,
    input [10:0] rd_addr_cons,
    input rd_clk,
    input act,
    input [2:0] mode_sel,
    input [1:0] cnt_loa,
    output [7:0] la_data,
    output [7:0] la_data_cons,
    input [3:0] div_sel
   );
    wire clken;
    wire clk_ram;
    wire clk_addr;
    wire [14:0] wr_addr;
    wire [10:0] wr_addr_cons;
    wire [7:0] wr_data;
    wire wr_en;
    
   div_freq sample(
        .clk_50M(clk_50M),
        .rst_n(rst_n),
        .clken(clken),
        .sel(div_sel)
    );

    sample sample_inst(
        .clk_50M(clk_50M),
        .rst_n(rst_n),
        .clken(clken),
        .act(act),
        .channel_sel(channel_sel),
        .mode_sel(mode_sel),
        .data_in(pmod_data_in),
        .cnt_loa(cnt_loa),
        .wr_addr(wr_addr),
        .wr_addr_cons(wr_addr_cons),
        .wr_data(wr_data),
        .wren(wr_en)
    );
    
    wire wr_en_uart, rx_en, rx_finish;
    wire [7:0] wr_data_uart;
    wire [14:0] wr_addr_uart;
    wire wr_clk_uart;
    uart_rx u_uart_rx(
        .clk(clk_50M),
        .uart_rx(pmod_data_in[0]),
        .rst_n(rst_n),
        .en(act && cnt_loa == 2'd2),
        
        .rx_data(wr_data_uart),
        .wr_addr(wr_addr_uart),
        .wr_en(wr_en_uart),
        .rx_en(rx_en),
        .rx_finish(rx_finish) 
    );

    wire [7:0] rd_data_static;
    la_ram ram_la (
      .wr_data(wr_data),    // input [7:0]
      .wr_addr(wr_addr),    // input [14:0]
      .wr_en((wr_en && (cnt_loa == 2'd0))),        // input
      .wr_clk(clken),     // input
      .wr_rst(!act),      // input
      .rd_addr(rd_addr),    // input [14:0]
      .rd_data(rd_data_static),    // output [7:0]
      .rd_clk(rd_clk),      // input
      .rd_rst(!act)       // input
    );

    la_constant_ram ram_constant_la (
      .wr_data(wr_data),    // input [7:0]
      .wr_addr(wr_addr_cons),    // input [10:0]
      .wr_en((wr_en && (cnt_loa == 2'd1))),        // input
      .wr_clk(clken),      // input
      .wr_rst(!act),      // input
      .rd_addr(rd_addr_cons),    // input [10:0]
      .rd_data(la_data_cons),    // output [7:0]
      .rd_clk(rd_clk),      // input
      .rd_rst(!act)       // input
    );

    wire [7:0] rd_data_uart;
    uart_ram u_uart_ram(
        .wr_data(wr_data_uart),
        .wr_addr(wr_addr_uart),
        .wr_en(wr_en_uart && (cnt_loa == 2'd2)),   
        .wr_clk(clken),
        .wr_rst(!act),
        .rd_data(rd_data_uart),
        .rd_addr(rd_addr),
        .rd_clk(rd_clk),
        .rd_rst(!act)
    );
    assign la_data = {8{cnt_loa == 2'd0}} & rd_data_static
                    |{8{cnt_loa == 2'd2}} & rd_data_uart;

endmodule