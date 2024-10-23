module top(
    input  wire clk_50M ,
    input  wire rst_n,

    
    input [7:0] key_in,

     // ad_da module
    input [7:0] ad_data_in,
    output [7:0] da_data_out,
    output da_clk,
    output ad_clk,

    //hdmi signals
    output            rstn_out      ,
    output            iic_tx_scl    ,
    inout             iic_tx_sda    ,
    output            led_int       ,

    output            vout_clk      ,                         
    output            vs_out        , 
    output            hs_out        , 
    output            de_out        ,
    output      [7:0]  r_out        , 
    output      [7:0]  g_out        , 
    output      [7:0]  b_out   

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

         // OSI
    reg fft_confirm;
    always @(posedge clk_50M) begin
        if(!rst_n) begin
            fft_confirm <= 1'b0;
        end
        else if(cstate == OSI) begin
            if(confirm) begin
                fft_confirm <= 1'b1;
            end
            else begin
                fft_confirm <= fft_confirm;
            end
        end
        else begin
            fft_confirm <= 1'b0;
        end
    end

    reg [1:0] vertical_zoom, horizontal_zoom;
    always @(posedge clk_50M) begin
        if(!rst_n) begin
            vertical_zoom <= 2'd0;
            horizontal_zoom <= 2'd0;
        end
        else if((cstate == OSI) && !fft_confirm) begin
            if(up) begin
                if(vertical_zoom == 2'd2) begin
                    vertical_zoom <= 2'd0;
                end
                else begin
                    vertical_zoom <= vertical_zoom + 1'd1;
                end
            end
            else if(down) begin
                if(vertical_zoom == 2'd0) begin
                    vertical_zoom <= 2'd2;
                end
                else begin
                    vertical_zoom <= vertical_zoom - 1'd1;
                end         
            end
            else begin
                vertical_zoom <= vertical_zoom;
            end
                
            if(left) begin
                if(horizontal_zoom == 2'd0) begin
                    horizontal_zoom <= 2'd2;
                end
                else begin
                    horizontal_zoom <= horizontal_zoom - 1'd1;
                end
            end
            else if(right) begin
                if(horizontal_zoom == 2'd2) begin
                    horizontal_zoom <= 2'd0;
                end
                else begin
                    horizontal_zoom <= horizontal_zoom + 1'd1;
                end    
            end
            else begin
                horizontal_zoom <= horizontal_zoom;
            end
        end
        else begin
            vertical_zoom <= 2'd0;
            horizontal_zoom <= 2'd0;
        end
    end

    reg loa_left, loa_right, loa_pause;
    always @(posedge clk_50M) begin
        if(rst_n) begin
            loa_pause <= 1'd0;
        end
        else if(cstate == LoA) begin
            if(confirm) begin
                if(loa_pause == 1'd0) begin
                    loa_pause <= 1'd1;
                end
                else begin
                    loa_pause <= 1'd0;
                end
            end
            else begin
                loa_pause <= loa_pause;
            end
        end
        else begin
            loa_pause <= 1'd0;
        end
    end

    always @(posedge clk_50M) begin
        if(!rst_n) begin
            loa_left <= 1'd0;
        end
        else if ((cstate == LoA) && loa_pause) begin
            loa_left <= up;
        end
        else begin
            loa_left <= 1'd0;
        end
    end

    always @(posedge clk_50M) begin
        if(!rst_n) begin
            loa_right <= 1'd0;
        end
        else if ((cstate == LoA) && loa_pause) begin
            loa_right <= down;
        end
        else begin
            loa_right <= 1'd0;
        end
    end

    reg [11:0] loa_refline_x;
    always @(posedge clk_50M) begin
        if(!rst_n) begin
            loa_refline_x <= 12'd0;
        end
        else if(cstate == LoA) begin
            if(left) begin
                if(loa_refline_x == 12'd0) begin
                  loa_refline_x <= 12'd1400;
                end
                else begin
                    loa_refline_x <= loa_refline_x - 12'd70;
                end
            end
            else if(right) begin
                if(loa_refline_x == 12'd1400) begin
                    loa_refline_x <= 12'd0;
                end
                else begin
                    loa_refline_x <= loa_refline_x + 12'd70;
                end
            end
            else begin
                loa_refline_x <= loa_refline_x;
            end
        end
        else begin
            loa_refline_x <= 12'd0;
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

     wire fft_clk;
     wire [31:0] fft_data;
     wire fft_data_valid;
     oscilloscope_top u_oscilloscope(
         .clk(clk_50M),
         .oscilloscope_en((cnt_level1==2'b01 && level==1'b1)),
         .fft_en(fft_confirm),
         .rst_n(rst_n),
         .ad_data_in(ad_data_in),
         .fft_data_valid(fft_data_valid),
         //.ad_data(),
         .fft_clk(fft_clk),
         .fft_data(fft_data),
         .ad_clk(ad_clk)
     );
    
        

    //hdmi display module
    hdmi_dis_top hdmi_display(
    //input
    .sys_clk(clk_50M),
    .rst_n(rst_n),

    .cnt_level1(cntlevel1),
    .level(level),

    .sig_gen_cnt({cntlevel2_sig, cnt_wave, cnt_amp, cnt_fre, cnt_phaseORduty}),

    .fft_confirm(fft_confirm),
    .ad_clk(ad_clk),
    .ad_data_in(ad_data_in),
    .fft_clk(fft_clk),
    .fft_data_in(fft_data),
    .fft_data_valid(fft_data_valid),
    .amp_choose(vertical_zoom),
    .fre_choose(horizontal_zoom),
    
    
    //output
    .rstn_out(rstn_out),
    .iic_tx_scl( iic_tx_scl),
    .iic_tx_sda(iic_tx_sda),
    .led_int(led_int),

    .vout_clk(vout_clk),
    .vs_out(vs_out),
    .hs_out(hs_out),
    .de_out(de_out),
    .r_out(r_out),
    .g_out(g_out),
    .b_out(b_out)   
    );
  
endmodule