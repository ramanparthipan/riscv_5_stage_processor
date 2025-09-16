module cpu #(
    parameter INSTR_MEM_SIZE_BYTES = 1024,
    parameter MEM_SIZE_BYTES = 1024
)(
    input   logic           clk,
    input   logic           resetn,

    output  logic [31:0]    pc_out, // to instr_mem
    input   logic [31:0]    instr,

    output  logic           clk, // to data_memory
    output  logic           wr_en,
    output  mem_op_t        mem_ctrl,
    output  logic [31:0]    addr,
    output  logic [31:0]    mem_data_in,
    input   logic [31:0]    mem_data_out
);

    // IF stage
    wire                pc_enable;       // Enable for normal increment
    wire                pc_jump_enable;  // Enable for a jump
    wire [31:0]         pc_jump_addr;  // Jump target address from ALU
    wire                if_id_enable;
    wire                fe_enable;

    // ID stage
    wire [31:0]         instr_id;
    wire [31:0]         pc_id;
    wire [31:0]         pc_plus4_id;


    program_counter program_counter_h(
        .clk(clk),
        .resetn(resetn),
        .en(pc_enable),
        .jump_en(pc_jump_enable),
        .jump_addr(pc_jump_addr),
        .pc_out(pc_out)
    );

    logic [31:0] pc_plus4;
    assign pc_plus4 = pc_out + 4;

    if_id_register if_id_register_h(
        .clk(clk),
        .clear(if_id_enable),
        .enable(fe_enable),
        .instr_if(instr),
        .pc_if(pc_out),
        .pc_plus4_if(pc_plus4),
        .instr_id(instr_id),
        .pc_id(pc_id),
        .pc_plus4_id(pc_plus4_id)
    );



endmodule