module wav_display(
	input                       rst_n,   
	input                       pclk,
    input                       clk_50M,
    input                      ad_clk,
	input[23:0]                 wave_color,
	input[7:0]                  ad_data_in,/*synthesis PAP_MARK_DEBUG="1"*/
	input                       i_hs,    
	input                       i_vs,    
	input                       i_de,	
	input[23:0]                 i_data,
	input 						oscen,  
    //input                       fft_confirm,
    input                  [1:0] amp_choose,
    input                  [1:0] fre_choose,
    
	output                      o_hs/* synthesis PAP_MARK_DEBUG="true" */,    
	output                      o_vs/* synthesis PAP_MARK_DEBUG="true" */,    
	output                      o_de/* synthesis PAP_MARK_DEBUG="true" */,    
	output[23:0]                o_data/* synthesis PAP_MARK_DEBUG="true" */
);

wire [10:0]wr_addr ;/*synthesis PAP_MARK_DEBUG="1"*/
reg  wren ;
reg [10:0]sample_cnt ;/*synthesis PAP_MARK_DEBUG="1"*/
// reg [31:0]wait_cnt ;

reg [3:0] state ;
parameter IDLE = 3'b001 ;
parameter S_SAMPLE = 3'b010 ;
parameter S_WAIT = 3'b100 ;


wire[11:0] pos_x;
wire[11:0] pos_y;
wire       pos_hs;
wire       pos_vs;
wire       pos_de;
wire[23:0] pos_data;
reg[23:0]  v_data;
reg[10:0]   rdaddress/* synthesis PAP_MARK_DEBUG="true" */;
wire[7:0]  q/* synthesis PAP_MARK_DEBUG="true" */;
reg        region_active/* synthesis PAP_MARK_DEBUG="true" */;
wire [11:0]ref_sig/* synthesis PAP_MARK_DEBUG="true" */ ;
assign ref_sig = 12'd287 - q[7:0] ;
wire ref_sig2 /* synthesis PAP_MARK_DEBUG="true" */;
assign ref_sig2 = ((region_active == 1'b1)&&(12'd287 - pos_y == {4'd0,q[7:0]})) ? 1'b1 : 1'b0 ;
wire [10:0]ref_rd_addr/* synthesis PAP_MARK_DEBUG="true" */ ;
assign ref_rd_addr = rdaddress;

assign o_data = v_data;
assign o_hs = pos_hs;
assign o_vs = pos_vs;
assign o_de = pos_de;

always@(posedge pclk)
begin
	if(pos_y >= 12'd9 && pos_y <= 12'd1075 && pos_x >= 12'd442 && pos_x  <= 12'd1522)
		region_active <= 1'b1;
	else
		region_active <= 1'b0;
end

// 1/2 of pclk
reg pclk_div2;
always @(posedge pclk) begin
    pclk_div2 <= ~pclk_div2; 
end

// 1/3 of pclk
reg [1:0] counter = 2'b0; 
reg pclk_div3;         
always @(posedge pclk) 
begin
        counter <= counter + 1'b1;   
        if (counter == 2'b10)
        begin  
            counter <= 2'd0;
            pclk_div3 <= ~pclk_div3;   
        end
end

//choose which frequecy of wave
wire wave_clk;
assign wave_clk = fre_choose == 2'b00 ? pclk : (fre_choose == 2'b01 ? pclk_div2 : pclk_div3);
 
always@(posedge wave_clk)
begin
	if(region_active == 1'b1 && pos_de == 1'b1)
		rdaddress <= rdaddress + 11'd1;
	else
		rdaddress <= 11'd0;
end

always@(posedge wave_clk)
begin
    case(amp_choose)
    2'b00:
    begin
	        if(region_active == 1'b1)
		        if((12'd1055- pos_y)/4 == {4'd0,q[7:0]})
			        v_data <= wave_color;
		        else
			        v_data <= pos_data;
	        else
		        v_data <= pos_data;
    end
    2'b01:
    begin
	        if(region_active == 1'b1)
		        if((12'd928- pos_y)/3 == {4'd0,q[7:0]})
			        v_data <= wave_color;
		        else
			        v_data <= pos_data;
	        else
		        v_data <= pos_data;
    end
    2'b10:
    begin
	        if(region_active == 1'b1)
		        if((12'd800- pos_y)/2 == {4'd0,q[7:0]})
			        v_data <= wave_color;
		        else
			        v_data <= pos_data;
	        else
		        v_data <= pos_data;
    end
    default:
    begin
	        if(region_active == 1'b1)
		        if((12'd1055- pos_y)/4 == {4'd0,q[7:0]})
			        v_data <= wave_color;
		        else
			        v_data <= pos_data;
	        else
		        v_data <= pos_data;
    end
    endcase
end

// always @(posedge ad_clk ) begin
// 	if (~rst_n)begin
// 		state <= 3'b001 ;
// 		wren <= 1'b0 ;
// 		sample_cnt <= 11'd0;
// 		wait_cnt <= 32'd0;
// 	end
// 	else begin
// 		case (state)
// 			IDLE : begin
// 				state <= S_SAMPLE ; 
// 			end 
// 			S_SAMPLE : begin
// 				if(sample_cnt == 11'd1079)
// 				begin
// 					sample_cnt <= 11'd0;
// 					wren <= 1'b0;
// 					state <= S_WAIT;
// 				end
// 				else
// 				begin
// 					sample_cnt <= sample_cnt + 11'd1;
// 					wren <= 1'b1;
// 				end
// 			end
// 			S_WAIT : begin
// 				if(wait_cnt == 32'd12_367_003) // 32'd33_670_033
// 				begin
// 					state <= S_SAMPLE;
// 					wait_cnt <= 32'd0;
// 				end
// 				else
// 				begin
// 					wait_cnt <= wait_cnt + 32'd1;
// 				end
// 			end
// 			default: state <= IDLE ; 
// 		endcase
// 	end 
// end

reg full_flag = 1'd0;
reg [23:0] cntwait;
parameter waitime = 24'd4_999_499;
always @(posedge clk_50M) begin
	if(cntwait == waitime) begin
		full_flag <= 1'd0;
	end
	else if(sample_cnt == 11'd1079) begin
		full_flag <= 1'd1;
	end
	else begin
		full_flag <= full_flag;
	end
end

always @(posedge clk_50M) begin
	if(full_flag) begin
		cntwait <= cntwait + 1'd1;
	end
	else begin
		cntwait <= 24'd0;
	end
end

always @(posedge clk_50M) begin
	if(oscen) begin
		wren <= 1'd1;
	end
	else begin
		wren <= 1'd0;
	end
end
always @(posedge clk_50M) begin
	if(!full_flag) begin
		if(wren && ad_clk) begin
			if(sample_cnt == 11'd1079) begin
				sample_cnt <= 11'd0;
			end
			else begin
				sample_cnt <= sample_cnt + 11'd1;
			end
		end
		else begin
			sample_cnt <= sample_cnt;
		end
	end
	else begin
		sample_cnt <= 11'd0;
	end
end


assign wr_addr = sample_cnt;

ram1024x8 u_ram (
  .wr_data(ad_data_in),    // input [7:0]
  .wr_addr(wr_addr),    // input [10:0]
  .wr_en(wren),        // input
  .wr_clk(ad_clk),      // input
  .wr_rst(!oscen),      // input
  .rd_addr(rdaddress),    // input [9:0]
  .rd_data(q),    // output [7:0]
  .rd_clk(pclk),      // input
  .rd_rst(~rst_n)       // input
);

/*assign ad_clk = clk_50M;*/

timing_gen_xy timing_gen_xy_m0(
	.rst_n    (rst_n    ),
	.clk      (pclk     ),
	.i_hs     (i_hs     ),
	.i_vs     (i_vs     ),
	.i_de     (i_de     ),
	.i_data   (i_data   ),
	.o_hs     (pos_hs   ),
	.o_vs     (pos_vs   ),
	.o_de     (pos_de   ),
	.o_data   (pos_data ),
	.x        (pos_x    ),
	.y        (pos_y    )
);
endmodule