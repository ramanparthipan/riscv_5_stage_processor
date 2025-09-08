module id_ex_register(
    input logic        reg_do_write_ctrl, // RegWrite signal
    input logic        mem_do_write_ctrl, // MemWrite signal
    input logic        mem_do_read_ctrl,  // MemRead signal
    input logic        do_branch,
    input logic        do_jump,
    input comp_op_t    comp_ctrl,
    input reg_wr_src_t reg_wr_src_ctrl,
    input alu_src1_t   alu_op1_ctrl,
    input alu_src2_t   alu_op2_ctrl,
    input alu_op_t     alu_ctrl,
    input mem_ctrl_t   mem_ctrl
);



endmodule