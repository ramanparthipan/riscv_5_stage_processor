`timescale 1ns / 1ps

module cpu_tb;
    `include "opcodes.sv"
    `include "control_types.sv"

    localparam CLK_PERIOD = 10;
    localparam INSTR_MEM_SIZE_BYTES = 1024;
    localparam MEM_SIZE_BYTES = 1024;

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
    instr_mem #(.INSTR_MEM_SIZE_BYTES(INSTR_MEM_SIZE_BYTES)) instr_mem_h(
        .addr(pc_out),
        .instr(instr_if)
    );

    // Instantiate DUTs
    cpu cpu_h (.*);
    data_memory #(.MEM_SIZE_BYTES(MEM_SIZE_BYTES)) data_memory_h(
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

        // initialise values in instr_mem and data_memory
        for (int i=0; i<INSTR_MEM_SIZE_BYTES; i++) begin
            instr_mem_h.mem[i] = 8'b0;
        end
        for (int i=0; i<MEM_SIZE_BYTES; i++) begin
            data_memory_h.mem[i] = 8'b0;
        end

        // For C programs, need to load .text sections into instruction memory and .data sections into data memory
        // Easier to load everything into both memories for now
        $readmemh("verif/src/programs/c_test.hex", instr_mem_h.mem);
        $readmemh("verif/src/programs/c_test.hex", data_memory_h.mem);
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

        assert (data_memory_h.mem[512] == 8'h69)
            $display("PASS: Final sum of 105 was correctly stored in memory.");
        else
            $error("FAIL: Incorrect value in memory. Got %h", data_memory_h.mem[512]);

        $finish;
    end

endmodule