//======================================
// REG_CC — Registro de Condition Codes
// Guarda Z, N, C, V desde la ALU (EX)
//======================================

module REG_CC (
    input  wire clk,
    input  wire reset,

    input  wire CC_WE_EX,   // write-enable desde EX
    input  wire Z_EX,
    input  wire N_EX,
    input  wire C_EX,
    input  wire V_EX,

    output reg Z_CC,
    output reg N_CC,
    output reg C_CC,
    output reg V_CC
);

    always @(posedge clk) begin
        if (reset) begin
            Z_CC <= 1'b0;
            N_CC <= 1'b0;
            C_CC <= 1'b0;
            V_CC <= 1'b0;
        end 
        else if (CC_WE_EX) begin
            Z_CC <= Z_EX;
            N_CC <= N_EX;
            C_CC <= C_EX;
            V_CC <= V_EX;
        end
    end

endmodule
