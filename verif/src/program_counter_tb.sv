`timescale 1ns / 1ps

module tb_program_counter;
    localparam ADDR_WIDTH = 32;
    localparam CLK_PERIOD = 10; // 10ns period

    // Signals to connect to the DUT
    logic                clk;
    logic                rst_n;
    logic                en;
    logic [ADDR_WIDTH-1:0] pc_out;

    // Instantiate the Device Under Test (DUT)
    program_counter #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .pc_out(pc_out)
    );

    // Clock generator
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Monitor to display changes
    initial begin
        $monitor("Time: %0t | Reset: %b | Enable: %b | PC_Out: %h (%0d)",
                 $time, rst_n, en, pc_out, pc_out);
    end

    // Test sequence
    initial begin
        // 1. Assert reset
        rst_n = 1'b0;
        en = 1'b0;
        #20;

        // 2. De-assert reset and enable counting
        rst_n = 1'b1;
        en = 1'b1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk); // PC should now be 16 (0x10)
        #2 // Give some time so disabling isn't evaluated at this clock cycle

        // 3. Disable counting
        $display("--- Disabling PC increment ---");
        en = 1'b0;
        @(posedge clk);
        @(posedge clk); // PC should hold its value at 16
        #2
        
        // 4. Re-enable counting
        $display("--- Re-enabling PC increment ---");
        en = 1'b1;
        @(posedge clk);
        @(posedge clk); // PC should be 20, then 24

        $finish;
    end

endmodule