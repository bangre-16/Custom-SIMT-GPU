`timescale 1ns/1ps

module tb_memory_controller;

    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter DEPTH      = 256;

    // =========================================================
    // SIGNALS
    // =========================================================

    logic clk;
    logic reset;

    logic                  read_enable;
    logic                  write_enable;
    logic [ADDR_WIDTH-1:0] address;
    logic [DATA_WIDTH-1:0] write_data;

    logic [DATA_WIDTH-1:0] read_data;
    logic                  ready;
    logic                  busy;

    logic                  mem_read;
    logic                  mem_write;
    logic [ADDR_WIDTH-1:0] mem_address;
    logic [DATA_WIDTH-1:0] mem_write_data;
    logic [DATA_WIDTH-1:0] mem_read_data;

    integer passed;
    integer failed;

    // =========================================================
    // DUT
    // =========================================================

    memory_controller #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .reset(reset),

        .read_enable(read_enable),
        .write_enable(write_enable),
        .address(address),
        .write_data(write_data),

        .read_data(read_data),
        .ready(ready),
        .busy(busy),

        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_address(mem_address),
        .mem_write_data(mem_write_data),
        .mem_read_data(mem_read_data)
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

    task check_signal;

        input [8*80-1:0] test_name;
        input             condition;

        begin

            if (condition) begin

                $display("%-32s : PASS", test_name);
                passed = passed + 1;

            end
            else begin

                $display("%-32s : FAIL", test_name);
                failed = failed + 1;

            end

        end

    endtask

    // =========================================================
    // TEST PROCEDURE
    // =========================================================

    initial begin

        passed = 0;
        failed = 0;

        // -----------------------------------------------------
        // INITIAL CONDITIONS
        // -----------------------------------------------------

        reset        = 1'b1;
        read_enable  = 1'b0;
        write_enable = 1'b0;
        address      = 32'h00000000;
        write_data   = 32'h00000000;
        mem_read_data = 32'h00000000;

        #12;

        reset = 1'b0;

        #2;

        $display("");
        $display("==================================================");
        $display("       CUSTOM GPU MEMORY CONTROLLER TEST");
        $display("==================================================");

        // =====================================================
        // TEST 1 : RESET READY
        // =====================================================

        check_signal(
            "RESET READY",
            ready == 1'b1
        );

        // =====================================================
        // TEST 2 : RESET NOT BUSY
        // =====================================================

        check_signal(
            "RESET NOT BUSY",
            busy == 1'b0
        );

        // =====================================================
        // TEST 3 : WRITE ADDRESS 10
        // =====================================================

        @(negedge clk);

        address      = 32'd10;
        write_data   = 32'h12345678;
        write_enable = 1'b1;
        read_enable  = 1'b0;

        @(posedge clk);
        #1;

        check_signal(
            "WRITE ADDRESS 10",
            mem_write == 1'b1 &&
            mem_address == 32'd10 &&
            mem_write_data == 32'h12345678
        );

        write_enable = 1'b0;

        // =====================================================
        // TEST 4 : READ ADDRESS 10
        // =====================================================

        @(negedge clk);

        address     = 32'd10;
        read_enable = 1'b1;

        @(posedge clk);
        #1;

        check_signal(
            "READ ADDRESS 10",
            mem_read == 1'b1 &&
            mem_address == 32'd10
        );

        check_signal(
            "READ DATA 10",
            read_data == 32'h12345678
        );

        read_enable = 1'b0;

        // =====================================================
        // TEST 5 : WRITE ADDRESS 20
        // =====================================================

        @(negedge clk);

        address      = 32'd20;
        write_data   = 32'hAABBCCDD;
        write_enable = 1'b1;

        @(posedge clk);
        #1;

        check_signal(
            "WRITE ADDRESS 20",
            mem_write == 1'b1 &&
            mem_address == 32'd20 &&
            mem_write_data == 32'hAABBCCDD
        );

        write_enable = 1'b0;

        // =====================================================
        // TEST 6 : READ ADDRESS 20
        // =====================================================

        @(negedge clk);

        address     = 32'd20;
        read_enable = 1'b1;

        @(posedge clk);
        #1;

        check_signal(
            "READ ADDRESS 20",
            mem_read == 1'b1 &&
            mem_address == 32'd20
        );

        check_signal(
            "READ DATA 20",
            read_data == 32'hAABBCCDD
        );

        read_enable = 1'b0;

        // =====================================================
        // TEST 7 : MEMORY ISOLATION
        // =====================================================

        @(negedge clk);

        address     = 32'd10;
        read_enable = 1'b1;

        @(posedge clk);
        #1;

        check_signal(
            "MEMORY ISOLATION",
            read_data == 32'h12345678
        );

        read_enable = 1'b0;

        // =====================================================
        // TEST 8 : ZERO DATA WRITE
        // =====================================================

        @(negedge clk);

        address      = 32'd30;
        write_data   = 32'h00000000;
        write_enable = 1'b1;

        @(posedge clk);
        #1;

        write_enable = 1'b0;

        @(negedge clk);

        address     = 32'd30;
        read_enable = 1'b1;

        @(posedge clk);
        #1;

        check_signal(
            "ZERO DATA READ",
            read_data == 32'h00000000
        );

        read_enable = 1'b0;

        // =====================================================
        // TEST 9 : ALL ONES
        // =====================================================

        @(negedge clk);

        address      = 32'd40;
        write_data   = 32'hFFFFFFFF;
        write_enable = 1'b1;

        @(posedge clk);
        #1;

        write_enable = 1'b0;

        @(negedge clk);

        address     = 32'd40;
        read_enable = 1'b1;

        @(posedge clk);
        #1;

        check_signal(
            "ALL ONES READ",
            read_data == 32'hFFFFFFFF
        );

        read_enable = 1'b0;

        // =====================================================
        // TEST 10 : DIFFERENT DATA PATTERN
        // =====================================================

        @(negedge clk);

        address      = 32'd50;
        write_data   = 32'hDEADBEEF;
        write_enable = 1'b1;

        @(posedge clk);
        #1;

        write_enable = 1'b0;

        @(negedge clk);

        address     = 32'd50;
        read_enable = 1'b1;

        @(posedge clk);
        #1;

        check_signal(
            "DEADBEEF READ",
            read_data == 32'hDEADBEEF
        );

        read_enable = 1'b0;

        // =====================================================
        // TEST 11 : ADDRESS 100
        // =====================================================

        @(negedge clk);

        address      = 32'd100;
        write_data   = 32'hCAFEBABE;
        write_enable = 1'b1;

        @(posedge clk);
        #1;

        write_enable = 1'b0;

        @(negedge clk);

        address     = 32'd100;
        read_enable = 1'b1;

        @(posedge clk);
        #1;

        check_signal(
            "ADDRESS 100 READ",
            read_data == 32'hCAFEBABE
        );

        read_enable = 1'b0;

        // =====================================================
        // TEST 12 : WRITE ENABLE OFF
        // =====================================================

        @(negedge clk);

        address      = 32'd60;
        write_data   = 32'h11111111;
        write_enable = 1'b0;
        read_enable  = 1'b0;

        @(posedge clk);
        #1;

        check_signal(
            "WRITE ENABLE OFF",
            mem_write == 1'b0
        );

        // =====================================================
        // TEST 13 : READ ENABLE OFF
        // =====================================================

        check_signal(
            "READ ENABLE OFF",
            mem_read == 1'b0
        );

        // =====================================================
        // TEST 14 : IDLE READY
        // =====================================================

        check_signal(
            "IDLE READY",
            ready == 1'b1
        );

        // =====================================================
        // TEST 15 : IDLE NOT BUSY
        // =====================================================

        check_signal(
            "IDLE NOT BUSY",
            busy == 1'b0
        );

        // =====================================================
        // TEST 16 : SECOND WRITE
        // =====================================================

        @(negedge clk);

        address      = 32'd70;
        write_data   = 32'hFACEFACE;
        write_enable = 1'b1;

        @(posedge clk);
        #1;

        check_signal(
            "SECOND WRITE",
            mem_write == 1'b1 &&
            mem_write_data == 32'hFACEFACE
        );

        write_enable = 1'b0;

        // =====================================================
        // TEST 17 : SECOND READ
        // =====================================================

        @(negedge clk);

        address     = 32'd70;
        read_enable = 1'b1;

        @(posedge clk);
        #1;

        check_signal(
            "SECOND READ",
            read_data == 32'hFACEFACE
        );

        read_enable = 1'b0;

        // =====================================================
        // TEST 18 : RESET CLEARS MEMORY
        // =====================================================

        @(negedge clk);

        reset = 1'b1;

        @(posedge clk);
        #1;

        reset = 1'b0;

        @(negedge clk);

        address     = 32'd10;
        read_enable = 1'b1;

        @(posedge clk);
        #1;

        check_signal(
            "RESET CLEARS MEMORY",
            read_data == 32'h00000000
        );

        read_enable = 1'b0;

        // =====================================================
        // FINAL RESULT
        // =====================================================

        $display("");
        $display("--------------------------------------------------");
        $display("PASSED : %0d", passed);
        $display("FAILED : %0d", failed);
        $display("--------------------------------------------------");

        if (failed == 0)
            $display("ALL MEMORY CONTROLLER TESTS PASSED");
        else
            $display("MEMORY CONTROLLER TESTS FAILED");

        $display("==================================================");

        #10;

        $finish;

    end

endmodule