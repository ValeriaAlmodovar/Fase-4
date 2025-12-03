//====================================================
//  mux32to1 
//====================================================

module mux32to1 (
    input  wire [31:0] D0,  input wire [31:0] D1,
    input  wire [31:0] D2,  input wire [31:0] D3,
    input  wire [31:0] D4,  input wire [31:0] D5,
    input  wire [31:0] D6,  input wire [31:0] D7,
    input  wire [31:0] D8,  input wire [31:0] D9,
    input  wire [31:0] D10, input wire [31:0] D11,
    input  wire [31:0] D12, input wire [31:0] D13,
    input  wire [31:0] D14, input wire [31:0] D15,
    input  wire [31:0] D16, input wire [31:0] D17,
    input  wire [31:0] D18, input wire [31:0] D19,
    input  wire [31:0] D20, input wire [31:0] D21,
    input  wire [31:0] D22, input wire [31:0] D23,
    input  wire [31:0] D24, input wire [31:0] D25,
    input  wire [31:0] D26, input wire [31:0] D27,
    input  wire [31:0] D28, input wire [31:0] D29,
    input  wire [31:0] D30, input wire [31:0] D31,

    input wire [4:0] S,
    output reg [31:0] Y
);

always @(*) begin
    case(S)
        5'd0:  Y = D0;
        5'd1:  Y = D1;
        5'd2:  Y = D2;
        5'd3:  Y = D3;
        5'd4:  Y = D4;
        5'd5:  Y = D5;
        5'd6:  Y = D6;
        5'd7:  Y = D7;
        5'd8:  Y = D8;
        5'd9:  Y = D9;
        5'd10: Y = D10;
        5'd11: Y = D11;
        5'd12: Y = D12;
        5'd13: Y = D13;
        5'd14: Y = D14;
        5'd15: Y = D15;
        5'd16: Y = D16;
        5'd17: Y = D17;
        5'd18: Y = D18;
        5'd19: Y = D19;
        5'd20: Y = D20;
        5'd21: Y = D21;
        5'd22: Y = D22;
        5'd23: Y = D23;
        5'd24: Y = D24;
        5'd25: Y = D25;
        5'd26: Y = D26;
        5'd27: Y = D27;
        5'd28: Y = D28;
        5'd29: Y = D29;
        5'd30: Y = D30;
        5'd31: Y = D31;
        default: Y = 32'b0;
    endcase
end

endmodule
