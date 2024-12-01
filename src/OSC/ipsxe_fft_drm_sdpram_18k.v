// Created by IP Generator (Version 2022.1-SP2 build 109751)


//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
// Library:
// Filename:ipsxe_fft_drm_sdpram_18k.v
//////////////////////////////////////////////////////////////////////////////

module ipsxe_fft_drm_sdpram_18k (
    wr_data        , //input write data
    wr_addr        , //input write address
    wr_en          , //input write enable
    wr_clk         , //input write clock
    

    wr_clk_en      , //input write clock enable
    
    wr_rst         , //input write reset
    
    rd_data        , //output read data
    rd_addr        , //input read address
    rd_clk         , //input read clock
    
    rd_clk_en      , //input read clock enable
    
    rd_oce         , //input read output register enable
    
    rd_rst           //input read reset
);


localparam CAS_MODE = "18K" ; // @IPC enum 18K,36K,64K

localparam POWER_OPT = 0 ; // @IPC bool

localparam RESET_TYPE = "ASYNC" ; // @IPC enum SYNC,ASYNC

localparam SAMEWIDTH_EN = 1 ; // @IPC bool

localparam WR_BYTE_EN = 0 ; // @IPC bool

localparam BYTE_SIZE = 8 ; // @IPC enum 8,9

parameter  WR_ADDR_WIDTH = 9 ; // @IPC int 9,20

parameter  WR_DATA_WIDTH = 36 ; // @IPC int 1,1152

localparam BE_WIDTH = 1 ; // @IPC int 2,128

localparam WR_CLK_EN = 1 ; // @IPC bool

localparam WR_ADDR_STROBE_EN = 0 ; // @IPC bool

parameter  RD_ADDR_WIDTH = 9 ; // @IPC int 9,20

parameter  RD_DATA_WIDTH = 36 ; // @IPC int 1,1152

localparam RD_BE_WIDTH = 1 ; // @IPC int 2,128

localparam RD_CLK_EN = 1 ; // @IPC bool

localparam RD_ADDR_STROBE_EN = 0 ; // @IPC bool

localparam OUTPUT_REG = 0 ; // @IPC bool

localparam RD_OCE_EN = 1 ; // @IPC bool

localparam RD_CLK_OR_POL_INV = 0 ; // @IPC bool

localparam FAB_REG = 1 ; // @IPC bool

localparam INIT_EN = 0 ; // @IPC bool

localparam INIT_FILE = "NONE" ; // @IPC string

localparam INIT_FORMAT = "BIN" ; // @IPC enum BIN,HEX

localparam RST_VAL_EN = 0 ; // @IPC bool


input  [WR_DATA_WIDTH-1:0]    wr_data        ; //input write data    [WR_DATA_WIDTH-1:0]
input  [WR_ADDR_WIDTH-1:0]    wr_addr        ; //input write address [WR_ADDR_WIDTH-1:0]
input                         wr_en          ; //input write enable
input                         wr_clk         ; //input write clock

input                         wr_clk_en      ; //input write clock enable

input                         wr_rst         ; //input write reset

output [RD_DATA_WIDTH-1:0]    rd_data        ; //output read data    [C_RD_DATA_WIDTH-1:0]
input  [RD_ADDR_WIDTH-1:0]    rd_addr        ; //input read address [RD_ADDR_WIDTH-1:0]
input                         rd_clk         ; //input read clock 

input                         rd_clk_en      ; //input read clock enable

input                         rd_rst         ; //input read reset

input                         rd_oce         ; //input read output register enable


wire  [WR_DATA_WIDTH-1:0]     wr_data        ; //input write data    [WR_DATA_WIDTH-1:0]
wire  [WR_ADDR_WIDTH-1:0]     wr_addr        ; //input write address [WR_ADDR_WIDTH-1:0]
wire                          wr_en          ; //input write enable
wire                          wr_clk         ; //input write clock
wire                          wr_clk_en      ; //input write clock enable
wire                          wr_rst         ; //input write reset
wire  [BE_WIDTH-1:0]          wr_byte_en     ; //input write reset
wire                          wr_addr_strobe ; //input write address string
wire  [RD_DATA_WIDTH-1:0]     rd_data        ; //output read data    [C_RD_DATA_WIDTH-1:0]
wire  [RD_ADDR_WIDTH-1:0]     rd_addr        ; //input read address [RD_ADDR_WIDTH-1:0]
wire                          rd_clk         ; //input read clock 
wire                          rd_clk_en      ; //input read clock enable
wire                          rd_rst         ; //input read reset
wire                          rd_oce         ; //input read output register enable
wire                          rd_addr_strobe ; //input read address string

wire  [BE_WIDTH-1:0]          wr_byte_en_mux     ;
wire                          rd_oce_mux2d       ;
wire                          rd_oce_mux2f       ;
wire                          wr_clk_en_mux      ;
wire                          rd_clk_en_mux      ;
wire                          wr_addr_strobe_mux ;
wire                          rd_addr_strobe_mux ;

wire [RD_DATA_WIDTH-1 : 0]    rd_data_d;
reg  [RD_DATA_WIDTH-1 : 0]    fab_reg_invt;
reg  [RD_DATA_WIDTH-1 : 0]    fab_reg;


assign wr_byte_en_mux      = (WR_BYTE_EN == 1) ? wr_byte_en : {BE_WIDTH{1'b1}}  ;
assign rd_oce_mux2d        = ((FAB_REG       == 1) && (OUTPUT_REG == 1)) ? 1 :
                              (OUTPUT_REG    == 1) ? ((RD_OCE_EN  == 1)  ? rd_oce : 1'b1) : 1'b0 ;
assign rd_oce_mux2f        =  (FAB_REG       == 1) ? ((RD_OCE_EN  == 1)  ? rd_oce : 1'b1) : 1'b0 ;
assign wr_clk_en_mux       = (WR_CLK_EN  == 1) ? wr_clk_en  : 1'b1 ;
assign rd_clk_en_mux       = (RD_CLK_EN  == 1) ? rd_clk_en  : 1'b1 ;
assign wr_addr_strobe_mux  = (WR_ADDR_STROBE_EN ==1) ? wr_addr_strobe : 1'b0 ;
assign rd_addr_strobe_mux  = (RD_ADDR_STROBE_EN ==1) ? rd_addr_strobe : 1'b0 ;

ipsxe_fft_drm_sdpram_v1_6a_18k #(
    .c_CAS_MODE             (CAS_MODE               ),
    .c_WR_ADDR_WIDTH        (WR_ADDR_WIDTH          ),
    .c_WR_DATA_WIDTH        (WR_DATA_WIDTH          ),
    .c_RD_ADDR_WIDTH        (RD_ADDR_WIDTH          ),
    .c_RD_DATA_WIDTH        (RD_DATA_WIDTH          ),
    .c_OUTPUT_REG           (OUTPUT_REG             ),
    .c_RD_OCE_EN            (RD_OCE_EN              ),
    .c_FAB_REG              (FAB_REG                ),
    .c_WR_ADDR_STROBE_EN    (WR_ADDR_STROBE_EN      ),
    .c_RD_ADDR_STROBE_EN    (RD_ADDR_STROBE_EN      ),
    .c_WR_CLK_EN            (WR_CLK_EN              ),
    .c_RD_CLK_EN            (RD_CLK_EN              ),
    .c_RD_CLK_OR_POL_INV    (RD_CLK_OR_POL_INV      ),
    .c_RESET_TYPE           (RESET_TYPE             ),
    .c_POWER_OPT            (POWER_OPT              ),
    .c_INIT_FILE            ("NONE"                 ),
    .c_INIT_FORMAT          (INIT_FORMAT            ),
    .c_WR_BYTE_EN           (WR_BYTE_EN             ),
    .c_BE_WIDTH             (BE_WIDTH               )
) U_drm_sdpram_18k (
    .wr_data                (wr_data                ),
    .wr_addr                (wr_addr                ),
    .wr_en                  (wr_en                  ),
    .wr_clk                 (wr_clk                 ),
    .wr_clk_en              (wr_clk_en_mux          ),
    .wr_rst                 (wr_rst                 ),
    .wr_byte_en             (wr_byte_en_mux         ),
    .wr_addr_strobe         (wr_addr_strobe_mux     ),

    
    .rd_data                ( rd_data_d             ),
    
    .rd_addr                (rd_addr                ),
    .rd_clk                 (rd_clk                 ),
    .rd_clk_en              (rd_clk_en_mux          ),
    .rd_rst                 (rd_rst                 ),
    .rd_oce                 (rd_oce_mux2d           ),
    .rd_addr_strobe         (rd_addr_strobe_mux     ) 
);


generate
    if (FAB_REG == 1) begin

        assign rd_data = (FAB_REG == 1) ? ((RD_CLK_OR_POL_INV == 1) ? fab_reg_invt : fab_reg) : rd_data_d ;
        if (RD_CLK_OR_POL_INV == 1) begin
            always @(negedge rd_clk or posedge rd_rst) begin
                if (rd_rst)
                    fab_reg_invt      <= {RD_DATA_WIDTH{1'b0}};
                else if (rd_oce_mux2f)
                    fab_reg_invt      <= rd_data_d;                    
            end
        end
        else begin
            always @(posedge rd_clk or posedge rd_rst) begin
                if (rd_rst)
                    fab_reg           <= {RD_DATA_WIDTH{1'b0}};
                else if (rd_oce_mux2f)
                    fab_reg           <= rd_data_d;
            end
        end
    end
endgenerate

endmodule
