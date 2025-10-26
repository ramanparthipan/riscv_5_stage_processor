module ex_mem_register 
    import control_types_pkg::*;
(
    input  logic         clk,
    input  logic         clear,
    input  logic         enable,

    input  logic         reg_do_write_ctrl_ex,
    input  reg_wr_src_t  reg_wr_src_ctrl_ex,
    input  logic         mem_do_write_ctrl_ex,
    input  mem_op_t      mem_ctrl_ex,
    input  logic [31:0]  pc_plus4_ex,
    input  logic [31:0]  alu_result_ex,
    input  logic [31:0]  mem_data_in_ex,
    input  logic [4:0]   wr_reg_idx_ex,

    output logic                reg_do_write_ctrl_mem,
    output reg_wr_src_t         reg_wr_src_ctrl_mem,
    output logic                mem_do_write_ctrl_mem,
    output mem_op_t             mem_ctrl_mem,
    output logic [31:0]         pc_plus4_mem,
    output logic [31:0]         alu_result_mem,
    output logic [31:0]         mem_data_in_mem,
    output logic [4:0]          wr_reg_idx_mem
);

    always @(posedge clk) begin
        if (clear) begin
            reg_do_write_ctrl_mem <= 1'b0;
            reg_wr_src_ctrl_mem   <= WRSRC_ALURES;
            mem_do_write_ctrl_mem <= 1'b0;
            mem_ctrl_mem          <= MEM_NOP;
            pc_plus4_mem          <= 32'b0;
            alu_result_mem        <= 32'b0;
            mem_data_in_mem       <= 32'b0;
            wr_reg_idx_mem        <= 5'b0;
        end else if (enable) begin
            reg_do_write_ctrl_mem <= reg_do_write_ctrl_ex;
            reg_wr_src_ctrl_mem   <= reg_wr_src_ctrl_ex;
            mem_do_write_ctrl_mem <= mem_do_write_ctrl_ex;
            mem_ctrl_mem          <= mem_ctrl_ex;
            pc_plus4_mem          <= pc_plus4_ex;
            alu_result_mem        <= alu_result_ex;
            mem_data_in_mem       <= mem_data_in_ex;
            wr_reg_idx_mem        <= wr_reg_idx_ex;
        end
        // If enable is low, outputs implicitly hold their value (stalling)
    end

endmodule