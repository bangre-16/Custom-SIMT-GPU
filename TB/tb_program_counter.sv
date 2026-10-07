`timescale 1ns/1ps

module tb_program_counter;

    logic clk;
    logic reset;

    logic        branch_enable;
    logic [31:0] branch_target;

    logic [31:0] pc;

    integer pass_count;
    integer fail_count;


    // =========================================================
    // DUT
    // =========================================================

    program_counter dut (
        .clk(clk),
        .reset(reset),

        .branch_enable(branch_enable),
        .branch_target(branch_target),

        .pc(pc)
    );


    // =========================================================
    // Clock
    // 10 ns period
    // =========================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end


    // =========================================================
    // Check task
    // =========================================================

    task check_pc(
        input logic [31:0] expected,
        input string test_name
    );

        begin

            if (pc === expected) begin

                $display(
                    "%-25s : PASS | Expected=%h Got=%h",
                    test_name,
                    expected,
                    pc
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-25s : FAIL | Expected=%h Got=%h",
                    test_name,
                    expected,
                    pc
                );

                fail_count = fail_count + 1;

            end

        end

    endtask


    // =========================================================
    // Test sequence
    // =========================================================

    initial begin

        pass_count = 0;
        fail_count = 0;

        reset         = 1'b1;
        branch_enable = 1'b0;
        branch_target = 32'h00000000;


        $display("==============================================");
        $display("        CUSTOM GPU PROGRAM COUNTER TEST");
        $display("==============================================");


        // =====================================================
        // TEST 1 — RESET
        // =====================================================

        @(posedge clk);

        #1;

        check_pc(
            32'h00000000,
            "RESET PC"
        );


        // =====================================================
        // TEST 2 — FIRST INSTRUCTION
        // =====================================================

        reset = 1'b0;

        @(posedge clk);

        #1;

        check_pc(
            32'h00000004,
            "PC + 4"
        );


        // =====================================================
        // TEST 3 — SECOND INSTRUCTION
        // =====================================================

        @(posedge clk);

        #1;

        check_pc(
            32'h00000008,
            "PC + 8"
        );


        // =====================================================
        // TEST 4 — THIRD INSTRUCTION
        // =====================================================

        @(posedge clk);

        #1;

        check_pc(
            32'h0000000C,
            "PC + 12"
        );


        // =====================================================
        // TEST 5 — BRANCH
        // =====================================================

        branch_target = 32'h00000100;
        branch_enable = 1'b1;

        @(posedge clk);

        #1;

        check_pc(
            32'h00000100,
            "BRANCH TARGET"
        );


        // =====================================================
        // TEST 6 — SEQUENTIAL AFTER BRANCH
        // =====================================================

        branch_enable = 1'b0;

        @(posedge clk);

        #1;

        check_pc(
            32'h00000104,
            "BRANCH + 4"
        );


        // =====================================================
        // TEST 7 — SECOND BRANCH
        // =====================================================

        branch_target = 32'h00000200;
        branch_enable = 1'b1;

        @(posedge clk);

        #1;

        check_pc(
            32'h00000200,
            "SECOND BRANCH"
        );


        // =====================================================
        // TEST 8 — SEQUENTIAL AFTER SECOND BRANCH
        // =====================================================

        branch_enable = 1'b0;

        @(posedge clk);

        #1;

        check_pc(
            32'h00000204,
            "SECOND BRANCH + 4"
        );


        // =====================================================
        // TEST 9 — RESET AGAIN
        // =====================================================

        reset = 1'b1;

        @(posedge clk);

        #1;

        check_pc(
            32'h00000000,
            "RESET AGAIN"
        );


        // =====================================================
        // FINAL RESULT
        // =====================================================

        $display("----------------------------------------------");

        $display(
            "PASSED : %0d",
            pass_count
        );

        $display(
            "FAILED : %0d",
            fail_count
        );

        $display("----------------------------------------------");

        if (fail_count == 0)
            $display("ALL PROGRAM COUNTER TESTS PASSED");
        else
            $display("PROGRAM COUNTER TESTS FAILED");

        $display("==============================================");

        #10;

        $finish;

    end

endmodule