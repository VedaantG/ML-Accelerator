module mac_unit #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire clk,
    input  wire rst,
    input  wire enable,
    input  wire clear,

    input  wire signed [DATA_WIDTH-1:0] a,
    input  wire signed [DATA_WIDTH-1:0] b,

    output reg  signed [ACC_WIDTH-1:0] acc_out
);

    always @(posedge clk) begin
        if (rst) begin
            acc_out <= 0;
        end 
        else if (clear) begin
            acc_out <= 0;
        end 
        else if (enable) begin
            acc_out <= acc_out + (a * b); 
        end
    end

endmodule