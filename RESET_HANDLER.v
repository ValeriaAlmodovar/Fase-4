//======================================
// RESET_HANDLER 
//======================================
module reset_handler (
    input  wire R,        // reset
    input  wire CALL,     // call
    input  wire J,        // branch tomado (BR_TAKEN_ID)
    input  wire BI,       // branch instruction (B_ID)
    input  wire J_L,      // jmpl
    input  wire a_bit,    // I[29] - annul bit
    output reg  [1:0] nPC_sel,
    output reg  IF_ID_R
);

    always @(*) begin
        // Default: secuencial, sin flush
        nPC_sel = 2'b00;
        IF_ID_R = 1'b0;

        if (R) begin
            // reset → PC = 0, nPC = 4 → secuencial
            nPC_sel = 2'b00;
            IF_ID_R = 1'b1;   // limpiar IF/ID
        end

        else if (J && BI) begin
            // Branch instruction tomado (J=BR_TAKEN, BI=B_ID)
            nPC_sel = 2'b01;  // usar TAG
            IF_ID_R = 1'b0;   // no flush (delay slot ejecuta)
        end

        else if (!J && BI && a_bit) begin
            // Branch instruction NO tomado (J=BR_TAKEN=0, BI=B_ID=1) con annul bit = 1
            // Flush delay slot
            nPC_sel = 2'b00;  // secuencial
            IF_ID_R = 1'b1;   // flush IF/ID
        end

        else if (CALL) begin
            // CALL salta
            nPC_sel = 2'b01;  // usar TAG
            IF_ID_R = 1'b0;   // no flush (delay slot ejecuta)
        end

        else if (J_L) begin
            // JMPL → dirección viene de ALU
            nPC_sel = 2'b10;
            IF_ID_R = 1'b0;   // no flush (delay slot ejecuta)
        end
    // ===== DEBUG: RESET HANDLER =====
    /*$display("RH> nPC_sel=%b R=%b CALL=%b J=%b BI=%b J_L=%b a_bit=%b",
         nPC_sel, R, CALL, J, BI, J_L, a_bit);*/

    end
endmodule
