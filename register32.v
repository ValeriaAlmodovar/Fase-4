//==============================================================
//  register32
//==============================================================

module register32 (
    input  wire       clk,
    input  wire       reset,
    input  wire       LE,     // load enable
    input  wire [31:0] D,
    output reg  [31:0] Q
);

always @(posedge clk) begin
    if (reset)
        Q <= 32'b0;
    else if (LE)
        Q <= D;
end

endmodule
