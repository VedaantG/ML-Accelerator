`timescale 1ns/1ps

module memory_tb;

    parameter DATA_WIDTH = 8;
    parameter ROWS = 4;
    parameter COLS = 4;
    parameter ADDR_WIDTH = 4;

    reg clk;
    reg rst;          
    reg clear;        
    reg write_en;
    reg read_en;
    reg [ADDR_WIDTH-1:0] addr;
    reg signed [DATA_WIDTH-1:0] data_in;

    // 2D output
    wire signed [DATA_WIDTH-1:0] data_out [0:ROWS-1][0:COLS-1];

    // DUT
    memory #(DATA_WIDTH, ROWS, COLS, ADDR_WIDTH) uut (
        .clk(clk),
        .rst(rst),           
        .clear(clear),        
        .write_en(write_en),
        .read_en(read_en),
        .addr(addr),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Clock
    always #5 clk = ~clk;

    integer i, j;

    // Dump
    initial begin
        $dumpfile("memory.vcd");
        $dumpvars(0, memory_tb);
    end

    // =========================
    // TASK: Write full matrix
    // =========================
    task write_matrix;
        input integer base_val;
        integer k;
        begin
            for (k = 0; k < ROWS*COLS; k = k + 1) begin
                @(negedge clk);
                write_en = 1;
                read_en  = 0;
                addr     = k;
                data_in  = base_val + k;

                @(posedge clk);
            end

            @(negedge clk);
            write_en = 0;
        end
    endtask

    // =========================
    // TASK: Read matrix
    // =========================
    task read_matrix;
        begin
            @(negedge clk);
            read_en = 1;

            @(posedge clk);
            @(posedge clk);   // pipeline settle

            @(negedge clk);
            read_en = 0;
        end
    endtask

    // =========================
    // PRINT MATRIX
    // =========================
    task print_matrix;
        begin
            $display("---- MATRIX OUTPUT ----");
            for (i = 0; i < ROWS; i = i + 1) begin
                for (j = 0; j < COLS; j = j + 1) begin
                    $write("%4d ", data_out[i][j]);
                end
                $write("\n");
            end
        end
    endtask

    // =========================
    // TEST SEQUENCE
    // =========================
    initial begin
        clk = 0;
        rst = 1;          
        clear = 0;
        write_en = 0;
        read_en = 0;
        addr = 0;
        data_in = 0;

        // Apply reset
        repeat(2) @(posedge clk);
        rst = 0;

        $display("==== MEMORY TEST START ====");

        // =========================
        // TEST 0: After reset
        // =========================
        read_matrix;
        print_matrix;   

        // =========================
        // TEST 1: Write 0..15
        // =========================
        write_matrix(0);
        read_matrix;
        print_matrix;

        // =========================
        // TEST 2: Overwrite (10..25)
        // =========================
        write_matrix(10);
        read_matrix;
        print_matrix;

        // =========================
        // TEST 3: Clear memory
        // =========================
        @(negedge clk);
        clear = 1;
        @(posedge clk);
        @(negedge clk);
        clear = 0;

        read_matrix;
        print_matrix;   

        // =========================
        // TEST 4: Signed values
        // =========================
        write_matrix(-8);
        read_matrix;
        print_matrix;

        $display("==== MEMORY TEST END ====");
        $finish;
    end

endmodule