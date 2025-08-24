`include "opcodes.sv"

module decode (
    input  logic [31:0]    instr,
    output opcode_out_t    opcode_out, // to control unit and imm. generator
    output logic [4:0]     wr_reg_idx, // rd
    output logic [4:0]     r1_reg_idx, // rs1
    output logic [4:0]     r2_reg_idx  // rs2
);

    // Extract the relevant fields from the instruction word
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

    // Combinatorial logic for decoding
    always_comb begin
        // Default to NOP
        opcode_out = NOP;

        case (opcode)
            OP_REG: begin
                    case (funct3)
                        3'b000: begin
                            if (funct7==7'h00) opcode_out = ADD;
                            else if (funct7==7'h20) opcode_out = SUB;
                            else opcode_out = NOP;
                        end
                        3'b001: opcode_out = SLL;
                        3'b010: opcode_out = SLT;
                        3'b011: opcode_out = SLTU;
                        3'b100: opcode_out = XOR;
                        3'b101: begin
                            if (funct7==7'h00) opcode_out = SRL;
                            else if (funct7==7'h20) opcode_out = SRA;
                            else opcode_out = NOP;
                        end
                        3'b110: opcode_out = OR;
                        3'b111: opcode_out = AND;
                        default: opcode_out = NOP;
                    endcase
            end
            OP_IMM: begin
                case (funct3)
                    3'b000: opcode_out = ADDI;
                    3'b010: opcode_out = SLTI;
                    3'b011: opcode_out = SLTIU;
                    3'b100: opcode_out = XORI;
                    3'b110: opcode_out = ORI;
                    3'b111: opcode_out = ANDI;
                    3'b001: opcode_out = SLLI;
                    3'b101: begin
                        if (funct7 == 7'b0000000) opcode_out = SRLI;
                        else if (funct7 == 7'b0100000) opcode_out = SRAI;
                        else opcode_out = NOP;
                    end
                    default: opcode_out = NOP;
                endcase
            end
            OP_LOAD: begin
                case (funct3)
                    3'b000: opcode_out = LB;
                    3'b001: opcode_out = LH;
                    3'b010: opcode_out = LW;
                    3'b100: opcode_out = LBU;
                    3'b101: opcode_out = LHU;
                    default: opcode_out = NOP;
                endcase
            end
            OP_STORE: begin
                case (funct3)
                    3'b000: opcode_out = SB;
                    3'b001: opcode_out = SH;
                    3'b011: opcode_out = SW;    
                endcase
            end
            OP_BRANCH:
                case (funct3)
                   3'b000: opcode_out = BEQ;
                   3'b001: opcode_out = BNE;
                   3'b100: opcode_out = BLT;
                   3'b101: opcode_out = BGE;
                   3'b110: opcode_out = BLTU;
                   3'b111: opcode_out = BGEU; 
                endcase
            OP_LUI:   opcode_out = LUI;
            OP_AUIPC: opcode_out = AUIPC;
            OP_JAL:   opcode_out = JAL;
            OP_JALR:  opcode_out = JALR;
            OP_SYSTEM:
                case (funct7)
                    7'h0: opcode_out = ECALL;
                    7'h1: opcode_out = EBREAK;
                endcase
            default: opcode_out = NOP;
        endcase
    end

    // Register indices can be assigned continuously as their position is fixed
    assign wr_reg_idx = instr[11:7];
    assign r1_reg_idx = instr[19:15];
    assign r2_reg_idx = instr[24:20];

endmodule