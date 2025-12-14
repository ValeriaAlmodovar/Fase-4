//======================================
// DecodeUnit — operand-use decoder for DUHU
//======================================
module DecodeUnit (
    input  wire [31:0] I_ID,       // instrucción en ID
    input  wire [3:0]  SOH_OP_ID,  // selector del segundo operando 
    input  wire        RW_ID,      // RW (0=load, 1=store) para op=11
    input  wire        L_ID,       // instrucción es LOAD 
    input  wire        B_ID,       // instrucción es BRANCH 
    input  wire        CALL_ID,    // instrucción es CALL 

    output reg         A_S_ID,     // rs1 se usa como operando
    output reg         B_S_ID,     // rs2 / RB se usa como operando
    output reg         D_S_ID,     // rd se usa como operando 
    output reg         ID_NOP_ID   // instrucción es NOP (burbuja)
);

    
    wire [1:0] op   = I_ID[31:30];
    wire [2:0] op2  = I_ID[24:22];
    wire [5:0] op3  = I_ID[24:19];
    wire       i_bit = I_ID[13];

    // Helper: SOH_OP indica si el segundo operando viene de inmediato
    reg uses_immediate;

    always @(*) begin
        // Detectar NOP: instrucción toda en cero => burbuja
        ID_NOP_ID = (I_ID == 32'b0);

        // Por defecto
        A_S_ID = 1'b0;
        B_S_ID = 1'b0;
        D_S_ID = 1'b0;

        // Decodificar si el segundo operando viene de inmediato
        uses_immediate =
              (SOH_OP_ID == 4'b0001)   // imm13 sign-extended
           || (SOH_OP_ID == 4'b0010)   // sethi (imm22 << 10)
           || (SOH_OP_ID == 4'b0011)   // branch displacement
           || (SOH_OP_ID == 4'b0101);  // shift immediate (si se usa)

        
        if (ID_NOP_ID) begin
            A_S_ID = 1'b0;
            B_S_ID = 1'b0;
            D_S_ID = 1'b0;
        end
        else begin
            case (op)
                //===============================
                // op = 00 → BRANCH / SETHI
                //===============================
                2'b00: begin
                    // BRANCH: usa únicamente CC, no rs1/rs2
                    // SETHI : rd = imm22 << 10, no usa rs1/rs2
                    A_S_ID = 1'b0;
                    B_S_ID = 1'b0;
                    D_S_ID = 1'b0;
                end

                //===============================
                // op = 01 → CALL
                //===============================
                2'b01: begin
                    // CALL: usa PC para calcular target, rd=%o7 para link
                    A_S_ID = 1'b0;
                    B_S_ID = 1'b0;
                    D_S_ID = 1'b0;
                end

                //===============================
                // op = 10 → ALU / JMPL
                //===============================
                2'b10: begin
                    // ALU y JMPL siempre usan rs1
                    A_S_ID = 1'b1;

                    // Segundo operando:
                    // - si viene de registro (no immediate) → usar rs2
                    // - si viene de inmediato → no usar rs2
                    if (!uses_immediate) begin
                        B_S_ID = 1'b1;
                    end
                    else begin
                        B_S_ID = 1'b0;
                    end
                    D_S_ID = 1'b0;
                end

                //===============================
                // op = 11 → LOAD / STORE
                //===============================
                2'b11: begin
                    // LOAD/STORE: siempre usan rs1 como base de dirección
                    A_S_ID = 1'b1;

                    // Para LOAD: dato viene de memoria → no se usa RB como operando
                    // Para STORE: dato a escribir viene de RB 
                    if (RW_ID == 1'b1) begin
                        // STORE
                        B_S_ID = 1'b1;  // el registro de dato sí se usa
                    end
                    else begin
                        // LOAD
                        B_S_ID = 1'b0;  // sólo base + desplazamiento
                    end

                    D_S_ID = 1'b0;  // ni load ni store leen rd como fuente
                end

                default: begin
                    A_S_ID = 1'b0;
                    B_S_ID = 1'b0;
                    D_S_ID = 1'b0;
                end
            endcase
        end
    end

endmodule
