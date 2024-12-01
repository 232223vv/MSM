module sqrt_calculator #(
    parameter DATA_WIDTH = 32,     // ��������λ��
    parameter ITERATIONS = 16      // ţ�ٵ�������������ĵ�������������������
)(
    input wire clk,                // ʱ���ź�
    input wire [DATA_WIDTH-1:0] radicand,  // �������ƽ����
    input                           rstn,
    output reg [DATA_WIDTH-1:0] sqrt_out,   // ���ƽ����
    output reg                  cal_done
    
);

    // �ڲ��Ĵ���
    reg [DATA_WIDTH-1:0] x_n;      // ���������е�ǰ����ֵ
    reg [DATA_WIDTH-1:0] radicand_reg; // ��������Ĵ���ƽ����
    reg [4:0] iter_count;          // ���ڵ����ļ�����

    // ״̬������ź�
    reg start_iter;                // ���������ź�
    reg iter_done;                 // ��������ź�

    // ��ʼ״̬
    always @(posedge clk) begin
        if (!rstn) begin
            sqrt_out <= 0;
            x_n <= 0;
            radicand_reg <= 0;
            iter_count <= 0;
            start_iter <= 0;
            iter_done <= 0;
            cal_done  <= 0;
        end else begin
            // ����ƽ��������
            if (start_iter == 0) begin
                // ��ʼ���������ݺͳ�ʼ����ֵ
                radicand_reg <= radicand;
                x_n <= radicand >> 1;    // ��ʼ�²�ֵΪ��������1/2
                iter_count <= 0;
                start_iter <= 1;         // �������������ź�
                iter_done <= 0;
            end else if (iter_done == 0) begin
                // ţ�ٵ�����x_(n+1) = (x_n + (S / x_n)) / 2
                if (iter_count < ITERATIONS) begin
                    // ִ��һ�ε���
                    x_n <= (x_n + (radicand_reg / x_n)) >> 1;
                    iter_count <= iter_count + 1;
                end else begin
                    // ������ɣ����ƽ�������
                    sqrt_out <= x_n;
                    iter_done <= 1;      // ��ǵ�������
                    cal_done <=1;
                end
            end
        end
    end

endmodule
