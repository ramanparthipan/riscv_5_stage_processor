`timescale 1ns / 1ps

module ex_mem_register_tb;
    import control_types_pkg::*;

    localparam CLK_PERIOD = 10;

    logic        clk, clear, enable;
    logic        reg_do_write_ctrl_ex;
    reg_wr_src_t reg_wr_src_ctrl_ex;
    logic        mem_do_write_ctrl_ex;
    mem_op_t     mem_ctrl_ex;
    logic [31:0] pc_plus4_ex, alu_result_ex, mem_data_in_ex;
    logic [4:0]  wr_reg_idx_ex;
    logic        reg_do_write_ctrl_mem;
    reg_wr_src_t reg_wr_src_ctrl_mem;
    logic        mem_do_write_ctrl_mem;
    mem_op_t     mem_ctrl_mem;
    logic [31:0] pc_plus4_mem, alu_result_mem, mem_data_in_mem;
    logic [4:0]  wr_reg_idx_mem;

    // Instantiate DUT
    ex_mem_register dut (.*);

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Test sequence
    initial begin
        $display("--- Starting EX/MEM Register Test ---");
        
        // 1. Test clear
        clear = 1; enable = 1;
        pc_plus4_ex = 32'hFFFFFFFF; // Drive inputs to show clear overrides them
        #CLK_PERIOD;
        assert (pc_plus4_mem == 32'b0)
            $display("PASS: Clear asserted, outputs are zeroed.");
        else
            $error("FAIL: Clear failed.");
        
        // 2. Test normal operation (enable)
        clear = 0;
        reg_do_write_ctrl_ex = 1;
        alu_result_ex = 32'hAAAAAAAA;
        wr_reg_idx_ex = 5;
        $display("\n--- Testing Normal Latching (Enable=1) ---");
        @(posedge clk);
        #1;
        assert (alu_result_mem == 32'hAAAAAAAA && wr_reg_idx_mem == 5)
            $display("PASS: Data latched correctly.");
        else
            $error("FAIL: Data did not latch correctly.");

        // 3. Test stall (disable)
        enable = 0;
        alu_result_ex = 32'hBBBBBBBB; // Change input data
        wr_reg_idx_ex = 10;
        $display("\n--- Testing Stall (Enable=0) ---");
        @(posedge clk);
        #1;
        assert (alu_result_mem == 32'hAAAAAAAA && wr_reg_idx_mem == 5)
            $display("PASS: Register correctly held its value during stall.");
        else
            $error("FAIL: Register changed value during stall.");
        
        // 4. Test resume
        enable = 1;
        $display("\n--- Testing Resume (Enable=1) ---");
        @(posedge clk);
        #1;
        assert (alu_result_mem == 32'hBBBBBBBB && wr_reg_idx_mem == 10)
            $display("PASS: Register resumed latching new data.");
        else
            $error("FAIL: Register did not resume correctly.");
        
        $display("\n--- Test Finished ---");
        $finish;
    end

endmodule