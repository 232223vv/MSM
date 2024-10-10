// Created by IP Generator (Version 2022.1 build 99559)



//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
//
// Library:
// Filename:ipm_distributed_rom_v1_3_cos_gen.v
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps
module ipm_distributed_rom_v1_3_cos_gen #(
    parameter  ADDR_WIDTH                  = 4       , //address width   range:4-10
    parameter  DATA_WIDTH                  = 4       , //data width      range:1-256
    parameter  RST_TYPE                    = "ASYNC" , //reset type   "ASYNC" "SYNC"
    parameter  OUT_REG                     = 0       , //output options :non_register(0)  register(1)
    parameter  INIT_FILE                   = "NONE"  , //legal value:"NONE" or "initial file name"
    parameter  FILE_FORMAT                 = "BIN"     //initial data format : "BIN" or "HEX"
)(
    output   wire   [DATA_WIDTH-1:0]       rd_data   ,
    input    wire   [ADDR_WIDTH-1:0]       addr      ,
    input    wire                          rst       ,
    input    wire                          clk
)/* synthesis syn_romstyle = "select_rom" */;

reg     [DATA_WIDTH-1:0]    mem [2**ADDR_WIDTH-1:0];
wire    [DATA_WIDTH-1:0]    q      ;
reg     [DATA_WIDTH-1:0]    q_reg  ;

//initialize rom
generate
    integer i,j;
    if (INIT_FILE != "NONE") begin
        if (FILE_FORMAT == "BIN") begin
            initial begin
                $readmemb(INIT_FILE,mem);
            end
        end
        else if (FILE_FORMAT == "HEX") begin
            initial begin
                $readmemh(INIT_FILE,mem);
            end
        end
    end
    else begin
        initial begin
            for (i=0;i<2**ADDR_WIDTH;i=i+1) begin
                for (j=0;j<DATA_WIDTH;j=j+1) begin
                    mem[i][j] = 1'b0;
                end
            end
        end
    end
endgenerate

//read rom
generate
    assign q = mem[addr];

    if (RST_TYPE == "ASYNC") begin
        always@(posedge clk or posedge rst)
        begin
            if(rst)
                q_reg <= {DATA_WIDTH{1'b0}};
            else
                q_reg <= q;
        end
    end
    else if (RST_TYPE == "SYNC") begin
        always@(posedge clk)
        begin
            if(rst)
                q_reg <= {DATA_WIDTH{1'b0}};
            else
                q_reg <= q;
        end
    end
endgenerate

assign rd_data = (OUT_REG == 1) ? q_reg : q;

endmodule
