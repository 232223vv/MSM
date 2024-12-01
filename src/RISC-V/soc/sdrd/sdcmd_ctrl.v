module sdcmd_ctrl (
    input  wire         rst_n,
    input  wire         clk,
    // SDcard signals (sdclk and sdcmd)
    output reg          sdclk,
    inout               sdcmd,
    // config clk freq
    input  wire  [15:0] clkdiv,
    // user input signal
    input  wire         start,
    input  wire  [15:0] precnt,
    input  wire  [ 5:0] cmd,
    input  wire  [31:0] arg,
    // user output signal
    output reg          busy,
    output reg          done,
    output reg          timeout,
    output reg          syntaxe,
    output wire  [31:0] resparg
);


localparam [7:0] TIMEOUT = 8'd250;

reg sdcmdoe;
reg sdcmdout;

// sdcmd tri-state driver
assign sdcmd = sdcmdoe ? sdcmdout : 1'bz;
wire sdcmdin = sdcmdoe ? 1'b1 : sdcmd;


reg  [ 5:0] req_cmd;    // request[45:40]
reg  [31:0] req_arg;    // request[39: 8]
reg  [ 6:0] req_crc;    // request[ 7: 1]
wire [51:0] request = {6'b111101, req_cmd, req_arg, req_crc, 1'b1};

reg response_st;
reg [ 5:0]response_cmd;
reg [31:0]response_arg;

assign resparg = response_arg;

reg  [17:0] clkdivr;
reg  [17:0] clkcnt;
reg  [15:0] cnt1;
reg  [ 5:0] cnt2;
reg  [ 7:0] cnt3;
reg  [ 7:0] cnt4;


always @ (posedge clk or negedge rst_n)
    if(~rst_n) begin
        {busy, done, timeout, syntaxe} <= 4'h0;
        sdclk <= 1'b0;
        {sdcmdoe, sdcmdout} <= 2'b01;
        {req_cmd, req_arg, req_crc} <= 45'd0;
        response_st <= 1'b0;
        response_cmd <= 6'd0;
        response_arg <= 32'd0;
        clkdivr <= 18'h3FFFF;
        clkcnt  <= 18'd0;
        cnt1 <= 16'd0;
        cnt2 <= 6'h3F;
        cnt3 <= 8'd0;
        cnt4 <= 8'hFF;
    end 
    else begin
        {done, timeout, syntaxe} <= 3'd0;
        
        clkcnt <= ( clkcnt < {clkdivr[16:0],1'b1} ) ? clkcnt+18'd1 : 18'd0;
        
        if(clkcnt == 18'd0)
            clkdivr <= {2'h0, clkdiv} + 18'd1;
        
        if(clkcnt == clkdivr)
            sdclk <= 1'b0;
        else if(clkcnt == {clkdivr[16:0],1'b1} )
            sdclk <= 1'b1;
        
        if(~busy) begin
            if(start) busy <= 1'b1;
            req_cmd <= cmd;
            req_arg <= arg;
            req_crc <= 7'd0;
            cnt1 <= precnt;
            cnt2 <= 6'd51;
            cnt3 <= TIMEOUT;
            cnt4 <= 8'd134;
        end else if(done) begin
            busy <= 1'b0;
        end else if( clkcnt == clkdivr) begin
            {sdcmdoe, sdcmdout} <= 2'b01;
            if(cnt1 != 16'd0) begin
                cnt1 <= cnt1 - 16'd1;
            end else if(cnt2 != 6'h3F) begin
                cnt2 <= cnt2 - 6'd1;
                {sdcmdoe, sdcmdout} <= {1'b1, request[cnt2]};
                if(cnt2>=8 && cnt2<48) req_crc <= {req_crc[5:0],req_crc[6]^request[cnt2]} ^ {3'b0,req_crc[6]^request[cnt2],3'b0};
            end
        end else if( clkcnt == {clkdivr[16:0],1'b1} && cnt1==16'd0 && cnt2==6'h3F ) begin
            if(cnt3 != 8'd0) begin
                cnt3 <= cnt3 - 8'd1;
                if(~sdcmdin)
                    cnt3 <= 8'd0;
                else if(cnt3 == 8'd1)
                    {done, timeout, syntaxe} <= 3'b110;
            end else if(cnt4 != 8'hFF) begin
                cnt4 <= cnt4 - 8'd1;
                if(cnt4 >= 8'd96) begin
                    {response_st, response_cmd, response_arg} <= {response_cmd, response_arg, sdcmdin};
                end
                if(cnt4 == 8'd0) begin
                    {done, timeout} <= 2'b10;
                    syntaxe <= response_st || ((response_cmd!=req_cmd) && (response_cmd!=6'h3F) && (response_cmd!=6'd0));
                end
            end
        end
    end

endmodule
