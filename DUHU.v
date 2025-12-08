//======================================
// HAZARD UNIT — load-use stall + CC hazard
//======================================
module hazard_unit (
    input  wire       L_EX,       // instrucción en EX es LOAD
    input  wire       RF_LE_EX,   // escribe en RF
    input  wire [4:0] RD_EX,      // destino en EX
    input  wire [4:0] RA_ID,      // rs1 en ID
    input  wire [4:0] RB_ID,      // rs2 en ID
    input  wire       CC_WE_EX,   // instrucción en EX escribe CC
    input  wire       USE_CC_ID,  // instrucción en ID usa CC (branch condicional)

    output reg        stall_F,    // frenar PC/nPC
    output reg        stall_D,    // frenar IF/ID
    output reg        flush_E     // burbuja en EX
);
    reg hazard_load_use;
    reg hazard_cc;

    always @(*) begin
        hazard_load_use = L_EX && RF_LE_EX && (RD_EX != 5'd0) &&
                         ((RD_EX == RA_ID) || (RD_EX == RB_ID));
        
        // CC hazard: addcc en EX, branch condicional en ID
        hazard_cc = CC_WE_EX && USE_CC_ID;
        
        stall_F = hazard_load_use || hazard_cc;
        stall_D = hazard_load_use || hazard_cc;
        flush_E = hazard_load_use || hazard_cc;
    end
endmodule
