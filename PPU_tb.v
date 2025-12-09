`timescale 1ns/1ps

module PPU_tb;

    // ============================================
    //  Selector de prueba
    // ============================================
    localparam integer TEST = 0;

    reg clk;
    reg reset;

    wire [31:0] PC_IF;
    wire [31:0] R5, R6, R16, R17, R18;

    wire [31:0] R1, R2, R3, R4, R8, R10, R11, R12, R15;

    // ============================
    //  CONECTAR  PPU
    // ============================
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

    // ============================
    //  EXTRAER REGISTROS INTERNOS
    // ============================
    assign R1  = uut.RF.reg_out[1];
    assign R2  = uut.RF.reg_out[2];
    assign R3  = uut.RF.reg_out[3];
    assign R4  = uut.RF.reg_out[4];
    assign R8  = uut.RF.reg_out[8];
    assign R10 = uut.RF.reg_out[10];
    assign R11 = uut.RF.reg_out[11];
    assign R12 = uut.RF.reg_out[12];
    assign R15 = uut.RF.reg_out[15];

    // ============================
    // CLOCK
    // ============================
    initial begin
        clk = 1'b0;
        forever #2 clk = ~clk;
    end

    // ============================
    // RESET
    // ============================
    initial begin
        reset = 1'b1;
        #3 reset = 1'b0;
    end

    // ============================
    // CARGA DE MEMORIAS
    // ============================
    initial begin
        case (TEST)
            0: begin
                $display(">>> Cargando debugging_code_SPARC.txt");
                $readmemb("debugging_code_SPARC.txt", uut.instr_mem.MEM);
                $readmemb("debugging_code_SPARC.txt", uut.dataram.Mem);
            end
            1: begin
                $display(">>> Cargando testcode_sparc1.txt");
                $readmemb("testcode_sparc1.txt", uut.instr_mem.MEM);
                $readmemb("testcode_sparc1.txt", uut.dataram.Mem);
            end
            2: begin
                $display(">>> Cargando testcode_sparc2.txt");
                $readmemb("testcode_sparc2.txt", uut.instr_mem.MEM);
                $readmemb("testcode_sparc2.txt", uut.dataram.Mem);
            end
        endcase
    end

    reg [31:0] last_PC;

    initial last_PC = 32'hFFFFFFFF;

    always @(posedge clk) begin
        if (!reset && PC_IF != last_PC) begin
            last_PC = PC_IF;

            case (TEST)
                0: begin
                    $display("PC=%0d | R5=%0d | R6=%0d | R16=%0d | R17=%0d | R18=%0d",
                             PC_IF, R5, R6, R16, R17, R18);
                end

                1: begin
                    $display("PC=%0d | R1=%0d | R2=%0d | R3=%0d | R5=%0d",
                             PC_IF, R1, R2, R3, R5);
                end

                2: begin
                    $display("PC=%0d | R1=%0d | R2=%0d | R3=%0d | R4=%0d | R5=%0d | R8=%0d | R10=%0d | R11=%0d | R12=%0d | R15=%0d",
                             PC_IF, R1, R2, R3, R4, R5, R8, R10, R11, R12, R15);
                end
            endcase
        end
    end

    integer i;

    initial begin
        case (TEST)
            0: begin
                #76;
                $display("Address 56: %b", uut.dataram.Mem[56]);
                $display("Address 57: %b", uut.dataram.Mem[57]);
                $display("Address 58: %b", uut.dataram.Mem[58]);
                $display("Address 59: %b", uut.dataram.Mem[59]);
                #4 $finish;
            end

            1: begin
                #160;
                $display("Address 44: %b %b %b %b",
                         uut.dataram.Mem[44],
                         uut.dataram.Mem[45],
                         uut.dataram.Mem[46],
                         uut.dataram.Mem[47]);
                #4 $finish;
            end

            2: begin
                #240;
                for (i = 224; i <= 263; i = i + 4) begin
                    $display("Address %0d: %b %b %b %b",
                             i,
                             uut.dataram.Mem[i],
                             uut.dataram.Mem[i+1],
                             uut.dataram.Mem[i+2],
                             uut.dataram.Mem[i+3]);
                end
                #4 $finish;
            end
        endcase
    end

endmodule
