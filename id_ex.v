//=====================================================
//  ID/EX PIPELINE REGISTER
//=====================================================
module ID_EX (
    input  wire        clk,
    input  wire        reset,
    input  wire        flush,

    // Inputs (control)
    input  wire [3:0]  SOH_OP_in,
    input  wire [3:0]  ALU_OP_in,
    input  wire        RW_in,
    input  wire        E_in,
    input  wire [1:0]  SIZE_in,
    input  wire        CC_WE_in,
    input  wire        USE_CC_in,
    input  wire        J_L_in,
    input  wire        CALL_in,
    input  wire        RF_LE_in,
    input  wire [2:0]  ID_SR_in,
    input  wire        B_in,
    input  wire        L_in,
    input  wire        SE_in,
    input  wire [4:0]  RD_in,      // <- destino en ID

    // Outputs (control + destino)
    output reg  [3:0]  SOH_OP_out,
    output reg  [3:0]  ALU_OP_out,
    output reg         RW_out,
    output reg         E_out,
    output reg  [1:0]  SIZE_out,
    output reg         CC_WE_out,
    output reg         USE_CC_out,
    output reg         J_L_out,
    output reg         CALL_out,
    output reg         RF_LE_out,
    output reg  [2:0]  ID_SR_out,
    output reg         B_out,
    output reg         L_out,
    output reg         SE_out,
    output reg  [4:0]  RD_out      // <- destino en EX
);

    always @(posedge clk) begin
        if (reset || flush) begin
            SOH_OP_out <= 4'd0;
            ALU_OP_out <= 4'd0;
            RW_out     <= 1'b0;
            E_out      <= 1'b0;
            SIZE_out   <= 2'b00;
            CC_WE_out  <= 1'b0;
            USE_CC_out <= 1'b0;
            J_L_out    <= 1'b0;
            CALL_out   <= 1'b0;
            RF_LE_out  <= 1'b0;
            ID_SR_out  <= 3'd0;
            B_out      <= 1'b0;
            L_out      <= 1'b0;
            SE_out     <= 1'b0;
            RD_out     <= 5'd0;   // <- en burbuja, destino = 0
        end
        else begin
            SOH_OP_out <= SOH_OP_in;
            ALU_OP_out <= ALU_OP_in;
            RW_out     <= RW_in;
            E_out      <= E_in;
            SIZE_out   <= SIZE_in;
            CC_WE_out  <= CC_WE_in;
            USE_CC_out <= USE_CC_in;
            J_L_out    <= J_L_in;
            CALL_out   <= CALL_in;
            RF_LE_out  <= RF_LE_in;
            ID_SR_out  <= ID_SR_in;
            B_out      <= B_in;
            L_out      <= L_in;
            SE_out     <= SE_in;
            RD_out     <= RD_in;  // <- pasar RD_ID a EX correctamente
        end

        // ===== DEBUG: ID/EX =====
        /*if (L_out) begin
            $display("IDEX> SE_EX=%b SIZE_EX=%b RW_EX=%b L_EX=%b RD_EX=%d", 
             SE_out, SIZE_out, RW_out, L_out, RD_out);
        end*/

    end

endmodule
