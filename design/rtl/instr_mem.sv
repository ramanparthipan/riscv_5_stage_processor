// instruction memory

module instr_mem #(
    parameter INSTR_MEM_SIZE_BYTES = 1024
)(
    input logic [31:0] addr,
    output logic [31:0] instr
);

    logic [7:0] mem [0:INSTR_MEM_SIZE_BYTES-1];
    
    assign instr = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};

endmodule // instr_mem