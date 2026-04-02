module memory #(
    parameter DATA_WIDTH = 8,
    parameter ROWS = 4,
    parameter COLS = 4,
    parameter ADDR_WIDTH = 4   // enough for 16 locations
)(
    input wire clk,
    input wire rst,          
    input wire clear,        

    // Write interface
    input wire write_en,
    input wire [ADDR_WIDTH-1:0] addr,
    input wire signed [DATA_WIDTH-1:0] data_in,

    // Parallel read interface
    input wire read_en,

    output reg signed [DATA_WIDTH-1:0] data_out [0:ROWS-1][0:COLS-1]
);

    // Internal memory
    reg signed [DATA_WIDTH-1:0] mem [0:(ROWS*COLS)-1];

    integer i, j;

    // =========================
    // WRITE + RESET + CLEAR
    // =========================
    always @(posedge clk) begin
        if (rst || clear) begin
            for (i = 0; i < ROWS*COLS; i = i + 1)
                mem[i] <= 0;
        end
        else if (write_en) begin
            mem[addr] <= data_in;
        end
    end

    // =========================
    // READ + RESET + CLEAR
    // =========================
    always @(posedge clk) begin
        if (rst || clear) begin
            for (i = 0; i < ROWS; i = i + 1)
                for (j = 0; j < COLS; j = j + 1)
                    data_out[i][j] <= 0;
        end
        else if (read_en) begin
            for (i = 0; i < ROWS; i = i + 1) begin
                for (j = 0; j < COLS; j = j + 1) begin
                    data_out[i][j] <= mem[i*COLS + j];
                end
            end
        end
    end

    // ==============================
    // DEBUG WIRES OF INTERNAL MEMORY
    // ==============================
    wire signed [DATA_WIDTH-1:0] mem0  = mem[0];
    wire signed [DATA_WIDTH-1:0] mem1  = mem[1];
    wire signed [DATA_WIDTH-1:0] mem2  = mem[2];
    wire signed [DATA_WIDTH-1:0] mem3  = mem[3];
    wire signed [DATA_WIDTH-1:0] mem4  = mem[4];
    wire signed [DATA_WIDTH-1:0] mem5  = mem[5];
    wire signed [DATA_WIDTH-1:0] mem6  = mem[6];
    wire signed [DATA_WIDTH-1:0] mem7  = mem[7];
    wire signed [DATA_WIDTH-1:0] mem8  = mem[8];
    wire signed [DATA_WIDTH-1:0] mem9  = mem[9];
    wire signed [DATA_WIDTH-1:0] mem10 = mem[10];
    wire signed [DATA_WIDTH-1:0] mem11 = mem[11];
    wire signed [DATA_WIDTH-1:0] mem12 = mem[12];
    wire signed [DATA_WIDTH-1:0] mem13 = mem[13];
    wire signed [DATA_WIDTH-1:0] mem14 = mem[14];
    wire signed [DATA_WIDTH-1:0] mem15 = mem[15];

endmodule