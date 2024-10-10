`timescale 1ns/1ns
`include "top.v"

module top_TB();

reg clk_50M, rst_n;
reg[7:0] key_in;

top u_top(
    .clk_50M(clk_50M),
    .rst_n(rst_n),
    .key_in(key_in),
);

initial begin
    $dumpfile("hahaha.vcd");
    $dumpvars;
    #5000000 $finish;
end

initial begin
    forever #10 clk_50M = ~clk_50M;
end

initial begin
    clk_50M = 1'b0;
    rst_n = 1'b1;
    key_in = 8'b1111_1111;

    #5 rst_n = 1'b0;
    #20 rst_n = 1'b1;

    #30000 key_in[0] = 1'b0;
    #30000 key_in[0] = 1'b1;
    #30000 key_in[0] = 1'b0;
    #30000 key_in[0] = 1'b1;
    #30000 key_in[0] = 1'b0;
    #30000 key_in[0] = 1'b1;

    #30000 key_in[4] = 1'b0;
    #30000 key_in[4] = 1'b1;

    #30000 key_in[0] = 1'b0;
    #30000 key_in[0] = 1'b1;
    #30000 key_in[0] = 1'b0;
    #30000 key_in[0] = 1'b1;

    #30000 key_in[3] = 1'b0;
    #30000 key_in[3] = 1'b1;
    #30000 key_in[0] = 1'b0;
    #30000 key_in[0] = 1'b1;

    #30000 key_in[3] = 1'b0;
    #30000 key_in[3] = 1'b1;
    #30000 key_in[0] = 1'b0;
    #30000 key_in[0] = 1'b1;

    #30000 key_in[3] = 1'b0;
    #30000 key_in[3] = 1'b1;
    #30000 key_in[0] = 1'b0;
    #30000 key_in[0] = 1'b1;

    #30000 key_in[3] = 1'b0;
    #30000 key_in[3] = 1'b1;

    #30000 key_in[4] = 1'b0;
    #30000 key_in[4] = 1'b1;

    #30000 key_in[5] = 1'b0;
    #30000 key_in[5] = 1'b1;


    #30000 key_in[0] = 1'b0;
    #30000 key_in[0] = 1'b1;
    #30000 key_in[0] = 1'b0;
    #30000 key_in[0] = 1'b1;
    #30000 key_in[0] = 1'b0;
    #30000 key_in[0] = 1'b1;

    #30000 key_in[4] = 1'b0;
    #30000 key_in[4] = 1'b1;

    #30000 key_in[0] = 1'b0;
    #30000 key_in[0] = 1'b1;
    #30000 key_in[0] = 1'b0;
    #30000 key_in[0] = 1'b1;

    #30000 key_in[3] = 1'b0;
    #30000 key_in[3] = 1'b1;
    #30000 key_in[0] = 1'b0;
    #30000 key_in[0] = 1'b1;

    #30000 key_in[3] = 1'b0;
    #30000 key_in[3] = 1'b1;
    #30000 key_in[0] = 1'b0;
    #30000 key_in[0] = 1'b1;

    #30000 key_in[3] = 1'b0;
    #30000 key_in[3] = 1'b1;
    #30000 key_in[0] = 1'b0;
    #30000 key_in[0] = 1'b1;

    #30000 key_in[3] = 1'b0;
    #30000 key_in[3] = 1'b1;

    #30000 key_in[4] = 1'b0;
    #30000 key_in[4] = 1'b1;

    #30000 key_in[5] = 1'b0;
    #30000 key_in[5] = 1'b1;



end



endmodule;