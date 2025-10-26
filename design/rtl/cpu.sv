module cpu 
    import opcodes_pkg::*;
    import control_types_pkg::*;
(
    input   logic           clk,
    input   logic           resetn,

    output  logic [31:0]    pc_out, // to instr_mem
    input   logic [31:0]    instr_if,

    output                  mem_wr_en, // to data_memory
    output  mem_op_t        mem_op,
    output  logic [31:0]    mem_addr,
    output  logic [31:0]    mem_data_in,
    input   logic [31:0]    mem_data_out
);

    // IF stage
    logic               pc_jump_enable;     // Enable for a jump
    logic [31:0]        pc_jump_addr;       // Jump target address from ALU
    logic               if_id_clear;        // Clear for IF/ID pipeline register, from Hazard Unit
    logic               fe_enable;          // Enable for IF stage (PC and IF/ID pipeline register   
    // ID stage   
    logic [31:0]        instr_id;               // Instruction signal in ID stage
    logic [31:0]        pc_id;                  // Propagated PC value in ID stage
    logic [31:0]        pc_plus4_id;            // Propagated PC+4 value in ID stage
    opcode_out_t        opcode_id;              // Opcode outputted from Decode unit
    comp_op_t           comp_ctrl_id;           // Control signal for Branch unit in ID stage
    reg_wr_src_t        reg_wr_src_ctrl_id;     // Source control signal for write data for Register File in ID stage
    alu_src1_t          alu_src1_ctrl_id;       // Source control signal for ALU operand 1 in ID stage
    alu_src2_t          alu_src2_ctrl_id;       // Source control signal for ALU operand 2 in ID stage
    alu_op_t            alu_ctrl_id;            // Control signal for ALU in ID stage
    mem_op_t            mem_ctrl_id;            // Control signal for Data Memory in ID stage
    logic [4:0]         wr_reg_idx_id;          // Write address to the Register File, originating from WB stage
    logic [4:0]         r1_reg_idx_id;          // Read address 1 from Register File
    logic [4:0]         r2_reg_idx_id;          // Read address 2 from Register File
    logic [31:0]        reg1_data_id;           // Read data 1 from Register File
    logic [31:0]        reg2_data_id;           // Read data 2 from Register File
    logic               reg_wr_en;              // Write enable for Register File
    logic [4:0]         reg_wr_idx;             // Write address for Register File
    logic [31:0]        reg_wr_data;            // Write data for Register File
    logic [31:0]        imm_id;                 // Immediate value outputted from Immediate Generator
    logic               id_ex_clear;            // Clear for ID/EX pipeline register, from Hazard Unit

    // EX stage
    logic                   reg_do_write_ctrl_ex;       // Write enable for Register File in EX stage
    logic                   mem_do_write_ctrl_ex;       // Write enable for Data Memory in EX stage
    logic                   mem_do_read_ctrl_ex;        // Read enable for Data Memory in EX stage
    logic                   do_branch_ex;               // Branch enable signal for updating PC
    logic                   do_jump_ex;                 // Jump enable signal for updating PC
    comp_op_t               comp_ctrl_ex;               // Control signal for Branch unit in EX stage
    reg_wr_src_t            reg_wr_src_ctrl_ex;         // Source control signal for write data for Register File in EX stage
    alu_src1_t              alu_src1_ctrl_ex;           // Source control signal for ALU operand 1 in EX stage
    alu_src2_t              alu_src2_ctrl_ex;           // Source control signal for ALU operand 2 in EX stage
    alu_op_t                alu_ctrl_ex;                // Control signal for ALU in EX stage
    mem_op_t                mem_ctrl_ex;                // Control signal for Data Memory in EX stage
    logic [31:0]            pc_plus4_ex;                // Propagated PC+4 value in EX stage
    logic [31:0]            pc_ex;                      // Propagated PC value in EX stage
    logic [31:0]            reg1_data_ex;               // Read data 1 from Register File in EX stage
    logic [31:0]            reg2_data_ex;               // Read data 2 from Register File in EX stage
    logic [31:0]            imm_ex;                     // Immediate value from Immediate Generator in EX stage
    logic [4:0]             r1_reg_idx_ex;              // Read address 1 for Register File in EX stage
    logic [4:0]             r2_reg_idx_ex;              // Read address 2 for Register File in EX stage
    logic [4:0]             wr_reg_idx_ex;              // Write address for Register File in EX stage
    forwarding_src_t        alu_reg1_forwarding_ctrl;   // Forwarding select signal for read address 1
    forwarding_src_t        alu_reg2_forwarding_ctrl;   // Forwarding select signal for read address 2
    logic [31:0]            reg1_src;                   // Forwarded value of Read address 1
    logic [31:0]            reg2_src;                   // Forwarded value of Read address 2
    logic [31:0]            alu_op1;                    // ALU operand 1
    logic [31:0]            alu_op2;                    // ALU operand 2
    logic [31:0]            alu_result_ex;              // ALU result in EX stage
    logic                   branch_taken;               // Branch taken signal to update PC

    // MEM stage
    logic                   reg_do_write_ctrl_mem;  // Write enable for Register File in MEM stage
    reg_wr_src_t            reg_wr_src_ctrl_mem;    // Source control signal for write data for Register File in MEM stage
    logic [31:0]            pc_plus4_mem;           // Propagated PC+4 value in MEM stage
    logic [31:0]            alu_result_mem;         // ALU result in MEM stage
    logic [4:0]             wr_reg_idx_mem;         // Write address for Register File in MEM stage

    // WB stage
    reg_wr_src_t            reg_wr_src_ctrl_wb; // Source control signal for write data for Register File in WB stage
    logic [31:0]            pc_plus4_wb;        // Propagated PC+4 value in WB stage
    logic [31:0]            alu_result_wb;      // ALU result in WB stage
    logic [31:0]            mem_data_out_wb;    // Data out from Data Memory in WB stage


    program_counter program_counter_h(
        .clk(clk),
        .resetn(resetn),
        .en(fe_enable),
        .jump_en(pc_jump_enable),
        .jump_addr(alu_result_ex),
        .pc_out(pc_out)
    );

    logic [31:0] pc_plus4;
    assign pc_plus4 = pc_out + 4;

    if_id_register if_id_register_h(
        .clk(clk),
        .clear(if_id_clear),
        .enable(fe_enable),

        .instr_if(instr_if),
        .pc_if(pc_out),
        .pc_plus4_if(pc_plus4),

        .instr_id(instr_id),
        .pc_id(pc_id),
        .pc_plus4_id(pc_plus4_id)
    );

    decode decode_h(
        .instr(instr_id),
        .opcode_out(opcode_id),
        .wr_reg_idx(wr_reg_idx_id),
        .r1_reg_idx(r1_reg_idx_id),
        .r2_reg_idx(r2_reg_idx_id)
    );

    control control_h(
        .opcode_in(opcode_id),
        .reg_do_write_ctrl(reg_do_write_ctrl_id),
        .mem_do_write_ctrl(mem_do_write_ctrl_id),
        .mem_do_read_ctrl(mem_do_read_ctrl_id),
        .do_branch(do_branch_id),
        .do_jump(do_jump_id),
        .comp_ctrl(comp_ctrl_id),
        .reg_wr_src_ctrl(reg_wr_src_ctrl_id),
        .alu_src1_ctrl(alu_src1_ctrl_id),
        .alu_src2_ctrl(alu_src2_ctrl_id),
        .alu_ctrl(alu_ctrl_id),
        .mem_ctrl(mem_ctrl_id)
    );

    register_file register_file_h(
        .clk(clk),
        .resetn(resetn),
        .r1_idx(r1_reg_idx_id),
        .r2_idx(r2_reg_idx_id),
        .reg1_data(reg1_data_id),
        .reg2_data(reg2_data_id),
        .wr_en(reg_wr_en),
        .wr_idx(reg_wr_idx),
        .wr_data(reg_wr_data)
    );

    immediate_generator immediate_generator_h(
        .opcode_in(opcode_id),
        .instr_in(instr_id),
        .imm_out(imm_id)
    );

    id_ex_register id_ex_register_h(
        .clk(clk),
        .clear(id_ex_clear),
        .enable(1'b1),

        .reg_do_write_ctrl_id(reg_do_write_ctrl_id),
        .mem_do_write_ctrl_id(mem_do_write_ctrl_id),
        .mem_do_read_ctrl_id(mem_do_read_ctrl_id),
        .do_branch_id(do_branch_id),
        .do_jump_id(do_jump_id),
        .comp_ctrl_id(comp_ctrl_id),
        .reg_wr_src_ctrl_id(reg_wr_src_ctrl_id),
        .alu_src1_ctrl_id(alu_src1_ctrl_id),
        .alu_src2_ctrl_id(alu_src2_ctrl_id),
        .alu_ctrl_id(alu_ctrl_id),
        .mem_ctrl_id(mem_ctrl_id),
        .pc_plus4_id(pc_plus4_id),
        .pc_id(pc_id),
        .reg1_data_id(reg1_data_id),
        .reg2_data_id(reg2_data_id),
        .imm_out_id(imm_id),
        .r1_reg_idx_id(r1_reg_idx_id),
        .r2_reg_idx_id(r2_reg_idx_id),
        .wr_reg_idx_id(wr_reg_idx_id),

        .reg_do_write_ctrl_ex(reg_do_write_ctrl_ex),
        .mem_do_write_ctrl_ex(mem_do_write_ctrl_ex),
        .mem_do_read_ctrl_ex(mem_do_read_ctrl_ex),
        .do_branch_ex(do_branch_ex),
        .do_jump_ex(do_jump_ex),
        .comp_ctrl_ex(comp_ctrl_ex),
        .reg_wr_src_ctrl_ex(reg_wr_src_ctrl_ex),
        .alu_src1_ctrl_ex(alu_src1_ctrl_ex),
        .alu_src2_ctrl_ex(alu_src2_ctrl_ex),
        .alu_ctrl_ex(alu_ctrl_ex),
        .mem_ctrl_ex(mem_ctrl_ex),
        .pc_plus4_ex(pc_plus4_ex),
        .pc_ex(pc_ex),
        .reg1_data_ex(reg1_data_ex),
        .reg2_data_ex(reg2_data_ex),
        .imm_out_ex(imm_ex),
        .r1_reg_idx_ex(r1_reg_idx_ex),
        .r2_reg_idx_ex(r2_reg_idx_ex),
        .wr_reg_idx_ex(wr_reg_idx_ex)
    );

    // Port order according to forwarding_src_t enum
    mux_3_to_1 reg1_src_sel_3_to_1(
        .sel(alu_reg1_forwarding_ctrl),
        .a(reg1_data_ex),
        .b(alu_result_mem),
        .c(reg_wr_data),
        .z(reg1_src)
    );

    // Port order according to alu_src1_t enum
    mux_2_to_1 alu_op1_sel_2_to_1(
        .sel(alu_src1_ctrl_ex),
        .a(reg1_src),
        .b(pc_ex),
        .z(alu_op1)
    );

    // Port order according to forwarding_src_t enum
    mux_3_to_1 reg2_src_sel_3_to_1(
        .sel(alu_reg2_forwarding_ctrl),
        .a(reg2_data_ex),
        .b(alu_result_mem),
        .c(reg_wr_data),
        .z(reg2_src)
    );

    // Port order according to alu_src2_t enum
    mux_2_to_1 alu_op2_sel_2_to_1(
        .sel(alu_src2_ctrl_ex),
        .a(reg2_src),
        .b(imm_ex),
        .z(alu_op2)
    );

    alu alu_h(
        .operand_a(alu_op1),
        .operand_b(alu_op2),
        .alu_op(alu_ctrl_ex),
        .result(alu_result_ex)
    );

    branch branch_h(
        .operand_a(reg1_src),
        .operand_b(reg2_src),
        .comp_op(comp_ctrl_ex),
        .result(branch_taken)
    );

    assign pc_jump_enable = (do_branch_ex & branch_taken) | do_jump_ex;

    forwarding_unit forwarding_unit_h(
        .ex_reg1_idx(r1_reg_idx_ex),
        .ex_reg2_idx(r2_reg_idx_ex),
        .mem_reg_wr_idx(wr_reg_idx_mem),
        .mem_reg_wr_en(reg_do_write_ctrl_mem),
        .wb_reg_wr_idx(reg_wr_idx),
        .wb_reg_wr_en(reg_wr_en),
        .alu_reg1_forwarding_ctrl(alu_reg1_forwarding_ctrl),
        .alu_reg2_forwarding_ctrl(alu_reg2_forwarding_ctrl)
    );

    hazard_unit hazard_unit_h(
        .id_reg1_idx(r1_reg_idx_id),
        .id_reg2_idx(r2_reg_idx_id),
        .pc_jump_enable(pc_jump_enable),
        .ex_reg_wr_idx(wr_reg_idx_ex),
        .ex_do_mem_read_en(mem_do_read_ctrl_ex),
        .hazard_fe_enable(fe_enable),
        .hazard_if_id_clear(if_id_clear),
        .hazard_id_ex_clear(id_ex_clear)
    );

    ex_mem_register ex_mem_register_h(
        .clk(clk),
        .clear(1'b0),
        .enable(1'b1),
        .reg_do_write_ctrl_ex(reg_do_write_ctrl_ex),
        .reg_wr_src_ctrl_ex(reg_wr_src_ctrl_ex),
        .mem_do_write_ctrl_ex(mem_do_write_ctrl_ex),
        .mem_ctrl_ex(mem_ctrl_ex),
        .pc_plus4_ex(pc_plus4_ex),
        .alu_result_ex(alu_result_ex),
        .mem_data_in_ex(reg2_src),
        .wr_reg_idx_ex(wr_reg_idx_ex),
        .reg_do_write_ctrl_mem(reg_do_write_ctrl_mem),
        .reg_wr_src_ctrl_mem(reg_wr_src_ctrl_mem),
        .mem_do_write_ctrl_mem(mem_wr_en),
        .mem_ctrl_mem(mem_op),
        .pc_plus4_mem(pc_plus4_mem),
        .alu_result_mem(alu_result_mem),
        .mem_data_in_mem(mem_data_in),
        .wr_reg_idx_mem(wr_reg_idx_mem)
    );

    assign mem_addr = alu_result_mem;

    mem_wb_register mem_wb_register_h(
        .clk(clk),
        .clear(1'b0),
        .enable(1'b1),
        .reg_do_write_ctrl_mem(reg_do_write_ctrl_mem),
        .reg_wr_src_ctrl_mem(reg_wr_src_ctrl_mem),
        .pc_plus4_mem(pc_plus4_mem),
        .alu_result_mem(alu_result_mem),
        .mem_data_out_mem(mem_data_out),
        .wr_reg_idx_mem(wr_reg_idx_mem),
        .reg_do_write_ctrl_wb(reg_wr_en),
        .reg_wr_src_ctrl_wb(reg_wr_src_ctrl_wb),
        .pc_plus4_wb(pc_plus4_wb),
        .alu_result_wb(alu_result_wb),
        .mem_data_out_wb(mem_data_out_wb),
        .wr_reg_idx_wb(reg_wr_idx)
    );

    // Port order according to reg_wr_src_t enum
    mux_3_to_1 reg_wr_src_3_to_1(
        .sel(reg_wr_src_ctrl_wb),
        .a(alu_result_wb),
        .b(mem_data_out_wb),
        .c(pc_plus4_wb),
        .z(reg_wr_data)
    );

endmodule