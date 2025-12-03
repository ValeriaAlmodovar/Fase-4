//==============================================================
//  decoder5to32
//==============================================================

module decoder5to32 (
    input  wire [4:0] a,   // número del registro a activar
    input  wire       en,  // enable
    output reg  [31:0] y
);

always @(*) begin
    if (!en)
        y = 32'b0;
    else begin
        y = 32'b0;
        y[a] = 1'b1;   // encender solo el bit "a"
    end
end

endmodule
