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
        $readmemh("verif/src/programs/r_type_test.hex", instr_mem_h.mem);
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
        // x10 = 0
        assert (cpu_h.register_file_h.registers[10] == 32'd0)
            $display("PASS: Register x10 has correct value 0");
        else
            $error($sformatf("x10 value is incorrect. Expected 0, got %d", cpu_h.register_file_h.registers[10]));
        // x11 = 0
        assert (cpu_h.register_file_h.registers[11] == 0)
            $display("PASS: Register x11 has correct value 0");
        else
            $error($sformatf("x11 value is incorrect. Expected 0, got %d", cpu_h.register_file_h.registers[11]));
        // x12 = 5
        assert (cpu_h.register_file_h.registers[12] == 5)
            $display("PASS: Register x12 has correct value 5");
        else
            $error($sformatf("x12 value is incorrect. Expected 5, got %d", cpu_h.register_file_h.registers[12]));
        // x13 = 20
        assert (cpu_h.register_file_h.registers[13] == 20)
            $display("PASS: Register x13 has correct value 20");
        else
            $error($sformatf("x13 value is incorrect. Expected 20, got %d", cpu_h.register_file_h.registers[13]));
        // x14 = 32'h0FFFFFFF
        assert (cpu_h.register_file_h.registers[14] == 32'h0FFFFFFF)
            $display("PASS: Register x14 has correct value 32'h0FFFFFFF");
        else
            $error($sformatf("x14 value is incorrect. Expected 32'h0FFFFFFF, got %h", cpu_h.register_file_h.registers[14]));
        // x15 = 0xFFFFFFFE
        assert (cpu_h.register_file_h.registers[15] == 32'hFFFFFFFE)
            $display("PASS: Register x15 has correct value 32'hFFFFFFFE");
        else
            $error($sformatf("x15 value is incorrect. Expected 32'hFFFFFFFE, got %h", cpu_h.register_file_h.registers[15]));
        // x16 = 1
        assert (cpu_h.register_file_h.registers[16] == 1)
            $display("PASS: Register x16 has correct value 1");
        else
            $error($sformatf("x16 value is incorrect. Expected 1, got %d", cpu_h.register_file_h.registers[16]));
        // x17 = 0
        assert (cpu_h.register_file_h.registers[17] == 0)
            $display("PASS: Register x17 has correct value 0");
        else
            $error($sformatf("x17 value is incorrect. Expected 0, got %d", cpu_h.register_file_h.registers[17]));

        $display("\n--- Test Finished ---");
        $finish;
    end

endmodule