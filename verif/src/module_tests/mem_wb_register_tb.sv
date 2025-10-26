`timescale 1ns / 1ps

module mem_wb_register_tb;
    import control_types_pkg::*;

    localparam CLK_PERIOD = 10;

    logic        clk, clear, enable;
    logic        reg_do_write_ctrl_mem;
    reg_wr_src_t reg_wr_src_ctrl_mem;
    logic [31:0] pc_plus4_mem, alu_result_mem, mem_data_out_mem;
    logic [4:0]  wr_reg_idx_mem;
    logic        reg_do_write_ctrl_wb;
    reg_wr_src_t reg_wr_src_ctrl_wb;
    logic [31:0] pc_plus4_wb, alu_result_wb, mem_data_out_wb;
    logic [4:0]  wr_reg_idx_wb;

    // Instantiate DUT
    mem_wb_register dut (.*);

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Test sequence
    initial begin
        $display("--- Starting MEM/WB Register Test ---");
        
        // 1. Test clear
        clear = 1; enable = 1;
        alu_result_mem = 32'hFFFFFFFF; // Drive inputs to show clear overrides them
        #CLK_PERIOD;
        assert (alu_result_wb == 32'b0)
            $display("PASS: Clear asserted, outputs are zeroed.");
        else
            $error("FAIL: Clear failed.");
        
        // 2. Test normal operation (simulating a LW result)
        clear = 0;
        reg_do_write_ctrl_mem = 1;
        reg_wr_src_ctrl_mem   = WRSRC_MEMREAD;
        mem_data_out_mem      = 32'hFEEDF00D;
        wr_reg_idx_mem        = 7;
        $display("\n--- Testing Normal Latching (Enable=1) ---");
        @(posedge clk);
        #1;
        assert (mem_data_out_wb == 32'hFEEDF00D && wr_reg_idx_wb == 7)
            $display("PASS: Data latched correctly.");
        else
            $error("FAIL: Data did not latch correctly.");

        // 3. Test stall (disable)
        enable = 0;
        mem_data_out_mem = 32'hBBBBBBBB; // Change input data
        wr_reg_idx_mem   = 12;
        $display("\n--- Testing Stall (Enable=0) ---");
        @(posedge clk);
        #1;
        assert (mem_data_out_wb == 32'hFEEDF00D && wr_reg_idx_wb == 7)
            $display("PASS: Register correctly held its value during stall.");
        else
            $error("FAIL: Register changed value during stall.");
        
        // 4. Test resume
        enable = 1;
        $display("\n--- Testing Resume (Enable=1) ---");
        @(posedge clk);
        #1;
        assert (mem_data_out_wb == 32'hBBBBBBBB && wr_reg_idx_wb == 12)
            $display("PASS: Register resumed latching new data.");
        else
            $error("FAIL: Register did not resume correctly.");
        
        $display("\n--- Test Finished ---");
        $finish;
    end

endmodule