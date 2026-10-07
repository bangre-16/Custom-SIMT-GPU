`timescale 1ns/1ps

module tb_gpu_fetch_unit;

    logic        clk;
    logic        reset;

    logic [31:0] pc;
    logic [31:0] instruction;

    integer passed;
    integer failed;

    // ============================================================
    // DUT
    // ============================================================

    gpu_fetch_unit dut (
        .clk         (clk),
        .reset       (reset),
        .pc          (pc),
        .instruction (instruction)
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

    task automatic check_instruction(
        input [127:0] test_name,
        input [31:0] expected
    );

        begin

            #1;

            if (instruction === expected) begin

                $display(
                    "%-18s : PASS | PC=%08h | Instruction=%08h",
                    test_name,
                    pc,
                    instruction
                );

                passed = passed + 1;

            end
            else begin

                $display(
                    "%-18s : FAIL | PC=%08h | Expected=%08h Got=%08h",
                    test_name,
                    pc,
                    expected,
                    instruction
                );

                failed = failed + 1;

            end

        end

    endtask

    // ============================================================
    // TEST
    // ============================================================

    initial begin

        passed = 0;
        failed = 0;

        reset = 1'b1;

        #2;

        $display("");
        $display("========================================");
        $display("     CUSTOM GPU FETCH UNIT TEST");
        $display("========================================");

        // Release reset
        #8;

        reset = 1'b0;

        // --------------------------------------------------------
        // PC = 0
        // --------------------------------------------------------

        #1;

        check_instruction(
            "FETCH_INST_0",
            {
                6'b000000,
                5'd1,
                5'd2,
                5'd3,
                11'd0
            }
        );

        // --------------------------------------------------------
        // PC = 4
        // --------------------------------------------------------

        @(posedge clk);
        #1;

        check_instruction(
            "FETCH_INST_1",
            {
                6'b000001,
                5'd1,
                5'd2,
                5'd4,
                11'd0
            }
        );

        // --------------------------------------------------------
        // PC = 8
        // --------------------------------------------------------

        @(posedge clk);
        #1;

        check_instruction(
            "FETCH_INST_2",
            {
                6'b000010,
                5'd1,
                5'd2,
                5'd5,
                11'd0
            }
        );

        // --------------------------------------------------------
        // PC = 12
        // --------------------------------------------------------

        @(posedge clk);
        #1;

        check_instruction(
            "FETCH_INST_3",
            {
                6'b000011,
                5'd1,
                5'd2,
                5'd6,
                11'd0
            }
        );

        // --------------------------------------------------------
        // PC = 16
        // --------------------------------------------------------

        @(posedge clk);
        #1;

        check_instruction(
            "FETCH_INST_4",
            {
                6'b000100,
                5'd1,
                5'd2,
                5'd7,
                11'd0
            }
        );

        // --------------------------------------------------------
        // PC = 20
        // --------------------------------------------------------

        @(posedge clk);
        #1;

        check_instruction(
            "FETCH_INST_5",
            {
                6'b000101,
                5'd1,
                5'd2,
                5'd8,
                11'd0
            }
        );

        // ========================================================
        // SUMMARY
        // ========================================================

        $display("----------------------------------------");
        $display("PASSED : %0d", passed);
        $display("FAILED : %0d", failed);
        $display("----------------------------------------");

        if (failed == 0)
            $display("ALL GPU FETCH TESTS PASSED");
        else
            $display("GPU FETCH TESTS FAILED");

        $display("========================================");

        #10;

        $finish;

    end

endmodule