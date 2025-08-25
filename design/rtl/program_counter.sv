`timescale 1ns / 1ps

module program_counter #(
    parameter ADDR_WIDTH = 32
) (
    input  logic                clk,      // Clock
    input  logic                rst_n,    // Asynchronous active-low reset
    input  logic                en,       // Enable for normal increment
    input  logic                jump_en,  // Enable for a jump
    input  logic [ADDR_WIDTH-1:0] alu_out,  // Jump target address from ALU
    output logic [ADDR_WIDTH-1:0] pc_out    // Program Counter output
);

    // Internal register to hold the PC value
    logic [ADDR_WIDTH-1:0] pc_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_reg <= '0;
        end else if (jump_en) begin
            pc_reg <= alu_out;
        end else if (en) begin
            pc_reg <= pc_reg + 4;
        end
    end

    assign pc_out = pc_reg;

endmodule