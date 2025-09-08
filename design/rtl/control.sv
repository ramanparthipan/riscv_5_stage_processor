// Include the enum definitions required by this module
`include "opcodes.sv"
`include "control_types.sv"

module control (
    input  opcode_out_t opcode_in,

    // Outputs
    output logic        reg_do_write_ctrl, // RegWrite signal
    output logic        mem_do_write_ctrl, // MemWrite signal
    output logic        mem_do_read_ctrl,  // MemRead signal
    output logic        do_branch,
    output logic        do_jump,
    output comp_op_t    comp_ctrl,
    output reg_wr_src_t reg_wr_src_ctrl,
    output alu_src1_t   alu_op1_ctrl,
    output alu_src2_t   alu_op2_ctrl,
    output alu_op_t     alu_ctrl,
    output mem_op_t     mem_ctrl
);

    always_comb begin
        // --- Set default values for all control signals ---
        reg_do_write_ctrl = 1'b0;
        mem_do_write_ctrl = 1'b0;
        mem_do_read_ctrl  = 1'b0;
        do_branch         = 1'b0;
        do_jump           = 1'b0;
        comp_ctrl         = BR_NOP;
        reg_wr_src_ctrl   = WRSRC_ALURES;
        alu_op1_ctrl      = SRC1_REG1;
        alu_op2_ctrl      = SRC2_REG2;
        alu_ctrl          = ALU_NOP;
        mem_ctrl          = MEM_NOP;

        // --- Generate signals based on the instruction type ---
        case (opcode_in)
            // --- R-Type Instructions ---
            ADD, SUB, XOR, OR, AND, SLL, SRL, SRA, SLT, SLTU: begin
                reg_do_write_ctrl = 1'b1;
                alu_op1_ctrl      = SRC1_REG1;
                alu_op2_ctrl      = SRC2_REG2;
                reg_wr_src_ctrl   = WRSRC_ALURES;
                case (opcode_in)
                    ADD:  alu_ctrl = ALU_ADD;
                    SUB:  alu_ctrl = ALU_SUB;
                    XOR:  alu_ctrl = ALU_XOR;
                    OR:   alu_ctrl = ALU_OR;
                    AND:  alu_ctrl = ALU_AND;
                    SLL:  alu_ctrl = ALU_SL;
                    SRL:  alu_ctrl = ALU_SRL;
                    SRA:  alu_ctrl = ALU_SRA;
                    SLT:  alu_ctrl = ALU_LT;
                    SLTU: alu_ctrl = ALU_LTU;
                endcase
            end

            // --- I-Type Instructions ---
            ADDI, XORI, ORI, ANDI, SLLI, SRLI, SRAI, SLTI, SLTIU: begin
                reg_do_write_ctrl = 1'b1;
                alu_op1_ctrl      = SRC1_REG1;
                alu_op2_ctrl      = SRC2_IMM;
                reg_wr_src_ctrl   = WRSRC_ALURES;
                case (opcode_in)
                    ADDI:  alu_ctrl = ALU_ADD;
                    XORI:  alu_ctrl = ALU_XOR;
                    ORI:   alu_ctrl = ALU_OR;
                    ANDI:  alu_ctrl = ALU_AND;
                    SLLI:  alu_ctrl = ALU_SL;
                    SRLI:  alu_ctrl = ALU_SRL;
                    SRAI:  alu_ctrl = ALU_SRA;
                    SLTI:  alu_ctrl = ALU_LT;
                    SLTIU: alu_ctrl = ALU_LTU;
                endcase
            end

            // --- Load Instructions ---
            LB, LH, LW, LBU, LHU: begin
                reg_do_write_ctrl = 1'b1;
                mem_do_read_ctrl  = 1'b1;
                alu_op1_ctrl      = SRC1_REG1;
                alu_op2_ctrl      = SRC2_IMM;
                alu_ctrl          = ALU_ADD; // ALU calculates address
                reg_wr_src_ctrl   = WRSRC_MEMREAD;
                case (opcode_in)
                    LB:     mem_ctrl = MEM_LB;
                    LH:     mem_ctrl = MEM_LH;
                    LW:     mem_ctrl = MEM_LW;
                    LBU:    mem_ctrl = MEM_LBU;
                    LHU:    mem_ctrl = MEM_LHU;
                endcase
            end

            // --- S-Type Instructions ---
            SB, SH, SW: begin
                mem_do_write_ctrl = 1'b1;
                alu_op1_ctrl      = SRC1_REG1;
                alu_op2_ctrl      = SRC2_IMM;
                alu_ctrl          = ALU_ADD; // ALU calculates address
                case (opcode_in)
                    SB: mem_ctrl = MEM_SB;
                    SH: mem_ctrl = MEM_SH;
                    SW: mem_ctrl = MEM_SW;
                endcase
            end

            // --- B-Type Instructions ---
            BEQ, BNE, BLT, BGE, BLTU, BGEU: begin
                do_branch    = 1'b1;
                alu_op1_ctrl = SRC1_PC;
                alu_op2_ctrl = SRC2_IMM;
                alu_ctrl     = ALU_ADD; // ALU calculates target address
                case (opcode_in)
                    BEQ:  comp_ctrl = BR_EQ;
                    BNE:  comp_ctrl = BR_NE;
                    BLT:  comp_ctrl = BR_LT;
                    BGE:  comp_ctrl = BR_GE;
                    BLTU: comp_ctrl = BR_LTU;
                    BGEU: comp_ctrl = BR_GEU;
                endcase
            end

            // --- J-Type Instructions ---
            JAL: begin
                reg_do_write_ctrl = 1'b1;
                do_jump           = 1'b1;
                alu_op1_ctrl      = SRC1_PC;
                alu_op2_ctrl      = SRC2_IMM;
                alu_ctrl          = ALU_ADD;
                reg_wr_src_ctrl   = WRSRC_PC4;
            end
            JALR: begin
                reg_do_write_ctrl = 1'b1;
                do_jump           = 1'b1;
                alu_op1_ctrl      = SRC1_REG1;
                alu_op2_ctrl      = SRC2_IMM;
                alu_ctrl          = ALU_ADD;
                reg_wr_src_ctrl   = WRSRC_PC4;
            end

            // --- U-Type Instructions ---
            LUI: begin
                reg_do_write_ctrl = 1'b1;
                alu_op2_ctrl      = SRC2_IMM;
                alu_ctrl          = ALU_LUI; // Special ALU op to pass immediate
                reg_wr_src_ctrl   = WRSRC_ALURES;
            end
            AUIPC: begin
                reg_do_write_ctrl = 1'b1;
                alu_op1_ctrl      = SRC1_PC;
                alu_op2_ctrl      = SRC2_IMM;
                alu_ctrl          = ALU_ADD;
                reg_wr_src_ctrl   = WRSRC_ALURES;
            end

            // --- System Instructions ---
            ECALL, EBREAK: begin
                // Pass
            end

            default: begin
                // NOP and any other default cases use the default values
            end
        endcase
    end

endmodule