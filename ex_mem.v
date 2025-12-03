module EX_MEM (
    input  wire       clk,
    input  wire       reset,

    input  wire       RW_in,
    input  wire       E_in,
    input  wire [1:0] SIZE_in,
    input  wire       RF_LE_in,
    input  wire       L_in,
    input  wire       SE_in,    
    input  wire [4:0] RD_in,   

    output reg        RW_out,
    output reg        E_out,
    output reg [1:0]  SIZE_out,
    output reg        RF_LE_out,
    output reg        L_out,
    output reg        SE_out,
    output reg [4:0]  RD_out  
);

    always @(posedge clk) begin
        if (reset) begin
            RW_out    <= 1'b0;
            E_out     <= 1'b0;
            SIZE_out  <= 2'b00;
            RF_LE_out <= 1'b0;
            L_out     <= 1'b0;
            SE_out    <= 1'b0;
            RD_out    <= 5'd0;
        end else begin
            RW_out    <= RW_in;
            E_out     <= E_in;
            SIZE_out  <= SIZE_in;
            RF_LE_out <= RF_LE_in;
            L_out     <= L_in;
            SE_out    <= SE_in;
            RD_out    <= RD_in;
        end
    end

endmodule
