`timescale 1ns / 1ps

module immediate_generator_tb;
    `include "opcodes.sv"

    opcode_out_t opcode_in;
    logic [31:0] instr_in;
    logic [31:0] imm_out;

    // Instantiate DUT
    immediate_generator dut (.*);

    // Helper function to convert opcode to string
    function string opcode_to_string(input opcode_out_t op);
        case (op)
            ADDI: return "ADDI"; SW: return "SW"; BEQ: return "BEQ";
            LUI: return "LUI"; JAL: return "JAL";
            default: return "OTHER";
        endcase
    endfunction

    // Helper task for verification
    task check_imm(input opcode_out_t op, input logic [31:0] instr, input logic [31:0] exp_imm);
        opcode_in = op;
        instr_in = instr;
        #1; // Wait for combinatorial logic to settle
        assert (imm_out == exp_imm)
            $display("PASS for %s: Immediate = %h (%d)", opcode_to_string(op), imm_out, imm_out);
        else
            $error("FAIL for %s. Got %h, expected %h", opcode_to_string(op), imm_out, exp_imm);
    endtask

    initial begin
        // Test I-Type: addi x5, x6, -1 (imm = -1)
        check_imm(ADDI, 32'hFFF30293, 32'hFFFFFFFF);

        // Test S-Type: sw x2, -4(x1) (imm = -4)
        check_imm(SW, 32'hFE20AE23, 32'hFFFFFFFC);

        // Test B-Type: beq x1, x0, -8 (imm = -8)
        check_imm(BEQ, 32'hFE008CE3, 32'hFFFFFFF8);

        // Test U-Type: lui x1, 0xABCDE
        check_imm(LUI, 32'hABCDE0B7, 32'hABCDE000);

        // Test J-Type: jal x1, -20 (imm = -20)
        check_imm(JAL, 32'hFEDFF0EF, 32'hFFFFFFEC);

        $finish;
    end
endmodule