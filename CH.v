module CH (
    input wire [3:0] cond,
    input wire       Z_CC,
    input wire       N_CC,
    input wire       C_CC,
    input wire       V_CC,
    output reg       BR_TAKEN
);

always @(*) begin
    case (cond)
        4'b0000: BR_TAKEN = 1'b1;                         // BA - ALWAYS
        4'b0001: BR_TAKEN = (Z_CC == 1'b0);               // BNE
        4'b0010: BR_TAKEN = (Z_CC == 1'b1);               // BE
        4'b0011: BR_TAKEN = (!Z_CC && (N_CC == V_CC));    // BG
        4'b0100: BR_TAKEN = (Z_CC || (N_CC != V_CC));     // BLE
        4'b0101: BR_TAKEN = (N_CC == V_CC);               // BGE
        4'b0110: BR_TAKEN = (N_CC != V_CC);               // BL
        4'b0111: BR_TAKEN = (C_CC == 1'b1);               // BGU
        4'b1000: BR_TAKEN = (C_CC == 1'b0);               // BLEU
        4'b1001: BR_TAKEN = (C_CC == 1'b0);               // BCC
        4'b1010: BR_TAKEN = (C_CC == 1'b1);               // BCS
        4'b1011: BR_TAKEN = (N_CC == 1'b0);               // BPOS
        4'b1100: BR_TAKEN = (N_CC == 1'b1);               // BNEG
        4'b1101: BR_TAKEN = (V_CC == 1'b0);               // BVC
        4'b1110: BR_TAKEN = (V_CC == 1'b1);               // BVS
        default: BR_TAKEN = 1'b0;
    endcase

    /*$display("CH> cond=%b Z=%b N=%b C=%b V=%b => TAKE=%b",
              cond, Z_CC, N_CC, C_CC, V_CC, BR_TAKEN);*/
end

endmodule
