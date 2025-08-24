// localparam definitions for standard RISC-V 32-bit opcodes
// Register-register ALU operations (ADD, SUB, etc.)
localparam OP_REG   = 7'b0110011;
// Register-immediate ALU operations (ADDI, SLTI, etc.)
localparam OP_IMM   = 7'b0010011;
// Load instructions (LB, LH, LW, etc.)
localparam OP_LOAD  = 7'b0000011;
// Store instructions (SB, SH, SW, etc.)
localparam OP_STORE = 7'b0100011;
// Conditional Branches (BEQ, BNE, etc.)
localparam OP_BRANCH= 7'b1100011;
// Jump and Link
localparam OP_JAL   = 7'b1101111;
// Jump and Link Register
localparam OP_JALR  = 7'b1100111;
// Load Upper Immediate
localparam OP_LUI   = 7'b0110111;
// Add Upper Immediate to PC
localparam OP_AUIPC = 7'b0010111;
// System calls and CSR instructions (ECALL, CSRRW, etc.)
localparam OP_SYSTEM= 7'b1110011;

typedef enum logic [5:0] {
    // --- NOP ---
    NOP,
    // --- R-Type Instructions ---
    ADD, SUB, XOR, OR, AND, SLL, SRL, SRA, SLT, SLTU,
    // --- I-Type Instructions ---
    ADDI, XORI, ORI, ANDI, SLLI, SRLI, SRAI, SLTI, SLTIU,
    // --- Load Instructions ---
    LB, LH, LW, LBU, LHU,
    // --- S-Type Instructions ---
    SB, SH, SW,
    // --- B-Type Instructions ---
    BEQ, BNE, BLT, BGE, BLTU, BGEU,
    // --- J-Type Instructions ---
    JAL, JALR,
    // --- U-Type Instructions ---
    LUI, AUIPC,
    // --- System Instructions ---
    ECALL, EBREAK
} opcode_out_t;