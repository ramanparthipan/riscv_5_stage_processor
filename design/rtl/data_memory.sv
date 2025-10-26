module data_memory 
import control_types_pkg::*;
#(
    parameter MEM_SIZE_BYTES = 1024 // 1KB memory size
)(
    input  logic         clk,
    input  logic         wr_en,
    input  mem_op_t      mem_ctrl,
    input  logic [31:0]  addr,
    input  logic [31:0]  data_in,

    output logic [31:0]  data_out
);

    // Memory implemented as an array of bytes
    logic [7:0] mem [0:MEM_SIZE_BYTES-1];

    always_ff @(posedge clk) begin
        if (wr_en) begin
            case (mem_ctrl)
                MEM_SB: mem[addr] <= data_in[7:0];
                MEM_SH: {mem[addr+1], mem[addr]} <= data_in[15:0]; // Using little-endian convention
                MEM_SW: {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]} <= data_in[31:0];
            endcase
        end
    end

    logic [31:0] word_at_addr;
    always_comb begin
        // Default to a known value
        data_out = 32'hDEADBEEF;

        // Assemble the 32-bit word at the given address (little-endian)
        word_at_addr = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};

        case (mem_ctrl)
            MEM_LB:  data_out = {{24{word_at_addr[7]}}, word_at_addr[7:0]}; // Sign-extend byte
            MEM_LBU: data_out = {24'b0, word_at_addr[7:0]};                 // Zero-extend byte
            MEM_LH:  data_out = {{16{word_at_addr[15]}}, word_at_addr[15:0]}; // Sign-extend half-word
            MEM_LHU: data_out = {16'b0, word_at_addr[15:0]};                  // Zero-extend half-word
            MEM_LW:  data_out = word_at_addr; // Return full word
            default: data_out = 32'b0;        // No read for NOP, stores, or invalid ops
        endcase
    end

endmodule