`include "source\rtl\defines.v"
module timer(

    input wire clk,
    input wire rst_n,

    input wire[7:0] waddr_i,
    input wire[`MemBus] data_i,
    input wire[3:0] sel_i,
    input wire we_i,
    input wire[7:0] raddr_i,
    input wire rd_i,
    output reg[`MemBus] data_o,

    output reg  timer_cmpo_p,//比较输出+
    output reg  timer_cmpo_n,//比较输出-
    input  wire timer_capi,//输入捕获

    output reg irq_timer_of      //定时器溢出中断

);

reg capi_trig0;//输入捕获触发0
reg capi_trig1;//输入捕获触发1

// 寄存器(偏移)地址
localparam TIMER_CTRL = 8'h0;
localparam TIMER_CMPO = 8'h4;
localparam TIMER_CAPI = 8'h8;
localparam TIMER_TCOF = 8'hc;

/* 
 * TIMER_CTRL定时器控制寄存器，0x00
 * [0]：RW，计数器使能，1使能，0停止并清零计数器
 * [1]：RW，比较输出初始极性
 * [3:2]：RW，捕获0触发配置位，触发后自动清零
 * [5:4]：RW，捕获1触发配置位，触发后自动清零
 * [6]: RW，定时器溢出中断使能
 * [15:7]：RO，读恒为0
 * [31:16]: RW，预分频器
 * 捕获触发模式配置位：
 * 00：不触发      01：上升沿触发
 * 10：下降沿触发  11：双沿触发
*/
reg timer_ctrl;//[0]计数器使能
reg timer_cmpol;//[1]比较输出初始极性
reg [1:0]timer_trig0;//[3:2]捕获0触发配置位
reg [1:0]timer_trig1;//[5:4]捕获1触发配置位
reg irq_timer_of_en;//中断使能
reg [15:0]timer_diver;//[31:16]预分频器

/* 
 * TIMER_CMPO比较寄存器，0x04
 * [15: 0]：RW，比较寄存器0
 * [31:16]：RW，比较寄存器1
*/
reg [15:0]timer_cmpo0;
reg [15:0]timer_cmpo1;

/* 
 * TIMER_CAPI比较寄存器，0x08
 * [15: 0]：RO，捕获寄存器0
 * [31:16]：RO，捕获寄存器1
*/
reg [15:0]timer_capi0;
reg [15:0]timer_capi1;

/* 
 * TIMER_TCOF计数器、溢出寄存器，0x0c
 * [15: 0]：RO，读取当前计数器的值
 * [31:16]：RW，溢出寄存器
*/
reg [15:0]timer_cnt;//Timer的计数器
reg [15:0]timer_of;//溢出寄存器

// 总线接口 写
always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        timer_ctrl  <= 1'b0;
        timer_cmpol <= 1'b0;
        timer_trig0 <= 2'b00;
        timer_trig1 <= 2'b00;
        timer_diver <= 16'h0;
        timer_of <= 16'hFFFF;
        irq_timer_of_en   <= 1'b0;
    end 
    else begin
        if (we_i == 1'b1) begin
            case (waddr_i)
                TIMER_CTRL: begin
                    timer_ctrl  <= data_i[0];
                    timer_cmpol <= data_i[1];
                    timer_trig0 <= data_i[3:2];
                    timer_trig1 <= data_i[5:4];
                    irq_timer_of_en <= data_i[6];
                    timer_diver <= data_i[31:16];
                end
                TIMER_CMPO: begin
                    timer_cmpo0 <= data_i[15:0];
                    timer_cmpo1 <= data_i[31:16];
                end
                TIMER_TCOF :begin
                    timer_of <= data_i[31:16];
                end
            endcase
        end 
        else begin
            if (capi_trig0) begin
                timer_trig0 <= 2'b00;
            end
            if (capi_trig1) begin
                timer_trig1 <= 2'b00;
            end
        end
    end
end

// 总线接口 读
always @ (posedge clk) begin
    if (rd_i == 1'b1) begin
        case (raddr_i)
            TIMER_CTRL: begin
                data_o[0] <= timer_ctrl ;
                data_o[1] <= timer_cmpol;
                data_o[3:2] <= timer_trig0;
                data_o[5:4] <= timer_trig1;
                data_o[6] <= irq_timer_of_en ;
                data_o[15:7] <= 9'h0;
                data_o[31:16] <= timer_diver;
            end
            TIMER_CMPO: begin
                data_o <= {timer_cmpo1, timer_cmpo0};
            end
            TIMER_CAPI: begin
                data_o <= {timer_capi1, timer_capi0};
            end
            TIMER_TCOF: begin
                data_o <= {16'h0, timer_cnt};
            end
            default: begin
                data_o <= 32'h0;
            end
        endcase
    end
    else begin
        data_o <= data_o;
    end
end

wire cmp_cmpo0 = timer_cnt >= timer_cmpo0;//比较0，计数器 大于等于 比较寄存器0，则为1
wire cmp_cmpo1 = timer_cnt >= timer_cmpo1;//比较1，计数器 大于等于 比较寄存器1，则为1
wire cmp_of = timer_cnt >= timer_of;//溢出，计数器 大于等于 溢出寄存器，则为1
wire cmpol_p = timer_cmpol;//比较输出的初始极性
wire cmpol_n = ~timer_cmpol;//比较输出的初始极性反相
reg cmp_out_p;//比较输出+

reg [2:0]capi_pp3;//捕获输入端口打3拍滤波，从低位到高位
reg [15:0]timer_div_cnt;//分频器计数

always @(posedge clk) begin
    irq_timer_of <= 1'b0;//溢出中断
    if(timer_ctrl==1'b0) begin //没有使能
        timer_div_cnt <= 16'h0;//分频器清零
        timer_cnt <= 16'h0;//计数器清零
    end
    else begin //使能
        if(timer_div_cnt >= timer_diver) begin //分频器计数值大于预分频器系数，溢出
            timer_div_cnt <= 16'h0;//清零
            if(cmp_of) begin //计数器溢出了
                timer_cnt <= 16'h0;//计数器清零
                irq_timer_of <= irq_timer_of_en;//溢出中断
            end
            else begin //计数器还没有溢出
                timer_cnt <= timer_cnt + 16'h1;//计数器+1
            end
        end
        else begin //分频器计数还没有溢出
            timer_div_cnt <= timer_div_cnt + 16'h1; //分频器计数+1
        end
    end
end

//比较输出
always @(*) begin
    case ({cmp_cmpo1, cmp_cmpo0})
        2'b00: cmp_out_p = cmpol_p;//计数值小于比较值01
        2'b01: cmp_out_p = cmpol_n;//计数值介于比较值01之间
        2'b10: cmp_out_p = cmpol_n;//计数值介于比较值01之间
        2'b11: cmp_out_p = cmpol_p;//计数值大于等于比较值01
    endcase
end
//输出打拍
always @(posedge clk) begin
    timer_cmpo_p <= cmp_out_p;//直接输出
    timer_cmpo_n <= ~cmp_out_p;//反相信号
end

//捕获输入打拍滤波
always @(posedge clk) begin
    capi_pp3[0] <= timer_capi;
    capi_pp3[1] <= capi_pp3[0];
    capi_pp3[2] <= capi_pp3[1];
end

//触发
always @(*) begin
    case (timer_trig0)//捕获0
        2'b00: capi_trig0 = 1'b0;//不触发
        2'b01: capi_trig0 = (capi_pp3[2]==1'b0 && capi_pp3[1]==1'b1);//上升沿
        2'b10: capi_trig0 = (capi_pp3[2]==1'b1 && capi_pp3[1]==1'b0);//下降沿
        2'b11: capi_trig0 = (capi_pp3[2]^capi_pp3[1]);//双边沿
    endcase
    case (timer_trig1)//捕获1
        2'b00: capi_trig1 = 1'b0;
        2'b01: capi_trig1 = (capi_pp3[2]==1'b0 && capi_pp3[1]==1'b1);
        2'b10: capi_trig1 = (capi_pp3[2]==1'b1 && capi_pp3[1]==1'b0);
        2'b11: capi_trig1 = (capi_pp3[2]^capi_pp3[1]);
    endcase
end

//捕获+中断
always @(posedge clk) begin
    if(capi_trig0) begin
        timer_capi0 <= timer_cnt;
    end  
    if(capi_trig1) begin
        timer_capi1 <= timer_cnt;
    end
end

endmodule
