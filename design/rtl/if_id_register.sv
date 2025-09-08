//
// IF/ID Pipeline Register with Enable
//
module if_id_register (
    input wire clk,          // Clock
    input wire clear,        // Asynchronous active-low reset
    input wire enable,      // Register enable signal

    // Inputs from IF Stage
    input wire [31:0] instr_if,     // Instruction from memory
    input wire [31:0] pc_if,        // Current Program Counter
    input wire [31:0] pc_plus4_if,  // PC + 4 calculated in IF stage

    // Outputs to ID Stage
    output reg [31:0] instr_id,
    output reg [31:0] pc_id,
    output reg [31:0] pc_plus4_id
);

    always @(posedge clk) begin
        if (clear) begin
            instr_id    <= 32'b0;
            pc_id       <= 32'b0;
            pc_plus4_id <= 32'b0;
        end else if (enable) begin
            // If enabled, latch the inputs from the IF stage
            instr_id    <= instr_if;
            pc_id       <= pc_if;
            pc_plus4_id <= pc_plus4_if;
        end
        // If enable is low, outputs implicitly hold their value (stalling the pipeline)
    end

endmodule