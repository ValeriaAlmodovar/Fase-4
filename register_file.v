//=====================================================
//  REGISTER FILE (32 registros x 32 bits)
//=====================================================

module register_file (
    input        clk,
    input        reset,
    input        LE,            // write enable
    input  [4:0] RW,            // write register
    input  [4:0] RA,            // read port A
    input  [4:0] RB,            // read port B
    input  [4:0] RD,            // read port D (third read)
    input  [31:0] PW,           // write data

    output [31:0] PA,           // output A
    output [31:0] PB,           // output B
    output [31:0] PD            // output D
);

    //===========================================
    //  DECODER for write enable
    //===========================================
    wire [31:0] dec_out;

    decoder5to32 DEC (
        .a (RW),
        .en(LE),
        .y (dec_out)
    );

    //===========================================
    //  REGISTER BANK
    //===========================================
    wire [31:0] reg_out [0:31];

    // r0 is always zero
    register_zero R0 (
        .Q(reg_out[0])
    );

    genvar i;
    generate
        for (i = 1; i < 32; i = i + 1) begin : REGGEN
            register32 REG (
                .clk  (clk),
                .reset(reset),
                .LE   (dec_out[i]),
                .D    (PW),
                .Q    (reg_out[i])
            );
        end
    endgenerate

    //===========================================
    //  MUX A
    //===========================================
    mux32to1 MUXA (
        .D0 (reg_out[0]),  .D1 (reg_out[1]),  .D2 (reg_out[2]),  .D3 (reg_out[3]),
        .D4 (reg_out[4]),  .D5 (reg_out[5]),  .D6 (reg_out[6]),  .D7 (reg_out[7]),
        .D8 (reg_out[8]),  .D9 (reg_out[9]),  .D10(reg_out[10]), .D11(reg_out[11]),
        .D12(reg_out[12]), .D13(reg_out[13]), .D14(reg_out[14]), .D15(reg_out[15]),
        .D16(reg_out[16]), .D17(reg_out[17]), .D18(reg_out[18]), .D19(reg_out[19]),
        .D20(reg_out[20]), .D21(reg_out[21]), .D22(reg_out[22]), .D23(reg_out[23]),
        .D24(reg_out[24]), .D25(reg_out[25]), .D26(reg_out[26]), .D27(reg_out[27]),
        .D28(reg_out[28]), .D29(reg_out[29]), .D30(reg_out[30]), .D31(reg_out[31]),
        .S(RA),
        .Y(PA)
    );

    //===========================================
    //  MUX B
    //===========================================
    mux32to1 MUXB (
        .D0 (reg_out[0]),  .D1 (reg_out[1]),  .D2 (reg_out[2]),  .D3 (reg_out[3]),
        .D4 (reg_out[4]),  .D5 (reg_out[5]),  .D6 (reg_out[6]),  .D7 (reg_out[7]),
        .D8 (reg_out[8]),  .D9 (reg_out[9]),  .D10(reg_out[10]), .D11(reg_out[11]),
        .D12(reg_out[12]), .D13(reg_out[13]), .D14(reg_out[14]), .D15(reg_out[15]),
        .D16(reg_out[16]), .D17(reg_out[17]), .D18(reg_out[18]), .D19(reg_out[19]),
        .D20(reg_out[20]), .D21(reg_out[21]), .D22(reg_out[22]), .D23(reg_out[23]),
        .D24(reg_out[24]), .D25(reg_out[25]), .D26(reg_out[26]), .D27(reg_out[27]),
        .D28(reg_out[28]), .D29(reg_out[29]), .D30(reg_out[30]), .D31(reg_out[31]),
        .S(RB),
        .Y(PB)
    );

    //===========================================
    //  MUX D
    //===========================================
    mux32to1 MUXD (
        .D0 (reg_out[0]),  .D1 (reg_out[1]),  .D2 (reg_out[2]),  .D3 (reg_out[3]),
        .D4 (reg_out[4]),  .D5 (reg_out[5]),  .D6 (reg_out[6]),  .D7 (reg_out[7]),
        .D8 (reg_out[8]),  .D9 (reg_out[9]),  .D10(reg_out[10]), .D11(reg_out[11]),
        .D12(reg_out[12]), .D13(reg_out[13]), .D14(reg_out[14]), .D15(reg_out[15]),
        .D16(reg_out[16]), .D17(reg_out[17]), .D18(reg_out[18]), .D19(reg_out[19]),
        .D20(reg_out[20]), .D21(reg_out[21]), .D22(reg_out[22]), .D23(reg_out[23]),
        .D24(reg_out[24]), .D25(reg_out[25]), .D26(reg_out[26]), .D27(reg_out[27]),
        .D28(reg_out[28]), .D29(reg_out[29]), .D30(reg_out[30]), .D31(reg_out[31]),
        .S(RD),
        .Y(PD)
    );

endmodule
