`timescale 1ns / 1ps

module branch_unit_tb;
    import control_types_pkg::*;

    logic [31:0] operand_a;
    logic [31:0] operand_b;
    comp_op_t    comp_op;
    logic        result;

    // Signed values for testing
    logic signed [31:0] neg_one;
    logic signed [31:0] five;

    // Instantiate DUT
    branch dut (.*);

    // Function to convert enum to string for printing
    function string comp_op_to_string(input comp_op_t op);
        case(op)
            BR_EQ: return "BR_EQ"; BR_NE: return "BR_NE";
            BR_LT: return "BR_LT"; BR_GE: return "BR_GE";
            BR_LTU: return "BR_LTU"; BR_GEU: return "BR_GEU";
            default: return "BR_NOP";
        endcase
    endfunction

    // Task for checking
    task check_branch(input comp_op_t op, input logic [31:0] a, input logic [31:0] b, input logic exp_res);
        comp_op   = op;
        operand_a = a;
        operand_b = b;
        #1; // Wait for combinatorial logic

        assert (result == exp_res)
            $display("PASS: %s(%d, %d) => %b", comp_op_to_string(op), a, b, result);
        else
            $error("FAIL: %s(%d, %d) => Got %b, Expected %b", comp_op_to_string(op), a, b, result, exp_res);
    endtask

    // Test sequence
    initial begin
        $display("--- Starting Branch Unit Test ---");
        
        neg_one = -1;
        five = 5;

        // Equality checks
        check_branch(BR_EQ, 100, 100, 1'b1);
        check_branch(BR_EQ, 100, 101, 1'b0);
        check_branch(BR_NE, 100, 101, 1'b1);
        check_branch(BR_NE, 100, 100, 1'b0);

        // Signed vs. unsigned comparison tests
        $display("\n--- Testing Signed vs. Unsigned (-1 vs 5) ---");
        check_branch(BR_LT,  neg_one, five, 1'b1); // -1 is less than 5 (signed)
        check_branch(BR_LTU, neg_one, five, 1'b0); // 0xFFFFFFFF is NOT less than 5 (unsigned)
        check_branch(BR_GE,  neg_one, five, 1'b0); // -1 is NOT greater/equal to 5 (signed)
        check_branch(BR_GEU, neg_one, five, 1'b1); // 0xFFFFFFFF IS greater/equal to 5 (unsigned)

        $display("\n--- Branch Unit Test Finished ---");
        $finish;
    end

endmodule