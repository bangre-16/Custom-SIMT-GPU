`timescale 1ns/1ps

module tb_noc;

    parameter NUM_NODES  = 4;
    parameter DATA_WIDTH = 32;
    parameter DEST_WIDTH = 2;

    // =========================================================
    // DUT SIGNALS
    // =========================================================

    logic clk;
    logic reset;

    logic [NUM_NODES-1:0] in_valid;
    logic [NUM_NODES-1:0][DEST_WIDTH-1:0] in_dest;
    logic [NUM_NODES-1:0][DATA_WIDTH-1:0] in_data;

    logic [NUM_NODES-1:0] out_valid;
    logic [NUM_NODES-1:0][DATA_WIDTH-1:0] out_data;

    logic [NUM_NODES-1:0] in_ready;

    logic [31:0] packet_count;

    integer passed;
    integer failed;

    // =========================================================
    // DUT
    // =========================================================

    noc #(
        .NUM_NODES(NUM_NODES),
        .DATA_WIDTH(DATA_WIDTH),
        .DEST_WIDTH(DEST_WIDTH)
    ) dut (
        .clk(clk),
        .reset(reset),

        .in_valid(in_valid),
        .in_dest(in_dest),
        .in_data(in_data),

        .out_valid(out_valid),
        .out_data(out_data),

        .in_ready(in_ready),

        .packet_count(packet_count)
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

    task check_output;

        input integer output_port;
        input logic [DATA_WIDTH-1:0] expected_data;
        input logic expected_valid;
        input [8*80-1:0] test_name;

        begin

            if ((out_valid[output_port] == expected_valid) &&
                (!expected_valid ||
                 (out_data[output_port] == expected_data))) begin

                $display("%-28s : PASS", test_name);
                passed = passed + 1;

            end
            else begin

                $display(
                    "%-28s : FAIL | Expected Valid=%0d Data=%h | Got Valid=%0d Data=%h",
                    test_name,
                    expected_valid,
                    expected_data,
                    out_valid[output_port],
                    out_data[output_port]
                );

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

        reset    = 1'b1;
        in_valid = '0;
        in_dest  = '0;
        in_data  = '0;

        #12;

        reset = 1'b0;

        #3;

        $display("");
        $display("==================================================");
        $display("             CUSTOM GPU NoC TEST");
        $display("==================================================");

        // =====================================================
        // TEST 1 : IDLE
        // =====================================================

        #2;

        check_output(
            0,
            32'h00000000,
            1'b0,
            "IDLE OUTPUT 0"
        );

        // =====================================================
        // TEST 2 : NODE 0 -> NODE 1
        // =====================================================

        in_valid[0] = 1'b1;
        in_dest[0]  = 2'd1;
        in_data[0]  = 32'h12345678;

        #2;

        check_output(
            1,
            32'h12345678,
            1'b1,
            "NODE0 TO NODE1"
        );

        in_valid[0] = 1'b0;

        #2;

        // =====================================================
        // TEST 3 : NODE 1 -> NODE 2
        // =====================================================

        in_valid[1] = 1'b1;
        in_dest[1]  = 2'd2;
        in_data[1]  = 32'hAABBCCDD;

        #2;

        check_output(
            2,
            32'hAABBCCDD,
            1'b1,
            "NODE1 TO NODE2"
        );

        in_valid[1] = 1'b0;

        #2;

        // =====================================================
        // TEST 4 : NODE 2 -> NODE 3
        // =====================================================

        in_valid[2] = 1'b1;
        in_dest[2]  = 2'd3;
        in_data[2]  = 32'hDEADBEEF;

        #2;

        check_output(
            3,
            32'hDEADBEEF,
            1'b1,
            "NODE2 TO NODE3"
        );

        in_valid[2] = 1'b0;

        #2;

        // =====================================================
        // TEST 5 : NODE 3 -> NODE 0
        // =====================================================

        in_valid[3] = 1'b1;
        in_dest[3]  = 2'd0;
        in_data[3]  = 32'hCAFEBABE;

        #2;

        check_output(
            0,
            32'hCAFEBABE,
            1'b1,
            "NODE3 TO NODE0"
        );

        in_valid[3] = 1'b0;

        #2;

        // =====================================================
        // TEST 6 : ALL FOUR NODES ACTIVE
        // =====================================================

        in_valid = 4'b1111;

        in_dest[0] = 2'd0;
        in_dest[1] = 2'd1;
        in_dest[2] = 2'd2;
        in_dest[3] = 2'd3;

        in_data[0] = 32'h00000010;
        in_data[1] = 32'h00000020;
        in_data[2] = 32'h00000030;
        in_data[3] = 32'h00000040;

        #2;

        check_output(
            0,
            32'h00000010,
            1'b1,
            "ALL NODES OUTPUT0"
        );

        check_output(
            1,
            32'h00000020,
            1'b1,
            "ALL NODES OUTPUT1"
        );

        check_output(
            2,
            32'h00000030,
            1'b1,
            "ALL NODES OUTPUT2"
        );

        check_output(
            3,
            32'h00000040,
            1'b1,
            "ALL NODES OUTPUT3"
        );

        in_valid = 4'b0000;

        #2;

        // =====================================================
        // TEST 7 : DIFFERENT DATA PATTERNS
        // =====================================================

        in_valid[0] = 1'b1;
        in_dest[0]  = 2'd3;
        in_data[0]  = 32'hFFFFFFFF;

        #2;

        check_output(
            3,
            32'hFFFFFFFF,
            1'b1,
            "ALL ONES PACKET"
        );

        in_valid[0] = 1'b0;

        #2;

        // =====================================================
        // TEST 8 : ZERO DATA
        // =====================================================

        in_valid[2] = 1'b1;
        in_dest[2]  = 2'd1;
        in_data[2]  = 32'h00000000;

        #2;

        check_output(
            1,
            32'h00000000,
            1'b1,
            "ZERO DATA PACKET"
        );

        in_valid[2] = 1'b0;

        #2;

        // =====================================================
        // FINAL RESULT
        // =====================================================

        $display("");
        $display("--------------------------------------------------");
        $display("PASSED : %0d", passed);
        $display("FAILED : %0d", failed);
        $display("--------------------------------------------------");

        if (failed == 0) begin

            $display("ALL NoC TESTS PASSED");

        end
        else begin

            $display("NoC TESTS FAILED");

        end

        $display("==================================================");

        #10;

        $finish;

    end

endmodule