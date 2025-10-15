`timescale 1ns / 1ps

module data_memory_tb;
    `include "control_types.sv"

    logic        clk;
    logic        wr_en;
    mem_op_t     mem_ctrl;
    logic [31:0] addr;
    logic [31:0] data_in;
    logic [31:0] data_out;

    // Instantiate DUT
    data_memory dut (.*);

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Task to write to memory
    task write_mem(input mem_op_t op, input logic [31:0] w_addr, w_data);
        @(posedge clk);
        wr_en    = 1'b1;
        mem_ctrl = op;
        addr     = w_addr;
        data_in  = w_data;
        @(posedge clk);
        wr_en    = 1'b0;
    endtask

    // Function to convert the mem_op_t enum to a string
    function string mem_op_to_string(input mem_op_t op);
        case (op)
            MEM_NOP: return "MEM_NOP";
            MEM_SB:  return "MEM_SB";
            MEM_SH:  return "MEM_SH";
            MEM_SW:  return "MEM_SW";
            MEM_LB:  return "MEM_LB";
            MEM_LH:  return "MEM_LH";
            MEM_LW:  return "MEM_LW";
            MEM_LBU: return "MEM_LBU";
            MEM_LHU: return "MEM_LHU";
            default: return "UNKNOWN_MEM_OP";
        endcase
    endfunction

    // Task to read and check memory
    task check_read(input mem_op_t op, input logic [31:0] r_addr, exp_data);
        mem_ctrl = op;
        addr     = r_addr;
        #1; // Wait for combinational logic
        assert (data_out == exp_data)
            $display("PASS: Read %s at addr %h => Got %h", mem_op_to_string(op), r_addr, data_out);
        else
            $error("FAIL: Read %s at addr %h => Got %h, Expected %h", mem_op_to_string(op), r_addr, data_out, exp_data);
    endtask


    // Test Sequence
    initial begin
        $display("--- Starting Data Memory Test ---");

        // 1. Write a full word to address 100
        write_mem(MEM_SW, 100, 32'h89ABCDEF);

        // 2. Read back data in different sizes and signedness
        check_read(MEM_LW,  100, 32'h89ABCDEF); // Read full word
        check_read(MEM_LBU, 100, 32'h000000EF); // Read byte unsigned (EF)
        check_read(MEM_LB,  100, 32'hFFFFFFEF); // Read byte signed (EF -> -17)
        check_read(MEM_LHU, 102, 32'h000089AB); // Read half-word unsigned (89AB)
        check_read(MEM_LH,  102, 32'hFFFF89AB); // Read half-word signed (89AB -> -30293)
        
        $display("\n--- Test Finished ---");
        $finish;
    end
endmodule