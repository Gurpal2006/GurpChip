`timescale 1ns/1ps

module counter_tb;

    // Inputs to the counter
    reg clk;
    reg rst_n;
    reg load;
    reg output_enable;

    reg [7:0] data_in;


    // Output from counter
    wire [7:0] count_out;


    // ---------------------------------------------------
    // Instantiate our counter
    // ---------------------------------------------------

    counter dut (
        .clk(clk),
        .rst_n(rst_n),
        .load(load),
        .output_enable(output_enable),
        .data_in(data_in),
        .count_out(count_out)
    );


    // ---------------------------------------------------
    // Clock generation
    //
    // Clock changes every 5 ns
    // Full clock period = 10 ns
    // ---------------------------------------------------

    always #5 clk = ~clk;


    // ---------------------------------------------------
    // Testbench
    // ---------------------------------------------------

    initial begin

        // Create waveform file for GTKWave
        $dumpfile("counter.vcd");
        $dumpvars(0, counter_tb);


        // Initial values
        clk = 0;

        rst_n = 1;

        load = 0;

        output_enable = 1;

        data_in = 8'h00;


        // =================================================
        // TEST 1: Asynchronous Reset
        // =================================================

        $display("TEST 1: Asynchronous Reset");

        #2;

        rst_n = 0;

        #1;

        if (count_out !== 8'h00)
            $display("ERROR: Reset failed");

        else
            $display("PASS: Reset");


        #2;

        rst_n = 1;



        // =================================================
        // TEST 2: Normal Counting
        // =================================================

        $display("TEST 2: Counting");


        // First rising clock
        @(posedge clk);
        #1;

        if (count_out !== 8'h01)
            $display("ERROR: Expected 1");

        else
            $display("PASS: Count = 1");


        // Second rising clock
        @(posedge clk);
        #1;

        if (count_out !== 8'h02)
            $display("ERROR: Expected 2");

        else
            $display("PASS: Count = 2");


        // Third rising clock
        @(posedge clk);
        #1;

        if (count_out !== 8'h03)
            $display("ERROR: Expected 3");

        else
            $display("PASS: Count = 3");



        // =================================================
        // TEST 3: Synchronous Load
        // =================================================

        $display("TEST 3: Synchronous Load");


        // Change signals away from rising edge
        @(negedge clk);

        data_in = 8'd25;
        load = 1;


        // Counter should load 25 here
        @(posedge clk);
        #1;


        if (count_out !== 8'd25)
            $display("ERROR: Load failed");

        else
            $display("PASS: Loaded 25");


        // Disable load
        @(negedge clk);

        load = 0;



        // =================================================
        // TEST 4: Continue Counting
        // =================================================

        $display("TEST 4: Count after Load");


        @(posedge clk);
        #1;

        if (count_out !== 8'd26)
            $display("ERROR: Expected 26");

        else
            $display("PASS: Count = 26");


        @(posedge clk);
        #1;

        if (count_out !== 8'd27)
            $display("ERROR: Expected 27");

        else
            $display("PASS: Count = 27");



        // =================================================
        // TEST 5: Tri-State Output
        // =================================================

        $display("TEST 5: Tri-State Output");


        @(negedge clk);

        output_enable = 0;

        #1;


        // === must be used when checking Z
        if (count_out === 8'bzzzzzzzz)
            $display("PASS: Output is High Impedance");

        else
            $display("ERROR: Output should be Z");



        // =================================================
        // TEST 6: Re-enable Output
        // =================================================

        @(negedge clk);

        output_enable = 1;

        #1;


        if (count_out === 8'bzzzzzzzz)
            $display("ERROR: Output still High Impedance");

        else
            $display("PASS: Output enabled again");



        // Let simulation run a little longer
        #20;


        $display("");
        $display("============================");
        $display("    TESTING COMPLETE");
        $display("============================");


        $finish;

    end


endmodule