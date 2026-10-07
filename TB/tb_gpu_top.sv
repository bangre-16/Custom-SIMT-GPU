`timescale 1ns/1ps

module tb_gpu_top;

    parameter NUM_SMS = 4;

    // ============================================================
    // CLOCK / RESET
    // ============================================================

    logic clk;
    logic reset;

    // ============================================================
    // INSTRUCTION
    // ============================================================

    logic [31:0] instruction;

    // ============================================================
    // GPU TOP OUTPUTS
    // ============================================================

    logic [31:0] pc [0:NUM_SMS-1];
    logic [31:0] alu_result [0:NUM_SMS-1];
    logic        zero [0:NUM_SMS-1];

    logic [31:0] writeback_data [0:NUM_SMS-1];
    logic        writeback_enable [0:NUM_SMS-1];

    // ============================================================
    // TEST COUNTERS
    // ============================================================

    integer pass_count;
    integer fail_count;
    integer i;

    // ============================================================
    // DUT
    // ============================================================

    gpu_top #(
        .NUM_SMS(NUM_SMS)
    ) dut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),

        .pc(pc),
        .alu_result(alu_result),
        .zero(zero),
        .writeback_data(writeback_data),
        .writeback_enable(writeback_enable)
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
                    "%-25s : PASS | SM%0d | Expected=%08h Got=%08h",
                    test_name,
                    sm_id,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-25s : FAIL | SM%0d | Expected=%08h Got=%08h",
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
                    "%-25s : PASS | SM%0d | Expected=%0d Got=%0d",
                    test_name,
                    sm_id,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-25s : FAIL | SM%0d | Expected=%0d Got=%0d",
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

        instruction = 32'd0;
        reset = 1'b1;

        $display("");
        $display("======================================================");
        $display("              CUSTOM GPU TOP TEST");
        $display("======================================================");
        $display("");

        // ========================================================
        // RESET
        // ========================================================

        #12;
        reset = 1'b0;
        #2;

        // ========================================================
        // TEST 1 : RESET
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 1 : GPU TOP RESET");
        $display("----------------------------------------------");

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h00000000,
                pc[i],
                "TOP RESET PC",
                i
            );

        end

        // ========================================================
        // TEST 2 : ADD THROUGH GPU TOP
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 2 : ADD THROUGH TOP");
        $display("----------------------------------------------");

        instruction = {
            6'b000000,
            5'd1,
            5'd2,
            5'd3,
            11'b0
        };

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h0000000F,
                alu_result[i],
                "TOP ADD RESULT",
                i
            );

            check_result(
                32'h0000000F,
                writeback_data[i],
                "TOP ADD WRITEBACK",
                i
            );

            check_signal(
                1'b1,
                writeback_enable[i],
                "TOP ADD WRITE ENABLE",
                i
            );

            check_signal(
                1'b0,
                zero[i],
                "TOP ADD ZERO",
                i
            );

        end

        // ========================================================
        // TEST 3 : PC UPDATE
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 3 : TOP PC UPDATE");
        $display("----------------------------------------------");

        @(posedge clk);
        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h00000008,
                pc[i],
                "TOP PC UPDATE",
                i
            );

        end

        // ========================================================
        // TEST 4 : SUB
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 4 : SUB THROUGH TOP");
        $display("----------------------------------------------");

        instruction = {
            6'b000001,
            5'd1,
            5'd2,
            5'd4,
            11'b0
        };

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h00000005,
                alu_result[i],
                "TOP SUB RESULT",
                i
            );

            check_result(
                32'h00000005,
                writeback_data[i],
                "TOP SUB WRITEBACK",
                i
            );

        end

        // ========================================================
        // TEST 5 : MUL
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 5 : MUL THROUGH TOP");
        $display("----------------------------------------------");

        instruction = {
            6'b000010,
            5'd1,
            5'd2,
            5'd5,
            11'b0
        };

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h00000032,
                alu_result[i],
                "TOP MUL RESULT",
                i
            );

        end

        // ========================================================
        // TEST 6 : AND
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 6 : AND THROUGH TOP");
        $display("----------------------------------------------");

        instruction = {
            6'b000011,
            5'd1,
            5'd2,
            5'd6,
            11'b0
        };

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h00000000,
                alu_result[i],
                "TOP AND RESULT",
                i
            );

            check_signal(
                1'b1,
                zero[i],
                "TOP AND ZERO",
                i
            );

        end

        // ========================================================
        // TEST 7 : OR
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 7 : OR THROUGH TOP");
        $display("----------------------------------------------");

        instruction = {
            6'b000100,
            5'd1,
            5'd2,
            5'd7,
            11'b0
        };

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h0000000F,
                alu_result[i],
                "TOP OR RESULT",
                i
            );

        end

        // ========================================================
        // TEST 8 : XOR
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 8 : XOR THROUGH TOP");
        $display("----------------------------------------------");

        instruction = {
            6'b000101,
            5'd1,
            5'd2,
            5'd8,
            11'b0
        };

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h0000000F,
                alu_result[i],
                "TOP XOR RESULT",
                i
            );

        end

        // ========================================================
        // TEST 9 : ADDI
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 9 : ADDI THROUGH TOP");
        $display("----------------------------------------------");

        instruction = {
            6'b000110,
            5'd1,
            5'b00000,
            16'd20
        };

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h0000001E,
                alu_result[i],
                "TOP ADDI RESULT",
                i
            );

            check_result(
                32'h0000001E,
                writeback_data[i],
                "TOP ADDI WRITEBACK",
                i
            );

            check_signal(
                1'b1,
                writeback_enable[i],
                "TOP ADDI WRITE ENABLE",
                i
            );

        end

        // ========================================================
        // TEST 10 : ALL SMs RECEIVE SAME INSTRUCTION
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 10 : MULTI-SM TOP INTEGRATION");
        $display("----------------------------------------------");

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h0000001E,
                alu_result[i],
                "TOP SM INTEGRATION",
                i
            );

        end

        // ========================================================
        // FINAL RESULT
        // ========================================================

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
            $display("ALL GPU TOP TESTS PASSED");
            $display("");

        end
        else begin

            $display("");
            $display("GPU TOP TESTS FAILED");
            $display("");

        end

        $display("======================================================");

        #10;
        $finish;

    end

endmodule