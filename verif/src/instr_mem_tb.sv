`timescale 1ns/1ps

module instr_mem_tb();
    localparam ADDR_BITS = 10;
    localparam DATA_BITS = 32;

    logic [ADDR_BITS-1:0] instr_addr;
    logic [DATA_BITS-1:0] instr;
    logic clk;


    instr_mem #(.ADDR_BITS(ADDR_BITS), .DATA_BITS(DATA_BITS)) dut(
        .clk(clk),
        .addr(instr_addr),
        .data(instr)
    );

    // generate clock signal
    initial begin
        clk = 'b0;
        forever begin
            #5 // clock period 10ns
            clk = ~clk;
        end
    end
    
    initial begin
        $readmemh("verif/src/program.hex", dut.mem);

        instr_addr = 'h0;
        #20
        $display($sformatf("Retrieved instruction, %h", instr));
        instr_addr = 'h1;
        #20
        $display($sformatf("Retrieved instruction, %h", instr));
        instr_addr = 'h2;
        #20
        $display($sformatf("Retrieved instruction, %h", instr));

        $finish;
    end

endmodule //instr_mem_tb