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
    output logic          hazardFEEnable,     // To PC and IF/ID enable
    output logic          hazardIDEXClear    // To ID/EX clear/bubble
);

    // Load-Use Hazard: occurs if the instruction in EX is a memory read (like lw)
    // and its destination register is a source for the instruction in ID.
    logic load_use_hazard;
    assign load_use_hazard = (ex_do_mem_read_en) && (ex_reg_wr_idx != 0) &&
                             ((ex_reg_wr_idx == id_reg1_idx) || (ex_reg_wr_idx == id_reg2_idx));

    // The ID/EX register is cleared (a bubble is inserted) for a load-use hazard.
    assign hazardIDEXClear = load_use_hazard;

    // The front-end of the pipeline (PC and IF/ID) is stalled if any hazard is detected.
    assign hazardFEEnable = !load_use_hazard;

endmodule