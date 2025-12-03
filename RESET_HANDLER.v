//======================================
// RESET_HANDLER 
//======================================
module reset_handler (
    input  wire R,        // reset
    input  wire CALL,     // call
    input  wire J,        // jump 
    input  wire BI,       // branch tomado
    input  wire J_L,      // jmpl
    input  wire a_bit,    // I[29]
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

        else if (BI) begin
            // Branch tomado
            nPC_sel = 2'b01;  // usar TAG
            //IF_ID_R = 1'b1;   // flush
        end

        else if (CALL) begin
            // CALL salta igual que branch, pero PC+8 se escribe
            nPC_sel = 2'b01;  // usar TAG
            //IF_ID_R = 1'b1;   // flush
        end

        else if (J_L || J) begin
            // JMPL → dirección viene de ALU
            nPC_sel = 2'b10;
            IF_ID_R = 1'b1;   // flush
        end
    end
endmodule
