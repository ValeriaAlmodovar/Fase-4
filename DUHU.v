//===============================================================
// DUHU — Data Unit + Hazard Unit
//===============================================================
module DUHU (
    // ===============================
    // Operand-use info (from Decode / ID_EX)
    // ===============================
    input  wire        A_S_EX,      // rs1 used
    input  wire        B_S_EX,      // rs2 used
    input  wire        D_S_EX,      // rd used as source 
    input  wire        SR_EX,       // shift-by-register uses rs2
    input  wire        ID_NOP_EX,   // bubble / NOP in EX

    // ===============================
    // Register numbers
    // ===============================
    input  wire [4:0]  RA_ID,       // rs1 in ID
    input  wire [4:0]  RB_ID,       // rs2 in ID
    input  wire [4:0]  RD_ID,       // rd in ID (for stores)
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
    // Outputs: EX forwarding
    // ===============================
    output reg  [1:0]  sel_A,
    output reg  [1:0]  sel_B,

    // ===============================
    // Outputs: ID forwarding
    // ===============================
    output reg  [1:0]  A_S,         // forward to PA in ID
    output reg  [1:0]  B_S,         // forward to PB in ID
    output reg  [1:0]  D_S,         // forward to PD in ID

    // ===============================
    // Outputs: pipeline control
    // ===============================
    output reg         stall_F,
    output reg         stall_D,
    output reg         flush_E
);

    //===========================================================
    // 1. EX STAGE FORWARDING
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
    // 2. ID STAGE FORWARDING (from EX/MEM/WB to register file outputs)
    //===========================================================
    always @(*) begin
        // defaults
        A_S = 2'b00;
        B_S = 2'b00;
        D_S = 2'b00;

        // ---------- PA (rs1 in ID) ----------
        if (RA_ID != 5'd0) begin
            if (RF_LE_EX && RD_EX == RA_ID && !ID_NOP_EX)
                A_S = 2'b11;   // from EX (new priority)
            else if (RF_LE_MEM && RD_MEM == RA_ID)
                A_S = 2'b01;   // from MEM
            else if (RF_LE_WB && RD_WB == RA_ID)
                A_S = 2'b10;   // from WB
        end

        // ---------- PB (rs2 in ID) ----------
        if (RB_ID != 5'd0) begin
            if (RF_LE_EX && RD_EX == RB_ID && !ID_NOP_EX)
                B_S = 2'b11;   // from EX (new priority)
            else if (RF_LE_MEM && RD_MEM == RB_ID)
                B_S = 2'b01;   // from MEM
            else if (RF_LE_WB && RD_WB == RB_ID)
                B_S = 2'b10;   // from WB
        end

        // ---------- PD (rd in ID, for stores) ----------
        if (RD_ID != 5'd0) begin
            if (RF_LE_EX && RD_EX == RD_ID && !ID_NOP_EX)
                D_S = 2'b11;   // from EX (new priority)
            else if (RF_LE_MEM && RD_MEM == RD_ID)
                D_S = 2'b01;   // from MEM
            else if (RF_LE_WB && RD_WB == RD_ID)
                D_S = 2'b10;   // from WB
        end
    end

    //===========================================================
    // 3. HAZARD DETECTION
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
