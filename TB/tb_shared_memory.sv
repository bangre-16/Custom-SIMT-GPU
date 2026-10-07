`timescale 1ns/1ps

module tb_shared_memory;

    parameter integer ADDR_WIDTH = 8;
    parameter integer DATA_WIDTH = 32;
    parameter integer DEPTH      = 256;

    // ============================================================
    // SIGNALS
    // ============================================================

    logic                         clk;
    logic                         reset;

    logic                         read_enable;
    logic                         write_enable;

    logic [ADDR_WIDTH-1:0]        address;
    logic [DATA_WIDTH-1:0]        write_data;

    logic [DATA_WIDTH-1:0]        read_data;
    logic                         ready;

    integer passed;
    integer failed;


    // ============================================================
    // DUT
    // ============================================================

    shared_memory #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk         (clk),
        .reset       (reset),
        .read_enable (read_enable),
        .write_enable(write_enable),
        .address     (address),
        .write_data  (write_data),
        .read_data   (read_data),
        .ready       (ready)
    );


    // ============================================================
    // CLOCK
    // ============================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end


    // ============================================================
    // CHECK DATA
    // ============================================================

    task automatic check_data;

        input [DATA_WIDTH-1:0] expected;
        input [DATA_WIDTH-1:0] actual;
        input string test_name;

        begin

            if (actual === expected) begin

                $display(
                    "%-30s : PASS | Expected=%h Got=%h",
                    test_name,
                    expected,
                    actual
                );

                passed = passed + 1;

            end

            else begin

                $display(
                    "%-30s : FAIL | Expected=%h Got=%h",
                    test_name,
                    expected,
                    actual
                );

                failed = failed + 1;

            end

        end

    endtask


    // ============================================================
    // CHECK READY
    // ============================================================

    task automatic check_ready;

        input expected;
        input actual;
        input string test_name;

        begin

            if (actual === expected) begin

                $display(
                    "%-30s : PASS | Expected=%b Got=%b",
                    test_name,
                    expected,
                    actual
                );

                passed = passed + 1;

            end

            else begin

                $display(
                    "%-30s : FAIL | Expected=%b Got=%b",
                    test_name,
                    expected,
                    actual
                );

                failed = failed + 1;

            end

        end

    endtask


    // ============================================================
    // MAIN TEST
    // ============================================================

    initial begin

        passed = 0;
        failed = 0;

        reset        = 1'b1;
        read_enable  = 1'b0;
        write_enable = 1'b0;
        address      = 8'h00;
        write_data   = 32'h00000000;


        // ========================================================
        // RESET
        // ========================================================

        #12;

        reset = 1'b0;

        #2;


        $display("");
        $display("==========================================================");
        $display("             CUSTOM GPU SHARED MEMORY TEST");
        $display("==========================================================");
        $display("");


        // ========================================================
        // TEST 1 - WRITE ADDRESS 10
        // ========================================================

        address      = 8'd10;
        write_data   = 32'h12345678;
        write_enable = 1'b1;
        read_enable  = 1'b0;

        @(posedge clk);
        #2;

        check_ready(
            1'b1,
            ready,
            "WRITE ADDRESS 10"
        );


        // ========================================================
        // TEST 2 - READ ADDRESS 10
        // ========================================================

        write_enable = 1'b0;
        read_enable  = 1'b1;

        @(posedge clk);
        #2;

        check_data(
            32'h12345678,
            read_data,
            "READ ADDRESS 10"
        );


        // ========================================================
        // TEST 3 - WRITE ADDRESS 20
        // ========================================================

        address      = 8'd20;
        write_data   = 32'hAABBCCDD;
        write_enable = 1'b1;
        read_enable  = 1'b0;

        @(posedge clk);
        #2;

        check_ready(
            1'b1,
            ready,
            "WRITE ADDRESS 20"
        );


        // ========================================================
        // TEST 4 - READ ADDRESS 20
        // ========================================================

        write_enable = 1'b0;
        read_enable  = 1'b1;

        @(posedge clk);
        #2;

        check_data(
            32'hAABBCCDD,
            read_data,
            "READ ADDRESS 20"
        );


        // ========================================================
        // TEST 5 - MEMORY ISOLATION
        // Address 10 must still contain original value
        // ========================================================

        address = 8'd10;

        @(posedge clk);
        #2;

        check_data(
            32'h12345678,
            read_data,
            "MEMORY ISOLATION"
        );


        // ========================================================
        // TEST 6 - ZERO DATA
        // ========================================================

        address      = 8'd30;
        write_data   = 32'h00000000;
        write_enable = 1'b1;
        read_enable  = 1'b0;

        @(posedge clk);
        #2;

        write_enable = 1'b0;
        read_enable  = 1'b1;

        @(posedge clk);
        #2;

        check_data(
            32'h00000000,
            read_data,
            "ZERO DATA READ"
        );


        // ========================================================
        // TEST 7 - ALL ONES
        // ========================================================

        address      = 8'd40;
        write_data   = 32'hFFFFFFFF;
        write_enable = 1'b1;
        read_enable  = 1'b0;

        @(posedge clk);
        #2;

        write_enable = 1'b0;
        read_enable  = 1'b1;

        @(posedge clk);
        #2;

        check_data(
            32'hFFFFFFFF,
            read_data,
            "ALL ONES READ"
        );


        // ========================================================
        // TEST 8 - DIFFERENT ADDRESS
        // ========================================================

        address      = 8'd100;
        write_data   = 32'hDEADBEEF;
        write_enable = 1'b1;
        read_enable  = 1'b0;

        @(posedge clk);
        #2;

        write_enable = 1'b0;
        read_enable  = 1'b1;

        @(posedge clk);
        #2;

        check_data(
            32'hDEADBEEF,
            read_data,
            "ADDRESS 100 READ"
        );


        // ========================================================
        // TEST 9 - WRITE/READ ADDRESS 255
        // ========================================================

        address      = 8'd255;
        write_data   = 32'hCAFEBABE;
        write_enable = 1'b1;
        read_enable  = 1'b0;

        @(posedge clk);
        #2;

        write_enable = 1'b0;
        read_enable  = 1'b1;

        @(posedge clk);
        #2;

        check_data(
            32'hCAFEBABE,
            read_data,
            "ADDRESS 255 READ"
        );


        // ========================================================
        // TEST 10 - READ AFTER MULTIPLE WRITES
        // ========================================================

        address      = 8'd20;

        @(posedge clk);
        #2;

        check_data(
            32'hAABBCCDD,
            read_data,
            "MULTIPLE WRITE RETENTION"
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

            $display("ALL SHARED MEMORY TESTS PASSED");

        end

        else begin

            $display("SHARED MEMORY TESTS FAILED");

        end


        $display("==========================================================");
        $display("");

        #10;

        $finish;

    end

endmodule