`timescale 1ns / 1ps

module cpu_tb;
    `include "opcodes.sv"
    `include "control_types.sv"

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
        $readmemh("verif/src/programs/add_full_test.hex", instr_mem_h.mem);
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
        // x10 = 1
        assert (cpu_h.register_file_h.registers[10] == 32'd1)
            $display("PASS: Register x10 has correct value 1");
        else
            $error($sformatf("x10 value is incorrect. Expected 1, got %d", cpu_h.register_file_h.registers[10]));
        // x11 = -2147483648 (max negative number)
        assert ($signed(cpu_h.register_file_h.registers[11]) == -2147483648)
            $display("PASS: Register x11 has correct value -2147483648");
        else
            $error($sformatf("x11 value is incorrect. Expected -2147483648, got %d", $signed(cpu_h.register_file_h.registers[11])));
        // x0 = 0
        assert (cpu_h.register_file_h.registers[0] == 0)
            $display("PASS: Register x0 has correct value 0");
        else
            $error($sformatf("x0 value is incorrect. Expected 0, got %d", cpu_h.register_file_h.registers[0]));
        // x12 = 301
        assert (cpu_h.register_file_h.registers[12] == 301)
            $display("PASS: Register x12 has correct value 301");
        else
            $error($sformatf("x12 value is incorrect. Expected 301, got %d", cpu_h.register_file_h.registers[12]));
        // x13 = 302
        assert (cpu_h.register_file_h.registers[13] == 302)
            $display("PASS: Register x13 has correct value 302");
        else
            $error($sformatf("x13 value is incorrect. Expected 302, got %d", cpu_h.register_file_h.registers[13]));
        // x14 = 301
        assert (cpu_h.register_file_h.registers[14] == 301)
            $display("PASS: Register x14 has correct value 301");
        else
            $error($sformatf("x14 value is incorrect. Expected 301, got %d", cpu_h.register_file_h.registers[14]));
        // x16 = 1235
        assert (cpu_h.register_file_h.registers[16] == 1235)
            $display("PASS: Register x16 has correct value 1235");
        else
            $error($sformatf("x16 value is incorrect. Expected 1235, got %d", cpu_h.register_file_h.registers[16]));
        // x17 = 0
        assert (cpu_h.register_file_h.registers[17] == 0)
            $display("PASS: Register x17 has correct value 0");
        else
            $error($sformatf("x17 value is incorrect. Expected 0, got %d", cpu_h.register_file_h.registers[17]));
        // x19 = 99
        assert (cpu_h.register_file_h.registers[19] == 99)
            $display("PASS: Register x19 has correct value 99");
        else
            $error($sformatf("x19 value is incorrect. Expected 99, got %d", cpu_h.register_file_h.registers[19]));

        $display("\n--- Test Finished ---");
        $finish;
    end

endmodule