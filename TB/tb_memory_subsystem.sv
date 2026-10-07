`timescale 1ns/1ps

module tb_memory_subsystem;

    logic clk;
    logic reset;

    logic load_enable;
    logic store_enable;

    logic [31:0] base_address;
    logic [31:0] offset;

    logic [31:0] store_data;
    logic [31:0] load_data;

    logic ready;
    logic busy;
    logic alignment_error;

    logic l2_hit;
    logic l2_miss;
    logic l2_ready;

    logic memory_ready;
    logic memory_busy;

    integer passed;
    integer failed;

    // ============================================================
    // DUT
    // ============================================================
    memory_subsystem dut (

        .clk             (clk),
        .reset           (reset),

        .load_enable     (load_enable),
        .store_enable    (store_enable),

        .base_address    (base_address),
        .offset          (offset),

        .store_data      (store_data),
        .load_data       (load_data),

        .ready           (ready),
        .busy             (busy),
        .alignment_error (alignment_error),

        .l2_hit          (l2_hit),
        .l2_miss         (l2_miss),
        .l2_ready        (l2_ready),

        .memory_ready    (memory_ready),
        .memory_busy     (memory_busy)
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
    task check_value;

        input [255:0] name;
        input [31:0] expected;
        input [31:0] actual;

        begin

            if (actual === expected) begin

                $display(
                    "%-32s : PASS | Expected=%h Got=%h",
                    name,
                    expected,
                    actual
                );

                passed = passed + 1;

            end
            else begin

                $display(
                    "%-32s : FAIL | Expected=%h Got=%h",
                    name,
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
        load_enable  = 1'b0;
        store_enable = 1'b0;

        base_address = 32'd0;
        offset       = 32'd0;
        store_data   = 32'd0;

        // ========================================================
        // TEST 1
        // ========================================================
        $display("");
        $display("======================================================");
        $display("           CUSTOM GPU MEMORY SUBSYSTEM TEST");
        $display("======================================================");

        $display("");
        $display("----------------------------------------------");
        $display("TEST 1 : RESET");
        $display("----------------------------------------------");

        #12;

        reset = 1'b0;

        #1;

        check_value(
            "RESET ALIGNMENT ERROR",
            32'd0,
            alignment_error
        );

        check_value(
            "RESET BUSY",
            32'd0,
            busy
        );

        check_value(
            "RESET L2 HIT",
            32'd0,
            l2_hit
        );

        check_value(
            "RESET L2 MISS",
            32'd0,
            l2_miss
        );

        // ========================================================
        // TEST 2
        // ========================================================
        $display("");
        $display("----------------------------------------------");
        $display("TEST 2 : STORE THROUGH MEMORY SUBSYSTEM");
        $display("----------------------------------------------");

        base_address = 32'h00000040;
        offset       = 32'h00000000;
        store_data   = 32'hDEADBEEF;

        store_enable = 1'b1;

        #1;

        check_value(
            "STORE READY",
            32'd1,
            ready
        );

        @(posedge clk);
        #1;

        check_value(
            "LSU STORE REQUEST",
            32'd1,
            dut.lsu_mem_write
        );

        check_value(
            "STORE EFFECTIVE ADDRESS",
            32'h00000040,
            dut.lsu_mem_address
        );

        check_value(
            "STORE DATA",
            32'hDEADBEEF,
            dut.lsu_mem_write_data
        );

        check_value(
            "L2 MEMORY WRITE",
            32'd1,
            dut.l2_mem_write
        );

        check_value(
            "L2 MEMORY ADDRESS",
            32'h00000040,
            dut.l2_mem_address
        );

        store_enable = 1'b0;

        @(posedge clk);
        #1;

        @(posedge clk);
        #1;

        check_value(
            "STORE COMPLETE BUSY",
            32'd0,
            busy
        );

        // ========================================================
        // TEST 3
        // ========================================================
        $display("");
        $display("----------------------------------------------");
        $display("TEST 3 : LOAD THROUGH MEMORY SUBSYSTEM");
        $display("----------------------------------------------");

        base_address = 32'h00000040;
        offset       = 32'h00000000;

        load_enable = 1'b1;

        #1;

        check_value(
            "LOAD READY",
            32'd1,
            ready
        );

        check_value(
            "LSU LOAD REQUEST",
            32'd1,
            dut.lsu_mem_read
        );

        check_value(
            "LOAD EFFECTIVE ADDRESS",
            32'h00000040,
            dut.lsu_mem_address
        );

        check_value(
            "L2 MISS ON FIRST LOAD",
            32'd1,
            l2_miss
        );

        @(posedge clk);
        #1;

        @(posedge clk);
        #1;

        check_value(
            "LOAD RETURN DATA",
            32'hDEADBEEF,
            load_data
        );

        load_enable = 1'b0;

        @(posedge clk);
        #1;

        // ========================================================
        // TEST 4
        // ========================================================
        $display("");
        $display("----------------------------------------------");
        $display("TEST 4 : L2 CACHE HIT");
        $display("----------------------------------------------");

        load_enable = 1'b1;

        #1;

        check_value(
            "L2 HIT",
            32'd1,
            l2_hit
        );

        check_value(
            "L2 MISS CLEAR",
            32'd0,
            l2_miss
        );

        check_value(
            "L2 HIT DATA",
            32'hDEADBEEF,
            load_data
        );

        load_enable = 1'b0;

        @(posedge clk);
        #1;

        // ========================================================
        // TEST 5
        // ========================================================
        $display("");
        $display("----------------------------------------------");
        $display("TEST 5 : DIFFERENT MEMORY ADDRESS");
        $display("----------------------------------------------");

        base_address = 32'h00000080;
        offset       = 32'h00000000;

        load_enable = 1'b1;

        #1;

        check_value(
            "SECOND ADDRESS",
            32'h00000080,
            dut.lsu_mem_address
        );

        check_value(
            "SECOND L2 READ",
            32'd1,
            dut.l2_mem_read
        );

        check_value(
            "SECOND ADDRESS MISS",
            32'd1,
            l2_miss
        );

        load_enable = 1'b0;

        @(posedge clk);
        #1;

        @(posedge clk);
        #1;

        // ========================================================
        // TEST 6
        // ========================================================
        $display("");
        $display("----------------------------------------------");
        $display("TEST 6 : OFFSET ADDRESS CALCULATION");
        $display("----------------------------------------------");

        base_address = 32'h00000100;
        offset       = 32'h0000000C;

        load_enable = 1'b1;

        #1;

        check_value(
            "OFFSET EFFECTIVE ADDRESS",
            32'h0000010C,
            dut.lsu_mem_address
        );

        load_enable = 1'b0;

        @(posedge clk);
        #1;

        // ========================================================
        // TEST 7
        // ========================================================
        $display("");
        $display("----------------------------------------------");
        $display("TEST 7 : ALIGNMENT ERROR");
        $display("----------------------------------------------");

        base_address = 32'h00000002;
        offset       = 32'h00000000;

        load_enable = 1'b1;

        #1;

        check_value(
            "MISALIGNED LOAD",
            32'd1,
            alignment_error
        );

        load_enable = 1'b0;

        @(posedge clk);
        #1;

        // ========================================================
        // TEST 8
        // ========================================================
        $display("");
        $display("----------------------------------------------");
        $display("TEST 8 : INVALID SIMULTANEOUS REQUEST");
        $display("----------------------------------------------");

        base_address = 32'h00000040;
        offset       = 32'h00000000;
        store_data   = 32'h12345678;

        load_enable  = 1'b1;
        store_enable = 1'b1;

        #1;

        check_value(
            "SIMULTANEOUS READ BLOCKED",
            32'd0,
            dut.lsu_mem_read
        );

        check_value(
            "SIMULTANEOUS WRITE BLOCKED",
            32'd0,
            dut.lsu_mem_write
        );

        check_value(
            "SIMULTANEOUS REQUEST NOT READY",
            32'd0,
            ready
        );

        load_enable  = 1'b0;
        store_enable = 1'b0;

        @(posedge clk);
        #1;

        // ========================================================
        // TEST 9
        // ========================================================
        $display("");
        $display("----------------------------------------------");
        $display("TEST 9 : MEMORY CONTROLLER STATUS");
        $display("----------------------------------------------");

        check_value(
            "MEMORY CONTROLLER READY",
            32'd1,
            memory_ready
        );

        // ========================================================
        // TEST 10
        // ========================================================
        $display("");
        $display("----------------------------------------------");
        $display("TEST 10 : FINAL IDLE");
        $display("----------------------------------------------");

        #10;

        check_value(
            "FINAL READY",
            32'd0,
            ready
        );

        check_value(
            "FINAL BUSY",
            32'd0,
            busy
        );

        // ========================================================
        // FINAL RESULT
        // ========================================================
        $display("");
        $display("======================================================");
        $display("                     FINAL RESULT");
        $display("======================================================");

        $display("PASSED : %0d", passed);
        $display("FAILED : %0d", failed);

        $display("======================================================");

        if (failed == 0)
            $display("ALL MEMORY SUBSYSTEM INTEGRATION TESTS PASSED");
        else
            $display("MEMORY SUBSYSTEM INTEGRATION TESTS FAILED");

        $display("======================================================");

        $finish;

    end

endmodule