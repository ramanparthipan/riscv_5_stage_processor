module mux_2_to_1(
    input   logic           sel,
    input   logic [31:0]    a,
    input   logic [31:0]    b,
    output  logic [31:0]    z
);
    assign z = sel ? b : a;

endmodule

module mux_3_to_1(
    input   logic [1:0]     sel,
    input   logic [31:0]    a,
    input   logic [31:0]    b,
    input   logic [31:0]    c,
    output  logic [31:0]    z
);
    always_comb begin
        case (sel)
            2'b00:      z = a;
            2'b01:      z = b;
            2'b10:      z = c;
            default:    z = 32'hDEADBEEF;
        endcase
    end

endmodule