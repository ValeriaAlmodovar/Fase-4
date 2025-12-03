//==============================================================
//  mux del control unit
//==============================================================
module MuxControl (
    input  wire        flush,   // convierte a NOP
    input  wire        stall,   // mantiene señales anteriores

    // Inputs from Control Unit
    input  wire [3:0]  SOH_OP_in,
    input  wire [3:0]  ALU_OP_in,
    input  wire        RW_in,
    input  wire        E_in,
    input  wire [1:0]  SIZE_in,
    input  wire        CC_WE_in,
    input  wire        USE_CC_in,
    input  wire        J_L_in,
    input  wire        CALL_in,
    input  wire        RF_LE_in,
    input  wire [2:0]  ID_SR_in,
    input  wire        B_in,
    input  wire        L_in,

    // Outputs to ID/EX
    output reg  [3:0]  SOH_OP_out,
    output reg  [3:0]  ALU_OP_out,
    output reg         RW_out,
    output reg         E_out,
    output reg  [1:0]  SIZE_out,
    output reg         CC_WE_out,
    output reg         USE_CC_out,
    output reg         J_L_out,
    output reg          CALL_out,
    output reg         RF_LE_out,
    output reg  [2:0]  ID_SR_out,
    output reg         B_out,
    output reg         L_out
);

    always @(*) begin
        if (flush) begin
            // convertir en NOP
            SOH_OP_out = 4'b0000;
            ALU_OP_out = 4'b0000;
            RW_out     = 1'b0;
            E_out      = 1'b0;
            SIZE_out   = 2'b00;
            CC_WE_out  = 1'b0;
            USE_CC_out = 1'b0;
            J_L_out    = 1'b0;
            CALL_out   = 1'b0;
            RF_LE_out  = 1'b0;
            ID_SR_out  = 3'b000;
            B_out      = 1'b0;
            L_out      = 1'b0;
        end
        else if (stall) begin
            // mantener señales actuales (no cambiar)
            SOH_OP_out = SOH_OP_out;
            ALU_OP_out = ALU_OP_out;
            RW_out     = RW_out;
            E_out      = E_out;
            SIZE_out   = SIZE_out;
            CC_WE_out  = CC_WE_out;
            USE_CC_out = USE_CC_out;
            J_L_out    = J_L_out;
            CALL_out   = CALL_out;
            RF_LE_out  = RF_LE_out;
            ID_SR_out  = ID_SR_out;
            B_out      = B_out;
            L_out      = L_out;
        end
        else begin
            // comportamiento normal
            SOH_OP_out = SOH_OP_in;
            ALU_OP_out = ALU_OP_in;
            RW_out     = RW_in;
            E_out      = E_in;
            SIZE_out   = SIZE_in;
            CC_WE_out  = CC_WE_in;
            USE_CC_out = USE_CC_in;
            J_L_out    = J_L_in;
            CALL_out   = CALL_in;
            RF_LE_out  = RF_LE_in;
            ID_SR_out  = ID_SR_in;
            B_out      = B_in;
            L_out      = L_in;
        end
    end
endmodule
