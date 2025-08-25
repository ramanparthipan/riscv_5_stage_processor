// instruction memory

module instr_mem #(
    parameter ADDR_BITS = 1024,
    parameter DATA_BITS = 8
)(
    input logic clk,
    input logic [ADDR_BITS-1:0] addr,
    output logic [DATA_BITS-1:0] data
);

    logic [DATA_BITS-1:0] mem [0:2**ADDR_BITS-1];
    
    always_ff @(posedge clk) begin
        data <= mem[addr];
    end

endmodule // instr_mem