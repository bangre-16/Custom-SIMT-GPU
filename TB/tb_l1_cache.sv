`timescale 1ns/1ps

module tb_l1_cache;

    parameter integer ADDR_WIDTH = 8;
    parameter integer DATA_WIDTH = 32;
    parameter integer NUM_LINES  = 16;

    logic                     clk;
    logic                     reset;

    logic                     read_enable;
    logic                     write_enable;

    logic [ADDR_WIDTH-1:0]    address;
    logic [DATA_WIDTH-1:0]    write_data;

    logic [DATA_WIDTH-1:0]    read_data;
    logic                     hit;
    logic                     miss;
    logic                     ready;

    integer passed;
    integer failed;


    // ============================================================
    // DUT
    // ============================================================

    l1_cache #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_LINES(NUM_LINES)
    ) dut (
        .clk         (clk),
        .reset       (reset),
        .read_enable (read_enable),
        .write_enable(write_enable),
        .address     (address),
        .write_data  (write_data),
        .read_data   (read_data),
        .hit         (hit),
        .miss        (miss),
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
                    "%-32s : PASS | Expected=%h Got=%h",
                    test_name,
                    expected,
                    actual
                );

                passed = passed + 1;

            end
            else begin

                $display(
                    "%-32s : FAIL | Expected=%h Got=%h",
                    test_name,
                    expected,
                    actual
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
                    "%-32s : PASS | Expected=%b Got=%b",
                    test_name,
                    expected,
                    actual
                );

                passed = passed + 1;

            end
            else begin

                $display(
                    "%-32s : FAIL | Expected=%b Got=%b",
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
        $display("                 CUSTOM GPU L1 CACHE TEST");
        $display("==========================================================");
        $display("");


        // ========================================================
        // TEST 1
        // READ INVALID ADDRESS -> MISS
        // ========================================================

        address      = 8'h10;
        read_enable  = 1'b1;
        write_enable = 1'b0;

        @(posedge clk);
        #2;

        check_signal(
            1'b0,
            hit,
            "INITIAL READ HIT"
        );

        check_signal(
            1'b1,
            miss,
            "INITIAL READ MISS"
        );


        // ========================================================
        // TEST 2
        // WRITE ADDRESS 10
        // ========================================================

        address      = 8'h10;
        write_data   = 32'h12345678;

        read_enable  = 1'b0;
        write_enable = 1'b1;

        @(posedge clk);
        #2;

        check_signal(
            1'b1,
            ready,
            "WRITE READY"
        );


        // ========================================================
        // TEST 3
        // READ SAME ADDRESS -> HIT
        // ========================================================

        address      = 8'h10;

        write_enable = 1'b0;
        read_enable  = 1'b1;

        @(posedge clk);
        #2;

        check_data(
            32'h12345678,
            read_data,
            "CACHE HIT DATA"
        );

        check_signal(
            1'b1,
            hit,
            "CACHE HIT"
        );

        check_signal(
            1'b0,
            miss,
            "CACHE HIT MISS FLAG"
        );


        // ========================================================
        // TEST 4
        // WRITE SECOND ADDRESS
        // ========================================================

        address      = 8'h25;
        write_data   = 32'hAABBCCDD;

        read_enable  = 1'b0;
        write_enable = 1'b1;

        @(posedge clk);
        #2;

        check_signal(
            1'b1,
            ready,
            "SECOND WRITE READY"
        );


        // ========================================================
        // TEST 5
        // READ SECOND ADDRESS -> HIT
        // ========================================================

        address      = 8'h25;

        write_enable = 1'b0;
        read_enable  = 1'b1;

        @(posedge clk);
        #2;

        check_data(
            32'hAABBCCDD,
            read_data,
            "SECOND CACHE HIT DATA"
        );

        check_signal(
            1'b1,
            hit,
            "SECOND CACHE HIT"
        );


        // ========================================================
        // TEST 6
        // ADDRESS WITH SAME INDEX BUT DIFFERENT TAG
        //
        // 0x10 -> index 0, tag 1
        // 0x20 -> index 0, tag 2
        //
        // Therefore 0x20 must MISS.
        // ========================================================

        address      = 8'h20;

        read_enable  = 1'b1;
        write_enable = 1'b0;

        @(posedge clk);
        #2;

        check_signal(
            1'b0,
            hit,
            "TAG MISMATCH HIT"
        );

        check_signal(
            1'b1,
            miss,
            "TAG MISMATCH MISS"
        );


        // ========================================================
        // TEST 7
        // WRITE NEW TAG TO SAME INDEX
        // ========================================================

        address      = 8'h20;
        write_data   = 32'hDEADBEEF;

        read_enable  = 1'b0;
        write_enable = 1'b1;

        @(posedge clk);
        #2;


        // ========================================================
        // TEST 8
        // READ NEW TAG -> HIT
        // ========================================================

        address      = 8'h20;

        write_enable = 1'b0;
        read_enable  = 1'b1;

        @(posedge clk);
        #2;

        check_data(
            32'hDEADBEEF,
            read_data,
            "NEW TAG HIT DATA"
        );

        check_signal(
            1'b1,
            hit,
            "NEW TAG HIT"
        );


        // ========================================================
        // TEST 9
        // CHECK OLD TAG WAS REPLACED
        // ========================================================

        address = 8'h10;

        @(posedge clk);
        #2;

        check_signal(
            1'b0,
            hit,
            "OLD TAG AFTER REPLACEMENT"
        );

        check_signal(
            1'b1,
            miss,
            "OLD TAG MISS AFTER REPLACEMENT"
        );


        // ========================================================
        // TEST 10
        // WRITE/READ LAST CACHE LINE
        // ========================================================

        address      = 8'hFF;
        write_data   = 32'hCAFEBABE;

        read_enable  = 1'b0;
        write_enable = 1'b1;

        @(posedge clk);
        #2;

        write_enable = 1'b0;
        read_enable  = 1'b1;

        @(posedge clk);
        #2;

        check_data(
            32'hCAFEBABE,
            read_data,
            "LAST CACHE LINE DATA"
        );

        check_signal(
            1'b1,
            hit,
            "LAST CACHE LINE HIT"
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
            $display("ALL L1 CACHE TESTS PASSED");
        else
            $display("L1 CACHE TESTS FAILED");


        $display("==========================================================");
        $display("");

        #10;

        $finish;

    end

endmodule