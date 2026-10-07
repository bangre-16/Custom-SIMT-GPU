`timescale 1ns/1ps

module tb_gpu_system;

    parameter NUM_SMS = 4;

    // =========================================================
    // CLOCK / RESET
    // =========================================================

    logic clk;
    logic reset;

    // =========================================================
    // HOST INTERFACE
    // =========================================================

    logic        host_valid;
    logic        host_write;
    logic [31:0] host_addr;
    logic [31:0] host_wdata;

    logic [31:0] host_rdata;
    logic        host_ready;

    // =========================================================
    // HOST -> DISPATCH
    // =========================================================

    logic [31:0] command_data;
    logic        command_valid;

    logic        dispatch_busy;

    // =========================================================
    // DISPATCH -> SMs
    // =========================================================

    logic [31:0] instruction [0:NUM_SMS-1];
    logic        instruction_valid [0:NUM_SMS-1];

    // =========================================================
    // MULTI-SM OUTPUTS
    // =========================================================

    logic [31:0] pc [0:NUM_SMS-1];
    logic [31:0] alu_result [0:NUM_SMS-1];
    logic        zero [0:NUM_SMS-1];
    logic [31:0] writeback_data [0:NUM_SMS-1];
    logic        writeback_enable [0:NUM_SMS-1];

    // =========================================================
    // TEST COUNTERS
    // =========================================================

    integer pass_count;
    integer fail_count;
    integer i;

    // =========================================================
    // DUT
    // =========================================================

    gpu_system #(
        .NUM_SMS(NUM_SMS)
    ) dut (

        .clk(clk),
        .reset(reset),

        .host_valid(host_valid),
        .host_write(host_write),
        .host_addr(host_addr),
        .host_wdata(host_wdata),

        .host_rdata(host_rdata),
        .host_ready(host_ready),

        .command_data(command_data),
        .command_valid(command_valid),

        .dispatch_busy(dispatch_busy),

        .instruction(instruction),
        .instruction_valid(instruction_valid),

        .pc(pc),
        .alu_result(alu_result),
        .zero(zero),
        .writeback_data(writeback_data),
        .writeback_enable(writeback_enable)

    );

    // =========================================================
    // CLOCK
    // =========================================================

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end

    // =========================================================
    // R-TYPE INSTRUCTION
    //
    // [31:26] OPCODE
    // [25:21] RS1
    // [20:16] RS2
    // [15:11] RD
    //
    // GPU core initializes:
    // R1 = 10
    // R2 = 5
    // =========================================================

    function automatic [31:0] make_rtype;

        input [5:0] opcode;
        input [4:0] rs1;
        input [4:0] rs2;
        input [4:0] rd;

        begin

            make_rtype = {
                opcode,
                rs1,
                rs2,
                rd,
                11'b0
            };

        end

    endfunction

    // =========================================================
    // 32-BIT CHECK
    // =========================================================

    task check_result;

        input [31:0] expected;
        input [31:0] actual;
        input string test_name;

        begin

            if (actual === expected) begin

                $display(
                    "%-32s : PASS | Expected=%08h Got=%08h",
                    test_name,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-32s : FAIL | Expected=%08h Got=%08h",
                    test_name,
                    expected,
                    actual
                );

                fail_count = fail_count + 1;

            end

        end

    endtask

    // =========================================================
    // 1-BIT CHECK
    // =========================================================

    task check_signal;

        input logic expected;
        input logic actual;
        input string test_name;

        begin

            if (actual === expected) begin

                $display(
                    "%-32s : PASS | Expected=%0d Got=%0d",
                    test_name,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-32s : FAIL | Expected=%0d Got=%0d",
                    test_name,
                    expected,
                    actual
                );

                fail_count = fail_count + 1;

            end

        end

    endtask

    // =========================================================
    // HOST WRITE TASK
    // =========================================================

    task host_write_command;

        input [31:0] data;

        begin

            @(negedge clk);

            host_valid = 1'b1;
            host_write = 1'b1;
            host_addr  = 32'h00000000;
            host_wdata = data;

            @(posedge clk);

            #1;

            host_valid = 1'b0;
            host_write = 1'b0;

        end

    endtask

    // =========================================================
    // MAIN TEST
    // =========================================================

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
        $display("        CUSTOM GPU SYSTEM INTEGRATION TEST");
        $display("======================================================");
        $display("");

        // =====================================================
        // TEST 1 : RESET
        // =====================================================

        #12;

        reset = 1'b0;

        #2;

        $display("");
        $display("----------------------------------------------");
        $display("TEST 1 : SYSTEM RESET");
        $display("----------------------------------------------");

        check_signal(
            1'b1,
            host_ready,
            "HOST READY AFTER RESET"
        );

        check_result(
            32'h00000000,
            command_data,
            "COMMAND DATA RESET"
        );

        check_signal(
            1'b0,
            command_valid,
            "COMMAND VALID RESET"
        );

        check_signal(
            1'b0,
            dispatch_busy,
            "DISPATCH BUSY RESET"
        );

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h00000000,
                pc[i],
                "RESET PC"
            );

            check_signal(
                1'b0,
                instruction_valid[i],
                "RESET INSTRUCTION VALID"
            );

        end

        // =====================================================
        // TEST 2 : HOST COMMAND WRITE
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 2 : HOST COMMAND WRITE");
        $display("----------------------------------------------");

        host_write_command(
            make_rtype(
                6'b000000,
                5'd1,
                5'd2,
                5'd3
            )
        );

        #1;

        check_result(
            make_rtype(
                6'b000000,
                5'd1,
                5'd2,
                5'd3
            ),
            command_data,
            "HOST COMMAND REGISTER"
        );

        // command_valid is expected to remain asserted
        // for the dispatch cycle.

        check_signal(
            1'b1,
            command_valid,
            "COMMAND VALID AFTER WRITE"
        );

        // =====================================================
        // TEST 3 : COMMAND DISPATCH
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 3 : COMMAND DISPATCH");
        $display("----------------------------------------------");

        @(posedge clk);

        #1;

        // The command is currently being processed by
        // the dispatch unit.

        check_signal(
            1'b1,
            dispatch_busy,
            "DISPATCH BUSY AFTER DISPATCH"
        );

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                make_rtype(
                    6'b000000,
                    5'd1,
                    5'd2,
                    5'd3
                ),
                instruction[i],
                "DISPATCHED INSTRUCTION"
            );

        end

        // =====================================================
        // TEST 4 : ADD EXECUTION
        //
        // R1 = 10
        // R2 = 5
        // R3 = 15
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 4 : ADD THROUGH COMPLETE CONTROL PATH");
        $display("----------------------------------------------");

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h0000000F,
                alu_result[i],
                "ADD ALU RESULT"
            );

            check_result(
                32'h0000000F,
                writeback_data[i],
                "ADD WRITEBACK"
            );

            check_signal(
                1'b1,
                writeback_enable[i],
                "ADD WRITE ENABLE"
            );

            check_signal(
                1'b0,
                zero[i],
                "ADD ZERO FLAG"
            );

        end

        // =====================================================
        // TEST 5 : MULTI-SM PC SYNCHRONIZATION
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 5 : MULTI-SM PC SYNCHRONIZATION");
        $display("----------------------------------------------");

        @(posedge clk);

        #1;

        // One additional instruction cycle has occurred,
        // therefore PC has advanced to 0x10.

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h00000010,
                pc[i],
                "SM PC SYNCHRONIZATION"
            );

        end

        // =====================================================
        // TEST 6 : SUB COMMAND
        //
        // 10 - 5 = 5
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 6 : SUB COMMAND");
        $display("----------------------------------------------");

        host_write_command(
            make_rtype(
                6'b000001,
                5'd1,
                5'd2,
                5'd4
            )
        );

        @(posedge clk);

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h00000005,
                alu_result[i],
                "SUB ALU RESULT"
            );

            check_result(
                32'h00000005,
                writeback_data[i],
                "SUB WRITEBACK"
            );

            check_signal(
                1'b1,
                writeback_enable[i],
                "SUB WRITE ENABLE"
            );

        end

        // =====================================================
        // TEST 7 : MUL COMMAND
        //
        // 10 * 5 = 50
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 7 : MUL COMMAND");
        $display("----------------------------------------------");

        host_write_command(
            make_rtype(
                6'b000010,
                5'd1,
                5'd2,
                5'd5
            )
        );

        @(posedge clk);

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h00000032,
                alu_result[i],
                "MUL ALU RESULT"
            );

            check_result(
                32'h00000032,
                writeback_data[i],
                "MUL WRITEBACK"
            );

        end

        // =====================================================
        // TEST 8 : AND COMMAND
        //
        // 10 & 5 = 0
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 8 : AND COMMAND");
        $display("----------------------------------------------");

        host_write_command(
            make_rtype(
                6'b000011,
                5'd1,
                5'd2,
                5'd6
            )
        );

        @(posedge clk);

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h00000000,
                alu_result[i],
                "AND ALU RESULT"
            );

            check_signal(
                1'b1,
                zero[i],
                "AND ZERO FLAG"
            );

        end

        // =====================================================
        // TEST 9 : OR COMMAND
        //
        // 10 | 5 = 15
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 9 : OR COMMAND");
        $display("----------------------------------------------");

        host_write_command(
            make_rtype(
                6'b000100,
                5'd1,
                5'd2,
                5'd7
            )
        );

        @(posedge clk);

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h0000000F,
                alu_result[i],
                "OR ALU RESULT"
            );

        end

        // =====================================================
        // TEST 10 : HOST COMMAND READBACK
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 10 : HOST COMMAND READBACK");
        $display("----------------------------------------------");

        @(negedge clk);

        host_valid = 1'b1;
        host_write = 1'b0;
        host_addr  = 32'h00000000;

        #1;

        check_result(
            make_rtype(
                6'b000100,
                5'd1,
                5'd2,
                5'd7
            ),
            host_rdata,
            "HOST COMMAND READBACK"
        );

        @(negedge clk);

        host_valid = 1'b0;

        // =====================================================
        // TEST 11 : INVALID HOST ADDRESS
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 11 : INVALID HOST ADDRESS");
        $display("----------------------------------------------");

        @(negedge clk);

        host_valid = 1'b1;
        host_write = 1'b0;
        host_addr  = 32'h00000010;

        #1;

        check_result(
            32'h00000000,
            host_rdata,
            "INVALID HOST READ"
        );

        @(negedge clk);

        host_valid = 1'b0;

        // =====================================================
        // FINAL RESULT
        // =====================================================

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
            $display("ALL GPU SYSTEM INTEGRATION TESTS PASSED");
            $display("");

        end
        else begin

            $display("");
            $display("GPU SYSTEM INTEGRATION TESTS FAILED");
            $display("");

        end

        $display("======================================================");

        #10;

        $finish;

    end

endmodule