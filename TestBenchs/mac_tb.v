`timescale 1ns/1ps

module mac_tb;

    parameter DATA_WIDTH = 8;
    parameter ACC_WIDTH  = 32;

    reg clk;
    reg rst;
    reg enable;
    reg clear;
    reg signed [DATA_WIDTH-1:0] a;
    reg signed [DATA_WIDTH-1:0] b;

    wire signed [ACC_WIDTH-1:0] acc_out;

    mac_unit #(DATA_WIDTH, ACC_WIDTH) uut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear(clear),
        .a(a),
        .b(b),
        .acc_out(acc_out)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Dump file
    initial begin
        $dumpfile("mac.vcd");
        $dumpvars(0, mac_tb);
    end

    // Task (clock-synchronous)
    task apply_input;
        input signed [7:0] in_a;
        input signed [7:0] in_b;
        begin
            // Step 1: Apply inputs BEFORE clock edge
            @(negedge clk);
            a = in_a;
            b = in_b;
            enable = 1;

            // Step 2: Let MAC execute at next posedge
            @(posedge clk);

            // Step 3: Disable enable BEFORE next posedge
            @(negedge clk);
            enable = 0;
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        enable = 0;
        clear = 0;
        a = 0;
        b = 0;

        // Reset
        repeat(2) @(posedge clk);
        rst = 0;

        $display("---- TEST START ----");

        // Test 1
        apply_input(2, 3);
        apply_input(4, 5);
        apply_input(1, 1);

        // Clear
        clear = 1;
        @(posedge clk);
        clear = 0;

        // Test 2 (signed)
        apply_input(-2, 3);
        apply_input(3, -4);

        // Enable OFF
        @(posedge clk);
        enable = 0;
        a = 10;
        b = 10;

        @(posedge clk);

        // Reset again
        rst = 1;
        @(posedge clk);
        rst = 0;

        $display("---- TEST END ----");
        $finish;
    end

    initial begin
        $monitor("Time=%0t | a=%d b=%d | acc_out=%d",
                  $time, a, b, acc_out);
    end

endmodule