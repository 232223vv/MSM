module oscilloscope_top(
   input    wire  clk_50M           ,
   input    wire  oscilloscope_en,
   input    wire  fft_en    ,
   input    wire  rst_n             ,
   input    wire  [7:0]ad_data_in   ,
   input          fft_clk           ,
   output         [31:0] fft_data   ,
   output         fft_data_valid    
  );

    //assign ad_data =((oscilloscope_en==1)? ad_data_in: 8'b0);
    reg [9:0] cnt;
    reg cnt_flag;
    always @(posedge fft_clk) begin
        if(!rst_n) begin
            cnt<=10'b0;
            cnt_flag<=1'b0;
        end
        else if(fft_en) begin
            if(cnt<10'd256)
                cnt<=cnt+1;
            else if(cnt==10'd256) begin
                cnt_flag<=1'b1;
                cnt<=cnt+1;
            end
            else if(cnt==10'd257) begin
                cnt<=cnt;
                cnt_flag<=1'b0;
            end
        end
        else begin
            cnt<=10'b0;
            cnt_flag<=1'b0;
        end
    end
    wire [31:0] fft_data_in;
    assign fft_data_in={000000000000000000000000,ad_data_in};
    wire o_axi4s_data_tready;
    wire o_axi4s_data_tlast;
    wire [2:0] o_alm;
    wire o_stat;
    fft_demo_00 inst_fft_demo_00(
        .i_aclk(fft_clk)                 ,//输入参考时钟
        .i_axi4s_data_tvalid(fft_en && cnt<10'd256)    ,//数据输入有效信号，上升沿后的第一个时钟周期开始传输，传输完拉低
        .i_axi4s_data_tdata(fft_data_in)     ,//输入数据
        .i_axi4s_data_tlast (cnt_flag)    ,//最后一个信号输入指示信号（1’b1）
        .o_axi4s_data_tready (o_axi4s_data_tready)    ,//允许数据输入指示信号
        .i_axi4s_cfg_tvalid  (1'b1)   ,//动态配置有效指示信号
        .i_axi4s_cfg_tdata    (1'b1)  ,//工作模式
        .o_axi4s_data_tvalid   (fft_data_valid) ,//数据输出有效信号
        .o_axi4s_data_tdata    (fft_data) ,//输出数据
        .o_axi4s_data_tlast    (o_axi4s_data_tlast),//最后一个数据输出指示信号
        .o_axi4s_data_tuser     (o_axi4s_data_tuser),//指示输出数据序号
        .o_alm                  (o_alm),
        .o_stat                 (o_stat)
    );
endmodule