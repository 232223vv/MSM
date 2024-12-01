`timescale 1ns / 1ps
`define UD #1

module uart_rx # (
    parameter            BPS_NUM     =    16'd5208
//  设置波特率为4800时，  bit位宽时钟周期个数:50MHz set 10417  40MHz set 8333
//  设置波特率为9600时，  bit位宽时钟周期个数:50MHz set 5208   40MHz set 4167
//  设置波特率为115200时，bit位宽时钟周期个数:50MHz set 434    40MHz set 347
)
(
      //input ports
      input             clk,
      input             uart_rx,
      input rst_n,
      input en,
      //output ports
      output reg [7:0]  rx_data,/*synthesis PAP_MARK_DEBUG="1"*/
      output reg        rx_en, /*synthesis PAP_MARK_DEBUG="1"*/
      output            rx_finish,
      output [14:0]     wr_addr,/*synthesis PAP_MARK_DEBUG="1"*/
      output            wr_en
);



    // uart rx state machine's state
    localparam  IDLE         = 4'h0;    //空闲状态，等待开始信号到来.
    localparam  RECEIV_START = 4'h1;    //接收Uart开始信号，低电平一个波特周期.
    localparam  RECEIV_DATA  = 4'h2;    //接收Uart传输数据信号，此工程定义传输8bit，每个波特周期中间位置取值，8个周期后跳转到stop状态.
    localparam  RECEIV_STOP  = 4'h3;    //停止状态数据线是高电平，与空闲状态是一致的按照协议标准需要等待一个停止位周期再做状态跳转.
    localparam  RECEIV_END   = 4'h4;    //结束中转状态.

    //==========================================================================
    //wire and reg in the module
    //==========================================================================
    reg    [2:0]        rx_state=0;       //current state of tx state machine. 当前状态
    reg    [2:0]        rx_state_n=0;     //next state of tx state machine.    下一个状态
    reg    [7:0]        rx_data_reg;      //                                   接收数据缓冲寄存器
    reg                 uart_rx_1d;       //save uart_rx one cycle.            保存uart_rx一个时钟周期
    reg                 uart_rx_2d;       //save uart_rx one cycle.保存uart_rx 前两个时钟周期
    wire                start;            //active when start a byte receive.  检测到start信号标志
    reg    [15:0]       clk_div_cnt;      //count for division the clock.      波特周期计数器
    reg                 wr_en_temp=0;
    //==========================================================================
    //logic
    //==========================================================================
    
    //some control single.
    
    always @ (posedge clk) 
    begin
         uart_rx_1d <= `UD uart_rx;
         uart_rx_2d <= `UD  uart_rx_1d;
    end

    assign start     = (!uart_rx) && (uart_rx_1d || uart_rx_2d);
    assign rx_finish = (rx_state == RECEIV_END);


    //division the clock to satisfy baud rate.波特周期计数器
    
   
    
    parameter changeTime = 11'd1000;
    reg [5:0] numofchange; 
    reg [10:0] cntwait;
    reg writetime;
    always@(posedge clk) begin
        if(rx_finish) begin
            writetime <= 1'd1;
        end
        else if(numofchange == 6'd40) begin
            writetime <= 1'd0;
        end
        else begin
            writetime <= writetime;
        end
    end
    
    always@(posedge clk) begin
        if(writetime)begin
            if(cntwait == changeTime) begin
                cntwait <= 11'd0;
            end
            else begin
                cntwait <= cntwait + 1'd1;
            end
        end
        else begin
            cntwait <= 11'd0;
        end
    end
    
    always@(posedge clk) begin
        if(writetime) begin
            if(cntwait == changeTime) begin
                if(numofchange == 6'd40) begin
                    numofchange <= 6'd0;
                end
                else begin 
                    numofchange <= numofchange + 1'd1;
                end
            end
            else begin
                numofchange <= numofchange;
            end
        end
        else begin
            numofchange <= 6'd0;
        end
    end
    
     always @(posedge clk) begin
        if(rx_finish) begin
            wr_en_temp <= 1'd1;
        end
        else if(numofchange == 6'd40) begin
            wr_en_temp <= 1'd0;
        end
        else begin
            wr_en_temp <= wr_en_temp;
        end  
    end
    
//    reg [14:0] wr_addr_temp=0;
//    always @(posedge clk) begin
//        if(!rst_n) begin
//            wr_addr_temp<=15'b0;
//        end
//        else if(rx_finish) begin
//            if(wr_addr_temp<=32767) begin
//                wr_addr_temp<=wr_addr_temp+1;
//            end
//            else begin
//                wr_addr_temp<=15'd0;
//            end
//        end
//        else begin
//            wr_addr_temp<=wr_addr_temp;
//        end
//    end

    reg [14:0] wr_addr_temp=15'd0;
    always@(posedge clk) begin
        if(writetime) begin
            if(cntwait == changeTime) begin
                if(wr_addr_temp == 15'd32767) begin
                    wr_addr_temp <= wr_addr_temp;
                end
                else begin
                    wr_addr_temp <= wr_addr_temp + 1'd1;
                end
            end
            else begin
                wr_addr_temp <= wr_addr_temp;
            end
        end
        else begin
            wr_addr_temp <= wr_addr_temp;
        end
    end
    reg [14:0] wr_addr_temp_1;
    reg [14:0] wr_addr_temp_2;
     always @(posedge clk) begin
        if(!rst_n) begin
            wr_addr_temp_1<=15'b0;
            wr_addr_temp_2<=15'b0;
        end
       
        else begin
            wr_addr_temp_1<=wr_addr_temp;
            wr_addr_temp_2<=wr_addr_temp_1;
        end
    end
    assign wr_addr=wr_addr_temp_2;
            
    always @ (posedge clk)
    begin
        if(rx_state == IDLE || clk_div_cnt == BPS_NUM)
            clk_div_cnt   <= `UD 16'h0;
        else
            clk_div_cnt   <= `UD clk_div_cnt + 16'h1;
    end
    reg    [2:0]      rx_bit_cnt=0;
    always @ (posedge clk)
    begin
        if(rx_state == IDLE)
            rx_bit_cnt <= `UD 3'h0;
        else if((rx_bit_cnt == 3'h7) && (clk_div_cnt == BPS_NUM))
            rx_bit_cnt <= `UD 3'h0;
        else if((rx_state == RECEIV_DATA) && (clk_div_cnt == BPS_NUM))
            rx_bit_cnt <= `UD rx_bit_cnt + 3'h1;
        else 
            rx_bit_cnt <= `UD rx_bit_cnt;
    end

//==========================================================================
//receive state machine
//==========================================================================
    //状态机状态跳转
    always @(posedge clk)
    begin
        rx_state <= rx_state_n;
    end
    
    //状态机状态跳转条件及跳转规律
    always @ (*)
    begin
      case(rx_state)
          IDLE       :  
          begin
              if(start&& en)                                     //监测到start信号到来，下一状态跳转到start状态
                  rx_state_n = RECEIV_START;
              else
                  rx_state_n = rx_state;
          end
          RECEIV_START    :  
          begin
              if(clk_div_cnt == BPS_NUM)                     //已完成接收start标志信号
                  rx_state_n = RECEIV_DATA;
              else
                  rx_state_n = rx_state;
          end
          RECEIV_DATA    :  
          begin
              if(rx_bit_cnt == 3'h7 && clk_div_cnt == BPS_NUM) //已完成8bit数据的传输
                  rx_state_n = RECEIV_STOP;
              else
                  rx_state_n = rx_state;
          end
          RECEIV_STOP    :  
          begin
              if(clk_div_cnt == BPS_NUM)                       //已完成接收stop标志信号
                  rx_state_n = RECEIV_END;
              else
                  rx_state_n = rx_state;
          end
          RECEIV_END    :  
          begin
              if(!uart_rx_1d)                                  //数据线重新被拉低，表示新数据传输又发送start标志信号，需要跳转到start状态
                  rx_state_n = RECEIV_START;
              else                                             //没有其他状况出现时，回到空闲状态，等待start信号的到来
                  rx_state_n = IDLE;
          end
          default    :  rx_state_n = IDLE;
      endcase
    end
    
    // 状态机输出
    always @ (posedge clk)
    begin
        case(rx_state)
            IDLE         ,
            RECEIV_START :                               //在空闲和start状态时将接收数据缓冲寄存器和数据使能置位；
            begin
                rx_en <= `UD 1'b0;
                rx_data_reg <= `UD 8'h0;
            end
            RECEIV_DATA  :  
            begin
                if(clk_div_cnt == BPS_NUM[15:1])        //在一个波特周期的中间位置取数据线上传输的数据；
                    rx_data_reg  <= `UD {uart_rx , rx_data_reg[7:1]};  //以循环右移的方式将uart_rx数据填入缓冲寄存器的最高位（Uart传输低位在前，最后一个bit刚好是最高位）
            end
            RECEIV_STOP  : 
            begin
                rx_en   <= `UD 1'b1;                    // 输出使能信号，表示最新的数据输出有效
                rx_data <= `UD rx_data_reg;             // 将缓冲寄存器的值赋值给输出寄存器
            end
            RECEIV_END    :  
            begin
                rx_data_reg <= `UD 8'h0;
            end
            default:    rx_en <= `UD 1'b0;
        endcase
    end

endmodule