module hdmi_dis_top(
    input wire        sys_clk       ,// input system clock 50MHz
    input      [1:0]  cnt_level1    ,// rec choose
    input             level         ,// level flag:0-->menu;1-->sub_modules
    input      [10:0] sig_gen_cnt   ,// each sub_module's function:{cnt,cnt_l_r_sig,cnt_l_r_amp,cnt_l_r_fre,cnt_l_r_phase}
    input             fft_confirm   ,
    input             rst_n         ,//switch to idle menu
        
    output            rstn_out      ,
    output            iic_tx_scl    ,
    inout             iic_tx_sda    ,
    output            led_int       ,
//hdmi_out 
    output            vout_clk       ,//pixclk from pll                          
    output            vs_out        , 
    output            hs_out        , 
    output            de_out        ,
    output     [7:0]  r_out        , 
    output     [7:0]  g_out        , 
    output     [7:0]  b_out 

    );

    

    wire        pix_clk;
    wire        sig_gen_vs_out;
    wire        sig_gen_hs_out;
    wire        sig_gen_de_out;
    wire [23:0] sig_gen_rgb_out;
    
    hdmi_dis u_sig_hdmi(
    .sys_clk(sys_clk),
    .cnt_level1(cnt_level1),
    .level(level),
    .sig_gen_cnt(sig_gen_cnt),
    .fft_confirm(fft_confirm),
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
    .b_out(sig_gen_rgb_out[7:0])   
    );
    
    assign vout_clk=pix_clk;
    /*assign vs_out=sig_gen_vs_out;
    assign hs_out=sig_gen_hs_out;
    assign de_out=sig_gen_de_out;
    assign {r_out,g_out,b_out}=sig_gen_rgb_out;*/


    //osc output grid
grid_display grid_display_1(
	.rst_n      (rst_n      ) ,                              
	.pclk       (pix_clk    ) ,                          
	.i_hs       (sig_gen_hs_out) ,                            
	.i_vs       (sig_gen_vs_out) ,                           
	.i_de       (sig_gen_de_out) ,                          
	.i_data     (sig_gen_rgb_out) ,                            
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
wav_display wav_display_1(
	.rst_n         (rst_n        ) ,                                      
	.pclk          (pix_clk      ) ,                         
	.wave_color    (24'hff0000) ,// wave color                              
   .ad_clk        (ad_clk    ) ,                           
	.ad_data_in    (ad_data_in) ,                              
	.i_hs          (grid_hs_out   ) ,                        
	.i_vs          (grid_vs_out   ) ,                        
	.i_de          (grid_de_out   ) ,                        
	.i_data        (grid_data_out ) ,                          
	.o_hs          (osc_hs_out        ) ,                        
	.o_vs          (osc_vs_out        ) ,                        
	.o_de          (osc_de_out        ) ,                        
	.o_data        (osc_rgb_out       )                          
);

    wire [23:0] osc_rgb_out;
    wire        osc_vs_out;
    wire        osc_hs_out;
    wire        osc_de_out;
    
    /*//choose which hdmi_data to output        
    always @(*)
    begin
        case(cnt)
        2'b00://sig_gen's rgb_data
        begin
            vs_out=sig_gen_vs_out;
            hs_out=sig_gen_hs_out;
            de_out=sig_gen_de_out;
            {r_out,g_out,b_out}=sig_gen_rgb_out;
        end
        2'b01://osc's rgb_data
        begin
            vs_out=osc_vs_out;
            hs_out=osc_hs_out;
            de_out=osc_de_out;
            {r_out,g_out,b_out}=osc_rgb_out;
        end
        default:
        begin
            vs_out=sig_gen_vs_out;
            hs_out=sig_gen_hs_out;
            de_out=sig_gen_de_out;
            {r_out,g_out,b_out}=sig_gen_rgb_out;
        end
        endcase
    end*/

    //choose which hdmi_data to output
    /*assign vs_out = ({level,cntlevel1} == 3'b000|| {level,cntlevel1}==3'b001 || {level,cntlevel1}==3'b010) ? sig_gen_vs_out :
                    ({level,cntlevel1} == 3'b010) ? osc_vs_out :
                                     sig_gen_vs_out; // default case
    assign vs_out = ({level,cntlevel1} == 3'b101 ? osc_vs_out : sig_gen_vs_out; // default case

    assign hs_out = ({level,cntlevel1} == 3'b000|| {level,cntlevel1}==3'b001) ? sig_gen_hs_out :
                    ({level,cntlevel1} == 3'b010) ? osc_hs_out :
                                     sig_gen_hs_out; // default case

    assign de_out = ({level,cntlevel1} == 3'b000|| {level,cntlevel1}==3'b001) ? sig_gen_de_out :
                    ({level,cntlevel1} == 3'b010) ? osc_de_out :
                                     sig_gen_de_out; // default case

    assign {r_out, g_out, b_out} = ({level,cntlevel1} == 3'b000|| {level,cntlevel1}==3'b001) ? sig_gen_rgb_out :
                                   ({level,cntlevel1} == 3'b010) ? osc_rgb_out :
                                                    sig_gen_rgb_out; // default case*/

    assign vs_out = {level,cnt_level1} == 3'b101 ? osc_vs_out : sig_gen_vs_out;
    assign hs_out = {level,cnt_level1} == 3'b101 ? osc_hs_out : sig_gen_hs_out;
    assign de_out = {level,cnt_level1} == 3'b101 ? osc_de_out : sig_gen_de_out;
    assign {r_out, g_out, b_out} = {level,cnt_level1} == 3'b101 ? osc_rgb_out : sig_gen_rgb_out;

    
        
     
endmodule