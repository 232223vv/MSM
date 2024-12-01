`include "config.v"

`define IRamSize (`IRam_KB*1024/4) //kB->B->4B
`define SRamSize (`SRam_KB*1024/4) //kB->B->4B
`define RstPC 32'h0000_0000 //复位后PC值在0000

`ifdef STABLE_REV_RTL
`define STABLE_REV_RTL 1'b1
`else
`define STABLE_REV_RTL 1'b0
`endif


`ifdef HDL_SIM//仿真模式
   `ifdef SIM_UART_FAST//加快printf
      `define UART_DIV_ZERO 1'b1  //定义uart分频系数=0
   `endif
`endif


// I type inst
`define INST_TYPE_I 7'b0010011
`define INST_ADDI   3'b000
`define INST_SLTI   3'b010
`define INST_SLTIU  3'b011
`define INST_XORI   3'b100
`define INST_ORI    3'b110
`define INST_ANDI   3'b111
`define INST_SLLI   3'b001
`define INST_SRI    3'b101

// L type inst
`define INST_TYPE_L 7'b0000011
`define INST_LB     3'b000
`define INST_LH     3'b001
`define INST_LW     3'b010
`define INST_LBU    3'b100
`define INST_LHU    3'b101

// S type inst
`define INST_TYPE_S 7'b0100011
`define INST_SB     3'b000
`define INST_SH     3'b001
`define INST_SW     3'b010

// R and M type inst
`define INST_TYPE_R_M 7'b0110011
// R type inst
`define INST_ADD    3'b000
`define INST_SUB    3'b000
`define INST_SLL    3'b001
`define INST_SLT    3'b010
`define INST_SLTU   3'b011
`define INST_XOR    3'b100
`define INST_SRA    3'b101
`define INST_SRL    3'b101
`define INST_OR     3'b110
`define INST_AND    3'b111
// M type inst
`define INST_MUL    3'b000
`define INST_MULH   3'b001
`define INST_MULHSU 3'b010
`define INST_MULHU  3'b011
`define INST_DIV    3'b100
`define INST_DIVU   3'b101
`define INST_REM    3'b110
`define INST_REMU   3'b111

// J type inst
`define INST_JAL    7'b1101111
`define INST_JALR   7'b1100111

`define INST_LUI    7'b0110111
`define INST_AUIPC  7'b0010111
`define INST_RET    32'h00008067

// J type inst
`define INST_TYPE_B 7'b1100011
`define INST_BEQ    3'b000
`define INST_BNE    3'b001
`define INST_BLT    3'b100
`define INST_BGE    3'b101
`define INST_BLTU   3'b110
`define INST_BGEU   3'b111

// CSR inst
`define INST_SYS    7'b1110011
//fun3
`define INST_CSRRW  3'b001
`define INST_CSRRS  3'b010
`define INST_CSRRC  3'b011
`define INST_CSRRWI 3'b101
`define INST_CSRRSI 3'b110
`define INST_CSRRCI 3'b111
//特殊指令fun3=0,inst_i[31:15]
`define INST_SI     3'b000
`define INST_ECALL  17'h0
`define INST_EBREAK 17'b000000000001_00000
`define INST_MRET   17'b0011000_00010_00000
`define INST_WFI    17'b0001000_00101_00000

// CSR addr
`define CSR_MSTATUS    12'h300
`define CSR_MISA       12'h301
`define CSR_MIE        12'h304
`define CSR_MTVEC      12'h305
`define CSR_MSCRATCH   12'h340
`define CSR_MEPC       12'h341
`define CSR_MCAUSE     12'h342
`define CSR_MTVAL      12'h343
`define CSR_MIP        12'h344
`define CSR_MSIP       12'h345
`define CSR_MPRINTS    12'h346//sim标准输出
`define CSR_MENDS      12'h347//仿真结束

`define CSR_MINSTRET   12'hB02//
`define CSR_MINSTRETH  12'hB82//
`define CSR_MTIME      12'hB03//
`define CSR_MTIMEH     12'hB83//
`define CSR_MTIMECMP   12'hB04//
`define CSR_MTIMECMPH  12'hB84//
`define CSR_MCCTR      12'hB88//系统控制

`define CSR_MVENDORID  12'hF11
`define CSR_MARCHID    12'hF12
`define CSR_MIMPID     12'hF13
`define CSR_MHARTID    12'hF14



`define MemBus 31:0
`define MemAddrBus 31:0
`define CsrAddrBus 11:0

`define InstBus 31:0
`define InstAddrBus 31:0

// common regs
`define RegAddrBus 4:0
`define RegBus 31:0
`define RegWidth 32

//trap类型
`define TRAP_EXCEP  32'h0000_0001 //系统异常
`define TRAP_ZERO   32'h8000_0000 //中断0 保留
`define TRAP_ERESV  32'h8000_0001 //中断1 异常保留
`define TRAP_SOFTI  32'h8000_0002 //中断2 软件中断
`define TRAP_TIMER  32'h8000_0003 //中断3 定时器中断
`define TRAP_PLIC0  32'h8000_0004 //中断4  PLIC0
`define TRAP_PLIC1  32'h8000_0005 //中断5  PLIC1
`define TRAP_PLIC2  32'h8000_0006 //中断6  PLIC2
`define TRAP_PLIC3  32'h8000_0007 //中断7  PLIC3
`define TRAP_PLIC4  32'h8000_0008 //中断8  PLIC4
`define TRAP_PLIC5  32'h8000_0009 //中断9  PLIC5
`define TRAP_PLIC6  32'h8000_000a //中断10 PLIC6
`define TRAP_PLIC7  32'h8000_000b //中断11 PLIC7
`define TRAP_PLIC8  32'h8000_000c //中断12 PLIC8
`define TRAP_PLIC9  32'h8000_000d //中断13 PLIC9
`define TRAP_PLIC10 32'h8000_000e //中断14 PLIC10
`define TRAP_PLIC11 32'h8000_000f //中断15 PLIC11
`define TRAP_PLIC12 32'h8000_0010 //中断16 PLIC12
`define TRAP_PLIC13 32'h8000_0011 //中断17 PLIC13
`define TRAP_PLIC14 32'h8000_0012 //中断18 PLIC14
`define TRAP_PLIC15 32'h8000_0013 //中断19 PLIC15
`define TRAP_NULL   32'h8000_0014 //中断20 空闲
