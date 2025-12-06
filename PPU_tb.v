`timescale 1ns/1ps

module PPU_tb;

    // ============================================
    //  Selector de prueba
    //  0 = debugging_code_SPARC
    //  1 = testcode_sparc1
    //  2 = testcode_sparc2
    // ============================================
    localparam integer TEST = 2;  // <-- CAMBIAS ESTO ENTRE 0,1,2

    reg clk;
    reg reset;

    wire [31:0] PC_IF;
    wire [31:0] R5, R6, R16, R17, R18;

    // Registros internos extra (no expuestos por PPU)
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
    // R5 ya viene como output, pero igual podrías usar RF
    assign R8  = uut.RF.reg_out[8];
    assign R10 = uut.RF.reg_out[10];
    assign R11 = uut.RF.reg_out[11];
    assign R12 = uut.RF.reg_out[12];
    assign R15 = uut.RF.reg_out[15];

    // ============================
    // CLOCK: periodo 4
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
    // CARGA DE MEMORIAS (ROM y RAM)
    // ============================
    initial begin
        case (TEST)
            0: begin
                $display(">>> Cargando debugging_code_SPARC.txt");
                $readmemh("debugging_code_SPARC.txt", uut.instr_mem.MEM);
                $readmemh("debugging_code_SPARC.txt", uut.dataram.Mem);
            end
            1: begin
                $display(">>> Cargando testcode_sparc1.txt");
                $readmemh("testcode_sparc1.txt", uut.instr_mem.MEM);
                $readmemh("testcode_sparc1.txt", uut.dataram.Mem);
            end
            2: begin
                $display(">>> Cargando testcode_sparc2.txt");
                $readmemh("testcode_sparc2.txt", uut.instr_mem.MEM);
                $readmemh("testcode_sparc2.txt", uut.dataram.Mem);
            end
            default: begin
                $display("ERROR: TEST invalido");
                $finish;
            end
        endcase
            // Debug: mostrar primeros 12 bytes de ROM una vez cargada
            #1;
            $display("ROM[0..11]: %h %h %h %h %h %h %h %h %h %h %h %h",
                uut.instr_mem.MEM[0],  uut.instr_mem.MEM[1],  uut.instr_mem.MEM[2],
                uut.instr_mem.MEM[3],  uut.instr_mem.MEM[4],  uut.instr_mem.MEM[5],
                uut.instr_mem.MEM[6],  uut.instr_mem.MEM[7],  uut.instr_mem.MEM[8],
                uut.instr_mem.MEM[9],  uut.instr_mem.MEM[10], uut.instr_mem.MEM[11]);
    end

    // ============================
    // MONITOR + REQUISITOS POR PROGRAMA
    // ============================
    integer i;

    // ============================
    // DEBUG  
    // ============================
    /*
    always @(posedge clk) begin
        $display("DEBUG: t=%0t | PC_IF=%0d | RA_EX=r%0d RB_EX=r%0d | RD_MEM=r%0d RD_WB=r%0d | fwdA=%b fwdB=%b | ALU_A=%0d ALU_B=%0d",
                 $time, PC_IF, uut.RA_EX, uut.RB_EX, uut.RD_MEM, uut.RD_WB, 
                 uut.fwdA_sel, uut.fwdB_sel, $signed(uut.ALU_A), $signed(uut.ALU_B));
        
        if (uut.CC_WE_EX) begin
            $display("  --> CC_UPDATE | Z=%b N=%b C=%b V=%b | Result=%0d",
                     uut.Z_EX, uut.N_EX, uut.C_EX, uut.V_EX, $signed(uut.ALU_OUT_EX));
        end
        
        if (uut.B_ID) begin
            $display("  --> BRANCH | cond=%b | Z_CC=%b N_CC=%b C_CC=%b V_CC=%b | BR_TAKEN=%b",
                     uut.COND_ID, uut.Z_CC, uut.N_CC, uut.C_CC, uut.V_CC, uut.BR_TAKEN_ID);
        end
        
        if (uut.stall_F || uut.stall_D || uut.flush_E) begin
            $display("  --> STALL | L_EX=%b RD_EX=r%0d RA_ID=r%0d RB_ID=r%0d",
                     uut.L_EX, uut.RD_EX, uut.RA_ID, uut.RB_ID);
        end
    end
    */

    initial begin
        case (TEST)
            // -------------------------------------
            // 0: Programa de validación (debugging)
            // -------------------------------------
            0: begin
                $monitor("t=%0t | PC=%0d | r5=%0d | r6=%0d | r16=%0d | r17=%0d | r18=%0d",
                         $time, PC_IF, R5, R6, R16, R17, R18);

                #76;
                $display("t=%0t | Word @56 (bytes 56..59) = %b %b %b %b",
                         $time,
                         uut.dataram.Mem[56],
                         uut.dataram.Mem[57],
                         uut.dataram.Mem[58],
                         uut.dataram.Mem[59]);
                #4;
                $finish;
            end

            // -------------------------------------
            // 1: Primer programa de prueba
            // -------------------------------------
            1: begin
                $monitor("t=%0t | PC=%0d | r1=%0d | r2=%0d | r3=%0d | r5=%0d",
                         $time, PC_IF, R1, R2, R3, R5);

                #160;
                $display("t=%0t | Word @44 = %b %b %b %b",
                         $time,
                         uut.dataram.Mem[44],
                         uut.dataram.Mem[45],
                         uut.dataram.Mem[46],
                         uut.dataram.Mem[47]);
                #4;
                $finish;
            end

            // -------------------------------------
            // 2: Segundo programa de prueba
            // -------------------------------------
            2: begin
                $monitor("t=%0t | PC=%0d | r1=%0d | r2=%0d | r3=%0d | r4=%0d | r5=%0d | r8=%0d | r10=%0d | r11=%0d | r12=%0d | r15=%0d",
                         $time, PC_IF, R1, R2, R3, R4, R5, R8, R10, R11, R12, R15);

                #240;
                $display("MEM[224..263] at t=%0t:", $time);
                for (i = 224; i <= 263; i = i + 1) begin
                    $write("%b ", uut.dataram.Mem[i]);
                end
                $write("\n");
                #4;
                $finish;
            end
        endcase
    end

endmodule
