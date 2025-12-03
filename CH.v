//======================================
// CH — Condition Handler 
//======================================

module CH (
    input  wire [3:0] cond,
    input  wire Z_CC,
    input  wire N_CC,
    input  wire C_CC,
    input  wire V_CC,
    output reg  BR_TAKEN
);

    wire less_signed = N_CC ^ V_CC;

    always @(*) begin
        case (cond)
            4'b0000: BR_TAKEN = 1'b0;                    // never
            4'b0001: BR_TAKEN = 1'b1;                    // always
            4'b0010: BR_TAKEN =  Z_CC;                   // equal (Z=1)
            4'b0011: BR_TAKEN = ~Z_CC;                   // not equal
            4'b0100: BR_TAKEN =  less_signed;            // less (N^V)
            4'b0101: BR_TAKEN = ~less_signed;            // >=
            4'b0110: BR_TAKEN =  less_signed | Z_CC;     // <=
            4'b0111: BR_TAKEN = ~less_signed & ~Z_CC;    // >
            4'b1000: BR_TAKEN =  N_CC;                   // negative
            4'b1001: BR_TAKEN = ~N_CC;                   // positive
            4'b1010: BR_TAKEN =  V_CC;                   // overflow set
            4'b1011: BR_TAKEN = ~V_CC;                   // overflow clear
            4'b1100: BR_TAKEN =  C_CC;                   // carry set (unsigned)
            4'b1101: BR_TAKEN = ~C_CC;                   // carry clear
            4'b1110: BR_TAKEN =  (C_CC | Z_CC);          // ≤ unsigned
            4'b1111: BR_TAKEN = ~(C_CC | Z_CC);          // > unsigned
            default: BR_TAKEN = 1'b0;
        endcase
    end

endmodule
