`timescale 1ns / 1ps

module tb_program_counter;
    localparam ADDR_WIDTH = 32;
    localparam CLK_PERIOD = 10;

    // Signals to connect to the DUT
    logic                clk;
    logic                resetn;
    logic                en;
    logic                jump_en;
    logic [ADDR_WIDTH-1:0] jump_addr;
    logic [ADDR_WIDTH-1:0] pc_out;

    // Instantiate DUT
    program_counter #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .resetn(resetn),
        .en(en),
        .jump_en(jump_en),
        .jump_addr(jump_addr),
        .pc_out(pc_out)
    );

    // Clock generator
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Monitor to display changes
    initial begin
        $monitor("Time: %0t | Rst: %b | En: %b | Jmp: %b | jump_addr: %h | PC_Out: %h",
                 $time, resetn, en, jump_en, jump_addr, pc_out);
    end

    // Test sequence
    initial begin
        // 1. Assert reset
        resetn = 1'b0; en = 1'b0; jump_en = 1'b0; jump_addr = 'x;
        #20;

        // 2. De-assert reset and enable counting
        resetn = 1'b1; en = 1'b1;
        @(posedge clk);
        @(posedge clk); // PC should be 4, then 8
        #2

        // 3. Test the jump
        $display("--- Testing Jump ---");
        jump_en = 1'b1;           // Enable the jump
        jump_addr = 32'hCAFE_BABE;  // Provide a jump target address
        @(posedge clk);           // On this clock edge, PC should load jump_addr
        #2

        // 4. Disable jump and resume normal increment
        $display("--- Resuming Increment from Jump Address ---");
        jump_en = 1'b0;
        jump_addr = 'x;             // Set ALU output to 'x' to show it's not being used
        @(posedge clk);           // PC should now be CAFE_BABE + 4
        @(posedge clk);           // PC should be CAFE_BABE + 8

        $finish;
    end

endmodule