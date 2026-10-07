`timescale 1ns/1ps

module tb_simt_controller;

    parameter integer NUM_LANES = 4;

    logic                         clk;
    logic                         reset;

    logic [31:0]                  instruction_in;
    logic [NUM_LANES-1:0]         active_mask_in;
    logic                         enable;

    logic                         branch_taken;
    logic [NUM_LANES-1:0]         branch_mask;

    logic [31:0]                  instruction_out;
    logic [NUM_LANES-1:0]         active_mask_out;
    logic [NUM_LANES-1:0]         lane_enable;
    logic                         warp_active;

    integer passed;
    integer failed;


    // ============================================================
    // DUT
    // ============================================================

    simt_controller #(
        .NUM_LANES(NUM_LANES)
    ) dut (
        .clk              (clk),
        .reset            (reset),
        .instruction_in   (instruction_in),
        .active_mask_in   (active_mask_in),
        .enable            (enable),
        .branch_taken     (branch_taken),
        .branch_mask      (branch_mask),
        .instruction_out  (instruction_out),
        .active_mask_out  (active_mask_out),
        .lane_enable      (lane_enable),
        .warp_active      (warp_active)
    );


    // ============================================================
    // CLOCK
    // ============================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // ============================================================
    // CHECK MASK
    // ============================================================

    task automatic check_mask;

        input [NUM_LANES-1:0] expected_mask;
        input [NUM_LANES-1:0] actual_mask;
        input string test_name;

        begin

            if (actual_mask === expected_mask) begin

                $display(
                    "%-28s : PASS | Expected=%b Got=%b",
                    test_name,
                    expected_mask,
                    actual_mask
                );

                passed = passed + 1;

            end
            else begin

                $display(
                    "%-28s : FAIL | Expected=%b Got=%b",
                    test_name,
                    expected_mask,
                    actual_mask
                );

                failed = failed + 1;

            end

        end

    endtask


    // ============================================================
    // CHECK SIGNAL
    // ============================================================

    task automatic check_signal;

        input expected;
        input actual;
        input string test_name;

        begin

            if (actual === expected) begin

                $display(
                    "%-28s : PASS | Expected=%b Got=%b",
                    test_name,
                    expected,
                    actual
                );

                passed = passed + 1;

            end
            else begin

                $display(
                    "%-28s : FAIL | Expected=%b Got=%b",
                    test_name,
                    expected,
                    actual
                );

                failed = failed + 1;

            end

        end

    endtask


    // ============================================================
    // CHECK INSTRUCTION
    // ============================================================

    task automatic check_instruction;

        input [31:0] expected;
        input [31:0] actual;
        input string test_name;

        begin

            if (actual === expected) begin

                $display(
                    "%-28s : PASS | Expected=%h Got=%h",
                    test_name,
                    expected,
                    actual
                );

                passed = passed + 1;

            end
            else begin

                $display(
                    "%-28s : FAIL | Expected=%h Got=%h",
                    test_name,
                    expected,
                    actual
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

        instruction_in = 32'b0;
        active_mask_in = 4'b0000;
        enable         = 1'b0;

        branch_taken   = 1'b0;
        branch_mask    = 4'b0000;

        reset = 1'b1;

        #12;

        reset = 1'b0;

        #2;

        $display("");
        $display("==========================================================");
        $display("             CUSTOM GPU SIMT CONTROLLER TEST");
        $display("==========================================================");
        $display("");


        // ========================================================
        // TEST 1 - ALL LANES ACTIVE
        // ========================================================

        instruction_in = 32'h00000001;
        active_mask_in = 4'b1111;
        enable         = 1'b1;

        @(posedge clk);
        #2;

        check_instruction(
            32'h00000001,
            instruction_out,
            "INSTRUCTION BROADCAST"
        );

        check_mask(
            4'b1111,
            active_mask_out,
            "ALL LANES ACTIVE"
        );

        check_mask(
            4'b1111,
            lane_enable,
            "ALL LANE ENABLES"
        );

        check_signal(
            1'b1,
            warp_active,
            "WARP ACTIVE"
        );


        // ========================================================
        // TEST 2 - PARTIAL ACTIVE MASK
        // ========================================================

        instruction_in = 32'h00000002;
        active_mask_in = 4'b0101;

        @(posedge clk);
        #2;

        check_instruction(
            32'h00000002,
            instruction_out,
            "SECOND INSTRUCTION"
        );

        check_mask(
            4'b0101,
            active_mask_out,
            "PARTIAL ACTIVE MASK"
        );

        check_mask(
            4'b0101,
            lane_enable,
            "PARTIAL LANE ENABLE"
        );


        // ========================================================
        // TEST 3 - SINGLE ACTIVE LANE
        // ========================================================

        instruction_in = 32'h00000003;
        active_mask_in = 4'b0010;

        @(posedge clk);
        #2;

        check_instruction(
            32'h00000003,
            instruction_out,
            "THIRD INSTRUCTION"
        );

        check_mask(
            4'b0010,
            active_mask_out,
            "SINGLE ACTIVE LANE"
        );

        check_mask(
            4'b0010,
            lane_enable,
            "SINGLE LANE ENABLE"
        );

        check_signal(
            1'b1,
            warp_active,
            "SINGLE LANE WARP ACTIVE"
        );


        // ========================================================
        // TEST 4 - BRANCH TAKEN
        // ========================================================

        instruction_in = 32'h00000004;
        active_mask_in = 4'b1111;

        branch_taken = 1'b1;
        branch_mask  = 4'b1001;

        @(posedge clk);
        #2;

        check_instruction(
            32'h00000004,
            instruction_out,
            "BRANCH INSTRUCTION"
        );

        check_mask(
            4'b1001,
            active_mask_out,
            "BRANCH ACTIVE MASK"
        );

        check_mask(
            4'b1001,
            lane_enable,
            "BRANCH LANE ENABLE"
        );

        check_signal(
            1'b1,
            warp_active,
            "BRANCH WARP ACTIVE"
        );


        // ========================================================
        // TEST 5 - EMPTY BRANCH
        // ========================================================

        instruction_in = 32'h00000005;

        branch_taken = 1'b1;
        branch_mask  = 4'b0000;

        @(posedge clk);
        #2;

        check_instruction(
            32'h00000005,
            instruction_out,
            "EMPTY BRANCH INSTRUCTION"
        );

        check_mask(
            4'b0000,
            active_mask_out,
            "EMPTY BRANCH MASK"
        );

        check_mask(
            4'b0000,
            lane_enable,
            "NO ACTIVE LANES"
        );

        check_signal(
            1'b0,
            warp_active,
            "WARP INACTIVE"
        );


        // ========================================================
        // TEST 6 - NORMAL ACTIVE MASK
        // ========================================================

        instruction_in = 32'h00000006;

        active_mask_in = 4'b1010;
        branch_taken   = 1'b0;

        @(posedge clk);
        #2;

        check_instruction(
            32'h00000006,
            instruction_out,
            "NORMAL INSTRUCTION"
        );

        check_mask(
            4'b1010,
            active_mask_out,
            "NORMAL ACTIVE MASK"
        );

        check_mask(
            4'b1010,
            lane_enable,
            "NORMAL LANE ENABLE"
        );

        check_signal(
            1'b1,
            warp_active,
            "NORMAL WARP ACTIVE"
        );


        // ========================================================
        // TEST 7 - CONTROLLER DISABLED
        // ========================================================

        enable = 1'b0;

        @(posedge clk);
        #2;

        check_mask(
            4'b1010,
            lane_enable,
            "DISABLED HOLD MASK"
        );

        check_signal(
            1'b1,
            warp_active,
            "DISABLED WARP STATUS"
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

        if (failed == 0)
            $display("ALL SIMT CONTROLLER TESTS PASSED");
        else
            $display("SIMT CONTROLLER TESTS FAILED");

        $display("==========================================================");
        $display("");

        #10;

        $finish;

    end

endmodule