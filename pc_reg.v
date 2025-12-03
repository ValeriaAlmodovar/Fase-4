//==============================================================
//  PC
//==============================================================
module pc_reg (
    input  wire        clk,
    input  wire        reset,
    input  wire        le,
    input  wire [31:0] d,
    output reg  [31:0] q
);
    always @(posedge clk) begin
        if (reset)
            q <= 32'd0;
        else if (le)
            q <= d;
    end
endmodule
