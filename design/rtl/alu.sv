`timescale 1ns / 1ps

`include "control_types.sv"

module alu (
    input  logic [31:0] operand_a,
    input  logic [31:0] operand_b,
    input  alu_op_t     alu_op,
    output logic [31:0] result
);

    always_comb begin
        result = 32'hDEADBEEF;

        case (alu_op)
            ALU_ADD: result = operand_a + operand_b;
            ALU_SUB: result = operand_a - operand_b;
            ALU_XOR: result = operand_a ^ operand_b;
            ALU_OR:  result = operand_a | operand_b;
            ALU_AND: result = operand_a & operand_b;
            ALU_SL:  result = operand_a << operand_b[4:0]; // Shift Left
            ALU_SRL: result = operand_a >> operand_b[4:0]; // Shift Right Logical
            ALU_SRA: result = $signed(operand_a) >>> operand_b[4:0]; // Shift Right Arithmetic
            ALU_LT:  result = ($signed(operand_a) < $signed(operand_b)) ? 32'd1 : 32'd0; // Signed
            ALU_LTU: result = (operand_a < operand_b) ? 32'd1 : 32'd0; // Unsigned
            ALU_LUI: result = operand_b; // LUI passes the immediate through the ALU
            default: result = 32'b0; // Default for NOP or any other case
        endcase
    end

endmodule