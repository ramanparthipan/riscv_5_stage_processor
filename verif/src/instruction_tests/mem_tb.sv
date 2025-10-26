`timescale 1ns / 1ps

module mem_tb;
    import opcodes_pkg::*;
    import control_types_pkg::*;

    localparam CLK_PERIOD = 10;
    localparam TEST = 1;

    logic         clk;
    logic         resetn;
    logic [31:0]  pc_out;
    logic [31:0]  instr_if;
    logic         mem_wr_en;
    mem_op_t      mem_op;
    logic [31:0]  mem_addr;
    logic [31:0]  mem_data_in;
    logic [31:0]  mem_data_out;

    // Instruction memory
    instr_mem instr_mem_h(
        .addr(pc_out),
        .instr(instr_if)
    );

    // Instantiate DUTs
    cpu cpu_h (.*);
    data_memory data_memory_h (
        .clk(clk), .wr_en(mem_wr_en), .mem_ctrl(mem_op),
        .addr(mem_addr), .data_in(mem_data_in), .data_out(mem_data_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Test sequence
    initial begin
        $display("--- Starting CPU Testbench ---");

        // Load program into instruction memory
        $readmemh("verif/src/programs/mem_test.hex", instr_mem_h.mem);
        $display("Instruction memory load done.");
        
        // Pulse reset
        resetn = 1'b0;
        #10;
        resetn = 1'b1;
        

        // Let the simulation run for enough cycles to complete the program
        #(CLK_PERIOD * 100);


        $display("Simulation run finished.");

        // Verification
        $display("\n--- Verification Phase ---");
        // x10 = 32'h12345678
        assert (cpu_h.register_file_h.registers[10] == 32'h12345678)
            $display("PASS: Register x10 has correct value 32'h12345678");
        else
            $error($sformatf("x10 value is incorrect. Expected 32'h12345678, got %h", cpu_h.register_file_h.registers[10]));
        // x11 = 32'h00000034
        assert (cpu_h.register_file_h.registers[11] == 32'h00000034)
            $display("PASS: Register x11 has correct value 32'h00000034");
        else
            $error($sformatf("x11 value is incorrect. Expected 32'h00000034, got %h", cpu_h.register_file_h.registers[11]));
        // x12 = 32'h00000034
        assert (cpu_h.register_file_h.registers[12] == 32'h00000034)
            $display("PASS: Register x12 has correct value 32'h00000034");
        else
            $error($sformatf("x12 value is incorrect. Expected 32'h00000034, got %h", cpu_h.register_file_h.registers[12]));
        // x13 = 32'h123456AA
        assert (cpu_h.register_file_h.registers[13] == 32'h123456AA)
            $display("PASS: Register x13 has correct value 32'h123456AA");
        else
            $error($sformatf("x13 value is incorrect. Expected 32'h123456AA, got %h", cpu_h.register_file_h.registers[13]));

        $display("\n--- Test Finished ---");
        $finish;
    end

endmodule