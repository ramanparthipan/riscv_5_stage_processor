module mux_2_to_1(
    input   logic           sel,
    input   logic [31:0]    a,
    input   logic [31:0]    b,
    output  logic [31:0]    output
);
    assign output = sel ? b : a;

endmodule

module mux_3_to_1(
    input   logic [1:0]     sel,
    input   logic [31:0]    a,
    input   logic [31:0]    b,
    input   logic [31:0]    c,
    output  logic [31:0]    output
);
    always_comb begin
        case (sel)
            2'b00:      output = a;
            2'b01:      output = b;
            2'b11:      output = c;
            default:    output = 32'hDEADBEEF;
        endcase
    end

endmodule