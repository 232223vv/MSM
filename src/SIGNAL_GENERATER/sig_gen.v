module sig_gen(
    input clk,
    input rst_n,
    input [1:0] cnt_sig,
    input [1:0] cnt_amp,
    input [1:0] cnt_fre,
    input [1:0] cnt_phase,
    input confirm,
    output   reg [7:0] data_out,
    output da_clk
    
    );
//    reg [7:0] data_out;
    
     //    分别改变频率控制字、相位控制字
    assign da_clk = clk;
     reg [3:0] fword; 
     reg [8:0] xword;
     always @(posedge clk) begin
        if(!rst_n)
            fword<=4'b1111;
        else if(confirm) begin
            case(cnt_fre)
              2'b11:fword<=4'b0001;
              2'b10:fword<=4'b0010;
              2'b01:fword<=4'b0011;
              2'b00:fword<=4'b0101;
              default:fword<=4'b0101;
            endcase 
        end
     end 
      always @(posedge clk) begin
        if(!rst_n)
           xword<=9'd192;
        else if (confirm) begin
            case(cnt_phase)
                2'd2:xword<=9'd64;
                2'd1:xword<=9'd0;
                2'd0:xword<=9'd192;
                2'd3:xword<=9'd128;
                default:xword<=9'd192;
            endcase
        end
    end
    reg [10:0] addr;
      always@(posedge clk ) begin
        if(!rst_n)
            addr<=xword;
        else if(confirm) begin
            addr<=addr+fword;
        end
        else
            addr<=addr;
    end 
 //    用ram存储深度为256，宽度为8位的正弦信号
 wire [7:0] sin_wave;
      
      cos_gen u_cos_gen (
  .addr(addr),          // input [9:0]
  .clk(clk),            // input
  .rst(!confirm),            // input
  .rd_data(sin_wave)     // output [7:0]
);
                              reg [10:0] counter;      
    reg [10:0] period;        
    reg [7:0] high_time;     
    reg [31:0] tri_counter;      
    reg [31:0] tri_period;
    reg [31:0] tri_step_size;       
    reg direction;            
     reg [7:0] amplitude;
     reg [7:0] counter_saw;       
     reg [7:0] period_saw;        
     reg [7:0] amplitude_saw;  
     reg cnt_flag;
     reg cnt_flag_1;   
    always @(posedge clk) begin
        if(!rst_n) begin
            data_out<=8'b0;
            period <= 9'd0;
             high_time <= 8'd0;
              
             counter <= 11'd0;
             tri_step_size<=32'd0;
             tri_counter<=32'd0;
             tri_period<=32'd0;
             direction <= 1'b1;
             amplitude<=8'd0;
             counter_saw<=8'd0;       
             period_saw<=8'd0;        
             amplitude_saw<=8'd0;  
        end
        else if(!confirm) begin
            data_out<=8'b0;
        end 
        else begin
            case(cnt_sig)
                2'b00:data_out<=sin_wave<<cnt_amp;
                2'b01:begin
                        case (cnt_fre)
                            2'b11: period <= 11'd399;   
                            2'b01: period <= 9'd99;   
                            2'b10: period <= 9'd199 ;
                            2'b00: period <= 9'd49;   
                            default: period <= 9'd49; 
                            
                        endcase
                    
                    case (cnt_phase)
                        2'b00: high_time <= (period * 30) / 100;  // 30% 占空比
                        2'b01: high_time <= (period * 50) / 100;  // 50% 占空比
                        2'b10: high_time <= (period * 70) / 100;  // 70% 占空比
                        2'b11: high_time <= (period * 90) / 100; // 90% 占空比
                        default: high_time <= (period * 50) / 100; // 默认50%占空比
                    endcase
                    if(confirm) begin
                        if (counter < period) begin
                            counter <= counter + 1;
                            if (counter < high_time)
                                data_out <= 8'd255;  
                            else
                                data_out <=8 'b0;  
                            end 
                            else begin
                            counter <= 8'd0;
                            end
                        end
                    end
                    2'b10:begin
                        case (cnt_fre)
                            2'b11:begin
                                tri_period <= 32'd3;
                                tri_step_size<=32'd255/25;
                            end   
                            2'b01:begin
                                tri_period <= 32'd1; 
                                tri_step_size<=32'd255/25;
                            end  
                            2'b10:begin
                                tri_period <= 32'd2 ;
                                tri_step_size<=32'd255/25; 
                            end 
                            2'b00:begin
                                tri_period <= 32'd0;
                                tri_step_size<=32'd255/25;
                            end    
                            default: begin
                                tri_period <= 32'd100;
                                tri_step_size<=32'd255/25;
                            end 
                      
                        endcase
                        if(confirm) begin
                                 if (tri_counter >= tri_period) begin
                                        tri_counter <= 32'd0;  // 重置计数器
                                        if (direction) begin
                                            if (amplitude + tri_step_size >= 8'd255) begin
                                                amplitude <= 8'd255;  // 达到顶点后切换方向
                                                direction <= 1'b0;
                                            end 
                                            else begin
                                                amplitude <= amplitude + tri_step_size;  // 幅值递增
                                            end
                                        end 
                                        else begin
                                            if (amplitude <= tri_step_size) begin
                                                amplitude <= 8'd0;  // 达到最低点后切换方向
                                                direction <= 1'b1;
                                            end else begin
                                                amplitude <= amplitude - tri_step_size;  // 幅值递减
                                            end
                                        end
                                    end 
                                    else begin
                                        tri_counter <= tri_counter + 1;  // 计数器递增
                                    end
                                end
   
                            data_out <= amplitude;
                        end
                   
                    2'b11:begin
                        case(cnt_fre)
                            2'b11:period_saw <= 8'd4;   
                            2'b01:period_saw <= 8'd1;   
                            2'b10:period_saw <= 8'd2 ;
                            2'b00:period_saw <= 8'd0;   
                            default: period_saw <= 8'd0;
                        endcase
                        
                        if(confirm) begin
                               if (counter_saw >= period_saw) begin
                                        counter_saw <= 8'd0;  // 重置计数器
                                        if (amplitude_saw < 8'd255)
                                            amplitude_saw <= amplitude_saw + 8'd255/50;  // 幅值递增
                                        else
                                            amplitude_saw <= 8'd0;  // 达到255后重置为0
                                    end 
                                else begin
                                    counter_saw <= counter_saw + 1;  // 计数器递增
                                end
                                
                               data_out <= amplitude_saw;  
                             end  
                        end
                   
            endcase
        end
    end
endmodule