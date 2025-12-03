//==============================================================
//  ALU de 32bits
//==============================================================
module ALU
(
    input  wire [31:0] A, B,   // Entradas de 32 bits
    input  wire        Ci,     // Carry-in / Borrow-in de 1 bit
    input  wire [3:0]  OP,     // Código de operación
    output reg  [31:0] OUT,    // Resultado
    output reg         Z,      // Zero flag
    output reg         N,      // Negative flag
    output reg         C,      // Carry / Borrow flag
    output reg         V       // Overflow flag
);

    // Resultado extendido a 33 bits para no perder el carry/borrow
    reg [32:0] Result;

    // Ejecuta este bloque cada vez que cualquier entrada cambie
    always @* begin
        // Reinicialización de salidas en cada evaluación
        OUT = 32'b0;
        Z   = 1'b0;
        N   = 1'b0;
        C   = 1'b0;
        V   = 1'b0;
        Result = 33'b0;

        case (OP)
            // 0000: A + B
            4'b0000: begin
                Result = {1'b0, A} + {1'b0, B};
                OUT    = Result[31:0];
                Z      = (OUT == 32'b0);
                N      = OUT[31];
                C      = Result[32];
                V      = (~(A[31] ^ B[31])) & (A[31] ^ OUT[31]);
            end

            // 0001: A + B + Ci
            4'b0001: begin
                Result = {1'b0, A} + {1'b0, B} + {32'b0, Ci};
                OUT    = Result[31:0];
                Z      = (OUT == 32'b0);
                N      = OUT[31];
                C      = Result[32];
                V      = (~(A[31] ^ B[31])) & (A[31] ^ OUT[31]);
            end

            // 0010: A - B  (A + ~B + 1)
            4'b0010: begin
                Result = {1'b0, A} + {1'b0, ~B} + 33'b1;
                OUT    = Result[31:0];
                Z      = (OUT == 32'b0);
                N      = OUT[31];
                // Borrow: 1 si A < B
                C      = (A < B);
                V      = (A[31] ^ B[31]) & (A[31] ^ OUT[31]);
            end

            // 0011: A - B - (1 - Ci)  (resta con borrow)
            4'b0011: begin
                // Si Ci=1, no restas 1; si Ci=0, restas 1 (borrow in)
                Result = {1'b0, A} + {1'b0, ~B} + {32'b0, (Ci ? 1'b0 : 1'b1)};
                OUT    = Result[31:0];
                Z      = (OUT == 32'b0);
                N      = OUT[31];
                C      = (A < B);
                V      = (A[31] ^ B[31]) & (A[31] ^ OUT[31]);
            end

            // 0100: A AND B
            4'b0100: begin
                OUT = A & B;
                Z   = (OUT == 32'b0);
                N   = OUT[31];
                C   = 1'b0;
                V   = 1'b0;
            end

            // 0101: A OR B
            4'b0101: begin
                OUT = A | B;
                Z   = (OUT == 32'b0);
                N   = OUT[31];
                C   = 1'b0;
                V   = 1'b0;
            end

            // 0110: A XOR B
            4'b0110: begin
                OUT = A ^ B;
                Z   = (OUT == 32'b0);
                N   = OUT[31];
                C   = 1'b0;
                V   = 1'b0;
            end

            // 0111: XNOR (NOT XOR)
            4'b0111: begin
                OUT = ~(A ^ B);
                Z   = (OUT == 32'b0);
                N   = OUT[31];
                C   = 1'b0;
                V   = 1'b0;
            end

            // 1000: A AND (~B)
            4'b1000: begin
                OUT = A & (~B);
                Z   = (OUT == 32'b0);
                N   = OUT[31];
                C   = 1'b0;
                V   = 1'b0;
            end

            // 1001: A OR (~B)
            4'b1001: begin
                OUT = A | (~B);
                Z   = (OUT == 32'b0);
                N   = OUT[31];
                C   = 1'b0;
                V   = 1'b0;
            end

            // 1010: A << B[4:0]
            4'b1010: begin
                OUT = A << B[4:0];
                Z   = (OUT == 32'b0);
                N   = OUT[31];
                C   = 1'b0;
                V   = 1'b0;
            end

            // 1011: A >> B[4:0] (logical shift right)
            4'b1011: begin
                OUT = A >> B[4:0];
                Z   = (OUT == 32'b0);
                N   = OUT[31];
                C   = 1'b0;
                V   = 1'b0;
            end

            // 1100: A >>> B[4:0] (arithmetic shift right)
            4'b1100: begin
                OUT = $signed(A) >>> B[4:0];
                Z   = (OUT == 32'b0);
                N   = OUT[31];
                C   = 1'b0;
                V   = 1'b0;
            end

            // 1101: OUT = A
            4'b1101: begin
                OUT = A;
                Z   = (OUT == 32'b0);
                N   = OUT[31];
                C   = 1'b0;
                V   = 1'b0;
            end

            // 1110: OUT = B
            4'b1110: begin
                OUT = B;
                Z   = (OUT == 32'b0);
                N   = OUT[31];
                C   = 1'b0;
                V   = 1'b0;
            end

            // 1111: OUT = ~B
            4'b1111: begin
                OUT = ~B;
                Z   = (OUT == 32'b0);
                N   = OUT[31];
                C   = 1'b0;
                V   = 1'b0;
            end

            default: begin
                OUT = 32'b0;
                Z   = 1'b1;
                N   = 1'b0;
                C   = 1'b0;
                V   = 1'b0;
            end
        endcase
    end

endmodule
