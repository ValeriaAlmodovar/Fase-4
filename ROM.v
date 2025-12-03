//======================================
// ROM — almacena bytes del programa SPARC
// leer archivos HEX y unir bytes en words de 32 bits
//======================================
module ROM (
    input  wire [8:0] A,       // byte address
    output reg  [31:0] I
);

    reg [7:0] MEM [0:2047];

    initial begin
        // El archivo contiene BYTES en HEX (dos dígitos por línea)
        $readmemh("debugging_code_SPARC.txt", MEM);

        // DEBUG opcional
        $display("DEBUG: MEM[0]=%h", MEM[0]);
        $display("DEBUG: MEM[1]=%h", MEM[1]);
        $display("DEBUG: MEM[2]=%h", MEM[2]);
        $display("DEBUG: MEM[3]=%h", MEM[3]);
        $display("DEBUG: MEM[4]=%h", MEM[4]);
        $display("DEBUG: MEM[5]=%h", MEM[5]);
        $display("DEBUG: MEM[6]=%h", MEM[6]);
        $display("DEBUG: MEM[7]=%h", MEM[7]);
        $display("DEBUG: MEM[8]=%h", MEM[8]);
        $display("DEBUG: MEM[9]=%h", MEM[9]);
        $display("DEBUG: MEM[10]=%h", MEM[10]);
        $display("DEBUG: MEM[11]=%h", MEM[11]);
    end

    always @(*) begin
        // ensamblar en BIG-ENDIAN (SPARC)
        I = { MEM[A], MEM[A+1], MEM[A+2], MEM[A+3] };
    end

endmodule
