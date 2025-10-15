`timescale 1ns / 1ps

module alu_tb;
    `include "control_types.sv"

    logic [31:0] operand_a;
    logic [31:0] operand_b;
    alu_op_t     alu_op;
    logic [31:0] result;

    // Instantiate DUT
    alu dut (.*);

    // Function to convert the alu_op_t enum to a string
    function string alu_op_to_string(input alu_op_t op);
        case (op)
            ALU_NOP: return "ALU_NOP";
            ALU_ADD: return "ALU_ADD";
            ALU_SUB: return "ALU_SUB";
            ALU_XOR: return "ALU_XOR";
            ALU_OR:  return "ALU_OR";
            ALU_AND: return "ALU_AND";
            ALU_SL:  return "ALU_SL";
            ALU_SRL: return "ALU_SRL";
            ALU_SRA: return "ALU_SRA";
            ALU_LT:  return "ALU_LT";
            ALU_LTU: return "ALU_LTU";
            ALU_LUI: return "ALU_LUI";
            default: return "UNKNOWN_ALU_OP";
        endcase
    endfunction

    // Task for checking
    task check_op(input alu_op_t op, input logic [31:0] a, input logic [31:0] b, input logic [31:0] exp_res);
        alu_op    = op;
        operand_a = a;
        operand_b = b;
        #1; // Wait for combinatorial logic

        assert (result == exp_res)
            $display("PASS: %s(%h, %h) => %h", alu_op_to_string(op), a, b, result);
        else
            $error("FAIL: %s(%h, %h) => Got %h, Expected %h", alu_op_to_string(op), a, b, result, exp_res);
    endtask

    // Test sequence
    initial begin
        $display("--- Starting ALU Test ---");

        check_op(ALU_ADD, 32'd5,   32'd10,  32'd15);        // 5 + 10 = 15
        check_op(ALU_SUB, 32'd5,   32'd10,  32'hFFFFFFF_B); // 5 - 10 = -5
        check_op(ALU_AND, 32'hF0,  32'h0F,  32'h00);        // F0 & 0F = 00
        check_op(ALU_OR,  32'hF0,  32'h0F,  32'hFF);        // F0 | 0F = FF
        check_op(ALU_XOR, 32'hF0,  32'hFF,  32'h0F);        // F0 ^ FF = 0F
        check_op(ALU_SL,  32'd2,   32'd3,   32'd16);       // 2 << 3 = 16
        check_op(ALU_SRL, 32'h80,  32'd4,   32'h8);         // Logical shift
        check_op(ALU_SRA, 32'hFFFFFF_80, 32'd4, 32'hFFFFFFF_8); // Arithmetic shift
        check_op(ALU_LT,  32'hFFFFFFFF, 32'd5, 32'd1);      // -1 < 5 (signed) is true
        check_op(ALU_LT,  32'd5,   32'hFFFFFFFF, 32'd0);    // 5 < -1 (signed) is false
        check_op(ALU_LTU, 32'hFFFFFFFF, 32'd5, 32'd0);      // large_unsigned < 5 is false
        check_op(ALU_LTU, 32'd5,   32'hFFFFFFFF, 32'd1);    // 5 < large_unsigned is true
        check_op(ALU_LUI, 32'hX, 32'hABCDE000, 32'hABCDE000); // Pass-through B
        check_op(ALU_NOP, 32'hX, 32'hX, 32'd0); // NOP should be 0

        $display("--- ALU Test Finished ---");
        $finish;
    end

endmodule