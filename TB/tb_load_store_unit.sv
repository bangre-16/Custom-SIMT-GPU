`timescale 1ns/1ps

module tb_load_store_unit;

    // =========================================================
    // Parameters
    // =========================================================

    localparam ADDR_WIDTH = 32;
    localparam DATA_WIDTH = 32;

    // =========================================================
    // Testbench signals
    // =========================================================

    logic clk;
    logic reset;

    logic load_enable;
    logic store_enable;

    logic [ADDR_WIDTH-1:0] base_address;
    logic [ADDR_WIDTH-1:0] offset;

    logic [DATA_WIDTH-1:0] store_data;

    logic mem_read;
    logic mem_write;

    logic [ADDR_WIDTH-1:0] mem_address;
    logic [DATA_WIDTH-1:0] mem_write_data;

    logic [DATA_WIDTH-1:0] mem_read_data;

    logic [DATA_WIDTH-1:0] load_data;

    logic ready;
    logic busy;
    logic alignment_error;

    integer passed;
    integer failed;

    // =========================================================
    // DUT
    // =========================================================

    load_store_unit dut (

        .clk              (clk),
        .reset            (reset),

        .load_enable      (load_enable),
        .store_enable     (store_enable),

        .base_address     (base_address),
        .offset           (offset),

        .store_data       (store_data),

        .mem_read         (mem_read),
        .mem_write        (mem_write),

        .mem_address      (mem_address),
        .mem_write_data   (mem_write_data),

        .mem_read_data    (mem_read_data),

        .load_data        (load_data),

        .ready            (ready),
        .busy             (busy),
        .alignment_error  (alignment_error)
    );

    // =========================================================
    // Clock
    // =========================================================

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end

    // =========================================================
    // Check task
    // =========================================================

    task check_result;

        input [255:0] test_name;
        input         condition;

        begin

            if (condition) begin

                $display("%-28s : PASS", test_name);
                passed = passed + 1;

            end
            else begin

                $display("%-28s : FAIL", test_name);
                failed = failed + 1;

            end

        end

    endtask

    // =========================================================
    // Test sequence
    // =========================================================

    initial begin

        passed = 0;
        failed = 0;

        reset         = 1'b1;

        load_enable   = 1'b0;
        store_enable  = 1'b0;

        base_address  = 32'd0;
        offset        = 32'd0;

        store_data    = 32'd0;
        mem_read_data = 32'd0;

        #12;

        reset = 1'b0;

        $display("");
        $display("==================================================");
        $display("          CUSTOM GPU LOAD/STORE UNIT TEST");
        $display("==================================================");
        $display("");

        // =====================================================
        // TEST 1 : IDLE
        // =====================================================

        load_enable  = 1'b0;
        store_enable = 1'b0;

        #1;

        check_result(
            "IDLE READY",
            ready == 1'b0
        );

        check_result(
            "IDLE MEM READ",
            mem_read == 1'b0
        );

        check_result(
            "IDLE MEM WRITE",
            mem_write == 1'b0
        );


        // =====================================================
        // TEST 2 : LOAD
        // =====================================================

        base_address  = 32'd100;
        offset        = 32'd20;

        mem_read_data = 32'h12345678;

        load_enable   = 1'b1;
        store_enable  = 1'b0;

        #1;

        check_result(
            "LOAD ENABLE",
            mem_read == 1'b1
        );

        check_result(
            "LOAD MEM WRITE OFF",
            mem_write == 1'b0
        );

        check_result(
            "LOAD ADDRESS",
            mem_address == 32'd120
        );

        check_result(
            "LOAD DATA",
            load_data == 32'h12345678
        );

        check_result(
            "LOAD READY",
            ready == 1'b1
        );

        check_result(
            "LOAD ALIGNMENT",
            alignment_error == 1'b0
        );


        // =====================================================
        // TEST 3 : STORE
        // =====================================================

        load_enable   = 1'b0;
        store_enable  = 1'b1;

        base_address  = 32'd200;
        offset        = 32'd20;

        store_data    = 32'hAABBCCDD;

        #1;

        check_result(
            "STORE ENABLE",
            mem_write == 1'b1
        );

        check_result(
            "STORE MEM READ OFF",
            mem_read == 1'b0
        );

        check_result(
            "STORE ADDRESS",
            mem_address == 32'd220
        );

        check_result(
            "STORE DATA",
            mem_write_data == 32'hAABBCCDD
        );

        check_result(
            "STORE READY",
            ready == 1'b1
        );

        check_result(
            "STORE ALIGNMENT",
            alignment_error == 1'b0
        );


        // =====================================================
        // TEST 4 : ANOTHER LOAD
        // =====================================================

        load_enable   = 1'b1;
        store_enable  = 1'b0;

        base_address  = 32'd400;
        offset        = 32'd12;

        mem_read_data = 32'hDEADBEEF;

        #1;

        check_result(
            "SECOND LOAD ADDRESS",
            mem_address == 32'd412
        );

        check_result(
            "SECOND LOAD DATA",
            load_data == 32'hDEADBEEF
        );

        check_result(
            "SECOND LOAD READY",
            ready == 1'b1
        );


        // =====================================================
        // TEST 5 : MISALIGNED LOAD
        // =====================================================

        load_enable  = 1'b1;
        store_enable = 1'b0;

        base_address = 32'd100;
        offset       = 32'd2;

        #1;

        check_result(
            "MISALIGNED LOAD",
            alignment_error == 1'b1
        );


        // =====================================================
        // TEST 6 : MISALIGNED STORE
        // =====================================================

        load_enable  = 1'b0;
        store_enable = 1'b1;

        base_address = 32'd200;
        offset       = 32'd1;

        #1;

        check_result(
            "MISALIGNED STORE",
            alignment_error == 1'b1
        );


        // =====================================================
        // TEST 7 : SIMULTANEOUS LOAD + STORE
        // =====================================================

        load_enable  = 1'b1;
        store_enable = 1'b1;

        base_address = 32'd300;
        offset       = 32'd4;

        #1;

        check_result(
            "SIMULTANEOUS REQUEST",
            (mem_read == 1'b0) &&
            (mem_write == 1'b0) &&
            (ready == 1'b0)
        );


        // =====================================================
        // TEST SUMMARY
        // =====================================================

        $display("");
        $display("--------------------------------------------------");
        $display("PASSED : %0d", passed);
        $display("FAILED : %0d", failed);
        $display("--------------------------------------------------");

        if (failed == 0) begin

            $display("ALL LOAD/STORE UNIT TESTS PASSED");

        end
        else begin

            $display("LOAD/STORE UNIT TESTS FAILED");

        end

        $display("==================================================");
        $display("");

        #10;

        $finish;

    end

endmodule