`timescale 1ns / 1ps

module control_tb;

    // Include the necessary enum definitions
    `include "opcodes.sv"       // Contains the 'opcode_out_t' typedef
    `include "control_types.sv" // Contains the control signal enums

    // --- Signals ---
    opcode_out_t opcode_in;
    logic        reg_do_write_ctrl;
    logic        mem_do_write_ctrl;
    logic        mem_do_read_ctrl;
    logic        do_branch;
    logic        do_jump;
    comp_op_t    comp_ctrl;
    reg_wr_src_t reg_wr_src_ctrl;
    alu_src1_t   alu_op1_ctrl;
    alu_src2_t   alu_op2_ctrl;
    alu_op_t     alu_ctrl;

    // --- Instantiate the Device Under Test (DUT) ---
    control dut (.*); // Connects ports by name

    // Helper function to convert opcode to string (for readable logs)
    function string opcode_to_string(input opcode_out_t op);
        case (op)
            ADD: return "ADD"; ADDI: return "ADDI"; LW: return "LW";
            SW: return "SW"; BEQ: return "BEQ"; JAL: return "JAL";
            LUI: return "LUI"; NOP: return "NOP";
            default: return "OTHER";
        endcase
    endfunction


    // --- Helper Task for Verification ---
    task check_signals (
        input opcode_out_t  test_op,
        // Expected Outputs
        input logic         exp_reg_write, input logic         exp_mem_write,
        input logic         exp_mem_read,  input logic         exp_branch,
        input logic         exp_jump,      input comp_op_t     exp_comp,
        input reg_wr_src_t  exp_wr_src,    input alu_src1_t    exp_alu1,
        input alu_src2_t    exp_alu2,      input alu_op_t      exp_alu_op
    );
        opcode_in = test_op;
        #1; // Wait for combinatorial logic to settle

        assert (reg_do_write_ctrl == exp_reg_write) else $error("RegWrite FAIL for %s", opcode_to_string(test_op));
        assert (mem_do_write_ctrl == exp_mem_write) else $error("MemWrite FAIL for %s", opcode_to_string(test_op));
        assert (mem_do_read_ctrl  == exp_mem_read)  else $error("MemRead FAIL for %s", opcode_to_string(test_op));
        assert (do_branch         == exp_branch)    else $error("Branch FAIL for %s", opcode_to_string(test_op));
        assert (do_jump           == exp_jump)      else $error("Jump FAIL for %s", opcode_to_string(test_op));
        assert (comp_ctrl         == exp_comp)      else $error("CompCtrl FAIL for %s", opcode_to_string(test_op));
        assert (reg_wr_src_ctrl   == exp_wr_src)    else $error("RegWrSrc FAIL for %s", opcode_to_string(test_op));
        assert (alu_op1_ctrl      == exp_alu1)      else $error("AluSrc1 FAIL for %s", opcode_to_string(test_op));
        assert (alu_op2_ctrl      == exp_alu2)      else $error("AluSrc2 FAIL for %s", opcode_to_string(test_op));
        assert (alu_ctrl          == exp_alu_op)    else $error("AluOp FAIL for %s", opcode_to_string(test_op));

        $display("PASS: Correct control signals for %s", opcode_to_string(test_op));
    endtask


    // --- Main Test Sequence ---
    initial begin
        $display("--- Starting Control Unit Test ---");

        //                 test_op|WrR|WrM|RdM|Br |Jmp|Comp   |WrSrc        |Alu1     |Alu2     |AluOp
        check_signals(ADD,   1,  0,  0,  0,  0,  BR_NOP, WRSRC_ALURES, SRC1_REG1, SRC2_REG2, ALU_ADD);
        check_signals(ADDI,  1,  0,  0,  0,  0,  BR_NOP, WRSRC_ALURES, SRC1_REG1, SRC2_IMM,  ALU_ADD);
        check_signals(LW,    1,  0,  1,  0,  0,  BR_NOP, WRSRC_MEMREAD,SRC1_REG1, SRC2_IMM,  ALU_ADD);
        check_signals(SW,    0,  1,  0,  0,  0,  BR_NOP, WRSRC_ALURES, SRC1_REG1, SRC2_IMM,  ALU_ADD);
        check_signals(BEQ,   0,  0,  0,  1,  0,  BR_EQ,  WRSRC_ALURES, SRC1_PC,   SRC2_IMM,  ALU_ADD);
        check_signals(JAL,   1,  0,  0,  0,  1,  BR_NOP, WRSRC_PC4,    SRC1_PC,   SRC2_IMM,  ALU_ADD);
        check_signals(LUI,   1,  0,  0,  0,  0,  BR_NOP, WRSRC_ALURES, SRC1_REG1, SRC2_IMM,  ALU_LUI); // AluSrc1 is don't-care, REG1 is default
        check_signals(NOP,   0,  0,  0,  0,  0,  BR_NOP, WRSRC_ALURES, SRC1_REG1, SRC2_REG2, ALU_NOP);

        $display("--- Test Finished ---");
        $finish;
    end

endmodule