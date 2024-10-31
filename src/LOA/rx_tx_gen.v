module rx_tx_gen(
    //input ports
    input         clk,
    input         uart_rx,
    
    //output ports
  
    output        uart_tx
);

   parameter      BPS_NUM = 16'd434;
   //  设置波特率为4800时，  bit位宽时钟周期个数:50MHz set 10417  40MHz set 8333
   //  设置波特率为9600时，  bit位宽时钟周期个数:50MHz set 5208   40MHz set 4167
   //  设置波特率为115200时，bit位宽时钟周期个数:50MHz set 434    40MHz set 347 12M set 104
   

//==========================================================================
//wire and reg in the module
//==========================================================================

    wire           tx_busy;         //transmitter is free.
    wire           rx_finish;       //receiver is free.
    wire    [7:0]  rx_data;         //the data receive from uart_rx.
                                    
    wire    [7:0]  tx_data;         
                                    
    wire           tx_en;           //enable transmit.

//==========================================================================

//==========================================================================
    wire rx_en;

//==========================================================================
//instance
//==========================================================================
    reg  [7:0] receive_data;
    
    uart_data_gen uart_data_gen(
        .clk                  (  clk      ),//input             clk,
        .read_data            (  receive_data ),//input      [7:0]  read_data,
        .tx_busy              (  tx_busy      ),//input             tx_busy,
        .write_max_num        (  8'h14        ),//input      [7:0]  write_max_num,
        .write_data           (  tx_data      ),//output reg [7:0]  write_data
        .write_en             (  tx_en        ) //output reg        write_en
    );
    
    //uart transmit data module.
    uart_tx #(
         .BPS_NUM            (  BPS_NUM       ) //parameter         BPS_NUM  =    16'd434
     )
     u_uart_tx(
        .clk                 (  clk         ),// input            clk,               
        .tx_data             (  tx_data       ),// input [7:0]      tx_data,           
        .tx_pluse            (  tx_en         ),// input            tx_pluse,          
        .uart_tx             (  uart_tx       ),// output reg       uart_tx,                                  
        .tx_busy             (  tx_busy       ) // output           tx_busy            
    );                                             
                                               
    //Uart receive data module.                
    uart_rx #(
         .BPS_NUM            (  BPS_NUM       ) //parameter          BPS_NUM  =    16'd434
     )
     u_uart_rx (                        
        .clk                 (  clk           ),// input             clk,                              
        .uart_rx             (  uart_rx       ),// input             uart_rx,            
        .rx_data             (  rx_data       ),// output reg [7:0]  rx_data,                                   
        .rx_en               (  rx_en         ),// output reg        rx_en,                          
        .rx_finish           (  rx_finish     ) // output            rx_finish           
    );                                            
                                                  
 
    
endmodule