module pe_unit #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input wire clk,
    input wire rst,

    // Control signals
    input wire enable,
    input wire clear,
    input wire load_a,
    input wire load_b,

    // Inputs
    input wire signed [DATA_WIDTH-1:0] a_in,
    input wire signed [DATA_WIDTH-1:0] b_in,

    // Output
    output wire signed [ACC_WIDTH-1:0] acc_out
);

    // Internal registers
    reg signed [DATA_WIDTH-1:0] a_reg;
    reg signed [DATA_WIDTH-1:0] b_reg;

    // Load registers
    always @(posedge clk) begin
        if (rst) begin
            a_reg <= 0;
            b_reg <= 0;
        end
        else begin
            if (load_a)
                a_reg <= a_in;

            if (load_b)
                b_reg <= b_in;
        end
    end

    // MAC instance
    mac_unit #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) mac_inst (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear(clear),
        .a(a_reg),
        .b(b_reg),
        .acc_out(acc_out)
    );

endmodule