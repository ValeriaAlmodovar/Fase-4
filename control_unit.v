//==============================================================
//  CONTROL UNIT – Versión completa y correcta para tu programa
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
                SOH_OP = 4'b0010;  // imm22<<10
                ALU_OP = 4'b1101;  // pass-through A
            end
        end

        //======================================================
        //   ALU / JMPL
        //======================================================
        else if (op == 2'b10) begin
            // immediate or register
            SOH_OP = i_bit ? 4'b0001 : 4'b0000;

            // JMPL
            if (op3 == 6'b111000) begin
                J_L   = 1'b1;
                RF_LE = 1'b1;
            end

            // ALU
            else begin
                RF_LE = 1'b1;
                L     = 1'b0;

                case (op3)
                    6'b000000: begin ALU_OP = 4'b0000; CC_WE = 1'b0; end // add
                    6'b010000: begin ALU_OP = 4'b0000; CC_WE = 1'b1; end // addcc
                    6'b000100: begin ALU_OP = 4'b0010; CC_WE = 1'b0; end // sub
                    6'b010100: begin ALU_OP = 4'b0010; CC_WE = 1'b1; end // subcc
                    default: RF_LE = 1'b0;
                endcase
            end
        end

        //======================================================
        //   LOAD / STORE
        //======================================================
        else if (op == 2'b11) begin
            SOH_OP = i_bit ? 4'b0001 : 4'b0000;

            // ------ LOADS ------
            case (op3)
                6'b000001: begin
                    // ldub
                    RW=0; E=1; RF_LE=1; L=1;
                    SIZE=2'b00; SE=0;
                end
                6'b001001: begin
                    // ldsb
                    RW=0; E=1; RF_LE=1; L=1;
                    SIZE=2'b00; SE=1;
                end
                6'b000010: begin
                    // lduh
                    RW=0; E=1; RF_LE=1; L=1;
                    SIZE=2'b01; SE=0;
                end
                6'b001010: begin
                    // ldsh
                    RW=0; E=1; RF_LE=1; L=1;
                    SIZE=2'b01; SE=1;
                end
                6'b000000: begin
                    // ld (word)
                    RW=0; E=1; RF_LE=1; L=1;
                    SIZE=2'b10; SE=0;
                end

                // ------ STORES ------
                6'b000101: begin 
                    // stb
                    RW=1; E=1; SIZE=2'b00; 
                end
                6'b000110: begin
                    // sth
                    RW=1; E=1; SIZE=2'b01;
                end
                6'b000100: begin
                    // st (word)
                    RW=1; E=1; SIZE=2'b10;
                end
            endcase
        end
    end
endmodule
