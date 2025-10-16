//
// RISC-V 32x32-bit Register File
//
// Implements the standard 32-entry register file.
// - Register x0 is hardwired to the value 0.
// - Features two combinational (asynchronous) read ports.
// - Features one synchronous write port
//
module register_file (
    input wire clk,          // Clock
    input wire resetn,        // Asynchronous active-low reset

    // Read Port 1
    input wire [4:0]  r1_idx,       // Address of register to read
    output wire [31:0] reg1_data,   // Data read from register

    // Read Port 2
    input wire [4:0]  r2_idx,       // Address of register to read
    output wire [31:0] reg2_data,   // Data read from register

    // Write Port
    input wire        wr_en,        // Write enable signal
    input wire [4:0]  wr_idx,       // Address of register to write
    input wire [31:0] wr_data       // Data to write into register
);

    // 32 registers, each 32 bits wide.
    reg [31:0] registers [0:31];

    // --- Synchronous Write Logic ---
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            integer i;
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (wr_en) begin
            // Must not allow writes to register x0
            if (wr_idx != 5'b0) begin
                registers[wr_idx] <= wr_data;
            end
        end
    end

    // --- Combinational Read Logic ---
    // Allows forwarding from the WB stage
    assign reg1_data = (r1_idx == 0) ? 32'b0 : 
    (r1_idx == wr_idx && wr_en) ? wr_data : registers[r1_idx];
    assign reg2_data = (r2_idx == 0) ? 32'b0 : 
    (r2_idx == wr_idx && wr_en) ? wr_data : registers[r2_idx];

endmodule