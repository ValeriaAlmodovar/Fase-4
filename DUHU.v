//===============================================================
// DUHU — Data Unit + Hazard Unit
// Implements forwarding + hazard detection according to SPARC
//===============================================================
module DUHU (
    // ===============================
    // Operand-use info (from Decode / ID_EX)
    // ===============================
    input  wire        A_S_EX,      // rs1 used
    input  wire        B_S_EX,      // rs2 used
    input  wire        D_S_EX,      // rd used as source (rare)
    input  wire        SR_EX,       // shift-by-register uses rs2
    input  wire        ID_NOP_EX,   // bubble / NOP in EX

    // ===============================
    // Register numbers
    // ===============================
    input  wire [4:0]  RA_EX,
    input  wire [4:0]  RB_EX,
    input  wire [4:0]  RD_EX,
    input  wire [4:0]  RD_MEM,
    input  wire [4:0]  RD_WB,

    // ===============================
    // Write enables
    // ===============================
    input  wire        RF_LE_EX,
    input  wire        RF_LE_MEM,
    input  wire        RF_LE_WB,

    // ===============================
    // Load / CC hazard info
    // ===============================
    input  wire        L_EX,        // EX is a load
    input  wire        CC_WE_EX,    // EX writes condition codes
    input  wire        USE_CC_ID,   // ID instruction uses CC (branch)

    // ===============================
    // Outputs: forwarding
    // ===============================
    output reg  [1:0]  sel_A,
    output reg  [1:0]  sel_B,

    // ===============================
    // Outputs: pipeline control
    // ===============================
    output reg         stall_F,
    output reg         stall_D,
    output reg         flush_E
);

    //===========================================================
    // 1. FORWARDING LOGIC
    //===========================================================
    always @(*) begin
        // defaults
        sel_A = 2'b00;
        sel_B = 2'b00;

        // ---------- Operand A (rs1) ----------
        if (A_S_EX && !ID_NOP_EX) begin
            if (RF_LE_MEM && RD_MEM != 5'd0 && RD_MEM == RA_EX)
                sel_A = 2'b01;   // from MEM
            else if (RF_LE_WB && RD_WB != 5'd0 && RD_WB == RA_EX)
                sel_A = 2'b10;   // from WB
        end

        // ---------- Operand B (rs2 / shift) ----------
        if ((B_S_EX || SR_EX) && !ID_NOP_EX) begin
            if (RF_LE_MEM && RD_MEM != 5'd0 && RD_MEM == RB_EX)
                sel_B = 2'b01;   // from MEM
            else if (RF_LE_WB && RD_WB != 5'd0 && RD_WB == RB_EX)
                sel_B = 2'b10;   // from WB
        end
    end

    //===========================================================
    // 2. HAZARD DETECTION
    //===========================================================

    // ---------- Load-use RAW hazard ----------
    wire hazard_load_use =
        L_EX && RF_LE_EX && (RD_EX != 5'd0) &&
        (
            (A_S_EX && RA_EX == RD_EX) ||
            ((B_S_EX || SR_EX) && RB_EX == RD_EX)
        );

    // ---------- Condition-code hazard ----------
    wire hazard_cc = CC_WE_EX && USE_CC_ID;

    //===========================================================
    // 3. STALL / FLUSH CONTROL
    //===========================================================
    always @(*) begin
        if (ID_NOP_EX) begin
            // never stall on bubbles
            stall_F = 1'b0;
            stall_D = 1'b0;
            flush_E = 1'b0;
        end
        else if (hazard_load_use || hazard_cc) begin
            stall_F = 1'b1;
            stall_D = 1'b1;
            flush_E = 1'b1;
        end
        else begin
            stall_F = 1'b0;
            stall_D = 1'b0;
            flush_E = 1'b0;
        end
    end

endmodule
