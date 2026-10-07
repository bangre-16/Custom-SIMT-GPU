`timescale 1ns/1ps

module tb_full_gpu_system;

    parameter NUM_SMS   = 4;
    parameter NUM_NODES = 4;

    // =========================================================
    // CLOCK / RESET
    // =========================================================

    logic clk;
    logic reset;

    // =========================================================
    // HOST
    // =========================================================

    logic        host_valid;
    logic        host_write;
    logic [31:0] host_addr;
    logic [31:0] host_wdata;

    logic [31:0] host_rdata;
    logic        host_ready;

    // =========================================================
    // COMMAND / DISPATCH
    // =========================================================

    logic [31:0] command_data;
    logic        command_valid;
    logic        dispatch_busy;

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
    // MEMORY SUBSYSTEM
    // =========================================================

    logic        load_enable;
    logic        store_enable;

    logic [31:0] base_address;
    logic [31:0] offset;
    logic [31:0] store_data;

    logic [31:0] load_data;

    logic        memory_ready;
    logic        memory_busy;

    logic        memory_ready_lsu;
    logic        memory_busy_lsu;

    logic        alignment_error;

    logic        l2_hit;
    logic        l2_miss;
    logic        l2_ready;

    // =========================================================
    // NoC
    // =========================================================

    logic [NUM_NODES-1:0] in_valid;

    logic [NUM_NODES-1:0][1:0] in_dest;

    logic [NUM_NODES-1:0][31:0] in_data;

    logic [NUM_NODES-1:0] out_valid;

    logic [NUM_NODES-1:0][31:0] out_data;

    logic [NUM_NODES-1:0] in_ready;

    logic [31:0] packet_count;

    // =========================================================
    // TEST COUNTERS
    // =========================================================

    integer pass_count;
    integer fail_count;
    integer i;

    // =========================================================
    // DUT
    // =========================================================

    full_gpu_system #(
        .NUM_SMS(NUM_SMS),
        .NUM_NODES(NUM_NODES)
    ) dut (

        .clk(clk),
        .reset(reset),

        // Host
        .host_valid(host_valid),
        .host_write(host_write),
        .host_addr(host_addr),
        .host_wdata(host_wdata),

        .host_rdata(host_rdata),
        .host_ready(host_ready),

        // Command / Dispatch
        .command_data(command_data),
        .command_valid(command_valid),
        .dispatch_busy(dispatch_busy),

        .instruction(instruction),
        .instruction_valid(instruction_valid),

        // Multi-SM
        .pc(pc),
        .alu_result(alu_result),
        .zero(zero),
        .writeback_data(writeback_data),
        .writeback_enable(writeback_enable),

        // Memory
        .load_enable(load_enable),
        .store_enable(store_enable),
        .base_address(base_address),
        .offset(offset),
        .store_data(store_data),

        .load_data(load_data),

        .memory_ready(memory_ready),
        .memory_busy(memory_busy),

        .memory_ready_lsu(memory_ready_lsu),
        .memory_busy_lsu(memory_busy_lsu),

        .alignment_error(alignment_error),

        .l2_hit(l2_hit),
        .l2_miss(l2_miss),
        .l2_ready(l2_ready),

        // NoC
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
    // CHECK 32-BIT
    // =========================================================

    task check_result;

        input [31:0] expected;
        input [31:0] actual;
        input string test_name;

        begin

            if (actual === expected) begin

                $display(
                    "%-35s : PASS | Expected=%08h Got=%08h",
                    test_name,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-35s : FAIL | Expected=%08h Got=%08h",
                    test_name,
                    expected,
                    actual
                );

                fail_count = fail_count + 1;

            end

        end

    endtask

    // =========================================================
    // CHECK 1-BIT
    // =========================================================

    task check_signal;

        input logic expected;
        input logic actual;
        input string test_name;

        begin

            if (actual === expected) begin

                $display(
                    "%-35s : PASS | Expected=%0d Got=%0d",
                    test_name,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-35s : FAIL | Expected=%0d Got=%0d",
                    test_name,
                    expected,
                    actual
                );

                fail_count = fail_count + 1;

            end

        end

    endtask

    // =========================================================
    // R-TYPE INSTRUCTION
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
    // HOST WRITE
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

        load_enable  = 1'b0;
        store_enable = 1'b0;

        base_address = 32'h00000000;
        offset       = 32'h00000000;
        store_data   = 32'h00000000;

        in_valid = '0;
        in_dest  = '0;
        in_data  = '0;

        reset = 1'b1;

        // =====================================================
        // HEADER
        // =====================================================

        $display("");
        $display("======================================================");
        $display("          FULL CUSTOM GPU SYSTEM TEST");
        $display("======================================================");
        $display("");

        // =====================================================
        // RESET
        // =====================================================

        #12;

        reset = 1'b0;

        #2;

        $display("");
        $display("----------------------------------------------");
        $display("TEST 1 : FULL SYSTEM RESET");
        $display("----------------------------------------------");

        check_signal(
            1'b1,
            host_ready,
            "HOST READY"
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

        check_signal(
            1'b1,
            memory_ready,
            "MEMORY READY RESET"
        );

        check_signal(
            1'b0,
            memory_busy,
            "MEMORY BUSY RESET"
        );

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h00000000,
                pc[i],
                "SM PC RESET"
            );

            check_signal(
                1'b0,
                instruction_valid[i],
                "SM INSTRUCTION VALID RESET"
            );

        end

        // =====================================================
        // HOST → DISPATCH → ALL SMS
        // ADD
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 2 : HOST TO MULTI-SM DATA PATH");
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
            32'h00221800,
            command_data,
            "HOST COMMAND"
        );

        check_signal(
            1'b1,
            command_valid,
            "COMMAND VALID"
        );

        @(posedge clk);

        #1;

        check_signal(
            1'b1,
            dispatch_busy,
            "DISPATCH BUSY"
        );

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h00221800,
                instruction[i],
                "INSTRUCTION BROADCAST"
            );

        end

        // =====================================================
        // ADD EXECUTION
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 3 : MULTI-SM ADD EXECUTION");
        $display("----------------------------------------------");

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h0000000F,
                alu_result[i],
                "SM ADD RESULT"
            );

            check_result(
                32'h0000000F,
                writeback_data[i],
                "SM ADD WRITEBACK"
            );

            check_signal(
                1'b1,
                writeback_enable[i],
                "SM ADD WRITE ENABLE"
            );

            check_signal(
                1'b0,
                zero[i],
                "SM ADD ZERO"
            );

        end

        // =====================================================
        // PC SYNCHRONIZATION
        // =====================================================

        @(posedge clk);

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h00000010,
                pc[i],
                "SM PC SYNCHRONIZATION"
            );

        end

        // =====================================================
        // MEMORY STORE
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 4 : MEMORY STORE PATH");
        $display("----------------------------------------------");

        @(negedge clk);

        base_address = 32'h00000040;
        offset       = 32'h00000000;
        store_data   = 32'hA5A5A5A5;

        load_enable  = 1'b0;
        store_enable = 1'b1;

        #1;

        check_signal(
            1'b1,
            memory_ready_lsu,
            "LSU STORE READY"
        );

        check_signal(
            1'b1,
            l2_ready,
            "L2 STORE READY"
        );

        check_signal(
            1'b1,
            l2_miss,
            "L2 STORE MISS"
        );

        @(posedge clk);

        #1;

        check_signal(
            1'b1,
            memory_busy,
            "MEMORY CONTROLLER BUSY STORE"
        );

        @(negedge clk);

        store_enable = 1'b0;

        @(posedge clk);

        #1;

        check_signal(
            1'b1,
            memory_ready,
            "MEMORY READY AFTER STORE"
        );

        // =====================================================
        // MEMORY LOAD
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 5 : MEMORY LOAD PATH");
        $display("----------------------------------------------");

        @(negedge clk);

        base_address = 32'h00000040;
        offset       = 32'h00000000;

        load_enable  = 1'b1;
        store_enable = 1'b0;

        #1;

        check_signal(
            1'b1,
            memory_ready_lsu,
            "LSU LOAD READY"
        );

        check_signal(
            1'b1,
            l2_miss,
            "L2 LOAD MISS"
        );

        @(posedge clk);

        #1;

        check_result(
            32'hA5A5A5A5,
            load_data,
            "MEMORY LOAD DATA"
        );

        check_signal(
            1'b1,
            memory_busy,
            "MEMORY CONTROLLER BUSY LOAD"
        );

        @(negedge clk);

        load_enable = 1'b0;

        @(posedge clk);

        #1;

        // =====================================================
        // SECOND LOAD = CACHE HIT
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 6 : L2 CACHE HIT");
        $display("----------------------------------------------");

        @(negedge clk);

        load_enable  = 1'b1;
        store_enable = 1'b0;

        #1;

        check_signal(
            1'b1,
            l2_hit,
            "L2 CACHE HIT"
        );

        check_signal(
            1'b0,
            l2_miss,
            "L2 CACHE MISS AFTER FILL"
        );

        check_result(
            32'hA5A5A5A5,
            load_data,
            "L2 CACHE DATA"
        );

        @(negedge clk);

        load_enable = 1'b0;

        // =====================================================
        // NoC TEST
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 7 : NoC PACKET ROUTING");
        $display("----------------------------------------------");

        @(negedge clk);

        in_valid[0] = 1'b1;
        in_dest[0]  = 2'd2;
        in_data[0]  = 32'h12345678;

        #1;

        check_signal(
            1'b1,
            out_valid[2],
            "NoC DESTINATION VALID"
        );

        check_result(
            32'h12345678,
            out_data[2],
            "NoC ROUTED DATA"
        );

        check_signal(
            1'b1,
            in_ready[0],
            "NoC INPUT READY"
        );

        @(posedge clk);

        #1;

        check_result(
            32'h00000001,
            packet_count,
            "NoC PACKET COUNT"
        );

        @(negedge clk);

        in_valid = '0;

        // =====================================================
        // NoC SECOND PACKET
        // =====================================================

        @(negedge clk);

        in_valid[1] = 1'b1;
        in_dest[1]  = 2'd3;
        in_data[1]  = 32'hCAFEBABE;

        #1;

        check_signal(
            1'b1,
            out_valid[3],
            "NoC SECOND DESTINATION"
        );

        check_result(
            32'hCAFEBABE,
            out_data[3],
            "NoC SECOND DATA"
        );

        @(posedge clk);

        #1;

        check_result(
            32'h00000002,
            packet_count,
            "NoC PACKET COUNT SECOND"
        );

        @(negedge clk);

        in_valid = '0;

        // =====================================================
        // HOST READBACK
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 8 : HOST READBACK");
        $display("----------------------------------------------");

        @(negedge clk);

        host_valid = 1'b1;
        host_write = 1'b0;
        host_addr  = 32'h00000000;

        #1;

        check_result(
            32'h00221800,
            host_rdata,
            "HOST COMMAND READBACK"
        );

        @(negedge clk);

        host_valid = 1'b0;

        // =====================================================
        // INVALID HOST ADDRESS
        // =====================================================

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
        $display("                  FINAL RESULT");
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
            $display("ALL FULL GPU SYSTEM INTEGRATION TESTS PASSED");
            $display("");

        end
        else begin

            $display("");
            $display("FULL GPU SYSTEM INTEGRATION TESTS FAILED");
            $display("");

        end

        $display("======================================================");

        #10;

        $finish;

    end

endmodule