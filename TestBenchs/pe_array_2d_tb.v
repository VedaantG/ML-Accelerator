`timescale 1ns/1ps

module pe_array_2d_tb;

    parameter DATA_WIDTH = 8;
    parameter ACC_WIDTH  = 32;
    parameter ROWS = 4;
    parameter COLS = 4;

    reg clk;
    reg rst;
    reg enable;
    reg clear;
    reg load_a;
    reg load_b;

    reg signed [DATA_WIDTH-1:0] a_in [0:ROWS-1][0:COLS-1];
    reg signed [DATA_WIDTH-1:0] b_in [0:ROWS-1][0:COLS-1];

    wire signed [ACC_WIDTH-1:0] acc_out [0:ROWS-1][0:COLS-1];

    pe_array_2d #(DATA_WIDTH, ACC_WIDTH, ROWS, COLS) uut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear(clear),
        .load_a(load_a),
        .load_b(load_b),
        .a_in(a_in),
        .b_in(b_in),
        .acc_out(acc_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("pe_array.vcd");
        $dumpvars(0, pe_array_2d_tb);
    end

    integer i, j;

    // Monitor
    initial begin
        $monitor("Time=%0t | acc_out[0][0]=%d acc_out[1][1]=%d acc_out[3][3]=%d",
                  $time,
                  acc_out[0][0],
                  acc_out[1][1],
                  acc_out[3][3]);
    end

    task load_matrix;
        begin
            @(negedge clk);
            load_a = 1;
            load_b = 1;

            @(posedge clk);

            @(negedge clk);
            load_a = 0;
            load_b = 0;
        end
    endtask

    task compute_once;
        begin
            @(negedge clk);
            enable = 1;

            @(posedge clk);

            @(negedge clk);
            enable = 0;
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        enable = 0;
        clear = 0;
        load_a = 0;
        load_b = 0;

        // Initialize
        for (i = 0; i < ROWS; i = i + 1)
            for (j = 0; j < COLS; j = j + 1) begin
                a_in[i][j] = 0;
                b_in[i][j] = 0;
            end

        // Reset
        repeat(2) @(posedge clk);
        rst = 0;

        $display("---- 2D PE ARRAY TEST START ----");

        // =========================
        // TEST 1
        // =========================
        for (i = 0; i < ROWS; i = i + 1)
            for (j = 0; j < COLS; j = j + 1) begin
                a_in[i][j] = i + j;
                b_in[i][j] = 2;
            end

        load_matrix;
        compute_once;
        repeat(2) @(posedge clk);

        $display("---- OUTPUT MATRIX (TEST 1) ----");
        for (i = 0; i < ROWS; i = i + 1) begin
            for (j = 0; j < COLS; j = j + 1)
                $write("%4d ", acc_out[i][j]);
            $write("\n");
        end

        // =========================
        // TEST 2
        // =========================
        for (i = 0; i < ROWS; i = i + 1)
            for (j = 0; j < COLS; j = j + 1) begin
                a_in[i][j] = 1;
                b_in[i][j] = 3;
            end

        load_matrix;
        compute_once;
        repeat(2) @(posedge clk);

        $display("---- OUTPUT MATRIX (TEST 2) ----");
        for (i = 0; i < ROWS; i = i + 1) begin
            for (j = 0; j < COLS; j = j + 1)
                $write("%4d ", acc_out[i][j]);
            $write("\n");
        end

        // =========================
        // TEST 3 (CLEAR)
        // =========================
        @(negedge clk);
        clear = 1;
        @(posedge clk);
        @(negedge clk);
        clear = 0;

        repeat(2) @(posedge clk);

        $display("---- OUTPUT MATRIX (AFTER CLEAR) ----");
        for (i = 0; i < ROWS; i = i + 1) begin
            for (j = 0; j < COLS; j = j + 1)
                $write("%4d ", acc_out[i][j]);
            $write("\n");
        end

        // =========================
        // TEST 4 (SIGNED)
        // =========================
        for (i = 0; i < ROWS; i = i + 1)
            for (j = 0; j < COLS; j = j + 1) begin
                a_in[i][j] = -i;
                b_in[i][j] = j;
            end

        load_matrix;
        compute_once;
        repeat(2) @(posedge clk);

        $display("---- OUTPUT MATRIX (TEST 4 - SIGNED) ----");
        for (i = 0; i < ROWS; i = i + 1) begin
            for (j = 0; j < COLS; j = j + 1)
                $write("%4d ", acc_out[i][j]);
            $write("\n");
        end

        $display("---- TEST END ----");
        $finish;
    end

endmodule