module Logic_analyzer_dis(
    input                     rst_n,
    input                      pclk, //148.5MHZ 
    input                   clk_50M,
    input                      i_hs,
    input                      i_vs,
    input                      i_de,
    input        [23:0] rgb_data_in, //background chart's rgbdata
    input        [11:0]      marker, //vertical line marker
    input        [7:0]rd_data_store,/*synthesis PAP_MARK_DEBUG="1"*/ //static and uart
    input        [7:0] rd_data_cons,/*synthesis PAP_MARK_DEBUG="1"*///dynamic
    input                  mov_left,
    input                 mov_right,
    input        [1:0]      cnt_loa,


    output                    rd_clk, 
    output       [14:0]      rd_addr,//static and uart
    output       [10:0] rd_addr_cons,//dynamic
    output                      o_hs,    
	output                      o_vs,    
	output                      o_de,
    output       [23:0] rgb_data_out
   );



assign o_hs = pos_hs;
assign o_vs = pos_vs;
assign o_de = pos_de;
assign rd_clk = pclk;


//-------------regs----------------
reg [23:0] disp_data_r;
reg region_active;
reg [3:0] cnt_stop = 4'd0;
reg [7:0] rd_data_r;
reg [14:0] addr_offset = 0;

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
wire [7:0] rd_data;/*synthesis PAP_MARK_DEBUG="1"*/


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
    if(cnt_loa != 2'b01)
        begin
        if(mov_left) begin
            if(addr_offset == 15'd0)    
                addr_offset <= 15'd32767;
            else
                addr_offset <= addr_offset - 15'd360;
        end
        else if(mov_right) begin
            if(addr_offset == 15'd32767) 
                addr_offset <= 15'd0;
            else 
                addr_offset <= addr_offset + 15'd360;
        end
        else 
            addr_offset <= addr_offset;  
        end
    else
        addr_offset <= 0;  
end

//rd_addr setting
assign rd_addr = pos_x + addr_offset + 1'b1;
//assign rd_addr_cons = region_active ? pos_x - 10'd450 : 0;
assign rd_addr_cons = pos_x;

//rd_data choosing
assign rd_data = (cnt_loa==2'b01) ? rd_data_cons : rd_data_store;

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

loa_pll pll_loa (
  .clkin1(clk_50M),        // input
  .pll_lock(pll_lock),    // output
  .clkout0(edge_clk)       // output
);

endmodule
