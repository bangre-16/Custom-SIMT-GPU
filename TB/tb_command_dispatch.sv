`timescale 1ns/1ps

module tb_command_dispatch;

    parameter NUM_SMS = 4;

    // ============================================================
    // CLOCK / RESET
    // ============================================================

    logic clk;
    logic reset;

    // ============================================================
    // COMMAND INPUT
    // ============================================================

    logic [31:0] command_data;
    logic        command_valid;

    // ============================================================
    // DISPATCH OUTPUT
    // ============================================================

    logic [31:0] instruction [0:NUM_SMS-1];
    logic        instruction_valid [0:NUM_SMS-1];

    logic busy;

    // ============================================================
    // TEST COUNTERS
    // ============================================================

    integer pass_count;
    integer fail_count;
    integer i;

    // ============================================================
    // DUT
    // ============================================================

    command_dispatch #(
        .NUM_SMS(NUM_SMS)
    ) dut (

        .clk(clk),
        .reset(reset),

        .command_data(command_data),
        .command_valid(command_valid),

        .instruction(instruction),
        .instruction_valid(instruction_valid),

        .busy(busy)

    );

    // ============================================================
    // CLOCK
    // ============================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end

    // ============================================================
    // CHECK 32-BIT RESULT
    // ============================================================

    task check_result;

        input [31:0] expected;
        input [31:0] actual;
        input string test_name;
        input integer sm_id;

        begin

            if (actual === expected) begin

                $display(
                    "%-30s : PASS | SM%0d | Expected=%08h Got=%08h",
                    test_name,
                    sm_id,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end

            else begin

                $display(
                    "%-30s : FAIL | SM%0d | Expected=%08h Got=%08h",
                    test_name,
                    sm_id,
                    expected,
                    actual
                );

                fail_count = fail_count + 1;

            end

        end

    endtask

    // ============================================================
    // CHECK 1-BIT SIGNAL
    // ============================================================

    task check_signal;

        input logic expected;
        input logic actual;
        input string test_name;
        input integer sm_id;

        begin

            if (actual === expected) begin

                $display(
                    "%-30s : PASS | SM%0d | Expected=%0d Got=%0d",
                    test_name,
                    sm_id,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end

            else begin

                $display(
                    "%-30s : FAIL | SM%0d | Expected=%0d Got=%0d",
                    test_name,
                    sm_id,
                    expected,
                    actual
                );

                fail_count = fail_count + 1;

            end

        end

    endtask

    // ============================================================
    // TEST SEQUENCE
    // ============================================================

    initial begin

        pass_count = 0;
        fail_count = 0;

        command_data  = 32'h00000000;
        command_valid = 1'b0;
        reset         = 1'b1;

        $display("");
        $display("======================================================");
        $display("          CUSTOM GPU COMMAND DISPATCH TEST");
        $display("======================================================");
        $display("");

        // ========================================================
        // TEST 1 : RESET
        // ========================================================

        #12;

        reset = 1'b0;

        #2;

        $display("");
        $display("----------------------------------------------");
        $display("TEST 1 : RESET");
        $display("----------------------------------------------");

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h00000000,
                instruction[i],
                "RESET INSTRUCTION",
                i
            );

            check_signal(
                1'b0,
                instruction_valid[i],
                "RESET VALID",
                i
            );

        end

        check_signal(
            1'b0,
            busy,
            "RESET BUSY",
            0
        );

        // ========================================================
        // TEST 2 : FIRST COMMAND DISPATCH
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 2 : FIRST COMMAND DISPATCH");
        $display("----------------------------------------------");

        command_data  = 32'h12345678;
        command_valid = 1'b1;

        @(posedge clk);

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h12345678,
                instruction[i],
                "COMMAND BROADCAST",
                i
            );

            check_signal(
                1'b1,
                instruction_valid[i],
                "COMMAND VALID",
                i
            );

        end

        check_signal(
            1'b1,
            busy,
            "DISPATCH BUSY",
            0
        );

        // ========================================================
        // TEST 3 : VALID PULSE CLEAR
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 3 : VALID PULSE CLEAR");
        $display("----------------------------------------------");

        command_valid = 1'b0;

        @(posedge clk);

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_signal(
                1'b0,
                instruction_valid[i],
                "VALID CLEAR",
                i
            );

            check_result(
                32'h12345678,
                instruction[i],
                "INSTRUCTION RETAIN",
                i
            );

        end

        check_signal(
            1'b0,
            busy,
            "BUSY CLEAR",
            0
        );

        // ========================================================
        // TEST 4 : SECOND COMMAND
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 4 : SECOND COMMAND");
        $display("----------------------------------------------");

        command_data  = 32'hA5A5A5A5;
        command_valid = 1'b1;

        @(posedge clk);

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'hA5A5A5A5,
                instruction[i],
                "SECOND BROADCAST",
                i
            );

            check_signal(
                1'b1,
                instruction_valid[i],
                "SECOND VALID",
                i
            );

        end

        // ========================================================
        // TEST 5 : THIRD COMMAND
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 5 : THIRD COMMAND");
        $display("----------------------------------------------");

        command_data = 32'h0000000F;

        @(posedge clk);

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h0000000F,
                instruction[i],
                "THIRD BROADCAST",
                i
            );

            check_signal(
                1'b1,
                instruction_valid[i],
                "THIRD VALID",
                i
            );

        end

        // ========================================================
        // TEST 6 : NO COMMAND
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 6 : NO COMMAND");
        $display("----------------------------------------------");

        command_valid = 1'b0;

        @(posedge clk);

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_signal(
                1'b0,
                instruction_valid[i],
                "NO COMMAND VALID",
                i
            );

            check_result(
                32'h0000000F,
                instruction[i],
                "LAST INSTRUCTION RETAIN",
                i
            );

        end

        check_signal(
            1'b0,
            busy,
            "NO COMMAND BUSY",
            0
        );

        // ========================================================
        // TEST 7 : ALL SMs RECEIVE SAME COMMAND
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 7 : SM BROADCAST CONSISTENCY");
        $display("----------------------------------------------");

        command_data  = 32'hCAFEBABE;
        command_valid = 1'b1;

        @(posedge clk);

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'hCAFEBABE,
                instruction[i],
                "SM BROADCAST CONSISTENCY",
                i
            );

            check_signal(
                1'b1,
                instruction_valid[i],
                "SM BROADCAST VALID",
                i
            );

        end

        // ========================================================
        // FINAL RESULT
        // ========================================================

        command_valid = 1'b0;

        $display("");
        $display("======================================================");
        $display("                    FINAL RESULT");
        $display("======================================================");

        $display(
            "PASSED : %0d",
            pass_count
        );

        $display(
            "FAILED : %0d",
            fail_count
        );

        $display("======================================================");

        if (fail_count == 0) begin

            $display("");
            $display("ALL COMMAND DISPATCH TESTS PASSED");
            $display("");

        end

        else begin

            $display("");
            $display("COMMAND DISPATCH TESTS FAILED");
            $display("");

        end

        $display("======================================================");

        #10;

        $finish;

    end

endmodule