`timescale 1ns / 1ps

`include "opcodes.sv"

module immediate_generator (
    input  opcode_out_t   opcode_in,
    input  logic [31:0]   instr_in,
    output logic [31:0]   imm_out
);

    always_comb begin
        // For debugging purposes, but should not happen
        imm_out = 32'hDEADBEEF;

        case (opcode_in)
            // I-Type (Immediate arithmetic, Loads, JALR)
            ADDI, SLTI, SLTIU, XORI, ORI, ANDI, JALR, LB, LH, LW, LBU, LHU: begin
                // Sign-extend 12-bit immediate from bits 31:20
                imm_out = {{20{instr_in[31]}}, instr_in[31:20]};
            end

            // I-Type (Shifts)
            SLLI, SRLI, SRAI: begin
                // Zero-extend the 5-bit shift amount from bits 24:20
                imm_out = {27'b0, instr_in[24:20]};
            end

            // S-Type (Stores)
            SB, SH, SW: begin
                // Reassemble the split 12-bit immediate and sign-extend
                imm_out = {{20{instr_in[31]}}, instr_in[31:25], instr_in[11:7]};
            end

            // B-Type (Branches)
            BEQ, BNE, BLT, BGE, BLTU, BGEU: begin
                // Reassemble the scattered 13-bit immediate (12 bits + implicit 0) and sign-extend
                imm_out = {{20{instr_in[31]}}, instr_in[7], instr_in[30:25], instr_in[11:8], 1'b0};
            end

            // U-Type (LUI, AUIPC)
            LUI, AUIPC: begin
                // Place the 20-bit immediate in the upper bits, with lower 12 bits as zero
                imm_out = {instr_in[31:12], 12'b0};
            end

            // J-Type (JAL)
            JAL: begin
                // Reassemble the scattered 21-bit immediate (20 bits + implicit 0) and sign-extend
                imm_out = {{12{instr_in[31]}}, instr_in[19:12], instr_in[20], instr_in[30:21], 1'b0};
            end

            default: begin
                // For R-Type, ECALL, etc., there is no immediate.
                // Output a default value (can be 0 or a debug value).
                imm_out = 32'h0;
            end
        endcase
    end

endmodule