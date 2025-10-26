`timescale 1ns / 1ps

module register_file_tb;
    localparam DATA_WIDTH = 32;
    localparam CLK_PERIOD = 10;

    // --- Signals ---
    logic                clk;
    logic                resetn;
    logic [4:0]          r1_idx, r2_idx, wr_idx;
    logic                wr_en;
    logic [DATA_WIDTH-1:0] wr_data, reg1_data, reg2_data;

    // --- Instantiate DUT
    register_file dut (.*);

    // --- Clock and Reset ---
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        resetn = 1'b0;
        #20;
        resetn = 1'b1;
    end


    // --- Test Sequence ---
    initial begin
        // Wait for reset to finish
        @(posedge resetn);
        @(posedge clk);

        // =======================================================
        // Test 1: Write then Read
        // =======================================================
        $display("--- Testing Normal Write/Read Operation ---");
        // --- Write Cycle ---
        wr_en   = 1'b1;
        wr_idx  = 5;
        wr_data = 32'hAAAAAAAA;
        r1_idx  = 0; // Read from a different register
        $display("Time:%0t | Writing 0x%h to x5.", $time, wr_data);
        @(posedge clk);

        // --- Read Cycle ---
        wr_en  = 1'b0; // Disable write
        r1_idx = 5;    // Now, read from x5
        #1; // Wait a moment for combinational read logic to settle
        $display("Time:%0t | Reading from x5.", $time);
        assert (reg1_data == 32'hAAAAAAAA)
            $display("PASS: Normal read-back of 0x%h was successful.", reg1_data);
        else
            $error("FAIL: Normal read-back was incorrect. Got 0x%h", reg1_data);

        @(posedge clk);


        // =======================================================
        // Test 2: Forwarding Logic (Simultaneous Read/Write)
        // =======================================================
        $display("\n--- Testing Internal Forwarding ---");
        wr_en   = 1'b1;
        wr_idx  = 10;
        wr_data = 32'hDEADBEEF;
        r1_idx  = 10; // Read from the same address we are writing to
        $display("Time:%0t | Simultaneously writing 0x%h to x10 and reading from x10.", $time, wr_data);
        #1; // Wait for combinational forwarding logic to settle

        // Check the forwarded value before the clock edge
        assert (reg1_data == 32'hDEADBEEF)
            $display("PASS: Forwarding successful. Read 0x%h before clock edge.", reg1_data);
        else
            $error("FAIL: Forwarding was incorrect. Got 0x%h", reg1_data);

        // Let the clock edge happen, which writes the value to the register storage
        @(posedge clk);
        wr_en = 1'b0; // Disable write
        #1;

        // Verify the value was also written correctly by reading it normally
        assert (reg1_data == 32'hDEADBEEF)
            $display("PASS: Value 0x%h was correctly written to storage.", reg1_data);
        else
            $error("FAIL: Value was not written correctly to storage.");


        $finish;
    end

endmodule