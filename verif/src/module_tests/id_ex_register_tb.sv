`timescale 1ns/1ps

module id_ex_register_tb();
    localparam CLOCK_PERIOD = 10;

    logic         clk;
    logic         clear;
    logic         enable;

    logic         reg_do_write_ctrl_id; // Control unit
    logic         mem_do_write_ctrl_id;
    logic         mem_do_read_ctrl_id;
    logic         do_branch_id;
    logic         do_jump_id;
    comp_op_t     comp_ctrl_id;
    reg_wr_src_t  reg_wr_src_ctrl_id;
    alu_src1_t    alu_src1_ctrl_id;
    alu_src2_t    alu_src2_ctrl_id;
    alu_op_t      alu_ctrl_id;
    mem_op_t      mem_ctrl_id;
    logic [31:0]  pc_plus4_id; // PC
    logic [31:0]  pc_id;
    logic [31:0]  reg1_data_id; // Register file
    logic [31:0]  reg2_data_id;
    logic [31:0]  imm_out_id; // Immediate generator
    opcode_out_t  opcode_out_id; // Decode unit
    logic [4:0]   r1_reg_idx_id;
    logic [4:0]   r2_reg_idx_id;
    logic [4:0]   wr_reg_idx_id;

    logic        reg_do_write_ctrl_ex; // Control unit
    logic        mem_do_write_ctrl_ex;
    logic        mem_do_read_ctrl_ex;
    logic        do_branch_ex;
    logic        do_jump_ex;
    comp_op_t    comp_ctrl_ex;
    reg_wr_src_t reg_wr_src_ctrl_ex;
    alu_src1_t   alu_src1_ctrl_ex;
    alu_src2_t   alu_src2_ctrl_ex;
    alu_op_t     alu_ctrl_ex;
    mem_op_t     mem_ctrl_ex;
    logic [31:0] pc_plus4_ex; // PC
    logic [31:0] pc_ex;
    logic [31:0] reg1_data_ex; // Register file
    logic [31:0] reg2_data_ex;
    logic [31:0] imm_out_ex; // Immediate generator
    opcode_out_t opcode_out_ex; // Decode unit
    logic [4:0]  r1_reg_idx_ex;
    logic [4:0]  r2_reg_idx_ex;
    logic [4:0]  wr_reg_idx_ex;

    // Instantiate DUT
    id_ex_register dut(.*);

    // Clock generator
    initial begin
        clk = 'b0;
        forever begin
            #(CLOCK_PERIOD/2)
            clk = ~clk;
        end
    end
    
    initial begin
        // Test uninitialisation
        assert (reg_do_write_ctrl_ex === 1'bx) // use case equality for 'x' or 'z' states
            $display("PASS: reg_do_write_ctrl_ex uninitialised!");

        // Test clear
        clear = 'b1;
        enable = 'b0;
        @(posedge clk);
        #2  // Wait for logic to settle

        assert (reg_do_write_ctrl_ex == 'b0)
            $display("PASS: reg_do_write_ctrl_ex set to zero!");
        
        // Test if reg_do_write_ctrl_id propagates
        clear = 'b0;
        enable = 'b1;
        reg_do_write_ctrl_id = 'b1;
        @(posedge clk);
        #2

        assert (reg_do_write_ctrl_ex == 'b1)
            $display("PASS: reg_do_write_ctrl_id has propagated through id_ex pipeline register!");
        
        // Test clear again
        clear = 'b1;
        @(posedge clk);
        #2

        assert (reg_do_write_ctrl_ex == 'b0)
            $display("PASS: reg_do_write_ctrl_ex cleared!");

        $finish;
    end


endmodule