`timescale 1ns/1ps

module PPU_tb;

    reg clk;
    reg reset;

    wire [31:0] PC_IF;
    wire [31:0] R5, R6, R16, R17, R18;
    

    PPU uut (
        .clk   (clk),
        .reset (reset),
        .PC_IF (PC_IF),
        .R5    (R5),
        .R6    (R6),
        .R16   (R16),
        .R17   (R17),
        .R18   (R18)
    );

    // =========================================================
    // CLOCK: toggle cada 2 unidades → periodo 4
    // =========================================================
    initial begin
        clk = 1'b0;
        forever #2 clk = ~clk;   // 0,2,4,6,...
    end

    // =========================================================
    // RESET: activo en t=0, se desactiva en t=3
    // =========================================================
    initial begin
        reset = 1'b1;
        #3 reset = 1'b0;
    end

    // =========================================================
    // MONITOR: PC, r5, r6, r16, r17, r18 en decimal
    // =========================================================
    initial begin
        $monitor("t=%0t | PC=%0d | r5=%0d | r6=%0d | r16=%0d | r17=%0d | r18=%0d",
                 $time, PC_IF, R5, R6, R16, R17, R18);
    end

    // =========================================================
    // A t=76: imprimir word en la localización 56 (4 bytes)
    // =========================================================
    initial begin
        #76;
        $display("t=%0t | Word @56 (bytes 56..59) = %b %b %b %b",
                 $time,
                 uut.dataram.Mem[56],
                 uut.dataram.Mem[57],
                 uut.dataram.Mem[58],
                 uut.dataram.Mem[59]);

        // terminar en t=80
        #4;
        $finish;
    end

endmodule



