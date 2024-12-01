/*--------------------------------
 *          参数配置区           
 */
//系统主频，必须准确设置为处理器的实际工作频率
`define CPU_CLOCK_HZ 50_000_000

//iram指令存储器大小，单位为KB
`define IRam_KB 32

//sram数据存储器大小，单位为KB
`define SRam_KB 16

//FPIOA端口数量，支持区间为[1,32]
`define FPIOA_PORT_NUM 16

//Vendor ID
`define MVENDORID_NUM 32'h114514

//微架构编号
`define MARCHID_NUM 32'd1

//线程编号
`define MHARTID_NUM 32'd0

//除法器模式，支持"HF_DIV" "HP_DIV" "SIM_DIV"
`define DIV_MODE "HF_DIV"

/*
 *          参数配置区           
 *--------------------------------*/



/*--------------------------------
 *          iram配置区           
 */
///iram指令存储器禁止按字节写入，最小写入粒度强制为对齐的4字节(32bit)。可提高综合器的兼容性，但无法使用sb sh指令访问程序存储器
//安路FPGA可能需要打开此选项
//`define IRAM_SPRAM_W4B 1'b1

//综合阶段将程序固化到FPGA内部
`define PROG_IN_FPGA 1'b1
//固化到FPGA内部的程序路径，只能导入转换后的文本文件，反斜杠"\"的必须改为"/"
//`define PROG_FPGA_PATH "../../tb/inst.txt"
`define PROG_FPGA_PATH "D:/FPGA_PDS/projects/MSM_2.0/inst.txt"

/*--------------------------------
 *          开关配置区           
 */
//使用RV32I基础整数指令集，注释掉则使用RV32E
`define RV32I_BASE_ISA 1'b1

//启用M扩展(乘法/除法)
`define RV32_M_ISA 1'b1

//启用JTAG调试，功能残废，不建议使用
`define JTAG_DBG_MODULE 1'b1

//启用单周期乘法器
`define SGCY_MUL 1'b1

//启用minstret指令计数器
`define CSR_MINSTRET_EN 1'b1

//启用外部复位数字滤波，提高复位可靠性
`define HARD_RST_DIGT_FILTER 1'b1

//稳定版本
`define STABLE_REV_RTL 1'b1

/*
 *          开关配置区           
 *--------------------------------*/

/*--------------------------------
 *          仿真配置区           
 */
//UART分频器强制为0，加快printf仿真速度
`define SIM_UART_FAST 1'b1

//启用SD卡仿真模型
//`define SIM_SD_MODEL 1'b1

//打印RTL执行程序的关键信息，见/tb/trace.log
`define SIM_TRACE_LOG 1'b1

/*
 *          仿真配置区           
 *--------------------------------*/