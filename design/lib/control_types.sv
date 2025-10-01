`ifndef CONTROL_TYPES_
`define CONTROL_TYPES_

// For the write-back MUX
typedef enum logic [1:0] {
    WRSRC_ALURES,
    WRSRC_MEMREAD,
    WRSRC_PC4
} reg_wr_src_t;

// For the ALU's first operand MUX
typedef enum logic {
    SRC1_REG1,
    SRC1_PC
} alu_src1_t;

// For the ALU's second operand MUX
typedef enum logic {
    SRC2_REG2,
    SRC2_IMM
} alu_src2_t;

// For the ALU's operation control
typedef enum logic [3:0] {
    ALU_NOP,
    ALU_ADD, ALU_SUB, ALU_XOR, ALU_OR, ALU_AND,
    ALU_SL, ALU_SRL, ALU_SRA, ALU_LT, ALU_LTU,
    ALU_LUI
} alu_op_t;

// For the Branch comparison unit
typedef enum logic [2:0] {
    BR_NOP,
    BR_EQ, BR_NE, BR_LT, BR_GE, BR_LTU, BR_GEU
} comp_op_t;

// For Memory operations
typedef enum logic [3:0] {
    MEM_NOP,
    MEM_SB, MEM_SH, MEM_SW, MEM_LB, MEM_LH, MEM_LW,
    MEM_LBU, MEM_LHU 
} mem_op_t;

typedef enum logic [1:0] {
    FWD_SRC_ID,
    FWD_SRC_MEM,
    FWD_SRC_WB
} forwarding_src_t;

`endif