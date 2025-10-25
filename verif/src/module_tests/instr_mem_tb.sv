`timescale 1ns/1ps

module instr_mem_tb();
    localparam INSTR_MEM_SIZE_BYTES = 1024;

    logic [31:0] addr;
    logic [31:0] instr;


    instr_mem #(.INSTR_MEM_SIZE_BYTES(INSTR_MEM_SIZE_BYTES)) dut(.*);

    
    initial begin
        $readmemh("verif/src/programs/add_full_test.hex", dut.mem);

        addr = 'h0;
        #20
        $display($sformatf("Retrieved instruction, %h", instr));
        addr = 'h4;
        #20
        $display($sformatf("Retrieved instruction, %h", instr));
        addr = 'h8;
        #20
        $display($sformatf("Retrieved instruction, %h", instr));

        $finish;
    end

endmodule //instr_mem_tb