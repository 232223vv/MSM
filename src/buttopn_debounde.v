module buttopn_debounde(
    clk,
    tx,
    reset,
    bd_tx,
    release_sign
    );
    input tx ;
    input clk ;
    input reset ;
    output reg bd_tx ;
    output reg release_sign ;//按下释放信号
    
    reg [1:0]edge_detect_regist;
    always@(posedge clk or negedge reset)//输入信号的移位寄存器
    begin
        if (!reset)
            edge_detect_regist <= 2'd0 ;
        else 
            begin
            edge_detect_regist[0] <= tx ;
            edge_detect_regist[1] <= edge_detect_regist[0] ;
            //等效于 edge_detect_regist <={ edge_detect_regist[0] , tx }
            end            
    end
    
    wire neg_edge , pos_edge ;
    assign neg_edge = ( edge_detect_regist == 2'b10 ) ? 1 : 0 ;//下降沿
    assign pos_edge = ( edge_detect_regist == 2'b01 ) ? 1 : 0 ;//上升沿
    
    parameter delay = 20000000 / 20 ;//抖动20ms
    
    reg [3:0]state ;   
    reg [19:0]counter1 ;
    always@(posedge clk or negedge reset)
    begin
        if (!reset)
            state <= 4'd0 ;//空闲态
        else if ( ( neg_edge ) && ( state == 4'd0 ) )
            state <= 4'd1 ;//按下消抖态
        else if ( ( state == 4'd1 ) && (( delay - 1) > counter1 ) && ( pos_edge ) )   
             state <= 4'd0 ;//空闲态
        else if ( ( state == 4'd1 ) && (( delay - 1) <= counter1 ) )
            state <= 4'd2 ;//按下态
        else if ( ( pos_edge ) && ( state == 4'd2 ) )
            state <= 4'd3 ;//释放消抖态   
        else if ( ( state == 4'd3 ) && (( delay - 1) > counter1 ) && ( neg_edge ) ) 
            state <= 4'd2 ;//按下态
        else if ( ( state == 4'd3 ) && (( delay - 1) <= counter1 ) )
            state <= 4'd0 ;//空闲态                          
    end
    

    always@(posedge clk or negedge reset)
    begin
        if (!reset)
            counter1 <= 5'd0 ;
        else if ( ( neg_edge ) || ( pos_edge ) ) 
            counter1 <= 5'd0 ;
        else if ( ( state == 4'd1 ) && (! neg_edge ) && (! pos_edge ) )
            counter1 <= counter1 + 1'd1 ;
        else if ( ( state == 4'd3 ) && (! neg_edge ) && (! pos_edge ) )
            counter1 <= counter1 + 1'd1 ;              
    end
    
    always@(posedge clk or negedge reset)
    begin
        if (!reset)
            bd_tx <= 1'd1 ;//空闲态
        else 
            case(state)
            0:bd_tx <= 1'd1 ;
            1:bd_tx <= 1'd1 ;
            2:bd_tx <= 1'd0 ;
            3:bd_tx <= 1'd0 ;
           endcase           
    end    
    
    reg pre_sign ;
    always@(posedge clk or negedge reset)
    begin
        if (!reset)
            pre_sign <= 1'd1 ;//空闲态
        else if( ( state == 4'd1 ) && (( delay - 1) <= counter1 ) )
            pre_sign <= 1'd0 ;
        else if ( state == 4'd2 )      
            pre_sign <= 1'd1 ;
    end
    
    always@(posedge clk or negedge reset)
    begin
        if (!reset)
            release_sign <= 1'd0 ;//空闲态
        else if( ( state == 4'd3 ) && (( delay - 1) <= counter1 ) )
            release_sign <= 1'd1 ;
        else if ( state == 4'd0 )      
            release_sign <= 1'd0 ;
    end       
            
endmodule