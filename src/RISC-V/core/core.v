`include "source\rtl\defines.v"
module core (
    input  wire clk,
    input  wire rst_n,


    input  wire halt_req_i,//jtag停住cpu
    output wire hx_valid,//处理器运行指示
    output wire soft_rst,//mcctr[3]软件复位

    //外部中断
    input  wire core_ex_trap_valid_i,//外部中断请求
    input  wire [4:0]core_ex_trap_id_i,//外部中断源ID
    output wire core_ex_trap_ready_o,//外部中断响应
    output wire core_ex_trap_cplet_o,//外部中断完成
    output wire [4:0]core_ex_trap_cplet_id_o,//外部中断完成的中断源ID

    //ICB总线接口 Master core
    output wire                 core_icb_cmd_valid,//cmd有效
    input  wire                 core_icb_cmd_ready,//cmd准备好
    output wire [`MemAddrBus]   core_icb_cmd_addr ,//cmd地址
    output wire                 core_icb_cmd_read ,//cmd读使能
    output wire [`MemBus]       core_icb_cmd_wdata,//cmd写数据
    output wire [3:0]           core_icb_cmd_wmask,//cmd写选通
    input  wire                 core_icb_rsp_valid,//rsp有效
    output wire                 core_icb_rsp_ready,//rsp准备好
    input  wire                 core_icb_rsp_err  ,//rsp错误
    input  wire [`MemBus]       core_icb_rsp_rdata,//rsp读数据

    //与指令存储器交互
    output wire if_req_o,//取指请求
    output wire [`InstAddrBus] if_addr_o,//取指地址
    input wire if_ack_i,//取指响应
    input wire [`InstBus] if_data_i//取指数据
);

//-------------定义内部线网--------------
wire [`MemBus] mem_wdata;//存储空间写数据
wire [`MemBus] mem_rdata;//存储空间读数据
wire [`MemAddrBus] mem_addr;//存储空间访问地址
wire [3:0] mem_wem;//存储空间写掩码

wire [`RegAddrBus] reg_raddr1;//rs1地址
wire [`RegAddrBus] reg_raddr2;//rs2地址
wire [`RegBus] reg_rdata1;//rs1数据
wire [`RegBus] reg_rdata2;//rs2数据
wire [`RegAddrBus] reg_waddr;//rd写地址
wire [`RegBus] reg_wdata;//rd写数据
wire [`InstAddrBus] idex_pc_n;//idex下一条指令PC
wire [`InstAddrBus] trap_pc_n;//中断仲裁后的下一条指令PC
wire [`InstAddrBus] pc;//当前指令的PC
wire [`InstBus] inst;//当前指令
wire [`CsrAddrBus] idex_csr_addr;//idex访问csr地址
wire [`RegBus] idex_csr_wdata;//idex写csr数据
wire [`RegBus] idex_csr_rdata;//idex读csr数据
wire [`CsrAddrBus] trap_csr_addr;//trap访问csr地址
wire [`RegBus] trap_csr_wdata;//trap写csr数据
wire [`RegBus] trap_csr_rdata;//trap读csr数据
wire [`RegBus] div_dividend;//被除数
wire [`RegBus] div_divisor;//除数
wire [2:0] div_op;//除法指令
wire [`RegBus] div_result;//除法结果
wire [`InstAddrBus] mepc;//CSR mepc寄存器
//-------------定义内部线网--------------
sctr inst_sctr
(
    .clk                (clk),
    .rst_n              (rst_n),
    .reg_we_i           (reg_we_idex),
    .csr_we_i           (csr_we_idex),
    .mem_wdata_i        (mem_wdata),
    .mem_addr_i         (mem_addr),
    .mem_we_i           (mem_we),//存储空间写使能
    .mem_wem_i          (mem_wem),
    .mem_en_i           (mem_en),
    .mem_rdata_o        (mem_rdata),
    .reg_we_o           (reg_we_sctr),
    .csr_we_o           (csr_we_sctr),
    .inst_nxt_o         (inst_nxt),
    .div_start_i        (div_start),
    .div_ready_i        (div_ready),
    .mult_inst_i        (mult_inst),
    .halt_req_i         (halt_req_i),
    .trap_in_i          (trap_in),
    .trap_jump_i        (trap_jump),
    .icb_err_o          (icb_err),//ICB总线出错
    .sctr_icb_cmd_valid (core_icb_cmd_valid),
    .sctr_icb_cmd_ready (core_icb_cmd_ready),
    .sctr_icb_cmd_addr  (core_icb_cmd_addr),
    .sctr_icb_cmd_read  (core_icb_cmd_read),
    .sctr_icb_cmd_wdata (core_icb_cmd_wdata),
    .sctr_icb_cmd_wmask (core_icb_cmd_wmask),
    .sctr_icb_rsp_valid (core_icb_rsp_valid),
    .sctr_icb_rsp_ready (core_icb_rsp_ready),
    .sctr_icb_rsp_err   (core_icb_rsp_err),
    .sctr_icb_rsp_rdata (core_icb_rsp_rdata),
    .hx_valid           (hx_valid)
);

regs inst_regs
(
    .clk         (clk),
    .rst_n       (rst_n),
    .raddr1_i    (reg_raddr1),
    .raddr2_i    (reg_raddr2),
    .rdata1_o    (reg_rdata1),
    .rdata2_o    (reg_rdata2),
    .we_i        (reg_we_sctr),
    .waddr_i     (reg_waddr),
    .wdata_i     (reg_wdata),
    .bus_raddr_i (5'b0),
    .bus_data_o  ()
);

ifu inst_ifu
(
    .clk           (clk),
    .rst_n         (rst_n),
    .pc_n_i        (trap_pc_n),
    .inst_nxt_i    (inst_nxt),  
    .pc_o          (pc),
    .inst_o        (inst),
    .inst_valid_o  (inst_valid),    
    .if_req_o      (if_req_o),
    .if_addr_o     (if_addr_o), 
    .if_ack_i      (if_ack_i),
    .if_data_i     (if_data_i)
);

idex inst_idex
(
    .clk          (clk),
    .inst_i       (inst),
    .pc_i         (pc),
    .reg_rdata1_i (reg_rdata1),
    .reg_rdata2_i (reg_rdata2),
    .csr_rdata_i  (idex_csr_rdata),
    .mem_rdata_i  (mem_rdata),
    .dividend_o   (div_dividend),
    .divisor_o    (div_divisor),
    .div_op_o     (div_op),
    .div_start_o  (div_start),
    .div_result_i (div_result),
    .mult_inst_o  (mult_inst),
    .reg_raddr1_o (reg_raddr1),
    .reg_raddr2_o (reg_raddr2),
    .reg_wdata_o  (reg_wdata),
    .reg_we_o     (reg_we_idex),
    .reg_waddr_o  (reg_waddr),
    .csr_wdata_o  (idex_csr_wdata),
    .csr_we_o     (csr_we_idex),
    .csr_addr_o   (idex_csr_addr),
    .mem_wdata_o  (mem_wdata),
    .mem_addr_o   (mem_addr),
    .mem_we_o     (mem_we),
    .mem_wem_o    (mem_wem),
    .mem_en_o     (mem_en),
    .pc_n_o       (idex_pc_n),
    .wfi_o        (wfi_trap),
    .inst_err_o   (inst_err_trap),
    .idex_mret_o  (idex_mret),
    .mepc         (mepc)
);


div inst_div
(
    .clk         (clk),
    .rst_n       (rst_n),
    .dividend_i  (div_dividend),
    .divisor_i   (div_divisor),
    .start_i     (div_start & (~trap_in)),//发生中断，立即停止除法
    .op_i        (div_op),
    .result_o    (div_result),
    .res_valid_o (div_ready),
    .res_ready_i (hx_valid)
);

csr inst_csr
(
    .clk              (clk),
    .rst_n            (rst_n),
    .idex_csr_we_i    (csr_we_sctr),
    .idex_csr_addr_i  (idex_csr_addr),
    .idex_csr_wdata_i (idex_csr_wdata),
    .idex_csr_rdata_o (idex_csr_rdata),
    .trap_csr_we_i    (trap_csr_we),
    .trap_csr_addr_i  (trap_csr_addr),
    .trap_csr_wdata_i (trap_csr_wdata),
    .trap_csr_rdata_o (trap_csr_rdata),
    .mepc             (mepc),
    .soft_rst         (soft_rst),
    .ex_trap_valid_i  (core_ex_trap_valid_i),
    .ex_trap_valid_o  (ex_trap_valid),
    .tcmp_trap_valid_o(tcmp_trap_valid),
    .soft_trap_valid_o(soft_trap_valid),
    .mstatus_MIE3     (mstatus_MIE3),
    .inst_valid_i     (inst_valid),
    .hx_valid         (hx_valid)
);

trap inst_trap
(
    .clk                (clk),
    .rst_n              (rst_n),
    .csr_rdata_i        (trap_csr_rdata),
    .csr_wdata_o        (trap_csr_wdata),
    .csr_we_o           (trap_csr_we),
    .csr_addr_o         (trap_csr_addr),
    .wfi_i              (wfi_trap),
    .inst_err_i         (inst_err_trap),
    .mem_err_i          (1'b0),//访存错误
    .tcmp_trap_valid_i  (tcmp_trap_valid),
    .soft_trap_valid_i  (soft_trap_valid),
    .mstatus_MIE3       (mstatus_MIE3),
    .pc_i               (pc),
    .inst_i             (inst),
    .mem_addr_i         (mem_addr),
    //外部中断接口
    .ex_trap_valid_i       (ex_trap_valid),//外部中断有效
    .ex_trap_id_i          (core_ex_trap_id_i),//外部中断源ID
    .ex_trap_ready_o       (core_ex_trap_ready_o),//外部中断响应
    .ex_trap_cplet_o       (core_ex_trap_cplet_o),//外部中断完成
    .ex_trap_cplet_id_o    (core_ex_trap_cplet_id_o),//外部中断完成的中断源ID
    .idex_mret_i           (idex_mret),//中断返回

    .pc_n_i             (idex_pc_n),
    .pc_n_o             (trap_pc_n),
    .inst_valid_i       (inst_valid),
    .trap_jump_o        (trap_jump),
    .trap_in_o          (trap_in)
);

endmodule