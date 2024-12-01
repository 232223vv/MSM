module div_freq(
    clk_50M,//输入 50MHZ 时钟
    rst_n,
    clken,//时钟使能信号输出
    sel //频率选择
);
//-----------模块输入端口-----------
input clk_50M; //输入 50MHZ 时钟
input rst_n;
input [3:0]sel; //频率选择
//-----------模块输出端口-----------
output clken; //时钟使能信号输出
//------------寄存器定义------------
reg [18:0] cnt = 0;
reg [18:0] cnt_div;

    always @(sel) begin
        case(sel)
        4'd0:  cnt_div = 19'd499_999;   //100
        4'd1:  cnt_div = 19'd99_999;    //500
        4'd2:  cnt_div = 19'd49_999;    //1k
        4'd3:  cnt_div = 19'd9_999;     //5k
        4'd4:  cnt_div = 19'd4_999;     //10k
        4'd5:  cnt_div = 19'd999;       //50k
        4'd6:  cnt_div = 19'd499;       //100k
        4'd7:  cnt_div = 19'd249;       //200k  
        4'd8:  cnt_div = 19'd99;        //500k
        4'd9:  cnt_div = 19'd49;        //1M
        4'd10: cnt_div = 19'd24;       //2M
        4'd11: cnt_div = 19'd9;        //5M
        4'd12: cnt_div = 19'd4;        //10M
        4'd13: cnt_div = 19'd1;
        4'd14: cnt_div = 19'd0;        //50M
        endcase
    end



    always @(posedge clk_50M) begin
        if(!rst_n) begin
            cnt <= 19'd0;
        end
        else if(cnt == cnt_div) begin
            cnt <= 19'd0;
        end
        else begin
            cnt <= cnt + 1'd1;
        end
    end
    
    assign clken = (sel == 4'd14) ? clk_50M : (cnt == cnt_div);

endmodule