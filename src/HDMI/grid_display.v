
//0V-->y=35; +5V-->y=1055
module grid_display(
	input                       rst_n,   
	input                       pclk,
	input                       i_hs,    
	input                       i_vs,    
	input                       i_de,	
	input[23:0]                 i_data,
    input                       fft_confirm,
    input[1:0]                  amp_choose,
      
	output                      o_hs,    
	output                      o_vs,    
	output                      o_de,    
	output[23:0]                o_data
);

wire[11:0] pos_x;
wire[11:0] pos_y;
wire       pos_hs;
wire       pos_vs;
wire       pos_de;
wire[23:0] pos_data;
reg[23:0]  v_data;
reg[3:0]   grid_x;
reg[6:0]   grid_y;
reg        region_active;

assign o_data = v_data;
assign o_hs = pos_hs;
assign o_vs = pos_vs;
assign o_de = pos_de;





always@(posedge pclk)
begin
    if(!fft_confirm)
        begin
	if(pos_y >= 12'd9 && pos_y <= 12'd1075 && pos_x >= 12'd442 && pos_x  <= 12'd1521)
		region_active <= 1'b1;
	else
		region_active <= 1'b0;
        end
    else
        begin
	if(pos_y >= 12'd210 && pos_y <= 12'd980 && pos_x >= 12'd442 && pos_x  <= 12'd1521)
		region_active <= 1'b1;
	else
		region_active <= 1'b0;
        end
end


always@(posedge pclk)
begin
	if(region_active == 1'b1 && pos_de == 1'b1)
		grid_x <= (grid_x == 4'd7) ? 4'd0 : grid_x + 4'd1;
	else
		grid_x <= 4'd0;  
end

always@(posedge pclk)
begin
    if(!fft_confirm)
        begin
	if((region_active == 1'b1 && pos_de == 1'b1)&&((pos_y <= 12'd1055) && (pos_y >= 12'd32))&&(pos_x  == 12'd1521))
		grid_y <= (grid_y == 7'd101) ? 7'd0 : grid_y + 7'd1;
	else if (pos_y >= 12'd1055)
		grid_y <= 7'd0 ;
    else 
        grid_y <= grid_y ;
        end
    else
        begin
	if((region_active == 1'b1 && pos_de == 1'b1)&&((pos_y <= 12'd980) && (pos_y >= 12'd32))&&(pos_x  == 12'd1521))
		grid_y <= (grid_y == 7'd101) ? 7'd0 : grid_y + 7'd1;
	else if (pos_y >= 12'd980)
		grid_y <= 7'd0 ;
    else 
        grid_y <= grid_y ;
        end
end

// 加粗 y=35、y=1055 以及二者中间的网格线
always@(posedge pclk)
begin
    if(!fft_confirm)
        begin
	    if(region_active == 1'b1)
            begin
            // 加粗 y=35 网格线
            if((pos_y >= 12'd33 && pos_y <= 12'd37))
                v_data <= {8'd100, 8'd100, 8'd0}; // 绿色加粗线
            // 加粗 y=1055 网格线
            else if((pos_y >= 12'd1053 && pos_y <= 12'd1057))
                v_data <= {8'd100, 8'd100, 8'd0}; // 绿色加粗线
            // 加粗 y=163 网格线
            else if((pos_y >= 12'd161 && pos_y <= 12'd165))
                v_data <= {8'd100, 8'd100, 8'd0}; // 绿色加粗线
            // 加粗 y=928 网格线
            else if((pos_y >= 12'd926 && pos_y <= 12'd930))
                v_data <= {8'd100, 8'd100, 8'd0}; // 绿色加粗线
            // 加粗 y=290 网格线
            else if((pos_y >= 12'd288 && pos_y <= 12'd292))
                v_data <= {8'd100, 8'd100, 8'd0}; // 绿色加粗线
            // 加粗 y=800 网格线
            else if((pos_y >= 12'd798 && pos_y <= 12'd802))
                v_data <= {8'd100, 8'd100, 8'd0}; // 绿色加粗线
            // 加粗中间的网格线
            else if((pos_y >= 12'd541 && pos_y <= 12'd545))
                v_data <= {8'd100, 8'd100, 8'd0}; // 绿色加粗线
            // y方向每60个像素一条细网格线
            else if((pos_y > 12'd32 && pos_y < 12'd1055) && ((pos_y-32) % 60 == 0)) 
                v_data <= {8'd100, 8'd100, 8'd100};  // 绿色细网格线
            else if((pos_x > 12'd442 && pos_x < 12'd1521) && ((pos_x-442) % 60 == 0)) 
                v_data <= {8'd100, 8'd100, 8'd100};  // 绿色细网格线
            else
			    v_data <= 24'h000000;
            end
        else
		    v_data <= pos_data;
        end
    else
        begin
	    if(region_active == 1'b1)
        begin
        // 加粗 y=215 网格线
        if((pos_y >= 12'd213 && pos_y <= 12'd217))
            v_data <= {8'd100, 8'd100, 8'd0}; // 绿色加粗线

        // 加粗 y=980 网格线
        else if((pos_y >= 12'd975 && pos_y <= 12'd982))
            v_data <= {8'd100, 8'd100, 8'd0}; // 绿色加粗线

        // 加粗中间的网格线
        else if((pos_y >= 12'd596 && pos_y <= 12'd600))
            v_data <= {8'd100, 8'd100, 8'd0}; // 绿色加粗线 
        // 其余网格线
        // y方向每55个像素一条细网格线
        else if((pos_y > 12'd100 && pos_y < 12'd980) && ((pos_y-32) % 55 == 0)) 
            v_data <= {8'd100, 8'd100, 8'd100};  // 绿色细网格线
        else if((pos_x > 12'd442 && pos_x < 12'd1521) && ((pos_x-442) % 55 == 0)) 
            v_data <= {8'd100, 8'd100, 8'd100};  // 绿色细网格线
		else
			v_data <= 24'h000000;
        end
	else
		v_data <= pos_data;
        end
end

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




