//======================================
// ROM — almacena bytes del programa SPARC
// leer archivos HEX y unir bytes en words de 32 bits
//======================================
module ROM (
    input  wire [8:0] A,       // byte address
    output reg  [31:0] I
);

    reg [7:0] MEM [0:2047];

    

    always @(*) begin
        // ensamblar en BIG-ENDIAN (SPARC)
        I = { MEM[A], MEM[A+1], MEM[A+2], MEM[A+3] };
    end

endmodule
