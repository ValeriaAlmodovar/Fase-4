//==============================================================
//  RAM - Data Memory (512 bytes, async, if(load)/else(store))
//==============================================================
module RAM (
    input  wire [8:0]  A,      // byte address 0–511
    input  wire [31:0] DI,     // data in (for stores)
    input  wire [1:0]  Size,   // 00=byte, 01=halfword, 10=word
    input  wire        RW,     // 0 = READ (load), 1 = WRITE (store)
    input  wire        E,      // enable
    input  wire        SE,     // sign extend for loads
    output reg  [31:0] DO      // data out (for loads)
);

    // 512 bytes of data memory
    reg [7:0] Mem [0:511];

    // Bytes at and after A (big-endian)
    wire [7:0] b0 = Mem[A];
    wire [7:0] b1 = Mem[A+1];
    wire [7:0] b2 = Mem[A+2];
    wire [7:0] b3 = Mem[A+3];

    //==========================================================
    //  ONE ALWAYS: IF = LOAD, ELSE = STORE (como dijo el profe)
    //==========================================================
    always @(*) begin
        // -----------------------
        // LOAD  (RW == 0)
        // -----------------------
        if (E && (RW == 1'b0)) begin
            case (Size)
                // BYTE
                2'b00: begin
                    // SE=1 → signed byte, SE=0 → unsigned byte
                    DO = SE ? $signed({b0}) 
                            : {24'b0, b0};
                end

                // HALFWORD (big-endian: {b0,b1})
                2'b01: begin
                    // SE=1 → signed halfword, SE=0 → unsigned halfword
                    DO = SE ? $signed({b0, b1})
                            : {16'b0, b0, b1};
                end

                // WORD (big-endian: {b0,b1,b2,b3})
                2'b10: begin
                    DO = {b0, b1, b2, b3};
                end

                default: begin
                    DO = 32'b0;
                end
            endcase
        end

        // -----------------------
        // STORE (RW == 1)
        // -----------------------
        else if (E && (RW == 1'b1)) begin
            // DO no importa en store; se pone en 0 para evitar latches
            DO = 32'b0;

            case (Size)
                // STORE BYTE
                2'b00: begin
                    Mem[A] = DI[7:0];
                end

                // STORE HALFWORD (big-endian)
                2'b01: begin
                    Mem[A]   = DI[15:8];
                    Mem[A+1] = DI[7:0];
                end

                // STORE WORD (big-endian)
                2'b10: begin
                    Mem[A]   = DI[31:24];
                    Mem[A+1] = DI[23:16];
                    Mem[A+2] = DI[15:8];
                    Mem[A+3] = DI[7:0];
                end

                default: begin
                    // no-op
                end
            endcase
        end

        // -----------------------
        // E == 0 → memoria apagada
        // -----------------------
        else begin
            DO = 32'b0;
        end
    end

endmodule
