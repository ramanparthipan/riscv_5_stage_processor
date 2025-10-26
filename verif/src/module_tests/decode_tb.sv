`timescale 1ns / 1ps

module tb_decode;
    import opcodes_pkg::*;

    // Signals to connect to the decoder module
    logic [31:0]        instr;
    opcode_out_t        opcode_out;
    logic [4:0]         wr_reg_idx, r1_reg_idx, r2_reg_idx;

    // Instantiate the DUT
    decode dut (
        .instr(instr),
        .opcode_out(opcode_out),
        .wr_reg_idx(wr_reg_idx),
        .r1_reg_idx(r1_reg_idx),
        .r2_reg_idx(r2_reg_idx)
    );

    // Helper task to apply an instruction and check the output
    task check_instr(input logic [31:0] test_instr, input opcode_out_t expected_opcode);
        instr = test_instr;
        #1; // Wait 1ns for the combinatorial logic to settle

        if (opcode_out == expected_opcode) begin
            $display("PASS: Instr %h decoded as %d. rd=%d, rs1=%d, rs2=%d",
                     test_instr, expected_opcode, wr_reg_idx, r1_reg_idx, r2_reg_idx);
        end else begin
            $error("FAIL: Instr %h decoded as %d, expected %d",
                   test_instr, opcode_out, expected_opcode);
        end
    endtask


    // Main test sequence
    initial begin
        $display("--- Starting Decoder Test ---");

        // Test vector for: addi x5, x6, 42
        check_instr(32'h02A30293, ADDI);

        // Test vector for: add x1, x2, x3
        check_instr(32'h003100B3, ADD);

        // Test vector for: lw x10, 16(x2)
        check_instr(32'h01012503, LW);
        
        // Test vector for: beq x1, x2, <offset>
        check_instr(32'h00208663, BEQ);

        // Test vector for: lui x3, 0xABCDE
        check_instr(32'hABCDE1B7, LUI);

        $display("--- Test Finished ---");
        $finish;
    end

endmodule