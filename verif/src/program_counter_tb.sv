`timescale 1ns / 1ps

module tb_program_counter;
    localparam ADDR_WIDTH = 32;
    localparam CLK_PERIOD = 10;

    // Signals to connect to the DUT
    logic                clk;
    logic                rst_n;
    logic                en;
    logic                jump_en;
    logic [ADDR_WIDTH-1:0] alu_out;
    logic [ADDR_WIDTH-1:0] pc_out;

    // Instantiate DUT
    program_counter #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .jump_en(jump_en),
        .alu_out(alu_out),
        .pc_out(pc_out)
    );

    // Clock generator
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Monitor to display changes
    initial begin
        $monitor("Time: %0t | Rst: %b | En: %b | Jmp: %b | ALU_Out: %h | PC_Out: %h",
                 $time, rst_n, en, jump_en, alu_out, pc_out);
    end

    // Test sequence
    initial begin
        // 1. Assert reset
        rst_n = 1'b0; en = 1'b0; jump_en = 1'b0; alu_out = 'x;
        #20;

        // 2. De-assert reset and enable counting
        rst_n = 1'b1; en = 1'b1;
        @(posedge clk);
        @(posedge clk); // PC should be 4, then 8
        #2

        // 3. Test the jump
        $display("--- Testing Jump ---");
        jump_en = 1'b1;           // Enable the jump
        alu_out = 32'hCAFE_BABE;  // Provide a jump target address
        @(posedge clk);           // On this clock edge, PC should load alu_out
        #2

        // 4. Disable jump and resume normal increment
        $display("--- Resuming Increment from Jump Address ---");
        jump_en = 1'b0;
        alu_out = 'x;             // Set ALU output to 'x' to show it's not being used
        @(posedge clk);           // PC should now be CAFE_BABE + 4
        @(posedge clk);           // PC should be CAFE_BABE + 8

        $finish;
    end

endmodule