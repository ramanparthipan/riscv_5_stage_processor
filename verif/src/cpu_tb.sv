`timescale 1ns / 1ps

module cpu_tb;
    `include "opcodes.sv"
    `include "control_types.sv"

    localparam CLK_PERIOD = 10;
    localparam TEST = 5;

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
    data_memory data_mem_h (
        .clk(clk), .wr_en(mem_wr_en), .mem_ctrl(mem_op),
        .addr(mem_addr), .data_in(mem_data_in), .data_out(mem_data_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Test sequence
    logic [31:0] stored_val;
    initial begin
        if (TEST == 1) begin
            $display("--- Starting CPU Testbench ---");

            // Load program into instruction memory
            $readmemh("verif/src/programs/cpu_test_01.hex", instr_mem_h.mem);
            $display("Instruction memory load done.");
            
            // Pulse reset
            resetn = 1'b0;
            #10;
            resetn = 1'b1;
            

            // Let the simulation run for enough cycles to complete the program
            #(CLK_PERIOD * 20);


            $display("Simulation run finished.");

            // Verification
            $display("\n--- Verification Phase ---");

            // Check 1: The value 25 (0x19) should have been stored at address 40
            stored_val = {data_mem_h.mem[43], data_mem_h.mem[42], data_mem_h.mem[41], data_mem_h.mem[40]};
            assert (stored_val == 32'd25)
                $display("PASS: Value 25 correctly stored in data memory.");
            else
                $error("FAIL: Incorrect value in data memory. Got %h", stored_val);

            
            // Check 2: Register x7 should contain 25 (result of add)
            assert (cpu_h.register_file_h.registers[7] == 32'd25)
                $display("PASS: Register x7 holds correct value 25.");
            else
                $error("FAIL: Register x7 incorrect. Got %d", cpu_h.register_file_h.registers[7]);
            
            // Check 3: Register x8 should contain 26 (result of lw + addi)
            assert (cpu_h.register_file_h.registers[8] == 32'd26)
                $display("PASS: Register x8 holds correct value 26.");
            else
                $error("FAIL: Register x8 incorrect. Got %d", cpu_h.register_file_h.registers[8]);

            // Check 4: The 'pass' instruction should have been reached, setting x30 to 0xAA
            assert (cpu_h.register_file_h.registers[30] == 32'hAA)
                $display("PASS: Program reached 'pass' label, x30 is 0xAA.");
            else
                $error("FAIL: Program did not reach 'pass' label. x30 is %h", cpu_h.register_file_h.registers[30]);
            

            $display("\n--- Test Finished ---");
            $finish;
        end
        else if (TEST == 2) begin
            $display("--- Starting CPU Testbench ---");

            // Load program into instruction memory
            $readmemh("verif/src/programs/cpu_test_02.hex", instr_mem_h.mem);
            $display("Instruction memory load done.");
            
            // Pulse reset
            resetn = 1'b0;
            #10;
            resetn = 1'b1;

            // Let the simulation run for enough cycles to complete the program
            #(CLK_PERIOD * 20);


            $display("Simulation run finished.");

            // Verification
            $display("\n--- Verification Phase ---");

            // Register x7 should contain 10
            assert (cpu_h.register_file_h.registers[7] == 32'd10)
                $display("PASS: Register x7 holds correct value 10.");
            else
                $error("FAIL: Register x7 incorrect. Got %d", cpu_h.register_file_h.registers[7]);

            // The value 10 (0x19) should have been stored at address 40
            stored_val = {data_mem_h.mem[43], data_mem_h.mem[42], data_mem_h.mem[41], data_mem_h.mem[40]};
            assert (stored_val == 32'd10)
                $display("PASS: Value 10 correctly stored in data memory.");
            else
                $error("FAIL: Incorrect value in data memory. Got %h", stored_val);

           
            $display("\n--- Test Finished ---");
            $finish;
        end
        else if (TEST == 3) begin
            $display("--- Starting CPU Testbench ---");

            // Load program into instruction memory
            $readmemh("verif/src/programs/cpu_test_03.hex", instr_mem_h.mem);
            $display("Instruction memory load done.");

            // Pulse reset
            resetn = 1'b0;
            #10;
            resetn = 1'b1;

            // Let the simulation run for enough cycles to complete the program
            #(CLK_PERIOD * 20);


            $display("Simulation run finished.");

            // Verification
            $display("\n--- Verification Phase ---");

            // Register x5 should contain 10
            assert (cpu_h.register_file_h.registers[5] == 32'd10)
                $display("PASS: Register x5 holds correct value 10.");
            else
                $error("FAIL: Register x5 incorrect. Got %d", cpu_h.register_file_h.registers[5]);

            // Register x6 should contain 15
            assert (cpu_h.register_file_h.registers[6] == 32'd15)
                $display("PASS: Register x6 holds correct value 15.");
            else
                $error("FAIL: Register x6 incorrect. Got %d", cpu_h.register_file_h.registers[6]);

           
            $display("\n--- Test Finished ---");
            $finish;
        end
        else if (TEST == 4) begin
            $display("--- Starting CPU Testbench ---");

            // Load program into instruction memory
            $readmemh("verif/src/programs/cpu_test_04.hex", instr_mem_h.mem);
            $display("Instruction memory load done.");

            // Pulse reset
            resetn = 1'b0;
            #10;
            resetn = 1'b1;

            // Let the simulation run for enough cycles to complete the program
            #(CLK_PERIOD * 20);


            $display("Simulation run finished.");

            // Verification
            $display("\n--- Verification Phase ---");

            // Register x5 should contain 10
            assert (cpu_h.register_file_h.registers[5] == 32'd10)
                $display("PASS: Register x5 holds correct value 10.");
            else
                $error("FAIL: Register x5 incorrect. Got %d", cpu_h.register_file_h.registers[5]);

            // Register x6 should contain 15
            assert (cpu_h.register_file_h.registers[6] == 32'd15)
                $display("PASS: Register x6 holds correct value 15.");
            else
                $error("FAIL: Register x6 incorrect. Got %d", cpu_h.register_file_h.registers[6]);

            // Register x7 should contain 25
            assert (cpu_h.register_file_h.registers[7] == 32'd25)
                $display("PASS: Register x7 holds correct value 25.");
            else
                $error("FAIL: Register x7 incorrect. Got %d", cpu_h.register_file_h.registers[7]);

           
            $display("\n--- Test Finished ---");
            $finish;
        end
        else if (TEST == 5) begin
            $display("--- Starting CPU Testbench ---");

            // Load program into instruction memory
            $readmemh("verif/src/programs/cpu_test_05.hex", instr_mem_h.mem);
            $display("Instruction memory load done.");

            // Pulse reset
            resetn = 1'b0;
            #10;
            resetn = 1'b1;

            // Let the simulation run for enough cycles to complete the program
            #(CLK_PERIOD * 20);


            $display("Simulation run finished.");
           
            $display("\n--- Test Finished ---");
            $finish;
        end
    end

    always @(pc_out) begin
        $display("At time %0t: pc_out changed to %h", $time, pc_out);
        #5;
        $display("At time %0t: instr_if has the value of %h", $time, instr_if);
        $display("At time %0t: instr_id has the value of %h", $time, cpu_h.if_id_register_h.instr_id);
    end


endmodule