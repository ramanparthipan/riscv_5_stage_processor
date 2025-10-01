`include "opcodes.sv"

module hazard_unit (
    // Inputs from ID stage
    input  opcode_out_t   opcode_in,
    input  logic [4:0]    id_reg1_idx,
    input  logic [4:0]    id_reg2_idx,

    // Inputs from EX stage
    input  logic [4:0]    ex_reg_wr_idx,
    input  logic          ex_do_mem_read_en,

    // Outputs to control the pipeline
    output logic          hazard_fe_enable,     // To PC and IF/ID enable
    output logic          hazard_if_id_clear,    // To IF/ID clear
    output logic          hazard_id_ex_clear    // To ID/EX clear
);

    // Load-Use Hazard: occurs if the instruction in EX is a memory read (like lw)
    // and its destination register is a source for the instruction in ID.
    logic load_use_hazard;
    assign load_use_hazard = (ex_do_mem_read_en) && (ex_reg_wr_idx != 0) &&
                             ((ex_reg_wr_idx == id_reg1_idx) || (ex_reg_wr_idx == id_reg2_idx));

    logic pc_jump_hazard;
    always_comb begin
        case (opcode_in)
            BEQ, BNE, BLT, BGE, BLTU, BGEU, JAL, JALR: pc_jump_hazard = 1;
            default: pc_jump_hazard = 0;
        endcase
    end

    // The ID/EX register is cleared (a bubble is inserted) for a load-use hazard.
    assign hazard_id_ex_clear = load_use_hazard;

    // The IF/ID register is cleared if a PC jump is detected.
    assign hazard_if_id_clear = pc_jump_hazard;

    // The front-end of the pipeline (PC and IF/ID) is stalled if any hazard is detected.
    assign hazard_fe_enable = !(load_use_hazard || pc_jump_hazard);

endmodule