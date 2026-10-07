`timescale 1ns/1ps

module tb_l2_cache;

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;

    // =========================================================
    // Signals
    // =========================================================

    logic clk;
    logic reset;

    logic read_enable;
    logic write_enable;

    logic [ADDR_WIDTH-1:0] address;
    logic [DATA_WIDTH-1:0] write_data;

    logic [DATA_WIDTH-1:0] read_data;

    logic hit;
    logic miss;
    logic ready;

    logic mem_read;
    logic mem_write;

    logic [ADDR_WIDTH-1:0] mem_address;
    logic [DATA_WIDTH-1:0] mem_write_data;

    logic [DATA_WIDTH-1:0] mem_read_data;

    integer passed;
    integer failed;

    // =========================================================
    // DUT
    // =========================================================

    l2_cache dut (

        .clk              (clk),
        .reset            (reset),

        .read_enable      (read_enable),
        .write_enable     (write_enable),

        .address          (address),
        .write_data       (write_data),

        .read_data        (read_data),

        .hit              (hit),
        .miss             (miss),
        .ready            (ready),

        .mem_read         (mem_read),
        .mem_write        (mem_write),

        .mem_address      (mem_address),
        .mem_write_data   (mem_write_data),

        .mem_read_data    (mem_read_data)
    );

    // =========================================================
    // CLOCK
    // =========================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end

    // =========================================================
    // CHECK TASK
    // =========================================================

    task check;

        input [255:0] name;
        input condition;

        begin

            if (condition) begin

                $display("%-32s : PASS", name);

                passed = passed + 1;

            end
            else begin

                $display("%-32s : FAIL", name);

                failed = failed + 1;

            end

        end

    endtask

    // =========================================================
    // TESTS
    // =========================================================

    initial begin

        passed = 0;
        failed = 0;

        reset = 1'b1;

        read_enable  = 1'b0;
        write_enable = 1'b0;

        address      = 32'h00000000;
        write_data   = 32'h00000000;

        mem_read_data = 32'h00000000;

        #12;

        reset = 1'b0;

        $display("");
        $display("==================================================");
        $display("             CUSTOM GPU L2 CACHE TEST");
        $display("==================================================");
        $display("");


        // =====================================================
        // TEST 1 : IDLE
        // =====================================================

        read_enable  = 1'b0;
        write_enable = 1'b0;

        #1;

        check(
            "IDLE READY",
            ready == 1'b0
        );


        // =====================================================
        // TEST 2 : INITIAL READ MISS
        // =====================================================

        address = 32'h00000010;

        mem_read_data = 32'h12345678;

        read_enable  = 1'b1;
        write_enable = 1'b0;

        #1;

        check(
            "INITIAL READ MISS",
            miss == 1'b1
        );

        check(
            "INITIAL MEMORY READ",
            mem_read == 1'b1
        );

        check(
            "INITIAL MISS DATA",
            read_data == 32'h12345678
        );

        check(
            "INITIAL READY",
            ready == 1'b1
        );

        @(posedge clk);

        #1;


        // =====================================================
        // TEST 3 : CACHE HIT
        // =====================================================

        mem_read_data = 32'hAAAAAAAA;

        #1;

        check(
            "CACHE HIT",
            hit == 1'b1
        );

        check(
            "CACHE HIT MISS FLAG",
            miss == 1'b0
        );

        check(
            "CACHE HIT DATA",
            read_data == 32'h12345678
        );

        check(
            "CACHE HIT NO MEMORY READ",
            mem_read == 1'b0
        );


        // =====================================================
        // TEST 4 : DIFFERENT ADDRESS / MISS
        // =====================================================

        address = 32'h00000020;

        mem_read_data = 32'hAABBCCDD;

        #1;

        check(
            "SECOND READ MISS",
            miss == 1'b1
        );

        check(
            "SECOND MISS MEMORY READ",
            mem_read == 1'b1
        );

        check(
            "SECOND MISS DATA",
            read_data == 32'hAABBCCDD
        );

        @(posedge clk);

        #1;


        // =====================================================
        // TEST 5 : SECOND CACHE HIT
        // =====================================================

        mem_read_data = 32'hFFFFFFFF;

        #1;

        check(
            "SECOND CACHE HIT",
            hit == 1'b1
        );

        check(
            "SECOND CACHE HIT DATA",
            read_data == 32'hAABBCCDD
        );


        // =====================================================
        // TEST 6 : WRITE HIT
        // =====================================================

        read_enable  = 1'b0;
        write_enable = 1'b1;

        address    = 32'h00000020;
        write_data = 32'hDEADBEEF;

        #1;

        check(
            "WRITE HIT",
            hit == 1'b1
        );

        check(
            "WRITE MEMORY ENABLE",
            mem_write == 1'b1
        );

        check(
            "WRITE ADDRESS",
            mem_address == 32'h00000020
        );

        check(
            "WRITE DATA",
            mem_write_data == 32'hDEADBEEF
        );

        @(posedge clk);

        #1;


        // =====================================================
        // TEST 7 : READ AFTER WRITE
        // =====================================================

        read_enable  = 1'b1;
        write_enable = 1'b0;

        mem_read_data = 32'h11111111;

        #1;

        check(
            "READ AFTER WRITE HIT",
            hit == 1'b1
        );

        check(
            "READ AFTER WRITE DATA",
            read_data == 32'hDEADBEEF
        );


        // =====================================================
        // TEST 8 : WRITE MISS
        // =====================================================

        read_enable  = 1'b0;
        write_enable = 1'b1;

        address    = 32'h00000030;
        write_data = 32'hCAFEBABE;

        #1;

        check(
            "WRITE MISS",
            miss == 1'b1
        );

        check(
            "WRITE MISS MEMORY ENABLE",
            mem_write == 1'b1
        );

        check(
            "WRITE MISS ADDRESS",
            mem_address == 32'h00000030
        );

        check(
            "WRITE MISS DATA",
            mem_write_data == 32'hCAFEBABE
        );


        // =====================================================
        // TEST 9 : SIMULTANEOUS READ + WRITE
        // =====================================================

        read_enable  = 1'b1;
        write_enable = 1'b1;

        address = 32'h00000040;

        #1;

        check(
            "SIMULTANEOUS REQUEST",
            (ready == 1'b0) &&
            (mem_read == 1'b0) &&
            (mem_write == 1'b0)
        );


        // =====================================================
        // TEST 10 : RESET INVALIDATES CACHE
        // =====================================================

        read_enable  = 1'b0;
        write_enable = 1'b0;

        reset = 1'b1;

        #2;

        reset = 1'b0;

        address = 32'h00000020;

        mem_read_data = 32'h55555555;

        read_enable  = 1'b1;
        write_enable = 1'b0;

        #1;

        check(
            "RESET INVALIDATES CACHE",
            miss == 1'b1
        );

        check(
            "RESET NEW MEMORY DATA",
            read_data == 32'h55555555
        );


        // =====================================================
        // SUMMARY
        // =====================================================

        $display("");
        $display("--------------------------------------------------");
        $display("PASSED : %0d", passed);
        $display("FAILED : %0d", failed);
        $display("--------------------------------------------------");

        if (failed == 0) begin

            $display("ALL L2 CACHE TESTS PASSED");

        end
        else begin

            $display("L2 CACHE TESTS FAILED");

        end

        $display("==================================================");
        $display("");

        #10;

        $finish;

    end

endmodule