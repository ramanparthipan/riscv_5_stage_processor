`include "control_types.sv"

module branch (
    input  logic [31:0] operand_a,
    input  logic [31:0] operand_b,
    input  comp_op_t    comp_op,
    output logic        result
);

    always_comb begin
        // Default result is false
        result = 1'b0;

        case (comp_op)
            BR_EQ:  result = (operand_a == operand_b);
            BR_NE:  result = (operand_a != operand_b);
            BR_LT:  result = ($signed(operand_a) < $signed(operand_b));
            BR_GE:  result = ($signed(operand_a) >= $signed(operand_b));
            BR_LTU: result = (operand_a < operand_b);
            BR_GEU: result = (operand_a >= operand_b);
            default: result = 1'b0; // Includes BR_NOP
        endcase
    end

endmodule