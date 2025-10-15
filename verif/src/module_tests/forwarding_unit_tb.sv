`timescale 1ns / 1ps

module forwarding_unit_tb;
    `include "control_types.sv"

    logic [4:0] ex_reg1_idx, ex_reg2_idx;
    logic [4:0] mem_reg_wr_idx, wb_reg_wr_idx;
    logic       mem_reg_wr_en, wb_reg_wr_en;
    forwarding_src_t alu_reg1_forwarding_ctrl, alu_reg2_forwarding_ctrl;

    // Instantiate DUT
    forwarding_unit dut (.*);

    // Function to convert enum to string
    function string fwd_src_to_string(input forwarding_src_t src);
        case(src)
            FWD_SRC_ID: return "ID"; FWD_SRC_MEM: return "MEM";
            FWD_SRC_WB: return "WB"; default: return "X";
        endcase
    endfunction

    // Test sequence
    initial begin
        $display("--- Starting Forwarding Unit Test ---");

        // Scenario 1: no hazard
        // No matching write registers
        ex_reg1_idx = 1; ex_reg2_idx = 2;
        mem_reg_wr_idx = 3; mem_reg_wr_en = 1;
        wb_reg_wr_idx = 4; wb_reg_wr_en = 1;
        #1;
        assert (alu_reg1_forwarding_ctrl == FWD_SRC_ID && alu_reg2_forwarding_ctrl == FWD_SRC_ID)
            $display("PASS: No Hazard.");
        else
            $error("FAIL: No Hazard. Got %s, %s", fwd_src_to_string(alu_reg1_forwarding_ctrl), fwd_src_to_string(alu_reg2_forwarding_ctrl));

        // Scenario 2: forward from MEM stage
        // rs1 (x5) needs data from instruction in MEM stage
        ex_reg1_idx = 5; ex_reg2_idx = 2;
        mem_reg_wr_idx = 5; mem_reg_wr_en = 1;
        wb_reg_wr_idx = 4; wb_reg_wr_en = 1;
        #1;
        assert (alu_reg1_forwarding_ctrl == FWD_SRC_MEM)
            $display("PASS: Forward from MEM to ALU op1.");
        else
            $error("FAIL: Forward from MEM. Got %s", fwd_src_to_string(alu_reg1_forwarding_ctrl));


        // Scenario 3: forward from WB stage
        // rs2 (x7) needs data from instruction in WB stage
        ex_reg1_idx = 1; ex_reg2_idx = 7;
        mem_reg_wr_idx = 3; mem_reg_wr_en = 1;
        wb_reg_wr_idx = 7; wb_reg_wr_en = 1;
        #1;
        assert (alu_reg2_forwarding_ctrl == FWD_SRC_WB)
            $display("PASS: Forward from WB to ALU op2.");
        else
            $error("FAIL: Forward from WB. Got %s", fwd_src_to_string(alu_reg2_forwarding_ctrl));

        // Scenario 4: priority test
        // rs1 (x10) has a hazard from BOTH MEM and WB. Must choose MEM.
        $display("\n--- Testing Priority (MEM must be chosen over WB) ---");
        ex_reg1_idx = 10; ex_reg2_idx = 2;
        mem_reg_wr_idx = 10; mem_reg_wr_en = 1; // Hazard from MEM
        wb_reg_wr_idx = 10; wb_reg_wr_en = 1;  // Hazard from WB
        #1;
        assert (alu_reg1_forwarding_ctrl == FWD_SRC_MEM)
            $display("PASS: Priority correct. Forwarded from MEM.");
        else
            $error("FAIL: Priority incorrect. Got %s", fwd_src_to_string(alu_reg1_forwarding_ctrl));

        // Scenario 5: x0 test
        // rs1 is x0. No forwarding should occur even with a match.
        ex_reg1_idx = 0;
        mem_reg_wr_idx = 0; mem_reg_wr_en = 1;
        #1;
        assert (alu_reg1_forwarding_ctrl == FWD_SRC_ID)
            $display("PASS: No forwarding for x0.");
        else
            $error("FAIL: Incorrectly forwarded for x0.");

        $display("\n--- Forwarding Unit Test Finished ---");
        $finish;
    end

endmodule