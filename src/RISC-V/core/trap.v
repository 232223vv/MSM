`include "source\rtl\defines.v"
module trap (
    input clk,
    input rst_n,

    //csr接口
    input wire[`RegBus] csr_rdata_i,        //读CSR寄存器数据
    output reg[`RegBus] csr_wdata_o,        //写CSR寄存器数据
    output reg csr_we_o,                    //写CSR寄存器请求
    output reg[`CsrAddrBus] csr_addr_o,     //访问CSR寄存器地址

    //异常输入接口
    input wire inst_err_i,//指令解码错误中断
    input wire mem_err_i,//访存错误

    //核内中断输入接口
    input wire tcmp_trap_valid_i,//定时器中断，需锁存
    input wire soft_trap_valid_i,//软件中断，需锁存

    input wire mstatus_MIE3,//全局中断使能标志
    input wire wfi_i,//wfi指令休眠

    input wire[`InstAddrBus] pc_i,            //当前条指令地址
    input wire[`InstBus] inst_i,              //指令内容
    input wire [`MemAddrBus] mem_addr_i,      //访存地址

    //外部中断响应接口，由PLIC统一管理并送入核内
    input wire ex_trap_valid_i,//外部中断有效，需锁存
    input wire [4:0]ex_trap_id_i,//外部中断源ID
    output reg ex_trap_ready_o,//外部中断响应
    output reg ex_trap_cplet_o,//外部中断完成
    output reg [4:0]ex_trap_cplet_id_o,//外部中断完成的中断源ID

    //下一个PC控制
    input wire[`InstAddrBus] pc_n_i,          //idex提供的下一条指令地址
    output reg[`InstAddrBus] pc_n_o,          //仲裁后的下一条指令地址
    input wire inst_valid_i,                  //当前指令有效
    output reg trap_jump_o,                   //中断跳转指示

    //MRET中断返回
    input wire idex_mret_i,//中断返回

    //进中断指示
    output reg trap_in_o//即将进入中断的时候，持续拉高
);
/*
Trap编码表，关联mcause
| Number | 原因 |
|--------|------|
| 0      | 保留          |
| 1      | 异常，不可屏蔽 |
| 2      | 软件中断       |
| 3      | 定时器中断     |
| 4-19   | PLIC外部中断  |
| 20-63  | 保留          |
来自PLIC外部中断的编码为 中断源ID + 4

*/
//trap主状态机
reg [2:0]sta_n,sta_p;//下一状态sta_n,当前状态sta_p
//状态定义
localparam IDLE = 3'd0;//空闲状态
localparam SWFI = 3'd1;//等待中断状态
localparam CMIE = 3'd2;//关闭全局中断mstatus->MPIE=MIE,MIE=0
localparam WRPC = 3'd3;//写返回地址mepc=PCn
localparam WMCA = 3'd4;//写异常原因mcause
localparam RTVA = 3'd5;//写异常值寄存器mtval
localparam JVPC = 3'd6;//跳转到中断入口PC=mtvec[31:2]，使能
localparam JVIF = 3'd7;//等待取指完成

//外部中断状态
reg ex_trap_state;

//-------进中断需要锁存的信息-----
reg pex_trap_r;//外部中断
reg ptcmp_trap_r;//定时器中断
reg psoft_trap_r;//软件中断

//-------进入陷阱使能-----
wire trap_exception_en = inst_err_i | mem_err_i;//有异常到达，不可屏蔽
wire trap_interrupt_en = ex_trap_valid_i | tcmp_trap_valid_i | soft_trap_valid_i;//有中断到达，可屏蔽

reg [`RegBus] mcause_gen;//生成mcause信息
reg [`RegBus] mtval_gen;//生成mtval信息
wire [5:0] trap_number = mcause_gen[5:0];//Trap编码，用于生成中断向量

always @(*) begin
    ex_trap_ready_o = 0;
    if(trap_interrupt_en) begin//中断
        mcause_gen[31] = 1'b1;//中断位
        if(pex_trap_r) begin//优先外部中断 
            mcause_gen[30:0] = ex_trap_cplet_id_o + 31'd4;
            ex_trap_ready_o  = (sta_p==CMIE) ? 1'b1 : 1'b0;//状态机在CMIE响应PLIC
        end
        else
            if(ptcmp_trap_r) begin//其次定时器中断
                mcause_gen[30:0] = 31'd3;
            end
            else
            begin//其次软件中断
                mcause_gen[30:0] = 31'd2;
            end
    end
    else begin//异常
        mcause_gen[31] = 1'b0;
        mcause_gen[30:0] = trap_exception_en ? 31'h1 : 31'h0;//异常统一入口
    end
end

always @(*) begin//生成异常原因
    if(trap_exception_en)
        if(inst_err_i)
            mtval_gen = inst_i;
        else
            mtval_gen = mem_addr_i;
    else
        mtval_gen = 0;
    
end



//--------------FSM------------------
always @(posedge clk or negedge rst_n) begin//状态切换
    if (~rst_n)
        sta_p <= IDLE;
    else
        sta_p <= sta_n;
end

always @(*) begin //状态转移条件
    case (sta_p)
        IDLE: begin//空闲状态
            if(trap_exception_en)//异常
                sta_n = CMIE;
            else
                if(mstatus_MIE3)//全局中断开
                    if(trap_interrupt_en)//中断
                        sta_n = CMIE;
                    else//没中断
                        if(wfi_i)//中断等待
                            sta_n = SWFI;
                        else//正常执行
                            sta_n = IDLE;
                else//全局中断关
                    if(wfi_i)//中断等待
                        sta_n = SWFI;
                    else//正常执行
                        sta_n = IDLE;
        end
        SWFI: begin//等待中断状态
            if(trap_exception_en)//异常
                sta_n = CMIE;
            else
                if(mstatus_MIE3)//全局中断开
                    if(trap_interrupt_en)//中断
                        sta_n = CMIE;
                    else//没中断
                        sta_n = SWFI;
                else//全局中断关
                    if(trap_interrupt_en)//中断
                        sta_n = IDLE;
                    else//正常执行
                        sta_n = SWFI;
        end
        CMIE: begin//关闭全局中断mstatus->MPIE=MIE,MIE=0
            sta_n = WRPC;
        end
        WRPC: begin//写返回地址mepc=PCn
            sta_n = WMCA;
        end
        WMCA: begin//写异常原因mcause
            sta_n = RTVA;
        end
        RTVA: begin//写异常值寄存器mtval
            sta_n = JVPC;
        end
        JVPC: begin//跳转到中断入口PC=mtvec[31:2]，使能
            sta_n = JVIF;
        end
        JVIF: begin//等待取指完成
            if (inst_valid_i)//指令有效，跳转完成
                sta_n = IDLE;
            else
                sta_n = JVPC;
        end
    endcase
end

always @(*) begin //输出
    csr_wdata_o=0;
    csr_we_o=0;
    csr_addr_o=0;
    trap_in_o=0;
    trap_jump_o=0;
    pc_n_o=pc_n_i;
    case (sta_p)
        IDLE: begin//空闲状态
            if(trap_exception_en)//异常
                trap_in_o=1;
            else
                if(mstatus_MIE3)//全局中断开
                    if(trap_interrupt_en)//中断
                        trap_in_o=1;
                    else//没中断
                        trap_in_o=0;
                else//全局中断关
                    trap_in_o=0;
        end
        SWFI: begin//等待中断状态
            trap_in_o=1;
        end
        CMIE: begin//关闭全局中断mstatus->MPIE=MIE,MIE=0
            trap_in_o=1;
            csr_wdata_o={csr_rdata_i[31:8],csr_rdata_i[3],csr_rdata_i[6:4],1'b0,csr_rdata_i[2:0]};
            csr_we_o=1;
            csr_addr_o=`CSR_MSTATUS;
        end
        WRPC: begin//写返回地址mepc=PC
            trap_in_o=1;
            csr_wdata_o=pc_i;
            csr_we_o=1;
            csr_addr_o=`CSR_MEPC;
        end
        WMCA: begin//写异常原因mcause
            trap_in_o=1;
            csr_wdata_o=mcause_gen;
            csr_we_o=1;
            csr_addr_o=`CSR_MCAUSE;
        end
        RTVA: begin//写异常值寄存器mtval
            trap_in_o=1;
            csr_wdata_o=mtval_gen;
            csr_we_o=1;
            csr_addr_o=`CSR_MTVAL;
        end
        JVPC: begin//跳转到中断入口PC=mtvec[31:2]，使能
            trap_in_o=1;
            trap_jump_o=1;//PC跳转
            csr_we_o=0;//读mtvec
            csr_addr_o=`CSR_MTVEC;
            pc_n_o={csr_rdata_i[31:2],2'b00}+{trap_number,2'b00};
        end
        JVIF: begin//等跳转完成
            trap_in_o=1;
            trap_jump_o=1;//PC跳转
            csr_we_o=0;//读mtvec
            csr_addr_o=`CSR_MTVEC;
            pc_n_o={csr_rdata_i[31:2],2'b00}+{trap_number,2'b00};
        end
    endcase
end

//--------------FSM------------------


always @(posedge clk) begin
    if(sta_n == CMIE) begin//若即将进入中断/异常，则锁存必要信息
        pex_trap_r   <= ex_trap_valid_i   ;//锁存外部中断
        ptcmp_trap_r <= tcmp_trap_valid_i ;//锁存定时器中断
        psoft_trap_r <= soft_trap_valid_i ;//锁存软件中断     
    end
    else begin
        
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ex_trap_state <= 1'b0;
        ex_trap_cplet_o <= 1'b0;
        ex_trap_cplet_id_o <= 5'h0;
    end
    else begin
        if(pex_trap_r && ex_trap_ready_o) begin//进入外部中断
            ex_trap_cplet_id_o <= ex_trap_id_i;//锁存ID
            ex_trap_state <= 1'b1;//进入中断状态
        end
        else 
            if(idex_mret_i) begin//外部中断返回
                ex_trap_cplet_o <= 1'b1;//中断完成
                ex_trap_state <= 1'b0;//脱离中断状态
                ex_trap_cplet_id_o <= 5'h0;//ID清0
            end
            else begin
                ex_trap_cplet_o <= 1'b0;
            end
    end
end

endmodule