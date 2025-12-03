//==============================================================
//  MEM/WB pipeline register
//==============================================================
module MEM_WB (
    input  wire        clk,
    input  wire        reset,

    // From MEM stage
    input  wire        RF_LE_in,   // write-back enable
    input  wire        L_in,       // 1 = load (use mem), 0 = ALU
    input  wire [4:0]  rd_in,      // destination register
    input  wire [31:0] alu_in,     // ALU result from MEM stage
    input  wire [31:0] mem_in,     // data memory output
    input  wire [31:0] pc8_in,     // (optional) PC+8, if you need it

    // To WB stage
    output reg         RF_LE_out,
    output reg         L_out,
    output reg [4:0]   rd_out,
    output reg [31:0]  alu_out,
    output reg [31:0]  mem_out,
    output reg [31:0]  pc8_out
);

    always @(posedge clk) begin
        if (reset) begin
            RF_LE_out <= 1'b0;
            L_out     <= 1'b0;
            rd_out    <= 5'd0;
            alu_out   <= 32'd0;
            mem_out   <= 32'd0;
            pc8_out   <= 32'd0;
        end else begin
            RF_LE_out <= RF_LE_in;
            L_out     <= L_in;
            rd_out    <= rd_in;
            alu_out   <= alu_in;
            mem_out   <= mem_in;
            pc8_out   <= pc8_in;
        end
    end

endmodule
