module div_freq(
    clk_50M,//���� 50MHZ ʱ��
    rst_n,
    clk,//ʱ��ʹ���ź����
    sel //Ƶ��ѡ��
);
//-----------ģ������˿�-----------
input clk_50M; //���� 50MHZ ʱ��
input rst_n;
input [3:0]sel; //Ƶ��ѡ��
//-----------ģ������˿�-----------
output clk; //ʱ��ʹ���ź����
//------------�Ĵ�������------------
reg [18:0] cnt = 0;
reg [18:0] cnt_div;

    always @(sel) begin
        case(sel)
        4'd0: cnt_div <= 19'd499_999;   //100
        4'd1: cnt_div <= 19'd99_999;    //500
        4'd2: cnt_div <= 19'd49_999;    //1k
        4'd3: cnt_div <= 19'd9_999;     //5k
        4'd4: cnt_div <= 19'd4_999;     //10k
        4'd5: cnt_div <= 19'd999;       //50k
        4'd6: cnt_div <= 19'd499;       //100k
        4'd7: cnt_div <= 19'd249;       //200k  
        4'd8: cnt_div <= 19'd99;        //500k
        4'd9: cnt_div <= 19'd49;
        4'd10: cnt_div <= 19'd24;
        4'd11: cnt_div <= 19'd9;
        4'd12: cnt_div <= 19'd4;
        4'd13: cnt_div <= 19'd0;
        endcase
    end

    always @(posedge clk_50M) begin
        if(clk)
            cnt <= 19'd0;
        else
            cnt <= cnt + 1'd1;
    end

    wire div_50M = (sel == 4'd13);

    assign clk = div_50M ? 1'd1 : (cnt == cnt_div);
endmodule