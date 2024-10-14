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
    assign da_clk = clk;

    reg [1:0] amp;
    always@(posedge clk) begin
        if(!rst_n) begin
            amp <= 3'd1;
        end
        else begin
            case(cnt_amp)
            2'd0: begin
                amp <= 2'd0;
            end
            2'd1: begin
                amp <= 2'd1;
            end
            2'd2: begin
                amp <= 2'd2;
            end
            2'd3: begin
                amp <= 2'd3;
            end
            endcase
        end
    end
    
    reg [5:0] fre_word;
    always @(posedge clk) begin
        if(!rst_n) begin
            fre_word <= 6'd40;
        end
        else begin
            case(cnt_fre)
            2'd0: begin
                fre_word <= 6'd40;
            end
            2'd1: begin
                fre_word <= 6'd20;
            end
            2'd2: begin
                fre_word <= 6'd10;
            end
            2'd3: begin
                fre_word <= 6'd5;
            end
            endcase
        end
    end

    reg [8:0] numOFsample;
    always @(posedge clk) begin
        if(!rst_n) begin
            numOFsample <= 9'd50;
        end
        else begin
            case(cnt_fre)
            2'd0: begin
                numOFsample <= 9'd50;
            end
            2'd1: begin
                numOFsample <= 9'd100;
            end
            2'd2: begin
                numOFsample <= 9'd200;
            end
            2'd3: begin
                numOFsample <= 9'd400;
            end
            endcase
        end
    end

    reg [10:0] pha_word;
    always @(posedge clk) begin
        if(!rst_n) begin
            pha_word <= 11'd0;
        end
        else begin
            case(cnt_phase)
            2'd0: begin
                pha_word <= 11'd0;
            end
            2'd1: begin
                pha_word  <= 11'd500;   
            end
            2'd2: begin
                pha_word <= 11'd1000;
            end
            2'd3: begin
                pha_word <= 11'd1500;
            end
            endcase
        end
    end

    reg [8:0] duty;
    always @(posedge clk) begin
        if(!rst_n) begin
            duty <= numOFsample * 30 / 100;
        end
        else begin
            case(cnt_phase)
            2'd0: begin
                duty <= numOFsample * 30 / 100;
            end
            2'd1: begin
                duty <= numOFsample * 50 / 100;
            end
            2'd2: begin
                duty <= numOFsample * 70 / 100;
            end
            2'd3: begin
                duty <= numOFsample * 90 / 100;
            end
            endcase
        end
    end
 
    reg [11:0] addr_temp;
    always @(posedge clk) begin
        if(!rst_n) begin
            addr_temp <= 12'd0;
        end
        else if((cnt_sig == 2'd0) && confirm) begin
            addr_temp <= pha_word + s3_data_cnt * fre_word;
        end
        else begin
            addr_temp <= 12'd0;
        end
    end

    wire [11:0] addr;
    assign addr = (addr_temp < 2000) ? addr_temp : addr_temp - 12'd2000;
    wire [7:0] sin_data;
    sin_gen u_sin_gen(
        .addr(addr[10:0]),          // input [9:0]
        .clk(clk),            // input
        .rst(!confirm),            // input
        .rd_data(sin_wave)     // output [7:0]
    );

    reg[8:0] s3_data_cnt;
    always @(posedge clk) begin
        if(!rst_n) begin
            s3_data_cnt <= 9'd0;
        end
        else if(((cnt_sig == 2'd1) | cnt_sig == 2'd3) & confirm) begin
            if(s3_data_cnt == numOFsample - 1) begin
                s3_data_cnt <= 9'd0;
            end
            else begin
                s3_data_cnt <= s3_data_cnt + 1'd1;
            end
        end
        else begin
            s3_data_cnt <= 9'd0;
        end
    end

    reg [7:0] squ_data;
    always @(posedge clk) begin
        if(!rst_n) begin
            squ_data <= 8'd0;
        end
        else if((cnt_sig == 2'd1) & confirm) begin
            if(s3_data_cnt <= duty - 1) begin
                squ_data <= 8'd0;
            end
            else begin
                squ_data <= (8'd255 >> amp);
            end
        end
        else begin
            squ_data <= 8'd0;
        end
    end

    reg [8:0] tri_data_cnt;
    reg seq_flag;
    always @(posedge clk) begin
        if(!rst_n) begin
            tri_data_cnt <= 9'd0;
            seq_flag <= 1'b0;
        end
        else if((cnt_sig == 2'd2) && confirm) begin
            if((tri_data_cnt == 9'd1) && seq_flag) begin
                tri_data_cnt <= tri_data_cnt - 1'd1;
                seq_flag <= 1'b0;
            end
            else if((tri_data_cnt == (numOFsample / 2)) && !seq_flag) begin
                tri_data_cnt <= tri_data_cnt - 1'd1;
                seq_flag <= 1'b1;
            end
            else begin
                tri_data_cnt <= seq_flag ? tri_data_cnt - 1'd1 : tri_data_cnt + 1'd1;
                seq_flag <= seq_flag;
            end
        end
        else begin
            tri_data_cnt <= 9'd0;
            seq_flag <= 1'b0;
        end
    end

    reg [7:0] tri_data;
    always @(posedge clk) begin
        if(!rst_n) begin
            tri_data <= 8'd0;
        end
        else if((cnt_sig == 2'd2) & confirm) begin
            // if(tri_data_cnt <= ((numOFsample / 2) - 1)) begin
            tri_data <= tri_data_cnt * (8'd255 >> amp) / (numOFsample / 2);
            // end
            // else begin // if(data_cnt == (numOFsample / 2)) 
            //     tri_data <= 8'd255 >> amp;
            // end
        end
        else begin
            tri_data <= 8'd0;
        end
    end

    reg [7:0] saw_data;
    always @(posedge clk) begin
        if(!rst_n) begin
            saw_data <= 8'd0;
        end
        else if((cnt_sig == 2'd3) && confirm) begin
            saw_data <= s3_data_cnt * (8'd255 >> amp) / (numOFsample - 1);
        end
        else begin
            saw_data <= 8'd0;
        end
    end

    always @(posedge clk) begin
        case(cnt_sig)
        2'd0: begin
            data_out <= (sin_data >> amp);
        end
        2'd1: begin
            data_out <= squ_data;
        end
        2'd2: begin
            data_out <= tri_data;
        end
        2'd3: begin
            data_out <= saw_data;
        end
        endcase
    end

endmodule