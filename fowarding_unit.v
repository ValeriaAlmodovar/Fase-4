//==============================================================
//  ForwardUnit 
//==============================================================

module fowarding_unit (
    input  wire [4:0] RA_EX,     // rs1 en EX (registro fuente A)
    input  wire [4:0] RB_EX,     // rs2 en EX (registro fuente B)
    input  wire [4:0] RD_MEM,    // registro destino en MEM
    input  wire [4:0] RD_WB,     // registro destino en WB
    input  wire       RF_LE_MEM, // Write enable en MEM
    input  wire       RF_LE_WB,  // Write enable en WB
    output reg  [1:0] sel_A,     // selector mux A_EX
    output reg  [1:0] sel_B      // selector mux B_EX
);

    always @(*) begin
        // Por defecto: usar los datos que vienen de ID/EX (sin forwarding)
        sel_A = 2'b00;
        sel_B = 2'b00;

        // ============================
        // Forward para operando A
        // ============================
        // 01 → tomar dato de etapa MEM
        if (RF_LE_MEM && (RD_MEM != 5'd0) && (RD_MEM == RA_EX)) begin
            sel_A = 2'b01;
        end
        // 10 → tomar dato de etapa WB (solo si no hubo match con MEM)
        else if (RF_LE_WB && (RD_WB != 5'd0) && (RD_WB == RA_EX)) begin
            sel_A = 2'b10;
        end

        // ============================
        // Forward para operando B
        // ============================
        if (RF_LE_MEM && (RD_MEM != 5'd0) && (RD_MEM == RB_EX)) begin
            sel_B = 2'b01;
        end
        else if (RF_LE_WB && (RD_WB != 5'd0) && (RD_WB == RB_EX)) begin
            sel_B = 2'b10;
        end
    end

endmodule
