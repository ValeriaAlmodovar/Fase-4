//==============================================================
//  Target Address Generator
//==============================================================
module TAG (
    input  wire [31:0] PC_ID,      // PC de la instrucción en ID
    input  wire [21:0] DISP22,     // usado por BRANCH
    input  wire [29:0] DISP30,     // usado por CALL
    input  wire        CALL_ID,
    input  wire        BI_ID,      // branch tomado
    output reg  [31:0] TAG_OUT
);

    // Branch displacement: disp22 << 2
    wire [31:0] BRANCH_TARGET;
    assign BRANCH_TARGET = PC_ID + {{8{DISP22[21]}}, DISP22, 2'b00};

    // CALL displacement: disp30 << 2
    wire [31:0] CALL_TARGET;
    assign CALL_TARGET = PC_ID + {DISP30, 2'b00};

    always @(*) begin
        if (CALL_ID)
            TAG_OUT = CALL_TARGET;
        else if (BI_ID)
            TAG_OUT = BRANCH_TARGET;
        else
            TAG_OUT = 32'd0;   // no usada en secuencial
    end

endmodule
