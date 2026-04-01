module pe_array_2d #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32,
    parameter ROWS = 4,
    parameter COLS = 4
)(
    input wire clk,
    input wire rst,

    // Global control signals
    input wire enable,
    input wire clear,
    input wire load_a,
    input wire load_b,

    // 2D Inputs
    input wire signed [DATA_WIDTH-1:0] a_in [0:ROWS-1][0:COLS-1],
    input wire signed [DATA_WIDTH-1:0] b_in [0:ROWS-1][0:COLS-1],

    // 2D Outputs
    output wire signed [ACC_WIDTH-1:0] acc_out [0:ROWS-1][0:COLS-1]
);

    // Internal wires
    wire signed [ACC_WIDTH-1:0] pe_out [0:ROWS-1][0:COLS-1];

    // Output registers (pipeline stage)
    reg signed [ACC_WIDTH-1:0] acc_reg [0:ROWS-1][0:COLS-1];

    genvar i, j;
    generate
        for (i = 0; i < ROWS; i = i + 1) begin : ROW_BLOCK
            for (j = 0; j < COLS; j = j + 1) begin : COL_BLOCK

                // Instantiate PE
                pe_unit #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .ACC_WIDTH(ACC_WIDTH)
                ) pe_inst (
                    .clk(clk),
                    .rst(rst),
                    .enable(enable),
                    .clear(clear),
                    .load_a(load_a),
                    .load_b(load_b),
                    .a_in(a_in[i][j]),
                    .b_in(b_in[i][j]),
                    .acc_out(pe_out[i][j])
                );

                // Pipeline register
                always @(posedge clk) begin
                    if (rst)
                        acc_reg[i][j] <= 0;
                    else
                        acc_reg[i][j] <= pe_out[i][j];
                end

                // Final output
                assign acc_out[i][j] = acc_reg[i][j];

            end
        end
    endgenerate

endmodule