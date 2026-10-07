`timescale 1ns/1ps

module tb_warp_scheduler;

    parameter integer NUM_WARPS = 4;

    logic clk;
    logic reset;

    logic [NUM_WARPS-1:0] ready_mask;
    logic schedule_en;

    logic [$clog2(NUM_WARPS)-1:0] selected_warp;
    logic warp_valid;

    integer passed;
    integer failed;


    // ============================================================
    // DUT
    // ============================================================

    warp_scheduler #(
        .NUM_WARPS(NUM_WARPS)
    ) dut (

        .clk          (clk),
        .reset        (reset),
        .ready_mask   (ready_mask),
        .schedule_en  (schedule_en),
        .selected_warp(selected_warp),
        .warp_valid   (warp_valid)

    );


    // ============================================================
    // CLOCK
    // ============================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end


    // ============================================================
    // CHECK TASK
    // ============================================================

    task automatic check_warp;

        input integer expected_warp;
        input integer expected_valid;
        input string test_name;

        begin

            #1;

            if ((selected_warp === expected_warp) &&
                (warp_valid === expected_valid)) begin

                $display(
                    "%-25s : PASS | Expected Warp=%0d Valid=%0d | Got Warp=%0d Valid=%0d",
                    test_name,
                    expected_warp,
                    expected_valid,
                    selected_warp,
                    warp_valid
                );

                passed = passed + 1;

            end
            else begin

                $display(
                    "%-25s : FAIL | Expected Warp=%0d Valid=%0d | Got Warp=%0d Valid=%0d",
                    test_name,
                    expected_warp,
                    expected_valid,
                    selected_warp,
                    warp_valid
                );

                failed = failed + 1;

            end

        end

    endtask


    // ============================================================
    // TEST SEQUENCE
    // ============================================================

    initial begin

        passed = 0;
        failed = 0;

        ready_mask  = 4'b0000;
        schedule_en = 1'b0;
        reset       = 1'b1;


        // ========================================================
        // RESET
        // ========================================================

        #12;

        reset = 1'b0;

        #2;


        $display("");
        $display("==========================================================");
        $display("             CUSTOM GPU WARP SCHEDULER TEST");
        $display("==========================================================");
        $display("");


        // ========================================================
        // TEST 1
        // No warp ready
        // ========================================================

        ready_mask  = 4'b0000;
        schedule_en = 1'b1;

        @(posedge clk);

        check_warp(
            0,
            0,
            "NO READY WARP"
        );


        // ========================================================
        // TEST 2
        // Only Warp 0 ready
        // ========================================================

        ready_mask = 4'b0001;

        @(posedge clk);

        check_warp(
            0,
            1,
            "WARP 0 SELECTION"
        );


        // ========================================================
        // TEST 3
        // All warps ready
        //
        // Round-robin should select Warp 1 next
        // ========================================================

        ready_mask = 4'b1111;

        @(posedge clk);

        check_warp(
            1,
            1,
            "ROUND ROBIN WARP 1"
        );


        // ========================================================
        // TEST 4
        // Continue round robin
        // ========================================================

        @(posedge clk);

        check_warp(
            2,
            1,
            "ROUND ROBIN WARP 2"
        );


        // ========================================================
        // TEST 5
        // Continue round robin
        // ========================================================

        @(posedge clk);

        check_warp(
            3,
            1,
            "ROUND ROBIN WARP 3"
        );


        // ========================================================
        // TEST 6
        // Wrap around to Warp 0
        // ========================================================

        @(posedge clk);

        check_warp(
            0,
            1,
            "ROUND ROBIN WRAP"
        );


        // ========================================================
        // TEST 7
        // Only Warp 2 and Warp 3 ready
        //
        // Scheduler should choose Warp 2
        // ========================================================

        ready_mask = 4'b1100;

        @(posedge clk);

        check_warp(
            2,
            1,
            "SPARSE READY WARP 2"
        );


        // ========================================================
        // TEST 8
        // After Warp 2, Warp 3 should execute
        // ========================================================

        @(posedge clk);

        check_warp(
            3,
            1,
            "SPARSE READY WARP 3"
        );


        // ========================================================
        // TEST 9
        // Disable scheduler
        // ========================================================

        schedule_en = 1'b0;

        @(posedge clk);

        check_warp(
            3,
            0,
            "SCHEDULER DISABLED"
        );


        // ========================================================
        // FINAL RESULT
        // ========================================================

        $display("");
        $display("----------------------------------------------------------");

        $display(
            "PASSED : %0d",
            passed
        );

        $display(
            "FAILED : %0d",
            failed
        );

        $display("----------------------------------------------------------");


        if (failed == 0) begin

            $display(
                "ALL WARP SCHEDULER TESTS PASSED"
            );

        end
        else begin

            $display(
                "WARP SCHEDULER TESTS FAILED"
            );

        end


        $display("==========================================================");
        $display("");

        #10;

        $finish;

    end

endmodule