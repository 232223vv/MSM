module Logic_analyzer_dis(
    input                     rst_n,
    input                      pclk, //148.5MHZ 
    input                      i_hs,
    input                      i_vs,
    input                      i_de,
    input        [23:0] rgb_data_in, //background chart's rgbdata
    input        [11:0]      marker, //vertical line marker
    input        [7:0]      rd_data, //8 bits each channel's data
    input                  mov_left,
    input                 mov_right,
    input                      stop,

    output                  rd_clk, 
    output       [16:0]      rd_addr_w, 
    output                      o_hs,    
	output                      o_vs,    
	output                      o_de,
    output       [23:0] rgb_data_out
   );



assign o_hs = pos_hs;
assign o_vs = pos_vs;
assign o_de = pos_de;
assign rd_clk = (pos_x-10'd450)%80==1 ? 1'b1 : 1'b0;

//-------------regs----------------
reg [23:0] disp_data_r;
reg region_active;
reg [3:0] cnt_stop = 4'd0;
reg [7:0] rd_data_r;
reg [16:0] rd_addr = 17'd0;
reg [16:0] addr_offset = 0;
reg [17:0] rd_addr_w_temp;

//------------wires------------
wire grid;
wire mark;
wire [7:0]wave; 
wire [7:0]wave_edge; 
wire [7:0]wave_stop;
wire [11:0] pos_x;
wire [11:0] pos_y;
wire       pos_hs;
wire       pos_vs;
wire       pos_de;
wire [23:0] pos_data;
wire [7:0] edges;
wire edge_clk;


//------------color parameters---------------
parameter MarkColor=24'hff0000; //yellow
parameter WaveColor=24'h00ff00; //green
parameter GridColor=24'hadd8e6; //light blue

//judge wave's display active region
always@(posedge pclk)
begin
	if(pos_y >= 12'd28 && pos_y <= 12'd1052 && pos_x >= 12'd450 && pos_x  <= 12'd1890)
		region_active <= 1'b1;
	else
		region_active <= 1'b0;   
end

//chanels' y position
parameter CH0_H=12'd44, CH0_L=12'd140,
CH1_H=12'd172, CH1_L=12'd268,
CH2_H=12'd300, CH2_L=12'd396,
CH3_H=12'd428, CH3_L=12'd524,
CH4_H=12'd556, CH4_L=12'd652,
CH5_H=12'd684, CH5_L=12'd780,
CH6_H=12'd812, CH6_L=12'd908,
CH7_H=12'd940, CH7_L=12'd1036;

//offset setting
always@(posedge pclk) begin
    if(stop) begin
        if(mov_left) begin
            if(addr_offset == 17'd0) begin     
                addr_offset <= 17'd131057;
            end
            else begin
                addr_offset <= addr_offset - 17'd18;
            end
        end
        else if(mov_right) begin
            if(addr_offset == 17'd131057) begin
                addr_offset <= 17'd0;
            end
            else begin
                addr_offset <= addr_offset + 17'd18;
            end
        end
        else begin
            addr_offset <= addr_offset;
        end    
    end
    else begin
        addr_offset <= 17'd0;
    end
end

always@(posedge rd_clk) begin
    rd_addr_w_temp <= rd_addr + addr_offset;
end

//rd_addr changing
always @(posedge rd_clk)
begin
    if(rd_addr == 17'h1ffff)
        rd_addr <= 17'd0;
    else 
    begin
        if(stop)
        begin
                if(cnt_stop == 4'd17)
                begin
                    cnt_stop <= 4'd0;
                    rd_addr <= rd_addr + 1'd1;
                end
                else if(cnt_stop == 4'd0)
                begin
                    cnt_stop <= cnt_stop + 4'd1;
                    rd_addr <= rd_addr - 4'd17;
                end
                else
                begin
                    cnt_stop <= cnt_stop + 4'd1;
                    rd_addr <= rd_addr + 1'd1;
                end
        end
        else
        begin
            cnt_stop <= 4'd0;
            rd_addr <= rd_addr + 1'd1;
        end
    end      
end

assign rd_addr_w = (rd_addr_w_temp >= 17'd131071) ? rd_addr_w_temp - 17'd131071 : rd_addr_w_temp;


//------------------mark x position------------------
assign mark=( (pos_x-10'd450==marker)||(pos_x-10'd449==marker)||(pos_x-10'd448==marker) )&&(pos_y[1:0]!=2'd1)&&region_active;


//------------------wave edges detecting------------------
always@(posedge edge_clk)
    rd_data_r<=rd_data;
    
assign wave_edge=rd_data^rd_data_r;



//------------------drawing waves and waves' edges------------------
assign wave[0]=region_active && (((pos_y==CH0_H)&&rd_data_r[0])
||((pos_y==CH0_L)&&~rd_data_r[0])
||((pos_y>=CH0_H)&&(pos_y<=CH0_L)&&wave_edge[0]));
assign wave[1]=region_active && (((pos_y==CH1_H)&&rd_data_r[1])
||((pos_y==CH1_L)&&~rd_data_r[1])
||((pos_y>=CH1_H)&&(pos_y<=CH1_L)&&wave_edge[1]));
assign wave[2]=region_active && (((pos_y==CH2_H)&&rd_data_r[2])
||((pos_y==CH2_L)&&~rd_data_r[2])
||((pos_y>=CH2_H)&&(pos_y<=CH2_L)&&wave_edge[2]));
assign wave[3]=region_active && (((pos_y==CH3_H)&&rd_data_r[3])
||((pos_y==CH3_L)&&~rd_data_r[3])
||((pos_y>=CH3_H)&&(pos_y<=CH3_L)&&wave_edge[3]));
assign wave[4]=region_active && (((pos_y==CH4_H)&&rd_data_r[4])
||((pos_y==CH4_L)&&~rd_data_r[4])
||((pos_y>=CH4_H)&&(pos_y<=CH4_L)&&wave_edge[4]));
assign wave[5]=region_active && (((pos_y==CH5_H)&&rd_data_r[5])
||((pos_y==CH5_L)&&~rd_data_r[5])
||((pos_y>=CH5_H)&&(pos_y<=CH5_L)&&wave_edge[5]));
assign wave[6]=region_active && (((pos_y==CH6_H)&&rd_data_r[6])
||((pos_y==CH6_L)&&~rd_data_r[6])
||((pos_y>=CH6_H)&&(pos_y<=CH6_L)&&wave_edge[6]));
assign wave[7]=region_active && (((pos_y==CH7_H)&&rd_data_r[7])
||((pos_y==CH7_L)&&~rd_data_r[7])
||((pos_y>=CH7_H)&&(pos_y<=CH7_L)&&wave_edge[7]));



//drawing grids
assign grid =(((pos_x-10'd450==10'd0)
||(pos_x-10'd450==12'd50)
||(pos_x-10'd450==12'd100)
||(pos_x-10'd450==12'd150)
||(pos_x-10'd450==12'd200)
||(pos_x-10'd450==12'd250)
||(pos_x-10'd450==12'd300)
||(pos_x-10'd450==12'd350)
||(pos_x-10'd450==12'd400)
||(pos_x-10'd450==12'd450)
||(pos_x-10'd450==12'd500)
||(pos_x-10'd450==12'd550)
||(pos_x-10'd450==12'd600)
||(pos_x-10'd450==12'd650)
||(pos_x-10'd450==12'd700)
||(pos_x-10'd450==12'd750)
||(pos_x-10'd450==12'd800)
||(pos_x-10'd450==12'd850)
||(pos_x-10'd450==12'd900)
||(pos_x-10'd450==12'd950)
||(pos_x-10'd450==12'd1000)
||(pos_x-10'd450==12'd1050)
||(pos_x-10'd450==12'd1100)
||(pos_x-10'd450==12'd1200)
||(pos_x-10'd450==12'd1250)
||(pos_x-10'd450==12'd1300)
||(pos_x-10'd450==12'd1350)
||(pos_x-10'd450==12'd1400))
&&(pos_y[1:0]!=2'd1))
||((pos_y-10'd28)%32==0)
&&(pos_x[2:0]==3'd0)
||(pos_y>=10'd155&&pos_y<=157)
||(pos_y>=10'd283&&pos_y<=285)
||(pos_y>=10'd411&&pos_y<=413)
||(pos_y>=10'd539&&pos_y<=541)
||(pos_y>=10'd667&&pos_y<=669)
||(pos_y>=10'd795&&pos_y<=797)
||(pos_y>=10'd923&&pos_y<=925);


//------------------each parts rgbdata out------------------
always@(posedge pclk)
begin
    if(|wave&&region_active)
        disp_data_r<=WaveColor;
    else if(mark&&region_active) 
        disp_data_r<=MarkColor;
    else if(grid && region_active) 
        disp_data_r<=GridColor;
    else 
        disp_data_r<=pos_data;
end

assign rgb_data_out=disp_data_r;

//timing parameters preparing
timing_gen_xy timing_gen_xy_m0(
	.rst_n    (rst_n    ),
	.clk      (pclk     ),
	.i_hs     (i_hs     ),
	.i_vs     (i_vs     ),
	.i_de     (i_de     ),
	.i_data   (rgb_data_in),
	.o_hs     (pos_hs   ),
	.o_vs     (pos_vs   ),
	.o_de     (pos_de   ),
	.o_data   (pos_data ),
	.x        (pos_x    ),
	.y        (pos_y    )
);

la_pll pll_la (
  .clkin1(pclk),        // input
  .pll_lock(pll_lock),    // output
  .clkout0(edge_clk)       // output
);

endmodule
