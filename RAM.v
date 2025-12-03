//==============================================================
//  RAM
//==============================================================
module RAM (
    input  wire [8:0]  A,      // byte address
    input  wire [31:0] DI,     // data in (for stores)
    input  wire [1:0]  Size,   // 00=byte, 01=halfword, 10=word
    input  wire        RW,     // 0 = READ, 1 = WRITE
    input  wire        E,      // enable
    input  wire        SE,     // sign extend
    input  wire        clk,
    output reg  [31:0] DO      // data out (for loads)
);

    reg [7:0]  Mem [0:511];
    reg [15:0] halfword_buf;
    integer i;

    // ==========================================
    // PRECARGA (programa de debugging)
    // ==========================================
    initial begin
        // Initialize all memory to 0
        for (i = 0; i < 512; i = i + 1)
            Mem[i] = 8'h00;
        // Load same code as ROM
        $readmemh("debugging_code_SPARC.txt", Mem);
    end

    // ============================
    // READ  (RW == 0)
    // ============================
    always @(*) begin
        DO = 32'b0;

        if (E && !RW) begin  // READ when RW == 0
            case (Size)
                // BYTE
                2'b00: begin
                    if (SE)
                        DO = {{24{Mem[A][7]}}, Mem[A]};
                    else
                        DO = {24'b0, Mem[A]};
                end

                // HALFWORD
                2'b01: begin
                    halfword_buf = {Mem[A], Mem[A+1]};
                    if (SE)
                        DO = {{16{halfword_buf[15]}}, halfword_buf};
                    else
                        DO = {16'b0, halfword_buf};
                end

                // WORD
                2'b10: begin
                    DO = {Mem[A], Mem[A+1], Mem[A+2], Mem[A+3]};
                end
            endcase
        end
    end

    // ============================
    // WRITE (RW == 1)
    // ============================
    always @(posedge clk) begin
        if (E && RW) begin   // STORE when RW == 1
            case (Size)

                // BYTE
                2'b00: Mem[A] <= DI[7:0];

                // HALFWORD
                2'b01: begin
                    Mem[A]   <= DI[15:8];
                    Mem[A+1] <= DI[7:0];
                end

                // WORD
                2'b10: begin
                    Mem[A]   <= DI[31:24];
                    Mem[A+1] <= DI[23:16];
                    Mem[A+2] <= DI[15:8];
                    Mem[A+3] <= DI[7:0];
                end
            endcase
        end
    end

endmodule
