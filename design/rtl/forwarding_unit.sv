`include "control_types.sv"

module forwarding_unit (
    // Inputs from ID/EX stage
    input  logic [4:0] ex_reg1_idx,
    input  logic [4:0] ex_reg2_idx,

    // Inputs from EX/MEM stage
    input  logic [4:0] mem_reg_wr_idx,
    input  logic       mem_reg_wr_en,

    // Inputs from MEM/WB stage
    input  logic [4:0] wb_reg_wr_idx,
    input  logic       wb_reg_wr_en,

    // Outputs to control ALU operand muxes
    output forwarding_src_t alu_reg1_forwarding_ctrl,
    output forwarding_src_t alu_reg2_forwarding_ctrl
);

    always_comb begin
        // ALU operand 1:
        // Default to no forwarding (use value from ID stage/Register File)
        alu_reg1_forwarding_ctrl = FWD_SRC_ID;
        // A non-zero register is needed for a hazard to be possible
        if (ex_reg1_idx != 0) begin
            // Hazard with MEM stage has HIGHER priority
            if (mem_reg_wr_en && (mem_reg_wr_idx == ex_reg1_idx)) begin
                alu_reg1_forwarding_ctrl = FWD_SRC_MEM;
            end
            // Hazard with WB stage has LOWER priority
            else if (wb_reg_wr_en && (wb_reg_wr_idx == ex_reg1_idx)) begin
                alu_reg1_forwarding_ctrl = FWD_SRC_WB;
            end
        end

        // ALU operand 2:
        alu_reg2_forwarding_ctrl = FWD_SRC_ID;
        if (ex_reg2_idx != 0) begin
            if (mem_reg_wr_en && (mem_reg_wr_idx == ex_reg2_idx)) begin
                alu_reg2_forwarding_ctrl = FWD_SRC_MEM;
            end
            else if (wb_reg_wr_en && (wb_reg_wr_idx == ex_reg2_idx)) begin
                alu_reg2_forwarding_ctrl = FWD_SRC_WB;
            end
        end
    end

endmodule