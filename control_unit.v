//==============================================================
//  CONTROL UNIT 
//==============================================================
module ControlUnit (
    input  wire [31:0] I,

    output reg  [3:0] SOH_OP,
    output reg  [3:0] ALU_OP,
    output reg        RW,
    output reg        E,
    output reg  [1:0] SIZE,
    output reg        CC_WE,
    output reg        USE_CC,
    output reg        J_L,
    output reg        CALL,
    output reg        RF_LE,
    output reg  [2:0] ID_SR,
    output reg        B,
    output reg        L,
    output reg        SE
);

    wire [1:0] op  = I[31:30];
    wire [2:0] op2 = I[24:22];
    wire [5:0] op3 = I[24:19];
    wire       i_bit = I[13];

    always @(*) begin
        // DEFAULTS
        SOH_OP = 4'b0000;
        ALU_OP = 4'b0000;
        RW     = 1'b0;
        E      = 1'b0;
        SIZE   = 2'b10;  // palabra por defecto
        SE     = 1'b0;
        CC_WE  = 1'b0;
        USE_CC = 1'b0;
        J_L    = 1'b0;
        CALL   = 1'b0;
        RF_LE  = 1'b0;
        ID_SR  = 3'b000;
        B      = 1'b0;
        L      = 1'b0;

        //======================================================
        //   CALL
        //======================================================
        if (op == 2'b01) begin
            CALL   = 1'b1;
            RF_LE  = 1'b1;
        end

        //======================================================
        //   BRANCH / SETHI
        //======================================================
        else if (op == 2'b00) begin

            // BRANCH
            if (op2 == 3'b010) begin
                B      = 1'b1;
                USE_CC = 1'b1;
            end

            // SETHI
            else if (op2 == 3'b100) begin
                RF_LE  = 1'b1;
                SOH_OP = 4'b0010; // imm22 << 10
                ALU_OP = 4'b1101; // PASS A
            end
        end

        //======================================================
        //   ALU / JMPL
        //======================================================
        else if (op == 2'b10) begin

            SOH_OP = i_bit ? 4'b0001 : 4'b0000;

            // JMPL
            if (op3 == 6'b111000) begin
                J_L   = 1'b1;
                RF_LE = 1'b1;
            end

            // ALU OPERATIONS
            else begin
                RF_LE = 1'b1;
                L     = 1'b0;

                case (op3)

                    //===========================
                    // ARITHMETIC
                    //===========================
                    6'b000000: begin ALU_OP = 4'b0000; CC_WE = 1'b0; end // add
                    6'b010000: begin ALU_OP = 4'b0000; CC_WE = 1'b1; end // addcc

                    6'b001000: begin ALU_OP = 4'b1110; CC_WE = 1'b0; end // addx (add with carry)
                    6'b011000: begin ALU_OP = 4'b1110; CC_WE = 1'b1; end // addxcc

                    6'b000100: begin ALU_OP = 4'b0010; CC_WE = 1'b0; end // sub
                    6'b010100: begin ALU_OP = 4'b0010; CC_WE = 1'b1; end // subcc

                    6'b001100: begin ALU_OP = 4'b1111; CC_WE = 1'b0; end // subx (sub with carry)
                    6'b011100: begin ALU_OP = 4'b1111; CC_WE = 1'b1; end // subxcc

                    //===========================
                    // LOGIC INSTRUCTIONS
                    //===========================
                    6'b000001: begin ALU_OP = 4'b0100; CC_WE = 1'b0; end // and
                    6'b010001: begin ALU_OP = 4'b0100; CC_WE = 1'b1; end // andcc

                    6'b000010: begin ALU_OP = 4'b0101; CC_WE = 1'b0; end // or
                    6'b010010: begin ALU_OP = 4'b0101; CC_WE = 1'b1; end // orcc

                    6'b000011: begin ALU_OP = 4'b0110; CC_WE = 1'b0; end // xor
                    6'b010011: begin ALU_OP = 4'b0110; CC_WE = 1'b1; end // xorcc

                    6'b000111: begin ALU_OP = 4'b0111; CC_WE = 1'b0; end // xnor
                    6'b010111: begin ALU_OP = 4'b0111; CC_WE = 1'b1; end // xnorcc

                    6'b000101: begin ALU_OP = 4'b1000; CC_WE = 1'b0; end // andn
                    6'b010101: begin ALU_OP = 4'b1000; CC_WE = 1'b1; end // andncc

                    6'b000110: begin ALU_OP = 4'b1001; CC_WE = 1'b0; end // orn
                    6'b010110: begin ALU_OP = 4'b1001; CC_WE = 1'b1; end // orncc

                    //===========================
                    // SHIFT INSTRUCTIONS
                    //===========================
                    6'b100101: begin ALU_OP = 4'b1010; ID_SR = 3'b001; end // sll
                    6'b100110: begin ALU_OP = 4'b1011; ID_SR = 3'b001; end // srl
                    6'b100111: begin ALU_OP = 4'b1100; ID_SR = 3'b001; end // sra

                    default: RF_LE = 1'b0;
                endcase
            end
        end

        //======================================================
        //   LOAD / STORE
        //======================================================
        else if (op == 2'b11) begin

            SOH_OP = i_bit ? 4'b0001 : 4'b0000;

            case (op3)

                // ---------------- LOADS ----------------
                6'b000001: begin RW=0; E=1; RF_LE=1; L=1; SIZE=2'b00; SE=0; end // ldub
                6'b001001: begin RW=0; E=1; RF_LE=1; L=1; SIZE=2'b00; SE=1; end // ldsb
                6'b000010: begin RW=0; E=1; RF_LE=1; L=1; SIZE=2'b01; SE=0; end // lduh
                6'b001010: begin RW=0; E=1; RF_LE=1; L=1; SIZE=2'b01; SE=1; end // ldsh
                6'b000000: begin RW=0; E=1; RF_LE=1; L=1; SIZE=2'b10; SE=0; end // ld word

                // ---------------- STORES ----------------
                6'b000101: begin RW=1; E=1; RF_LE=0; L=0; SIZE=2'b00; end // stb
                6'b000110: begin RW=1; E=1; RF_LE=0; L=0; SIZE=2'b01; end // sth
                6'b000100: begin RW=1; E=1; RF_LE=0; L=0; SIZE=2'b10; end // st word

            endcase
        end

        //======================================================
        //   DEBUG OUTPUT
        //======================================================
        /*if (op == 2'b11) begin
            $display("CU> LOAD/STORE op3=%b RW=%b L=%b RF_LE=%b SE=%b SIZE=%b",
                op3, RW, L, RF_LE, SE, SIZE);
        end

        if (op == 2'b00 && op2 == 3'b010) begin
            $display("CU> BRANCH cond=%b", I[28:25]);
        end

        if (op == 2'b10 && op3 == 6'b111000) begin
            $display("CU> JMPL detected");
        end*/
    end
endmodule
