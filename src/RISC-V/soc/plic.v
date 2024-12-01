`include "source\rtl\defines.v"
module plic (
	input clk,
	input rst_n,

    //ICB Slave
    input  wire                 plic_icb_cmd_valid,//cmd有效
    output wire                 plic_icb_cmd_ready,//cmd准备好
    input  wire [`MemAddrBus]   plic_icb_cmd_addr ,//cmd地址
    input  wire                 plic_icb_cmd_read ,//cmd读使能
    input  wire [`MemBus]       plic_icb_cmd_wdata,//cmd写数据
    input  wire [3:0]           plic_icb_cmd_wmask,//cmd写选通
    output reg                  plic_icb_rsp_valid,//rsp有效
    input  wire                 plic_icb_rsp_ready,//rsp准备好
    output wire                 plic_icb_rsp_err  ,//rsp错误
    output reg  [`MemBus]       plic_icb_rsp_rdata,//rsp读数据

    //全局中断源接口
    input  wire [15:0] plic_irq_port,

    //对接hart context硬件中断上下文0，与内核直接交互
    output wire core_ex_trap_valid_o,//外部中断请求
    output wire [4:0]core_ex_trap_id_o,//外部中断源ID
    input  wire core_ex_trap_ready_i//外部中断响应
);
/*
PLIC
支持15个中断源(加上保留的中断源ID:0是16个)
支持1个中断硬件上下文(hart context0)
支持4个中断优先级(2bit)
支持4个中断阈值(2bit)
与标准PLIC的不同之处(特性)：
对中断信号电平敏感，1有效
中断声明完成寄存器(PLIC_CPC)可由内核直接操作并实现相关功能，且总线读操作不会产生任何影响。
中断闸口永远是通的，即某个中断源的中断服务程序正在运行，再次出现的中断信号不会被屏蔽。
*/
//中断源0-15优先级：0x000000-0x00007c
localparam PLIC_IP  = 28'h001000;//中断待定位IP 0-15
localparam PLIC_IE  = 28'h002000;//context0的中断源0-31使能位
localparam PLIC_ITH = 28'h200000;//context0的中断优先级阈值
localparam PLIC_CPC = 28'h200004;//context0的声明/完成
//定义寄存器组
reg [1:0]plic_prt[15:1];//中断源0-15优先级寄存器
reg [15:0]plic_ip;//只读，中断待定位IP 0-15
reg [15:0]plic_ie;//context0的中断源0-15使能位
reg [1:0]plic_ith;//context0的中断优先级阈值
reg [3:0]plic_cpc;//只读，context0的中断声明完成寄存器

//ICB总线交互
wire icb_whsk = plic_icb_cmd_valid & ~plic_icb_cmd_read;//写握手
wire icb_rhsk = plic_icb_cmd_valid & plic_icb_cmd_read;//读握手
wire [27:0] waddr = plic_icb_cmd_addr[27:0];//写地址，屏蔽低位，字节选通替代
wire [27:0] raddr = plic_icb_cmd_addr[27:0];//读地址，屏蔽低位，译码执行部分替代
assign plic_icb_cmd_ready = 1'b1;
assign plic_icb_rsp_err   = 1'b0;
//读响应控制
always @(posedge clk or negedge rst_n)
if (~rst_n)
    plic_icb_rsp_valid <=1'b0;
else begin
    if (icb_rhsk)
        plic_icb_rsp_valid <=1'b1;
    else if (plic_icb_rsp_valid & plic_icb_rsp_ready)
        plic_icb_rsp_valid <=1'b0;
    else
        plic_icb_rsp_valid <= plic_icb_rsp_valid;
end
//总线写
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        plic_prt[1] <= 2'b0;
        plic_prt[2] <= 2'b0;
        plic_prt[3] <= 2'b0;
        plic_prt[4] <= 2'b0;
        plic_prt[5] <= 2'b0;
        plic_prt[6] <= 2'b0;
        plic_prt[7] <= 2'b0;
        plic_prt[8] <= 2'b0;
        plic_prt[9] <= 2'b0;
        plic_prt[10] <= 2'b0;
        plic_prt[11] <= 2'b0;
        plic_prt[12] <= 2'b0;
        plic_prt[13] <= 2'b0;
        plic_prt[14] <= 2'b0;
        plic_prt[15] <= 2'b0;
        plic_ie <= 16'h0;
        plic_ith <= 2'b0;
    end
    else begin
        if (icb_whsk) begin
            case (waddr)
                28'd4   : plic_prt[1] <= plic_icb_cmd_wdata[1:0];
                28'd8   : plic_prt[2] <= plic_icb_cmd_wdata[1:0];
                28'd12  : plic_prt[3] <= plic_icb_cmd_wdata[1:0];
                28'd16  : plic_prt[4] <= plic_icb_cmd_wdata[1:0];
                28'd20  : plic_prt[5] <= plic_icb_cmd_wdata[1:0];
                28'd24  : plic_prt[6] <= plic_icb_cmd_wdata[1:0];
                28'd28  : plic_prt[7] <= plic_icb_cmd_wdata[1:0];
                28'd32  : plic_prt[8] <= plic_icb_cmd_wdata[1:0];
                28'd36  : plic_prt[9] <= plic_icb_cmd_wdata[1:0];
                28'd40  : plic_prt[10] <= plic_icb_cmd_wdata[1:0];
                28'd44  : plic_prt[11] <= plic_icb_cmd_wdata[1:0];
                28'd48  : plic_prt[12] <= plic_icb_cmd_wdata[1:0];
                28'd52  : plic_prt[13] <= plic_icb_cmd_wdata[1:0];
                28'd56  : plic_prt[14] <= plic_icb_cmd_wdata[1:0];
                28'd60  : plic_prt[15] <= plic_icb_cmd_wdata[1:0];
                PLIC_IE : plic_ie <= plic_icb_cmd_wdata[15:0];
                PLIC_ITH: plic_ith <= plic_icb_cmd_wdata[1:0];
            endcase
        end
    end
end

always @(posedge clk) begin
    if (icb_rhsk) begin
        case (raddr)
            28'h0   : plic_icb_rsp_rdata <= 32'h0;
            28'd4   : plic_icb_rsp_rdata <= {30'h0, plic_prt[1]};
            28'd8   : plic_icb_rsp_rdata <= {30'h0, plic_prt[2]};
            28'd12  : plic_icb_rsp_rdata <= {30'h0, plic_prt[3]};
            28'd16  : plic_icb_rsp_rdata <= {30'h0, plic_prt[4]};
            28'd20  : plic_icb_rsp_rdata <= {30'h0, plic_prt[5]};
            28'd24  : plic_icb_rsp_rdata <= {30'h0, plic_prt[6]};
            28'd28  : plic_icb_rsp_rdata <= {30'h0, plic_prt[7]};
            28'd32  : plic_icb_rsp_rdata <= {30'h0, plic_prt[8]};
            28'd36  : plic_icb_rsp_rdata <= {30'h0, plic_prt[9]};
            28'd40  : plic_icb_rsp_rdata <= {30'h0, plic_prt[10]};
            28'd44  : plic_icb_rsp_rdata <= {30'h0, plic_prt[11]};
            28'd48  : plic_icb_rsp_rdata <= {30'h0, plic_prt[12]};
            28'd52  : plic_icb_rsp_rdata <= {30'h0, plic_prt[13]};
            28'd56  : plic_icb_rsp_rdata <= {30'h0, plic_prt[14]};
            28'd60  : plic_icb_rsp_rdata <= {30'h0, plic_prt[15]};
            PLIC_IP : plic_icb_rsp_rdata <= {16'h0, plic_ip};
            PLIC_IE : plic_icb_rsp_rdata <= {16'h0, plic_ie};
            PLIC_ITH: plic_icb_rsp_rdata <= {30'h0, plic_ith};
            PLIC_CPC: plic_icb_rsp_rdata <= {28'h0, plic_cpc};
            default: plic_icb_rsp_rdata <= 32'h0;
        endcase
    end
end
//写PLIC_CPC，暂时不用
//wire icb_cpc_whsk = icb_whsk & (waddr==PLIC_CPC);
//wire [3:0]icb_cpc_din = plic_icb_cmd_wdata[3:0];



/*-------------PLIC内核---------------------*/
wire [1:0]plic_pip[15:1];//中断等待位的优先级
wire [15:1]plic_pco;//中断优先级仲裁结果
wire [1:0]plic_zip[15:0];//中断优先级仲裁过程
wire [3:0]plic_zid[15:0];//中断编号仲裁过程

assign plic_zip[0] = 2'b0;
assign plic_zid[0] = 3'b0;
genvar i;//生成块循环变量
generate//中断源仲裁
for ( i=1 ; i<16 ; i=i+1 ) begin: zhongcai_gen
    assign plic_pip[i] = (plic_ip[i] & plic_ie[i]) ? plic_prt[i] : 2'b00;//生成每个中断源的优先级
    assign plic_pco[i] = (plic_pip[i]>plic_zip[i-1]) ? 1'b1 : 1'b0;//如果当前中断源优先级大于前一级的优先级
    assign plic_zip[i] = plic_pco[i] ? plic_pip[i] : plic_zip[i-1];//塞入当前中断源的优先级
    assign plic_zid[i] = plic_pco[i] ? i : plic_zid[i-1];//塞入当前中断源的ID
end
endgenerate

reg plic_eip;//EIP
always @(posedge clk) begin
    plic_eip <= (plic_zip[15]>plic_ith) ? 1'b1 : 1'b0;//最高优先级>中断阈值，中断
    plic_cpc <= plic_zid[15];//锁存ID
end
assign core_ex_trap_valid_o = plic_eip;
assign core_ex_trap_id_o = {1'b0, plic_cpc};

//控制PLIC_P
generate
    for ( i=0 ; i<16 ; i=i+1 ) begin: ctrl_gen
        always @(posedge clk or negedge rst_n) begin
            if(~rst_n) 
                plic_ip[i] <= 1'b0;
            else
                if(plic_ip[i])//IP=1
                    if(core_ex_trap_ready_i & (plic_cpc==i))//此中断源被响应
                        plic_ip[i] <= 1'b0;//清0
                    else
                        plic_ip[i] <= 1'b1;//保持
                else//IP=0
                    plic_ip[i] <= plic_irq_port[i];//接收中断信号
        end
    end
endgenerate

endmodule