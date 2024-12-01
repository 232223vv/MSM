`include "source\rtl\defines.v"
//总线、系统控制、阻塞
module sctr (
    input clk,
    input rst_n,

    //信号输入
    input wire  reg_we_i,                    //是否要写通用寄存器
    input wire  csr_we_i,                    //写CSR寄存器请求

    input wire [`MemBus] mem_wdata_i,       //写内存数据
    input wire [`MemAddrBus] mem_addr_i,    //访问内存地址，复用读
    input wire mem_we_i,                    //写内存使能
    input wire [3:0] mem_wem_i,             //写内存掩码
    input wire mem_en_i,                    //访问内存使能，复用读
    output wire [`MemBus] mem_rdata_o,       //读内存数据

    //信号输出
    output reg reg_we_o,                    //是否要写通用寄存器
    output reg csr_we_o,                    //写CSR寄存器请求
    output reg inst_nxt_o,                  //取下一条指令

    //阻塞指示
    input wire div_start_i,//除法启动
    input wire div_ready_i,//除法结束
    input wire mult_inst_i,//乘法开始
    input wire halt_req_i,//jtag停住cpu

    //中断相关
    input wire trap_in_i,//进中断指示
    input wire trap_jump_i,//中断跳转指示，进中断最后一步
    output wire icb_err_o,//ICB总线出错

    //ICB总线接口
    output wire                 sctr_icb_cmd_valid,//cmd有效
    input  wire                 sctr_icb_cmd_ready,//cmd准备好
    output wire [`MemAddrBus]   sctr_icb_cmd_addr ,//cmd地址
    output wire                 sctr_icb_cmd_read ,//cmd读使能
    output wire [`MemBus]       sctr_icb_cmd_wdata,//cmd写数据
    output wire [3:0]           sctr_icb_cmd_wmask,//cmd写选通
    input  wire                 sctr_icb_rsp_valid,//rsp有效
    output wire                 sctr_icb_rsp_ready,//rsp准备好
    input  wire                 sctr_icb_rsp_err  ,//rsp错误
    input  wire [`MemBus]       sctr_icb_rsp_rdata,//rsp读数据

    //回写使能
    output reg hx_valid//回写使能信号


);

//--------------FSM------------------
//0:初始阶段
//1:结束阶段
reg sta_p;
reg sta_n;
always @(posedge clk or negedge rst_n) begin//状态切换
    if (~rst_n)
        sta_p <= 1'b0;
    else
        sta_p <= sta_n;
end

always @(*) begin//状态转移条件
    if (sta_p == 1'b0) begin
        if( ~trap_in_i & ~halt_req_i & (div_start_i | mult_inst_i | ((~mem_we_i) & sctr_icb_cmd_valid & sctr_icb_cmd_ready)))//没有中断且(开始除法，或乘法指令，或读总线)
            sta_n = 1'b1;
        else
            sta_n = 1'b0;
    end 
    else begin
        if( div_ready_i | mult_inst_i | trap_in_i | halt_req_i | (sctr_icb_rsp_valid & sctr_icb_rsp_ready))//除法结束，或乘法指令，或中断，或读返回成功
            sta_n = 1'b0;
        else
            sta_n = 1'b1;
    end
end

always @(*) begin//阻塞条件hx_valid控制
    if (sta_p == 1'b0) begin//初始状态
        if( div_start_i | mult_inst_i | trap_in_i | halt_req_i | (mem_en_i & (~mem_we_i)) | (mem_en_i & mem_we_i & ~sctr_icb_cmd_ready))//开始除法，或乘法指令，或iram复位未结束，或中断，或halt，或总线等待
            hx_valid = 1'b0;
        else
            hx_valid = 1'b1;
    end
    else begin//等待结束状态
        if( ~trap_in_i & ~halt_req_i & (div_ready_i | mult_inst_i | (sctr_icb_rsp_valid & sctr_icb_rsp_ready)))//没有中断且(除法结束，或乘法指令，或读返回成功)
            hx_valid = 1'b1;
        else
            hx_valid = 1'b0;
    end
end
//--------------FSM-End--------------

always @(*) begin//reg,csr,iram写控制
    if(hx_valid) begin
        reg_we_o = reg_we_i;
        csr_we_o = csr_we_i;
        inst_nxt_o = 1'b1;
    end
    else begin
        reg_we_o = 1'b0;
        csr_we_o = 1'b0;
        if(trap_jump_i)
            inst_nxt_o = 1'b1;//发生中断，可以取指
        else
            inst_nxt_o = 1'b0;//未中断，不许取指
    end
end
assign sctr_icb_rsp_ready = 1'b1;//始终可以读返回
assign sctr_icb_cmd_read  = ~mem_we_i;//写使能反转为读使能
assign sctr_icb_cmd_addr  = {mem_addr_i[31:2], 2'b00};//写地址，屏蔽低位，字节选通替代
assign mem_rdata_o = sctr_icb_rsp_rdata;
assign sctr_icb_cmd_wdata = mem_wdata_i;//写数据
assign sctr_icb_cmd_wmask = mem_wem_i;//写数据选通
assign sctr_icb_cmd_valid = (sta_p == 1'b0)? (mem_en_i & ~trap_in_i & ~halt_req_i) : 1'b0;
assign icb_err_o = sctr_icb_rsp_err;



endmodule