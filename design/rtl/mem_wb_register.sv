`include "control_types.sv"

module mem_wb_register (
    input  logic         clk,
    input  logic         clear,
    input  logic         enable,

    input  logic         reg_do_write_ctrl_mem,
    input  reg_wr_src_t  reg_wr_src_ctrl_mem,
    input  logic [31:0]  pc_plus4_mem,
    input  logic [31:0]  alu_result_mem,
    input  logic [31:0]  mem_data_out_mem,
    input  logic [4:0]   wr_reg_idx_mem,

    output logic            reg_do_write_ctrl_wb,
    output reg_wr_src_t     reg_wr_src_ctrl_wb,
    output logic [31:0]     pc_plus4_wb,
    output logic [31:0]     alu_result_wb,
    output logic [31:0]     mem_data_out_wb,
    output logic [4:0]      wr_reg_idx_wb
);

    always @(posedge clk) begin
        if (clear) begin
            reg_do_write_ctrl_wb <= 1'b0;
            reg_wr_src_ctrl_wb   <= WRSRC_ALURES;
            pc_plus4_wb          <= 32'b0;
            alu_result_wb        <= 32'b0;
            mem_data_out_wb      <= 32'b0;
            wr_reg_idx_wb        <= 5'b0;
        end else if (enable) begin
            reg_do_write_ctrl_wb <= reg_do_write_ctrl_mem;
            reg_wr_src_ctrl_wb   <= reg_wr_src_ctrl_mem;
            pc_plus4_wb          <= pc_plus4_mem;
            alu_result_wb        <= alu_result_mem;
            mem_data_out_wb      <= mem_data_out_mem;
            wr_reg_idx_wb        <= wr_reg_idx_mem;
        end
        // If enable is low, outputs implicitly hold their value (stalling)
    end

endmodule