//==============================================================
//  FASE IV - PPU  
//==============================================================
module PPU (
    input  wire clk,
    input  wire reset,

    output wire [31:0] PC_IF,
    output wire [31:0] R5,
    output wire [31:0] R6,
    output wire [31:0] R16,
    output wire [31:0] R17,
    output wire [31:0] R18
);

// =============================================================
//  PC / nPC
// =============================================================
wire [31:0] pc_q;
reg  [31:0] pc_d;
wire [31:0] npc_q;
reg  [31:0] npc_d;

wire [1:0]  nPC_sel;
reg  [31:0] mux_pc_out;

reg  [31:0] mux_pc_in0;
reg  [31:0] mux_pc_in1;
reg  [31:0] mux_pc_in2;

// DUHU stall / flush
wire stall_F;
wire stall_D;
wire flush_E;

always @(*) begin
    mux_pc_in0 = npc_q;

    case (nPC_sel)
        2'b00: mux_pc_out = mux_pc_in0;
        2'b01: mux_pc_out = mux_pc_in1;
        2'b10: mux_pc_out = mux_pc_in2;
        default: mux_pc_out = mux_pc_in0;
    endcase

    pc_d  = mux_pc_out;
    npc_d = mux_pc_out + 32'd4;
end

pc_reg u_pc (
    .clk  (clk),
    .reset(reset),
    .le   (~stall_F),
    .d    (pc_d),
    .q    (pc_q)
);

npc_reg u_npc (
    .clk  (clk),
    .reset(reset),
    .le   (~stall_F),
    .d    (npc_d),
    .q    (npc_q)
);

assign PC_IF = pc_q;

// =============================================================
//  Instruction Memory
// =============================================================
wire [31:0] I_IF;

ROM instr_mem (
    .A(pc_q[8:0]),
    .I(I_IF)
);

// =============================================================
//  IF/ID
// =============================================================
wire [31:0] I_ID, PC_ID, nPC_ID;
wire        IF_ID_flush;

IF_ID ifid (
    .clk    (clk),
    .reset  (reset),
    .stall  (stall_D),
    .flush  (IF_ID_flush),
    .I_in   (I_IF),
    .PC_in  (pc_q),
    .nPC_in (npc_q),
    .I_out  (I_ID),
    .PC_out (PC_ID),
    .nPC_out(nPC_ID)
);

// =============================================================
//  CONTROL UNIT
// =============================================================
wire [3:0] SOH_OP_ID, ALU_OP_ID;
wire       RW_ID, E_ID, CC_WE_ID, USE_CC_ID;
wire [1:0] SIZE_ID;
wire       J_L_ID, CALL_ID, RF_LE_ID, B_ID, L_ID;
wire [2:0] ID_SR_ID;
wire       SE_ID;

ControlUnit CU (
    .I      (I_ID),
    .SOH_OP (SOH_OP_ID),
    .ALU_OP (ALU_OP_ID),
    .RW     (RW_ID),
    .E      (E_ID),
    .SIZE   (SIZE_ID),
    .SE     (SE_ID),
    .CC_WE  (CC_WE_ID),
    .USE_CC (USE_CC_ID),
    .J_L    (J_L_ID),
    .CALL   (CALL_ID),
    .RF_LE  (RF_LE_ID),
    .ID_SR  (ID_SR_ID),
    .B      (B_ID),
    .L      (L_ID)
);

// =============================================================
//  DECODE UNIT (operand usage)
// =============================================================
wire A_S_ID, B_S_ID, D_S_ID, ID_NOP_ID;

DecodeUnit DECODE (
    .I_ID      (I_ID),
    .SOH_OP_ID (SOH_OP_ID),
    .RW_ID     (RW_ID),
    .L_ID      (L_ID),
    .B_ID      (B_ID),
    .CALL_ID   (CALL_ID),
    .A_S_ID    (A_S_ID),
    .B_S_ID    (B_S_ID),
    .D_S_ID    (D_S_ID),
    .ID_NOP_ID (ID_NOP_ID)
);

// =============================================================
//  REGISTER FILE
// =============================================================
wire [4:0] RD_ID = (I_ID[31:30] == 2'b01) ? 5'd15 : I_ID[29:25];
wire [4:0] RA_ID = I_ID[18:14];
wire [4:0] RB_ID = (I_ID[31:30] == 2'b11 && RW_ID) ? I_ID[29:25] : I_ID[4:0];

wire [31:0] PA_ID, PB_ID, PD_ID;
wire        RF_LE_WB;
wire [4:0]  RD_WB;

register_file RF (
    .clk  (clk),
    .reset(reset),
    .LE   (RF_LE_WB),
    .RW   (RD_WB),
    .RA   (RA_ID),
    .RB   (RB_ID),
    .RD   (RD_ID),
    .PW   (PW_WB),
    .PA   (PA_ID),
    .PB   (PB_ID),
    .PD   (PD_ID)
);

assign R5  = RF.reg_out[5];
assign R6  = RF.reg_out[6];
assign R16 = RF.reg_out[16];
assign R17 = RF.reg_out[17];
assign R18 = RF.reg_out[18];

// =============================================================
//  ID STAGE FORWARDING MUXES
// =============================================================
wire [1:0] fwd_A_S, fwd_B_S, fwd_D_S;
reg [31:0] PA_ID_FWD, PB_ID_FWD, PD_ID_FWD;

always @(*) begin
    // Forward PA (rs1)
    case (fwd_A_S)
        2'b11: PA_ID_FWD = ALU_OUT_EX;
        2'b01: PA_ID_FWD = ALU_OUT_MEM;
        2'b10: PA_ID_FWD = PW_WB;
        default: PA_ID_FWD = PA_ID;
    endcase

    // Forward PB (rs2)
    case (fwd_B_S)
        2'b11: PB_ID_FWD = ALU_OUT_EX;
        2'b01: PB_ID_FWD = ALU_OUT_MEM;
        2'b10: PB_ID_FWD = PW_WB;
        default: PB_ID_FWD = PB_ID;
    endcase

    // Forward PD (rd for stores)
    case (fwd_D_S)
        2'b11: PD_ID_FWD = ALU_OUT_EX;
        2'b01: PD_ID_FWD = ALU_OUT_MEM;
        2'b10: PD_ID_FWD = PW_WB;
        default: PD_ID_FWD = PD_ID;
    endcase
end

// =============================================================
//  SOH
// =============================================================
wire [31:0] SOH_OUT_ID;
SOH soh (
    .R     (PB_ID_FWD),
    .imm13 (I_ID[12:0]),
    .imm22 (I_ID[21:0]),
    .S     (SOH_OP_ID),
    .N     (SOH_OUT_ID)
);

// =============================================================
//  TAG + RESET HANDLER
// =============================================================
wire [31:0] TAG_OUT_ID;
wire [3:0]  COND_ID = I_ID[28:25];
wire        BR_TAKEN_ID;

TAG tag_block (
    .PC_ID  (PC_ID),
    .DISP22 (I_ID[21:0]),
    .DISP30 (I_ID[29:0]),
    .CALL_ID(CALL_ID),
    .BI_ID  (B_ID & BR_TAKEN_ID),
    .TAG_OUT(TAG_OUT_ID)
);

always @(*) begin
    mux_pc_in1 = TAG_OUT_ID;
end

reset_handler RH (
    .R       (reset),
    .CALL    (CALL_ID),
    .J       (BR_TAKEN_ID),
    .BI      (B_ID),
    .J_L     (J_L_ID),
    .a_bit   (I_ID[29]),
    .nPC_sel (nPC_sel),
    .IF_ID_R (IF_ID_flush)
);

// =============================================================
//  ID/EX 
// =============================================================
wire [3:0] SOH_OP_EX, ALU_OP_EX;
wire       RW_EX, E_EX, CC_WE_EX, USE_CC_EX;
wire [1:0] SIZE_EX;
wire       J_L_EX, CALL_EX, RF_LE_EX, B_EX, L_EX;
wire [2:0] ID_SR_EX;
wire [4:0] RD_EX;
wire       SE_EX;

wire A_S_EX, B_S_EX, D_S_EX, ID_NOP_EX;

wire flush_ID_EX = flush_E | IF_ID_flush;

ID_EX idex (
    .clk        (clk),
    .reset      (reset),
    .flush      (flush_ID_EX),

    .SOH_OP_in  (SOH_OP_ID),
    .ALU_OP_in  (ALU_OP_ID),
    .RW_in      (RW_ID),
    .E_in       (E_ID),
    .SIZE_in    (SIZE_ID),
    .CC_WE_in   (CC_WE_ID),
    .USE_CC_in  (USE_CC_ID),
    .J_L_in     (J_L_ID),
    .CALL_in    (CALL_ID),
    .RF_LE_in   (RF_LE_ID),
    .ID_SR_in   (ID_SR_ID),
    .B_in       (B_ID),
    .L_in       (L_ID),
    .RD_in      (RD_ID),
    .SE_in      (SE_ID),

    .A_S_in     (A_S_ID),
    .B_S_in     (B_S_ID),
    .D_S_in     (D_S_ID),
    .ID_NOP_in  (ID_NOP_ID),

    .SOH_OP_out (SOH_OP_EX),
    .ALU_OP_out (ALU_OP_EX),
    .RW_out     (RW_EX),
    .E_out      (E_EX),
    .SIZE_out   (SIZE_EX),
    .CC_WE_out  (CC_WE_EX),
    .USE_CC_out (USE_CC_EX),
    .J_L_out    (J_L_EX),
    .CALL_out   (CALL_EX),
    .RF_LE_out  (RF_LE_EX),
    .ID_SR_out  (ID_SR_EX),
    .B_out      (B_EX),
    .L_out      (L_EX),
    .RD_out     (RD_EX),
    .SE_out     (SE_EX),

    .A_S_out    (A_S_EX),
    .B_S_out    (B_S_EX),
    .D_S_out    (D_S_EX),
    .ID_NOP_out (ID_NOP_EX)
);

// =============================================================
//  ID → EX datapath
// =============================================================
reg [31:0] A_EX, B_EX_DATA, PB_EX;
reg [4:0]  RA_EX, RB_EX;
reg [31:0] PC_EX;

always @(posedge clk) begin
    if (reset || flush_ID_EX) begin
        A_EX <= 0; B_EX_DATA <= 0; PB_EX <= 0;
        RA_EX <= 0; RB_EX <= 0; PC_EX <= 0;
    end else if (!stall_D) begin
        A_EX <= PA_ID_FWD;
        B_EX_DATA <= SOH_OUT_ID;
        PB_EX <= PB_ID_FWD;
        RA_EX <= RA_ID;
        RB_EX <= RB_ID;
        PC_EX <= PC_ID;
    end
end

// =============================================================
//  DUHU (forwarding + hazard)
// =============================================================
wire [1:0] fwdA_sel, fwdB_sel;
wire SR_EX = (ID_SR_EX == 3'b001);

wire RF_LE_MEM;
wire [4:0] RD_MEM;

DUHU DUHU0 (
    .A_S_EX    (A_S_EX),
    .B_S_EX    (B_S_EX),
    .D_S_EX    (D_S_EX),
    .SR_EX     (SR_EX),
    .ID_NOP_EX (ID_NOP_EX),

    .RA_ID     (RA_ID),
    .RB_ID     (RB_ID),
    .RD_ID     (RD_ID),
    .RA_EX     (RA_EX),
    .RB_EX     (RB_EX),
    .RD_EX     (RD_EX),
    .RD_MEM    (RD_MEM),
    .RD_WB     (RD_WB),

    .RF_LE_EX  (RF_LE_EX),
    .RF_LE_MEM (RF_LE_MEM),
    .RF_LE_WB  (RF_LE_WB),

    .L_EX      (L_EX),
    .CC_WE_EX  (CC_WE_EX),
    .USE_CC_ID (USE_CC_ID),

    .sel_A     (fwdA_sel),
    .sel_B     (fwdB_sel),
    .A_S       (fwd_A_S),
    .B_S       (fwd_B_S),
    .D_S       (fwd_D_S),

    .stall_F   (stall_F),
    .stall_D   (stall_D),
    .flush_E   (flush_E)
);

// =============================================================
//  ALU + forwarding muxes
// =============================================================
reg [31:0] ALU_A, ALU_B, STORE_DATA_EX;

always @(*) begin
   
    case (fwdA_sel)
        2'b01: ALU_A = ALU_OUT_MEM;
        2'b10: ALU_A = PW_WB;
        default: ALU_A = A_EX;
    endcase

    ALU_B = B_EX_DATA;   

    if (!RW_EX) begin
        case (fwdB_sel)
            2'b01: ALU_B = ALU_OUT_MEM;
            2'b10: ALU_B = PW_WB;
            default: ALU_B = B_EX_DATA;
        endcase
    end

    case (fwdB_sel)
        2'b01: STORE_DATA_EX = ALU_OUT_MEM;
        2'b10: STORE_DATA_EX = PW_WB;
        default: STORE_DATA_EX = PB_EX;
    endcase
end


// =============================================================
//  ALU
// =============================================================
wire [31:0] ALU_RES_EX;
wire Z_EX, N_EX, C_EX, V_EX;

ALU alu (
    .A       (ALU_A),
    .B       (ALU_B),
    .Ci      (1'b0),
    .ALU_OP  (ALU_OP_EX),
    .ALU_OUT (ALU_RES_EX),
    .Z_EX    (Z_EX),
    .N_EX    (N_EX),
    .C_EX    (C_EX),
    .V_EX    (V_EX)
);

reg [31:0] ALU_OUT_EX;
always @(*) begin
    ALU_OUT_EX = (CALL_EX) ? PC_EX : ALU_RES_EX;
    mux_pc_in2 = ALU_OUT_EX;
end

// =============================================================
//  REG_CC
// =============================================================
wire Z_CC, N_CC, C_CC, V_CC;

REG_CC regcc (
    .clk      (clk),
    .reset    (reset),
    .CC_WE_EX (CC_WE_EX),
    .Z_EX     (Z_EX),
    .N_EX     (N_EX),
    .C_EX     (C_EX),
    .V_EX     (V_EX),
    .Z_CC     (Z_CC),
    .N_CC     (N_CC),
    .C_CC     (C_CC),
    .V_CC     (V_CC)
);

// =============================================================
//  CH
// =============================================================
CH ch_unit (
    .cond    (COND_ID),
    .Z_CC    (Z_CC),
    .N_CC    (N_CC),
    .C_CC    (C_CC),
    .V_CC    (V_CC),
    .BR_TAKEN(BR_TAKEN_ID)
);

// =============================================================
//  EX/MEM
// =============================================================
wire [1:0] SIZE_MEM;
wire       RW_MEM, E_MEM;
wire       L_MEM;
wire       SE_MEM;

EX_MEM exmem (
    .clk       (clk),
    .reset     (reset),
    .RW_in     (RW_EX),
    .E_in      (E_EX),
    .SIZE_in   (SIZE_EX),
    .RF_LE_in  (RF_LE_EX),
    .L_in      (L_EX),
    .RW_out    (RW_MEM),
    .E_out     (E_MEM),
    .SIZE_out  (SIZE_MEM),
    .RF_LE_out (RF_LE_MEM),
    .L_out     (L_MEM),
    .RD_in     (RD_EX),
    .RD_out    (RD_MEM),
    .SE_in     (SE_EX),
    .SE_out    (SE_MEM)
);

reg [31:0] ALU_OUT_MEM, B_MEM;

// Para stores: leer directamente del register file el dato más actualizado
wire [31:0] STORE_DATA_MEM = B_MEM;

always @(posedge clk) begin
    if (reset) begin
        ALU_OUT_MEM <= 32'b0;
        B_MEM       <= 32'b0;
    end else begin
        ALU_OUT_MEM <= ALU_OUT_EX;
        B_MEM       <= STORE_DATA_EX;  // Valor correcto del registro (con forwarding)
    end
end

// =============================================================
//  MEM — DATA RAM
// =============================================================
wire [31:0] DO_MEM;
RAM dataram (
    .A    (ALU_OUT_MEM[8:0]),
    .DI   (STORE_DATA_MEM),  // Usar dato directo del register file
    .Size (SIZE_MEM),
    .RW   (RW_MEM),
    .E    (E_MEM),
    .SE   (SE_MEM),
    .DO   (DO_MEM)
);

// =============================================================
//  MEM/WB
// =============================================================
wire L_WB;
wire [31:0] ALU_WB;
wire [31:0] MEM_WB_DATA;
wire [31:0] unused_pc8;

MEM_WB memwb (
    .clk       (clk),
    .reset     (reset),
    .RF_LE_in  (RF_LE_MEM),
    .L_in      (L_MEM),
    .rd_in     (RD_MEM),
    .alu_in    (ALU_OUT_MEM),
    .mem_in    (DO_MEM),
    .pc8_in    (32'd0),

    .RF_LE_out (RF_LE_WB),
    .L_out     (L_WB),
    .rd_out    (RD_WB),
    .alu_out   (ALU_WB),
    .mem_out   (MEM_WB_DATA),
    .pc8_out   (unused_pc8)
);

// =============================================================
//  MUX WB
// =============================================================
reg [31:0] PW_WB;
always @(*) begin
    PW_WB = (L_WB) ? MEM_WB_DATA : ALU_WB;
end

endmodule