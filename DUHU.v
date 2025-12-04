//======================================
// HAZARD UNIT — load-use stall
//======================================
module hazard_unit (
    input  wire       L_EX,       // instrucción en EX es LOAD
    input  wire       RF_LE_EX,   // escribe en RF
    input  wire [4:0] RD_EX,      // destino en EX
    input  wire [4:0] RA_ID,      // rs1 en ID
    input  wire [4:0] RB_ID,      // rs2 en ID

    output reg        stall_F,    // frenar PC/nPC
    output reg        stall_D,    // frenar IF/ID
    output reg        flush_E     // burbuja en EX
);
    reg hazard_load_use;

    always @(*) begin
        hazard_load_use = L_EX && RF_LE_EX && (RD_EX != 5'd0) &&
                         ((RD_EX == RA_ID) || (RD_EX == RB_ID));
        
        stall_F = hazard_load_use;
        stall_D = hazard_load_use;
        flush_E = hazard_load_use;
    end
endmodule
