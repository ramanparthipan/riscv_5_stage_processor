`timescale 1ns / 1ps

// A simple Program Counter that increments by 4 when enabled.
module program_counter #(
    parameter ADDR_WIDTH = 32
) (
    input  logic                clk,   // Clock
    input  logic                rst_n, // Asynchronous active-low reset
    input  logic                en,    // Enable signal
    output logic [ADDR_WIDTH-1:0] pc_out // Program Counter output
);

    // Internal register to hold the PC value
    logic [ADDR_WIDTH-1:0] pc_reg;

    // Sequential logic for the register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // On reset, clear the PC to 0
            pc_reg <= '0;
        end else if (en) begin
            // If enabled, increment the current value by 4
            pc_reg <= pc_reg + 4;
        end
        // If not enabled, the register holds its current value implicitly.
    end

    // Assign the internal register's value to the output port
    assign pc_out = pc_reg;

endmodule