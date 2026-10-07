`timescale 1ns/1ps

module tb_host_interface;

    // ============================================================
    // CLOCK / RESET
    // ============================================================

    logic clk;
    logic reset;

    // ============================================================
    // HOST INTERFACE
    // ============================================================

    logic        host_valid;
    logic        host_write;
    logic [31:0] host_addr;
    logic [31:0] host_wdata;

    logic [31:0] host_rdata;
    logic        host_ready;

    // ============================================================
    // GPU COMMAND INTERFACE
    // ============================================================

    logic [31:0] command_data;
    logic        command_valid;

    // ============================================================
    // TEST COUNTERS
    // ============================================================

    integer pass_count;
    integer fail_count;

    // ============================================================
    // DUT
    // ============================================================

    host_interface dut (

        .clk(clk),
        .reset(reset),

        .host_valid(host_valid),
        .host_write(host_write),
        .host_addr(host_addr),
        .host_wdata(host_wdata),

        .host_rdata(host_rdata),
        .host_ready(host_ready),

        .command_data(command_data),
        .command_valid(command_valid)

    );

    // ============================================================
    // CLOCK
    // ============================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end

    // ============================================================
    // CHECK 32-BIT
    // ============================================================

    task check_result;

        input [31:0] expected;
        input [31:0] actual;
        input string test_name;

        begin

            if (actual === expected) begin

                $display(
                    "%-30s : PASS | Expected=%08h Got=%08h",
                    test_name,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end

            else begin

                $display(
                    "%-30s : FAIL | Expected=%08h Got=%08h",
                    test_name,
                    expected,
                    actual
                );

                fail_count = fail_count + 1;

            end

        end

    endtask

    // ============================================================
    // CHECK 1-BIT
    // ============================================================

    task check_signal;

        input logic expected;
        input logic actual;
        input string test_name;

        begin

            if (actual === expected) begin

                $display(
                    "%-30s : PASS | Expected=%0d Got=%0d",
                    test_name,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end

            else begin

                $display(
                    "%-30s : FAIL | Expected=%0d Got=%0d",
                    test_name,
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

        host_valid = 1'b0;
        host_write = 1'b0;
        host_addr  = 32'h00000000;
        host_wdata = 32'h00000000;

        reset = 1'b1;

        $display("");
        $display("======================================================");
        $display("              CUSTOM GPU HOST INTERFACE TEST");
        $display("======================================================");
        $display("");

        // ========================================================
        // TEST 1 : RESET
        // ========================================================

        #12;

        reset = 1'b0;

        #2;

        check_result(
            32'h00000000,
            command_data,
            "RESET COMMAND DATA"
        );

        check_signal(
            1'b0,
            command_valid,
            "RESET COMMAND VALID"
        );

        check_signal(
            1'b1,
            host_ready,
            "HOST READY"
        );

        // ========================================================
        // TEST 2 : HOST WRITE COMMAND
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 2 : HOST COMMAND WRITE");
        $display("----------------------------------------------");

        host_valid = 1'b1;
        host_write = 1'b1;
        host_addr  = 32'h00000000;
        host_wdata = 32'h12345678;

        @(posedge clk);

        #1;

        check_result(
            32'h12345678,
            command_data,
            "COMMAND REGISTER"
        );

        check_signal(
            1'b1,
            command_valid,
            "COMMAND VALID"
        );

        // ========================================================
        // TEST 3 : COMMAND VALID PULSE
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 3 : COMMAND VALID PULSE");
        $display("----------------------------------------------");

        host_valid = 1'b0;
        host_write = 1'b0;

        @(posedge clk);

        #1;

        check_signal(
            1'b0,
            command_valid,
            "COMMAND VALID CLEAR"
        );

        check_result(
            32'h12345678,
            command_data,
            "COMMAND DATA RETAIN"
        );

        // ========================================================
        // TEST 4 : HOST READ
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 4 : HOST READ");
        $display("----------------------------------------------");

        host_valid = 1'b1;
        host_write = 1'b0;
        host_addr  = 32'h00000000;

        #1;

        check_result(
            32'h12345678,
            host_rdata,
            "HOST READ DATA"
        );

        // ========================================================
        // TEST 5 : SECOND COMMAND
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 5 : SECOND COMMAND");
        $display("----------------------------------------------");

        host_valid = 1'b1;
        host_write = 1'b1;
        host_addr  = 32'h00000000;
        host_wdata = 32'hA5A5A5A5;

        @(posedge clk);

        #1;

        check_result(
            32'hA5A5A5A5,
            command_data,
            "SECOND COMMAND DATA"
        );

        check_signal(
            1'b1,
            command_valid,
            "SECOND COMMAND VALID"
        );

        // ========================================================
        // TEST 6 : INVALID ADDRESS
        // ========================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 6 : INVALID ADDRESS");
        $display("----------------------------------------------");

        host_valid = 1'b1;
        host_write = 1'b1;
        host_addr  = 32'h00000010;
        host_wdata = 32'hFFFFFFFF;

        @(posedge clk);

        #1;

        check_result(
            32'hA5A5A5A5,
            command_data,
            "INVALID ADDRESS PROTECTION"
        );

        check_signal(
            1'b0,
            command_valid,
            "INVALID ADDRESS VALID"
        );

        // ========================================================
        // TEST 7 : READ INVALID ADDRESS
        // ========================================================

        host_valid = 1'b1;
        host_write = 1'b0;
        host_addr  = 32'h00000010;

        #1;

        check_result(
            32'h00000000,
            host_rdata,
            "INVALID READ DATA"
        );

        // ========================================================
        // FINAL RESULT
        // ========================================================

        host_valid = 1'b0;
        host_write = 1'b0;

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
            $display("ALL HOST INTERFACE TESTS PASSED");
            $display("");

        end

        else begin

            $display("");
            $display("HOST INTERFACE TESTS FAILED");
            $display("");

        end

        $display("======================================================");

        #10;

        $finish;

    end

endmodule