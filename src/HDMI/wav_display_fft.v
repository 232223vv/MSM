module wav_display_fft(
	input                       rst_n,   
	input                       pclk,
	input[23:0]                 wave_color,
    input                       fft_clk ,
	input[31:0]                 fft_data_in,
	input                       i_hs,    
	input                       i_vs,    
	input                       i_de,	
	input[23:0]                 i_data,  
    input                   fft_data_valid,
    //input                       fft_confirm,
    
    
	output                      o_hs/* synthesis PAP_MARK_DEBUG="true" */,    
	output                      o_vs/* synthesis PAP_MARK_DEBUG="true" */,    
	output                      o_de/* synthesis PAP_MARK_DEBUG="true" */,    
	output[23:0]                o_data/* synthesis PAP_MARK_DEBUG="true" */
);

wire [7:0]wr_addr ;
reg  wren ;
reg [8:0]sample_cnt ;
reg [31:0]wait_cnt ;
wire cal_done;
reg [7:0] num_data;

reg [3:0] state ;
parameter IDLE = 4'b0001 ;
parameter S_SAMPLE = 4'b0010 ;
parameter S_DONE = 4'b0100 ;
parameter S_CAL = 4'b1000;


wire [31:0] re_sq;  // 实部平方
wire [31:0] im_sq;  // 虚部平方
wire [31:0] quadratic_sum;    // 实部平方 + 虚部平方
wire [31:0] amp;

assign re_sq = fft_data_in[31:16] * fft_data_in[31:16];// 计算实部平方和虚部平方
assign im_sq = fft_data_in[15:0] * fft_data_in[15:0];
assign quadratic_sum = re_sq + im_sq;// 计算平方和


wire[11:0] pos_x;
wire[11:0] pos_y;
wire       pos_hs;
wire       pos_vs;
wire       pos_de;
wire[23:0] pos_data;
reg[23:0]  v_data;
reg[7:0]   rdaddress/* synthesis PAP_MARK_DEBUG="true" */;
wire[31:0]  q/* synthesis PAP_MARK_DEBUG="true" */;
reg        region_active/* synthesis PAP_MARK_DEBUG="true" */;
//wire [11:0]ref_sig/* synthesis PAP_MARK_DEBUG="true" */ ;
//assign ref_sig = 12'd287 - q[7:0] ;
//wire ref_sig2 /* synthesis PAP_MARK_DEBUG="true" */;
//assign ref_sig2 = ((region_active == 1'b1)&&(12'd287 - pos_y == {4'd0,q[7:0]})) ? 1'b1 : 1'b0 ;
//wire [9:0]ref_rd_addr/* synthesis PAP_MARK_DEBUG="true" */ ;
//assign ref_rd_addr = rdaddress[9:0];

assign o_data = v_data;
assign o_hs = pos_hs;
assign o_vs = pos_vs;
assign o_de = pos_de;

always@(posedge pclk)
begin
	if(pos_y >= 12'd210 && pos_y <= 12'd980 && pos_x >= 12'd442 && pos_x  <= 12'd1522)
		region_active <= 1'b1;
	else
		region_active <= 1'b0;
end

always@(posedge pclk)
begin
	if(region_active == 1'b1 && pos_de == 1'b1 && rdaddress < 8'd255)
		rdaddress <= rdaddress + 8'd1;
	else
		rdaddress <= 8'd0;
end

//mapping amp--->amp_8bit
wire [31:0] q_max = 32'd42618000;//32'd92681000; // 设定数据的最大值
wire [31:0] q_tmp;

assign q_tmp = q * 8'd255;
//assign amp_8bit = amp_tmp / amp_max ; // 缩放到0-255范围（8位）

//mapping wr_addr--->pos_x
wire [7:0] rd_addr_max = 8'd255;


wire [18:0] rd_addr_tmp;
assign rd_addr_tmp = 12'd1080 * rdaddress;//防止乘法溢出
always@(posedge pclk)
begin
        if(region_active == 1'b1)
		    if(((12'd980- pos_y)/3 <= q_tmp / q_max) &&  ((pos_x-12'd442) >= rd_addr_tmp / rd_addr_max-1) &&((pos_x-12'd442) <= rd_addr_tmp / rd_addr_max+1)  )//从幅值映射点到x轴的竖线
            //if((12'd980- pos_y)/3 <= amp_tmp / amp_max) 
			    v_data <= wave_color;
		    else
			    v_data <= pos_data;
	    else
		    v_data <= pos_data;
end


//original FSM
/*always @(posedge fft_clk ) begin
	if (~rst_n)begin
		state <= IDLE ;
		wren <= 1'b0 ;
		sample_cnt <= 9'd0;
		wait_cnt <= 32'd0;
	end
	else begin
		case (state)
			IDLE : begin
				state <= S_SAMPLE ; 
			end 
			S_SAMPLE : begin
				if(sample_cnt == 9'd255)
				begin
					sample_cnt <= 9'd0;
					wren <= 1'b0;
					state <= S_WAIT;
				end
				else
				begin
					sample_cnt <= sample_cnt + 9'd1;
					wren <= 1'b1;
				end
			end
			S_WAIT : begin
				if(wait_cnt == 32'd1)
				begin
					state <= S_SAMPLE;
					wait_cnt <= 32'd0;
				end
				else
				begin
					wait_cnt <= wait_cnt + 32'd33_670_033;
				end
			end
			default: state <= IDLE ; 
		endcase
	end 
end*/

/*always @(posedge fft_clk) begin
    if (~rst_n) begin
        state <= IDLE;
        wren <= 1'b0;
        sample_cnt <= 9'd0;
        wait_cnt <= 32'd0;
    end else begin
        case (state)
            IDLE : begin
                if(fft_data_valid)
				   state <= S_CAL ;
                else
                    state <= IDLE;
                end
            S_CAL: begin
                if (cal_done) begin // 如果幅值计算完成
                    state <= S_SAMPLE; // 转到采样状态
                end
            end
            S_SAMPLE: begin
                if (sample_cnt == 9'd255) begin
                    sample_cnt <= 9'd0;
                    wren <= 1'b0;
                    state <= S_DONE;
                end else begin
                    sample_cnt <= sample_cnt + 9'd1;
                    wren <= 1'b1; // 进行写入
                end
            end
            S_DONE : begin
				wren<=1'b0;
				end
            default: state <= IDLE;
        endcase
    end 
end*/


//original FSM but S_DONE
always @(posedge fft_clk ) begin
	if (~rst_n)begin
		state <= IDLE ;
		wren <= 1'b0 ;
		sample_cnt <= 9'd0;
		wait_cnt <= 32'd0;
	end
	else begin
		case (state)
			IDLE : begin
                if(fft_data_valid)
				   state <= S_SAMPLE ;
                else
                    state <= IDLE; 
			end 
			S_SAMPLE : begin
				if(sample_cnt == 9'd255)
				begin
					sample_cnt <= 9'd0;
					wren <= 1'b0;
					state <= S_DONE;
				end
				else
				begin
					sample_cnt <= sample_cnt + 9'd1;
					wren <= 1'b1;
				end
			end
			S_DONE : begin
				wren<=1'b0;
				end
			default: state <= IDLE ; 
		endcase
	end 
end

assign wr_addr = sample_cnt[7:0] ;

// always @(posedge ad_clk ) begin
//     if (~rst_n)
//         wr_addr <= 10'd0 ;
//     else if (pos_y > 400)
//         wr_addr <= wr_addr + 10'd1 ;
// 	else 
// 		wr_addr <= 10'd0 ;
// end

// always @(posedge ad_clk ) begin
// 	if (~rst_n)
// 		wren <= 1'b0 ;
// 	else if (pos_y > 12'd400)
//         wren <= 1'b1 ;
// 	else 
// 		wren <= 1'b0 ;
// end

fft_ram ram_fft (
  .wr_data(fft_data_in),    // input [31:0]
  .wr_addr(wr_addr),    // input [7:0]
  .wr_en(wren),        // input
  .wr_clk(fft_clk),      // input
  .wr_rst(~rst_n),      // input
  .rd_addr(rdaddress),    // input [7:0]
  .rd_data(q),    // output [31:0]
  .rd_clk(pclk),      // input
  .rd_rst(~rst_n)       // input
);


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

//amp calculation
sqrt_calculator #(
        .DATA_WIDTH(32),           // 数据宽度为32位
        .ITERATIONS(20)            // 牛顿迭代的次数为20次
    ) sqrt_inst (
        .clk(fft_clk),                 // 连接顶层模块的时钟信号
        .radicand(quadratic_sum),      // 输入待开平方数
        .sqrt_out(amp),     // 输出平方根结果
        .rstn(rstn),
        .cal_done(cal_done)
    );
endmodule