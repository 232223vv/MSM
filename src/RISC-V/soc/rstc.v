module rstc (
    input wire clk,
    input wire hard_rst_n,  //硬件复位，低电平有效
    input wire soft_rst_en, //软件复位，高电平有效
    input wire jtag_rst_en, //JTAG复位，高电平有效
    output reg rst_n
);
reg [3:0] sys_rst_cnt = 4'h0;//系统复位计数器
reg hard_rst_r,hard_rst_rr,hard_rst_en;
`ifdef HARD_RST_DIGT_FILTER
localparam Filter_bit = clogb2(`CPU_CLOCK_HZ/10);//滤波计数器的位数
reg [Filter_bit-1:0] hrst_filter_cnt;//滤波计数器
`endif
//复位计数
always @(posedge clk) begin
    hard_rst_r <= ~hard_rst_n;
    hard_rst_rr <= hard_rst_r;//输入打两拍
`ifdef HDL_SIM //仿真模式不滤波
    hard_rst_en <= hard_rst_rr;
`else //非仿真
`ifdef HARD_RST_DIGT_FILTER //开启数字滤波
    if (hard_rst_rr) begin //复位键按下
        if(hrst_filter_cnt!={Filter_bit{1'b1}}) begin //计数器未饱和
            hrst_filter_cnt <= hrst_filter_cnt + 1; //+1
            hard_rst_en <= 1'b0;
        end
        else begin //计数器饱和
            hard_rst_en <= 1'b1;
        end
    end
    else begin //松开
        hrst_filter_cnt <= {Filter_bit{1'b0}}; //清零
        hard_rst_en <= 1'b0;
    end
`else //不滤波
    hard_rst_en <= hard_rst_rr;
`endif
`endif
    if (jtag_rst_en | soft_rst_en | hard_rst_en) begin//若发生复位事件
        sys_rst_cnt <= 4'h0;
        rst_n <= 1'b0;
    end
    else begin//没有复位事件
        if(sys_rst_cnt == 4'hF) begin//复位完成
            sys_rst_cnt <= sys_rst_cnt;
            rst_n <= 1'b1;
        end
        else begin//复位中
            sys_rst_cnt <= sys_rst_cnt + 4'h1;
            rst_n <= 1'b0;
        end
    end
end

function integer clogb2;
    input integer depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1)
            depth = depth >> 1;
endfunction

endmodule