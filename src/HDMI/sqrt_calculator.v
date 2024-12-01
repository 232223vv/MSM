module sqrt_calculator #(
    parameter DATA_WIDTH = 32,     // 输入数据位宽
    parameter ITERATIONS = 16      // 牛顿迭代次数，更多的迭代次数可以提升精度
)(
    input wire clk,                // 时钟信号
    input wire [DATA_WIDTH-1:0] radicand,  // 输入待开平方数
    input                           rstn,
    output reg [DATA_WIDTH-1:0] sqrt_out,   // 输出平方根
    output reg                  cal_done
    
);

    // 内部寄存器
    reg [DATA_WIDTH-1:0] x_n;      // 迭代过程中当前估计值
    reg [DATA_WIDTH-1:0] radicand_reg; // 保存输入的待开平方数
    reg [4:0] iter_count;          // 用于迭代的计数器

    // 状态机相关信号
    reg start_iter;                // 启动迭代信号
    reg iter_done;                 // 迭代完成信号

    // 初始状态
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
            // 启动平方根计算
            if (start_iter == 0) begin
                // 初始化输入数据和初始估计值
                radicand_reg <= radicand;
                x_n <= radicand >> 1;    // 初始猜测值为输入数的1/2
                iter_count <= 0;
                start_iter <= 1;         // 设置启动迭代信号
                iter_done <= 0;
            end else if (iter_done == 0) begin
                // 牛顿迭代：x_(n+1) = (x_n + (S / x_n)) / 2
                if (iter_count < ITERATIONS) begin
                    // 执行一次迭代
                    x_n <= (x_n + (radicand_reg / x_n)) >> 1;
                    iter_count <= iter_count + 1;
                end else begin
                    // 迭代完成，输出平方根结果
                    sqrt_out <= x_n;
                    iter_done <= 1;      // 标记迭代结束
                    cal_done <=1;
                end
            end
        end
    end

endmodule
