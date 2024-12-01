module hdmi_dis_top(
    input wire        sys_clk       ,// input system clock 50MHz
    input             rst_n         ,//switch to idle menu
    //control signals
    input      [1:0]  cnt_level1    ,// rec choose
    input             level         ,// level flag:0-->menu;1-->sub_modules
    //sig_gen signals
    input      [10:0] sig_gen_cnt   ,// each sub_module's function:{cnt,cnt_l_r_sig,cnt_l_r_amp,cnt_l_r_fre,cnt_l_r_phase}
    //osc signals
    input             fft_confirm   ,
    input       [7:0] ad_data_in    ,
    input       [31:0]fft_data_in   ,
    input           fft_data_valid  ,
    input           [1:0] amp_choose,
    input           [1:0] fre_choose,
    output                   fft_clk,
    input                    ad_clk,
    //logic analyzer signals
    input        [11:0]       marker,//vertical mark line
    input        [7:0] rd_data_store,/*synthesis PAP_MARK_DEBUG="1"*/
    input        [7:0]  rd_data_cons,/*synthesis PAP_MARK_DEBUG="1"*/
    input                   mov_left, 
    input                  mov_right,
    output                    rd_clk,
    output       [14:0]      rd_addr,
    output       [10:0] rd_addr_cons,   
    input        [1:0]       cnt_loa,
    //hdmi chips' signals
    output            rstn_out      ,
    output            iic_tx_scl    ,
    inout             iic_tx_sda    ,
    output            led_int       ,
    //hdmi_out 
    output            vout_clk      ,//pixclk from pll                          
    output            vs_out        , 
    output            hs_out        , 
    output            de_out        ,
    output     [7:0]  r_out         , 
    output     [7:0]  g_out         , 
    output     [7:0]  b_out             
    );

    
//whole sig_gen and part of osc and logic_analyzer display module
    wire        pix_clk;
    wire        sig_gen_vs_out;
    wire        sig_gen_hs_out;
    wire        sig_gen_de_out;
    wire [23:0] sig_gen_rgb_out;
    //sig_gen and part of osc and logic analyzer display module
    hdmi_dis u_sig_hdmi(
    .sys_clk(sys_clk),
    .cnt_level1(cnt_level1),
    .level(level),
    .sig_gen_cnt(sig_gen_cnt),
    .fft_confirm(fft_confirm),
    .amp_choose(amp_choose),
    .rst_n(rst_n),

    .rstn_out(rstn_out),
    .iic_tx_scl( iic_tx_scl),
    .iic_tx_sda(iic_tx_sda),
    .led_int(led_int),

    .pix_clk(pix_clk),
    .vs_out(sig_gen_vs_out),
    .hs_out(sig_gen_hs_out),
    .de_out(sig_gen_de_out),
    .r_out(sig_gen_rgb_out[23:16]),
    .g_out(sig_gen_rgb_out[15:8]),
    .b_out(sig_gen_rgb_out[7:0]), 

    .fft_clk(fft_clk)
    );
    
    assign vout_clk=pix_clk;
    

//osc display part
    //osc output grid
grid_display grid_display_osc(
	.rst_n      (rst_n      ) ,                              
	.pclk       (pix_clk    ) ,                          
	.i_hs       (sig_gen_hs_out) ,                            
	.i_vs       (sig_gen_vs_out) ,                           
	.i_de       (sig_gen_de_out) ,                          
	.i_data     (sig_gen_rgb_out) ,
    .fft_confirm(fft_confirm) ,  
    .amp_choose (amp_choose)  ,                          
	.o_hs       (grid_hs_out) ,                          
	.o_vs       (grid_vs_out) ,                          
	.o_de       (grid_de_out) ,                          
	.o_data     (grid_data_out)                             
);

wire grid_vs_out ;
wire grid_hs_out ;
wire grid_de_out ;
wire [23:0]  grid_data_out ;

    //osc output wave
wav_display wav_display_osc(
	.rst_n         (rst_n        ) , 
    .clk_50M       (sys_clk      ) ,                                     
	.pclk          (pix_clk      ) ,                         
	.wave_color    (24'hff0000) ,// wave color                              
    .ad_clk        (ad_clk    ) ,                           
	.ad_data_in    (ad_data_in) ,                              
	.i_hs          (grid_hs_out   ) ,                        
	.i_vs          (grid_vs_out   ) ,                        
	.i_de          (grid_de_out   ) ,                        
	.i_data        (grid_data_out ) ,
    .oscen         ((level == 1'd1 && cnt_level1 == 2'd1)),
    .amp_choose    (amp_choose)     ,
    .fre_choose    (fre_choose)     ,                          
	.o_hs          (osc_hs_out1        ) ,                        
	.o_vs          (osc_vs_out1        ) ,                        
	.o_de          (osc_de_out1       ) ,                        
	.o_data        (osc_rgb_out1       )                          
);

wav_display_fft wav_display_fft(
	.rst_n         (rst_n        ) ,                                      
	.pclk          (pix_clk      ) ,                         
	.wave_color    (24'hff0000) ,// wave color                              
    .fft_clk        (fft_clk    ) ,                           
	.fft_data_in    (fft_data_in) ,                              
	.i_hs          (grid_hs_out   ) ,                        
	.i_vs          (grid_vs_out   ) ,                        
	.i_de          (grid_de_out   ) ,                        
	.i_data        (grid_data_out ) ,
    .fft_data_valid(fft_data_valid) ,                         
	.o_hs          (osc_hs_out2        ) ,                        
	.o_vs          (osc_vs_out2        ) ,                        
	.o_de          (osc_de_out2        ) ,                        
	.o_data        (osc_rgb_out2       )                          
);

    wire [23:0] osc_rgb_out;
    wire        osc_vs_out;
    wire        osc_hs_out;
    wire        osc_de_out;

    wire [23:0] osc_rgb_out1;
    wire        osc_vs_out1;
    wire        osc_hs_out1;
    wire        osc_de_out1;

    wire [23:0] osc_rgb_out2;
    wire        osc_vs_out2;
    wire        osc_hs_out2;
    wire        osc_de_out2;
    
    //choose time or fft wave to display
    assign osc_rgb_out= fft_confirm ? osc_rgb_out2 : osc_rgb_out1;
    assign osc_vs_out= fft_confirm ? osc_vs_out2 : osc_vs_out1;
    assign osc_hs_out= fft_confirm ? osc_hs_out2 : osc_hs_out1;
    assign osc_de_out= fft_confirm ? osc_de_out2 : osc_de_out1;

//logic analyzer display part

Logic_analyzer_dis LA_display(
	.rst_n        (rst_n      ) ,                              
	.pclk         (pix_clk    ) ,
    .clk_50M      (sys_clk    ) ,                          
	.i_hs         (sig_gen_hs_out) ,                            
	.i_vs         (sig_gen_vs_out) ,                           
	.i_de         (sig_gen_de_out) ,                          
	.rgb_data_in  (sig_gen_rgb_out),
    .marker       (marker) , 
    .rd_data_store(rd_data_store),
    .rd_data_cons (rd_data_cons),
    .mov_left     (mov_left),
    .mov_right    (mov_right),
    .cnt_loa      (cnt_loa),

    .rd_clk       (rd_clk),
    .rd_addr      (rd_addr),   
    .rd_addr_cons (rd_addr_cons),                        
	.o_hs         (la_hs_out) ,                          
	.o_vs         (la_vs_out) ,                          
	.o_de         (la_de_out) ,                          
	.rgb_data_out (la_rgb_out)                             
);  
    wire        la_hs_out;
    wire        la_vs_out;
    wire        la_de_out;
    wire [23:0] la_rgb_out;


//choose which type of signals to output
    assign vs_out = {level,cnt_level1} == 3'b101 ? osc_vs_out : ({level,cnt_level1} == 3'b110 ? la_vs_out : sig_gen_vs_out);
    assign hs_out = {level,cnt_level1} == 3'b101 ? osc_hs_out : ({level,cnt_level1} == 3'b110 ? la_hs_out : sig_gen_hs_out);
    assign de_out = {level,cnt_level1} == 3'b101 ? osc_de_out : ({level,cnt_level1} == 3'b110 ? la_de_out : sig_gen_de_out);
    assign {r_out, g_out, b_out} = {level,cnt_level1} == 3'b101 ? osc_rgb_out : ({level,cnt_level1} == 3'b110 ? la_rgb_out : sig_gen_rgb_out);

endmodule