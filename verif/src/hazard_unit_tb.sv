`timescale 1ns / 1ps

module hazard_unit_tb;
    `include "opcodes.sv"

    opcode_out_t   opcode_in;
    logic [4:0]    id_reg1_idx, id_reg2_idx;
    logic [4:0]    ex_reg_wr_idx;
    logic          ex_do_mem_read_en;

    logic          hazard_fe_enable;
    logic          hazard_if_id_clear;
    logic          hazard_id_ex_clear;

    // Instantiate DUT
    hazard_unit dut (.*);

    // Test sequence
    initial begin
        $display("--- Starting Hazard Unit Test ---");

        // Scenario 1: No Hazard
        $display("\n--- Testing No Hazard Scenario ---");
        opcode_in = ADD; id_reg1_idx = 1; id_reg2_idx = 2;
        ex_reg_wr_idx = 3; ex_do_mem_read_en = 0;
        #1;
        assert (hazard_id_ex_clear == 0 && hazard_fe_enable == 1 && hazard_if_id_clear == 0)
            $display("PASS: No hazard detected correctly.");
        else
            $error("FAIL: Incorrect signals for no-hazard case.");


        // Scenario 2: Load-Use Hazard
        $display("\n--- Testing Load-Use Hazard ---");
        opcode_in = ADD; id_reg1_idx = 5; id_reg2_idx = 2; // ID stage needs x5
        ex_reg_wr_idx = 5; ex_do_mem_read_en = 1;         // EX stage is a load to x5
        #1;
        assert (hazard_id_ex_clear == 1 && hazard_fe_enable == 0 && hazard_if_id_clear == 0)
            $display("PASS: Load-use hazard detected correctly.");
        else
            $error("FAIL: Incorrect signals for load-use case.");

        // Scenario 3: Control Hazard (Branch in ID)
        $display("\n--- Testing Control Hazard ---");
        opcode_in = BEQ; // A branch instruction is now in the ID stage
        ex_do_mem_read_en = 0; // No load-use hazard
        #1;
        assert (hazard_id_ex_clear == 0 && hazard_if_id_clear == 1 && hazard_fe_enable == 0)
            $display("PASS: Control hazard (branch) detected correctly.");
        else
            $error("FAIL: Incorrect signals for control hazard case.");

        $display("\n--- Hazard Unit Test Finished ---");
        $finish;
    end

endmodule