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
// Filename:TB cos_gen_tb.v
//////////////////////////////////////////////////////////////////////////////

`timescale   1ns / 1ps

module  cos_gen_tb ();
    localparam T_CLK_PERIOD = 10  ;       //clock a half perid
    localparam T_RST_TIME   = 200 ;       //reset time

    localparam ADDR_WIDTH   = 10 ; //@IPC int 4,10

    localparam DATA_WIDTH   = 8 ; //@IPC int 1,256

    localparam RST_TYPE     = "ASYNC" ; //@IPC enum ASYNC,SYNC

    localparam OUT_REG      = 0 ; //@IPC bool

    localparam INIT_ENABLE  = 1 ; //@IPC bool

    localparam INIT_FILE    = "C:/Users/86150/Desktop/MSM/cos_1024hex.dat" ; //@IPC string

    localparam FILE_FORMAT  = "HEX" ; //@IPC enum BIN,HEX



// variable declaration
    reg                         clk_tb        ;
    reg                         tb_rst        ;
    reg     [ADDR_WIDTH-1:0]    tb_addr       ;
    reg     [DATA_WIDTH-1:0]    exp_rddata    ;
    reg     [DATA_WIDTH-1:0]    exp_rddata_ff ;
    wire    [DATA_WIDTH-1:0]    tb_rddata     ;
    reg                         check_err     ;
    reg     [2:0]               results_cnt   ;
//********************************************************* CGU ********************************************************************************
//generate clk_tb
initial begin
    clk_tb = 0;
    forever #(T_CLK_PERIOD/2)  clk_tb = ~clk_tb;
end

//********************************************************* DGU ********************************************************************************

initial begin
    tb_addr     = 0;
    tb_rst      = 1;
    #T_RST_TIME    ;
    tb_rst      = 0;
    #10             ;
    if(INIT_FILE == "NONE") begin
        $display("reading rom");
        read_rom;
        #10;
        $display("rom Simulation done");
    end
    else begin
        $display("reading initialized rom");
        read_rom;
        #10;
        $display("rom Simulation done");
    end
    if (|results_cnt)
        $display("Simulation Failed due to Error Found.") ;
    else
        $display("Simulation Success.") ;
    #500 ;
    $finish ;
end

//***************************************************************** DUT  INST **************************************************************************************
always@(*)begin
    if (DATA_WIDTH >= ADDR_WIDTH)
        exp_rddata = {{(DATA_WIDTH-ADDR_WIDTH){1'b0}},tb_addr};
    else
        exp_rddata = tb_addr[DATA_WIDTH-1 : 0];
end

always@(posedge clk_tb or posedge tb_rst)begin
    if (tb_rst)
        exp_rddata_ff <= 0;
    else
        exp_rddata_ff <= exp_rddata;
end

always@(posedge clk_tb or posedge tb_rst) begin
    if(tb_rst)
        check_err <=0;
    else if(INIT_FILE == "NONE")
        check_err <=(tb_rddata != 0);
    else begin
        if (OUT_REG == 0)
            check_err <= (tb_rddata != exp_rddata);
        else
            check_err <= (tb_rddata != exp_rddata_ff);
    end
end

always @(posedge clk_tb or posedge tb_rst)
begin
    if (tb_rst)
        results_cnt <= 3'b000 ;
    else if (&results_cnt)
        results_cnt <= 3'b100 ;
    else if (check_err)
        results_cnt <= results_cnt + 3'd1 ;
end

integer  result_fid;
initial begin
     result_fid = $fopen ("sim_results.log","a");
     $fmonitor(result_fid,"err_chk=%b",check_err);
end

GTP_GRS GRS_INST(
    .GRS_N(1'b1)
);
cos_gen  U_cos_gen (
    .addr        (tb_addr   ),         //input  wire [`T_A_ADDR_WIDTH-1 : 0]
    .rst         (tb_rst    ),         //input  wire
    .clk         (clk_tb    ),
    .rd_data     (tb_rddata )          //output wire [`T_A_DATA_WIDTH-1 : 0]
);

//********************************************************* task ********************************************************************************

task read_rom;
    integer  init_fid;
    integer  i;
    begin
        i = 0;
        tb_addr = 0;
        init_fid = $fopen ("init_results.dat","a");
        while (i < 2**ADDR_WIDTH )
        begin
            @(negedge clk_tb);
            tb_addr = tb_addr + 1'b1;
            i       = i + 1'b1;
            $fmonitor(init_fid,"%b",tb_rddata);
        end
    end
endtask

endmodule

