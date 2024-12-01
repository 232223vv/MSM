module sample(
input clk_50M, //ϵͳʱ�� 50MHZ
input rst_n, //
input clken, //ʱ��ʹ��
input act, //��������
input [3:0]channel_sel, //ͨ��ѡ��
input [2:0]mode_sel, //ģʽѡ��
input [7:0]data_in, //�����ź�����
input [1:0]cnt_loa,
//----------------ģ������˿�----------------
output [14:0]wr_addr,
output [10:0]wr_addr_cons, //д RAM ��ַ
output [7:0]wr_data, //д RAM ����
output  wren //дʹ��
);
//----------------ģ������˿�----------------

//----------------I/O �Ĵ���----------------
reg [7:0]data_r1; //�����ź�ͬ���Ĵ���
reg [7:0]data_r2;
reg [14:0]wr_addr_temp;/*synthesis PAP_MARK_DEBUG="1"*/
reg [10:0]wr_addr_cons_temp;/*synthesis PAP_MARK_DEBUG="1"*/
//----------------�ڲ��Ĵ���----------------
reg trigger = 0; //������־
reg wren_temp = 0; /*synthesis PAP_MARK_DEBUG="1"*/
reg act_r = 0; //��ʼ�ɼ�
reg [7:0]trigger_dat; //���������Ƚ�����
//----------------�ڲ�����----------------
wire [7:0] s_posedge; //�����ر�־
wire [7:0] s_negedge; //�½��ر�־
wire [7:0] s_edge; //���ر�־
assign wr_data = data_r2; //�ɼ���������� RAM
assign wren=wren_temp;
assign wr_addr=wr_addr_temp;
assign wr_addr_cons = wr_addr_cons_temp;
//----------------ͬ�������ź�----------------
always@(posedge clk_50M) begin
    if(clken) begin
        data_r1<=data_in;//һ���Ĵ�����ֵ
        data_r2<=data_r1;//�����Ĵ�����ֵ
    end
end
assign s_posedge=data_r1&~data_r2;//�����ؼ��
assign s_negedge=~data_r1&data_r2;//�½��ؼ��
assign s_edge=data_r1^data_r2; //���ؼ��
//----------------���ݲ�ͬ�Ĵ���ģʽѡ�񴥷����ݣ�trigger_dat�� ------

always@(mode_sel or s_posedge or s_negedge or s_edge or data_r2)
    begin
        case(mode_sel)
            3'd0:trigger_dat=~data_r2; //�͵�ƽ����
            3'd1:trigger_dat=data_r2; //�ߵ�ƽ����
            3'd2:trigger_dat=s_posedge; //�����ش���
            3'd3:trigger_dat=s_negedge; //�½��ش���
            3'd4:trigger_dat=s_edge; //���ش���
            3'd5:trigger_dat=10'h3ff; //���ش���
        default:trigger_dat=10'h3ff;
    endcase
end
//----------------����Ƿ����㴥������----------------

always@(posedge clk_50M) begin
    if(trigger_dat[channel_sel]&&clken) begin
        trigger<=1;
    end
    else begin
        trigger<=0;
    end
end

reg full_flag = 1'd0;/*synthesis PAP_MARK_DEBUG="1"*/
parameter waitime = 24'd2_499_999;
always@(posedge clk_50M) begin
    if(cnt_loa != 2'd1) begin
        if(act && (wr_addr_temp == 15'd32767)) begin
            full_flag <= 1'b1;
        end
        else begin
            full_flag <= 1'b0;
        end
    end
    else if(cnt_loa == 2'd1) begin
        if(wait_cnt == waitime) begin
            full_flag <= 1'd0;
        end
        else if(wr_addr_cons_temp == 11'd1919) begin
            full_flag <= 1'd1;
        end
        else begin
            full_flag <= full_flag;
        end
    end
end


reg [23:0] wait_cnt;/*synthesis PAP_MARK_DEBUG="1"*/
always@(posedge clk_50M) begin
    if(cnt_loa == 2'd1) begin
        if(full_flag) begin
            wait_cnt <= wait_cnt +1'd1;
        end
        else begin
            wait_cnt <= 24'd0;
        end
    end
    else begin
        wait_cnt <= 24'd0;
    end
end

always@(posedge clk_50M) begin
    if(cnt_loa != 2'd1) begin
        if(clken && wren_temp) begin
            wr_addr_temp <= wr_addr_temp + 1'd1;
        end
        else if(~wren_temp) begin
            if(full_flag) begin
                wr_addr_temp <= wr_addr_temp;
            end
            else begin
                wr_addr_temp <= 15'd0;
            end
        end
        else begin
            wr_addr_temp <= wr_addr_temp;
        end
    end
    else if(cnt_loa == 2'd1) begin
        wr_addr_temp <= 15'd0;
    end
end

always@(posedge clk_50M) begin
    if(cnt_loa != 2'd1) begin
        wr_addr_cons_temp <= 11'd0;
    end
    else if(cnt_loa == 2'd1) begin
        if(!full_flag) begin
            if(clken && wren_temp) begin
                if(wr_addr_cons_temp == 11'd1919) begin
                    wr_addr_cons_temp <= 11'd0;
                end
                else begin
                    wr_addr_cons_temp <= wr_addr_cons_temp + 1'd1;
                end
            end
            else begin
                wr_addr_cons_temp <= wr_addr_cons_temp;
            end
        end
        else begin
            wr_addr_cons_temp <= 11'd0;
        end
    end
    else begin
        wr_addr_cons_temp <= 11'd0;
    end
end



//----------------���д RAM �����Ƿ�����----------------
always@(posedge clk_50M) begin
    if(cnt_loa != 2'd1) begin
        if(wr_addr_temp == 15'd32767)
            wren_temp <= 1'b0;
        else if(act && trigger)
            wren_temp <= 1'b1;
        else if(!act) begin
            wren_temp <= 1'd0;
        end
        else begin
            wren_temp <= wren_temp;
        end
    end
    else if(cnt_loa == 2'd1) begin
        if(act && trigger) begin
            wren_temp <= 1'd1;
        end
        else if(!act) begin
            wren_temp <= 1'd0;
        end
        else begin
            wren_temp <= wren_temp;
        end
    end
end
endmodule

