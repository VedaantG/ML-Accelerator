`timescale 1ns/1ps

module pe_tb;

    parameter DATA_WIDTH = 8;
    parameter ACC_WIDTH  = 32;

    reg clk;
    reg rst;
    reg enable;
    reg clear;
    reg load_a;
    reg load_b;
    reg signed [DATA_WIDTH-1:0] a_in;
    reg signed [DATA_WIDTH-1:0] b_in;

    wire signed [ACC_WIDTH-1:0] acc_out;

    // Instantiate PE
    pe_unit #(DATA_WIDTH, ACC_WIDTH) uut (
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

    // Clock
    always #5 clk = ~clk;

    // Dump
    initial begin
        $dumpfile("pe.vcd");
        $dumpvars(0, pe_tb);
    end

    // ==============================
    //  TASK: Load A and B together
    // ==============================
    task load_ab;
        input signed [7:0] val_a;
        input signed [7:0] val_b;
        begin
            @(negedge clk);
            a_in = val_a;
            b_in = val_b;
            load_a = 1;
            load_b = 1;

            @(posedge clk);

            @(negedge clk);
            load_a = 0;
            load_b = 0;
        end
    endtask

    // Task: Compute (1 MAC operation)
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
        a_in = 0;
        b_in = 0;

        // Reset
        repeat(2) @(posedge clk);
        rst = 0;

        $display("---- PE TEST START ----");

        // =========================
        // TEST 1: Load and compute
        // =========================
        load_ab(2, 3);
        compute_once;   // 2*3 = 6

        // =========================
        // TEST 2: Accumulation
        // =========================
        load_ab(4, 3);
        compute_once;   // 6 + (4*3) = 18

        load_ab(1, 3);
        compute_once;   // 18 + (1*3) = 21

        // =========================
        // TEST 3: Clear
        // =========================
        @(negedge clk);
        clear = 1;
        @(posedge clk);
        @(negedge clk);
        clear = 0;

        // =========================
        // TEST 4: Signed numbers
        // =========================
        load_ab(-2, 3);
        compute_once;   // -6

        load_ab(3, -4);
        compute_once;   // -6 + (-12) = -18

        // =========================
        // TEST 5: Enable OFF
        // =========================
        @(negedge clk);
        enable = 0;
        a_in = 10;
        b_in = 10;
        @(posedge clk);

        $display("---- PE TEST END ----");
        $finish;
    end

    initial begin
        $monitor("Time=%0t | a_in=%d b_in=%d | acc_out=%d",
                  $time, a_in, b_in, acc_out);
    end

endmodule