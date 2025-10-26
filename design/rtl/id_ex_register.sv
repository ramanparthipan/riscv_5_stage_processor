module id_ex_register
    import control_types_pkg::*;
(
    input logic         clk,
    input logic         clear,
    input logic         enable,
    
    input logic         reg_do_write_ctrl_id, // Control unit
    input logic         mem_do_write_ctrl_id,
    input logic         mem_do_read_ctrl_id,
    input logic         do_branch_id,
    input logic         do_jump_id,
    input comp_op_t     comp_ctrl_id,
    input reg_wr_src_t  reg_wr_src_ctrl_id,
    input alu_src1_t    alu_src1_ctrl_id,
    input alu_src2_t    alu_src2_ctrl_id,
    input alu_op_t      alu_ctrl_id,
    input mem_op_t      mem_ctrl_id,
    input logic [31:0]  pc_plus4_id, // PC
    input logic [31:0]  pc_id,
    input logic [31:0]  reg1_data_id, // Register file
    input logic [31:0]  reg2_data_id,
    input logic [31:0]  imm_out_id, // Immediate generator
    input logic [4:0]   r1_reg_idx_id,
    input logic [4:0]   r2_reg_idx_id,
    input logic [4:0]   wr_reg_idx_id,

    output logic        reg_do_write_ctrl_ex, // Control unit
    output logic        mem_do_write_ctrl_ex,
    output logic        mem_do_read_ctrl_ex,
    output logic        do_branch_ex,
    output logic        do_jump_ex,
    output comp_op_t    comp_ctrl_ex,
    output reg_wr_src_t reg_wr_src_ctrl_ex,
    output alu_src1_t   alu_src1_ctrl_ex,
    output alu_src2_t   alu_src2_ctrl_ex,
    output alu_op_t     alu_ctrl_ex,
    output mem_op_t     mem_ctrl_ex,
    output logic [31:0] pc_plus4_ex, // PC
    output logic [31:0] pc_ex,
    output logic [31:0] reg1_data_ex, // Register file
    output logic [31:0] reg2_data_ex,
    output logic [31:0] imm_out_ex, // Immediate generator
    output logic [4:0]  r1_reg_idx_ex,
    output logic [4:0]  r2_reg_idx_ex,
    output logic [4:0]  wr_reg_idx_ex
);

always @(posedge clk) begin
    if (clear) begin
        reg_do_write_ctrl_ex    <= 0; 
        mem_do_write_ctrl_ex    <= 0;
        mem_do_read_ctrl_ex     <= 0;
        do_branch_ex            <= 0;
        do_jump_ex              <= 0;
        comp_ctrl_ex            <= BR_NOP;
        reg_wr_src_ctrl_ex      <= WRSRC_ALURES;
        alu_src1_ctrl_ex        <= SRC1_REG1;
        alu_src2_ctrl_ex        <= SRC2_REG2;         
        alu_ctrl_ex             <= ALU_NOP;
        mem_ctrl_ex             <= MEM_NOP;
        pc_plus4_ex             <= 0;
        pc_ex                   <= 0;
        reg1_data_ex            <= 0;
        reg2_data_ex            <= 0;
        imm_out_ex              <= 0;
        r1_reg_idx_ex           <= 0;
        r2_reg_idx_ex           <= 0;
        wr_reg_idx_ex           <= 0;
    end else if (enable) begin
        reg_do_write_ctrl_ex    <= reg_do_write_ctrl_id; 
        mem_do_write_ctrl_ex    <= mem_do_write_ctrl_id;
        mem_do_read_ctrl_ex     <= mem_do_read_ctrl_id;
        do_branch_ex            <= do_branch_id;
        do_jump_ex              <= do_jump_id;
        comp_ctrl_ex            <= comp_ctrl_id;
        reg_wr_src_ctrl_ex      <= reg_wr_src_ctrl_id;
        alu_src1_ctrl_ex         <= alu_src1_ctrl_id;
        alu_src2_ctrl_ex         <= alu_src2_ctrl_id;         
        alu_ctrl_ex             <= alu_ctrl_id;
        mem_ctrl_ex             <= mem_ctrl_id;
        pc_plus4_ex             <= pc_plus4_id;
        pc_ex                   <= pc_id;
        reg1_data_ex            <= reg1_data_id;
        reg2_data_ex            <= reg2_data_id;
        imm_out_ex              <= imm_out_id;
        r1_reg_idx_ex           <= r1_reg_idx_id;
        r2_reg_idx_ex           <= r2_reg_idx_id;
        wr_reg_idx_ex           <= wr_reg_idx_id;
    end
end

endmodule