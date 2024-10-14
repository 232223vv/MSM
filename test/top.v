`include "buttopn_debounde.v"
`include "sig_gen.v"

module top(
    input  wire clk_50M ,
    input  wire rst_n,

    
    input [7:0] key_in,

    output [7:0] da_data_out,
    output da_clk

    // //hdmi signals
    // output            rstn_out      ,
    // output            iic_tx_scl    ,
    // inout             iic_tx_sda    ,
    // output            led_int       ,

    // output            vout_clk      ,                         
    // output            vs_out        , 
    // output            hs_out        , 
    // output            de_out        ,
    // output      [7:0]  r_out        , 
    // output      [7:0]  g_out        , 
    // output      [7:0]  b_out   

    );

    //button setting 0-1-4-5-2-3
    wire left, right, confirm, quit, up, down;
    wire tx_left, tx_right, tx_confirm, tx_quit, tx_up, tx_down;

    buttopn_debounde 
    #(
    .delay(1000)
    )
    buttopn_debounde_left (
    .clk(clk_50M),
    .tx(key_in[0]),
    .reset(rst_n),
    .bd_tx(tx_left),
    .release_sign(left)
    );

    buttopn_debounde 
    #(
    .delay(1000)
    )
    buttopn_debounde_right (
    .clk(clk_50M),
    .tx(key_in[1]),
    .reset(rst_n),
    .bd_tx(tx_right),
    .release_sign(right)
    );

    buttopn_debounde 
    #(
    .delay(1000)
    )
    buttopn_debounde_confirm (
    .clk(clk_50M),
    .tx(key_in[4]),
    .reset(rst_n),
    .bd_tx(tx_confirm),
    .release_sign(confirm)
    );

    buttopn_debounde 
    #(
    .delay(1000)
    )
    buttopn_debounde_quit (
    .clk(clk_50M),
    .tx(key_in[5]),
    .reset(rst_n),
    .bd_tx(tx_quit),
    .release_sign(quit)
    );

    buttopn_debounde 
    #(
    .delay(1000)
    )
    buttopn_debounde_up (
    .clk(clk_50M),
    .tx(key_in[2]),
    .reset(rst_n),
    .bd_tx(tx_up),
    .release_sign(up)
    );

    buttopn_debounde 
    #(
    .delay(1000)
    )
    buttopn_debounde_down (
    .clk(clk_50M),
    .tx(key_in[3]),
    .reset(rst_n),
    .bd_tx(tx_down),
    .release_sign(down)
    );

    // control module
    localparam TOP = 2'D0, SIG = 2'D1, OSI = 2'D2, LoA = 2'D3;
    reg[1:0] cstate, nstate;
    reg level;

    always @(posedge clk_50M) begin
        if(!rst_n) begin
            nstate <= TOP;
            level <= 1'b0;
        end
        case(cstate)
            TOP: begin
                if(confirm) begin
                    if(cntlevel1 == 2'b00) begin
                        nstate <= SIG;
                        level <= 1'b1;
                    end
                    else if(cntlevel1 == 2'b01) begin
                        nstate <= OSI;
                        level <= 1'b1;
                    end
                    else if(cntlevel1 == 2'b10) begin
                        nstate <= LoA;
                        level <= 1'b1;
                    end
                    else begin
                        nstate <= nstate;
                    end
                end
                else begin
                    nstate <= nstate;
                    level <= 1'b0;
                end
            end
            SIG: begin
                if(quit) begin
                    nstate <= TOP;
                    level <= 1'b0;
                end
                else begin
                    nstate <= nstate;
                    level <= 1'b1;
                end
            end
            OSI: begin
                if(quit) begin
                    nstate <= TOP;
                    level <= 1'b0;
                end
                else begin
                    nstate <= nstate;
                    level <= 1'b1;
                end
            end
            LoA: begin
                if(quit) begin
                    nstate <= TOP;
                    level <= 1'b0;
                end
                else begin
                    nstate <= nstate;
                    level <= 1'b1;
                end
            end
            default: begin
                nstate <= TOP;
                level <= 1'b0;
            end
        endcase
    end

    always @( * ) begin
        if(!rst_n) begin
            cstate <= TOP;
        end
        else begin
            cstate <= nstate;
        end
    end

    reg[1:0] cntlevel1;

    // top
    always @(posedge clk_50M) begin
        if (!rst_n) begin
            cntlevel1 <= 2'b00;
        end
        else if(cstate == TOP) begin
                if(left) begin
                    if(cntlevel1 == 2'b00) begin
                        cntlevel1 <= 2'b10;
                    end
                    else begin
                        cntlevel1 <= cntlevel1 - 1'b1;
                    end
                end
                else if(right) begin
                    if(cntlevel1 == 2'b10) begin
                        cntlevel1 <= 2'b00;
                    end
                    else begin
                        cntlevel1 <= cntlevel1 + 1'b1;
                    end
                end
                else begin
                    cntlevel1 <= cntlevel1;
                end
        end
        else begin
            if(quit) begin
                cntlevel1 <= 2'b00;
            end
            else begin
                cntlevel1 <= cntlevel1;
            end
            
        end
    end

    reg[2:0] cntlevel2_sig;
    reg[1:0] cnt_wave, cnt_amp, cnt_fre, cnt_phaseORduty;
    reg confirm_done;
    // SIG_GEN 
    always @(posedge clk_50M) begin
        if (!rst_n) begin
            cntlevel2_sig <= 3'd0;
        end
        else if(cstate == SIG) begin
            if (up) begin
                if(cntlevel2_sig == 3'd0) begin
                    cntlevel2_sig <= 3'd4;
                end
                else begin
                    cntlevel2_sig <= cntlevel2_sig - 1'b1;
                end
            end
            else if(down) begin
                if(cntlevel2_sig == 3'd4) begin
                    cntlevel2_sig <= 3'd0;
                end
                else begin
                    cntlevel2_sig <= cntlevel2_sig + 1'b1;
                end
            end
            else begin
                cntlevel2_sig <= cntlevel2_sig;
            end
        end
        else begin
            cntlevel2_sig <= 3'd0;
        end    
    end

    always @(posedge clk_50M) begin
        if(!rst_n) begin
            cnt_wave <= 2'd0;
            cnt_amp <= 2'd0;
            cnt_fre <= 2'd0;
            cnt_phaseORduty <= 2'd0;
        end
        else if(cstate == SIG) begin
            case(cntlevel2_sig)
                3'd0: begin
                    if(left) begin
                        if(cnt_wave == 2'd0) begin
                            cnt_wave <= 2'd3;
                        end
                        else begin
                            cnt_wave <= cnt_wave - 1'd1;
                        end
                    end
                    else if(right) begin
                        if(cnt_wave == 2'd3) begin
                            cnt_wave <= 2'd0;
                        end
                        else begin
                            cnt_wave <= cnt_wave + 1'd1;
                        end
                    end
                    else begin
                        cnt_wave <= cnt_wave;
                    end
                end
                3'd1: begin
                    if(left) begin
                        if(cnt_amp == 2'd0) begin
                            cnt_amp <= 2'd3;
                        end
                        else begin
                            cnt_amp <= cnt_amp - 1'd1;
                        end
                    end
                    else if(right) begin
                        if(cnt_amp == 2'd3) begin
                            cnt_amp <= 2'd0;
                        end
                        else begin
                            cnt_amp <= cnt_amp + 1'd1;
                        end
                    end
                    else begin
                        cnt_amp <= cnt_amp;
                    end
                end
                3'd2: begin
                    if(left) begin
                        if(cnt_fre == 2'd0) begin
                            cnt_fre <= 2'd3;
                        end
                        else begin
                            cnt_fre <= cnt_fre - 1'd1;
                        end
                    end
                    else if(right) begin
                        if(cnt_fre == 2'd3) begin
                            cnt_fre <= 2'd0;
                        end
                        else begin
                            cnt_fre <= cnt_fre + 1'd1;
                        end
                    end
                    else begin
                        cnt_fre <= cnt_fre;
                    end
                end
                3'd3: begin
                    if(left) begin
                        if(cnt_phaseORduty == 2'd0) begin
                            cnt_phaseORduty <= 2'd3;
                        end
                        else begin
                            cnt_phaseORduty <= cnt_phaseORduty - 1'd1;
                        end
                    end
                    else if(right) begin
                        if(cnt_phaseORduty == 2'd3) begin
                            cnt_phaseORduty <= 2'd0;
                        end
                        else begin
                            cnt_phaseORduty <= cnt_phaseORduty + 1'd1;
                        end
                    end
                    else begin
                        cnt_phaseORduty <= cnt_phaseORduty;
                    end
                end
                default: begin
                    cnt_wave <= cnt_wave;
                    cnt_amp <= cnt_amp;
                    cnt_fre <= cnt_fre;
                    cnt_phaseORduty <= cnt_phaseORduty;
                end
            endcase
        end
        else begin
            cnt_wave <= 2'd0;
            cnt_amp <= 2'd0;
            cnt_fre <= 2'd0;
            cnt_phaseORduty <= 2'd0;
        end
    end

    always @(posedge clk_50M) begin
        if(!rst_n) begin
            confirm_done <= 1'b0;
        end
        else if(cstate == SIG) begin
            if(!confirm_done && cntlevel2_sig==3'd4 && confirm) begin
                confirm_done <= 1'b1;
            end
            else if(quit) begin
                confirm_done <= 1'b0;
            end
            else begin
                confirm_done <= confirm_done;
            end
        end
        else begin
            confirm_done <= 1'b0;
        end
    end

    sig_gen u_sig_gen(
        .clk(clk_50M),
        .rst_n(rst_n),

        .cnt_sig(cnt_wave),
        .cnt_amp(cnt_amp),
        .cnt_fre(cnt_fre),
        .cnt_phase(cnt_phaseORduty),
        .confirm(confirm_done),

        .data_out(da_data_out),
        .da_clk(da_clk)
    );


    // wire        pix_clk;
    // wire [23:0] sig_gen_rgb_out;
    // wire        sig_gen_vs_out;
    // wire        sig_gen_hs_out;
    // wire        sig_gen_de_out;
    
    // hdmi_dis u_sig_hdmi(
    // .sys_clk(clk_50M),
    // .cnt_level1(cntlevel1),
    // .level(level),
    // .sig_gen_cnt({cntlevel2_sig, cnt_wave, cnt_amp, cnt_fre, cnt_phaseORduty}),
    // .rst_n(rst_n),

    // .rstn_out(rstn_out),
    // .iic_tx_scl( iic_tx_scl),
    // .iic_tx_sda(iic_tx_sda),
    // .led_int(led_int),

    // .pix_clk(pix_clk),
    // .vs_out(sig_gen_vs_out),
    // .hs_out(sig_gen_hs_out),
    // .de_out(sig_gen_de_out),
    // .r_out(sig_gen_rgb_out[23:16]),
    // .g_out(sig_gen_rgb_out[15:8]),
    // .b_out(sig_gen_rgb_out[7:0])   
    // );

    // assign vout_clk=pix_clk;
    // assign vs_out=sig_gen_vs_out;
    // assign hs_out=sig_gen_hs_out;
    // assign de_out=sig_gen_de_out;
    // assign {r_out,g_out,b_out}=sig_gen_rgb_out;
endmodule