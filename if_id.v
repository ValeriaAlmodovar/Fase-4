module IF_ID (
    input  wire        clk,
    input  wire        reset,
    input  wire        stall,
    input  wire        flush,
    input  wire [31:0] I_in,
    input  wire [31:0] PC_in,
    input  wire [31:0] nPC_in,
    output reg  [31:0] I_out,
    output reg  [31:0] PC_out,
    output reg  [31:0] nPC_out
);
    always @(posedge clk) begin
        if (reset) begin
            I_out   <= 32'd0;
            PC_out  <= 32'd0;
            nPC_out <= 32'd0;
        end
        else if (flush) begin
            I_out   <= 32'd0;  // NOP
            PC_out  <= 32'd0;
            nPC_out <= 32'd0;
        end
        else if (stall) begin
            // mantener valores
            I_out   <= I_out;
            PC_out  <= PC_out;
            nPC_out <= nPC_out;
        end
        else begin
            I_out   <= I_in;
            PC_out  <= PC_in;
            nPC_out <= nPC_in;
        end
    end
endmodule
