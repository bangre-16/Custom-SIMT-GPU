`timescale 1ns/1ps

module tb_final_gpu_system;

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
    // MULTI-SM GPU
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

    integer result_fd;

    // =========================================================
    // DUT
    // =========================================================

    full_gpu_system #(
        .NUM_SMS(NUM_SMS),
        .NUM_NODES(NUM_NODES)
    ) dut (

        .clk(clk),
        .reset(reset),

        // HOST
        .host_valid(host_valid),
        .host_write(host_write),
        .host_addr(host_addr),
        .host_wdata(host_wdata),

        .host_rdata(host_rdata),
        .host_ready(host_ready),

        // COMMAND / DISPATCH
        .command_data(command_data),
        .command_valid(command_valid),
        .dispatch_busy(dispatch_busy),

        .instruction(instruction),
        .instruction_valid(instruction_valid),

        // MULTI-SM
        .pc(pc),
        .alu_result(alu_result),
        .zero(zero),
        .writeback_data(writeback_data),
        .writeback_enable(writeback_enable),

        // MEMORY
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
    // R-TYPE INSTRUCTION CREATOR
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
                    "%-38s : PASS | Expected=%08h Got=%08h",
                    test_name,
                    expected,
                    actual
                );

                $fdisplay(
                    result_fd,
                    "%-38s : PASS | Expected=%08h Got=%08h",
                    test_name,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-38s : FAIL | Expected=%08h Got=%08h",
                    test_name,
                    expected,
                    actual
                );

                $fdisplay(
                    result_fd,
                    "%-38s : FAIL | Expected=%08h Got=%08h",
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
                    "%-38s : PASS | Expected=%0d Got=%0d",
                    test_name,
                    expected,
                    actual
                );

                $fdisplay(
                    result_fd,
                    "%-38s : PASS | Expected=%0d Got=%0d",
                    test_name,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-38s : FAIL | Expected=%0d Got=%0d",
                    test_name,
                    expected,
                    actual
                );

                $fdisplay(
                    result_fd,
                    "%-38s : FAIL | Expected=%0d Got=%0d",
                    test_name,
                    expected,
                    actual
                );

                fail_count = fail_count + 1;

            end

        end

    endtask

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

        // -----------------------------------------------------
        // Open final test result file
        // -----------------------------------------------------

        result_fd = $fopen(
            "C:/Users/User/Downloads/Custom-SIMT-GPU/Results/Simulation/final_gpu_system_test.txt",
            "w"
        );

        if (result_fd == 0) begin

            $display("ERROR: Could not open final test result file.");
            $finish;

        end

        // -----------------------------------------------------
        // Initial values
        // -----------------------------------------------------

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
        $display("           FINAL CUSTOM GPU REGRESSION TEST");
        $display("======================================================");
        $display("");

        $fdisplay(
            result_fd,
            "======================================================"
        );

        $fdisplay(
            result_fd,
            "           FINAL CUSTOM GPU REGRESSION TEST"
        );

        $fdisplay(
            result_fd,
            "======================================================"
        );

        // =====================================================
        // TEST 1 : RESET
        // =====================================================

        #12;

        reset = 1'b0;

        #2;

        $display("");
        $display("----------------------------------------------");
        $display("TEST 1 : COMPLETE SYSTEM RESET");
        $display("----------------------------------------------");

        check_signal(
            1'b1,
            host_ready,
            "HOST READY AFTER RESET"
        );

        check_result(
            32'h00000000,
            command_data,
            "COMMAND RESET"
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
        // TEST 2 : HOST -> DISPATCH
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 2 : HOST TO MULTI-SM DISPATCH");
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
            "HOST COMMAND REGISTER"
        );

        check_signal(
            1'b1,
            command_valid,
            "COMMAND VALID AFTER WRITE"
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
        // TEST 3 : ADD
        // 10 + 5 = 15
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 3 : ALL-SM ADD");
        $display("----------------------------------------------");

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h0000000F,
                alu_result[i],
                "SM ADD ALU RESULT"
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
        // TEST 4 : PC SYNCHRONIZATION
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 4 : PC SYNCHRONIZATION");
        $display("----------------------------------------------");

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
        // TEST 5 : SUB
        // 10 - 5 = 5
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 5 : ALL-SM SUB");
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
                "SM SUB RESULT"
            );

            check_result(
                32'h00000005,
                writeback_data[i],
                "SM SUB WRITEBACK"
            );

            check_signal(
                1'b1,
                writeback_enable[i],
                "SM SUB WRITE ENABLE"
            );

        end

        // =====================================================
        // TEST 6 : MUL
        // 10 * 5 = 50
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 6 : ALL-SM MUL");
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
                "SM MUL RESULT"
            );

            check_result(
                32'h00000032,
                writeback_data[i],
                "SM MUL WRITEBACK"
            );

        end

        // =====================================================
        // TEST 7 : AND
        // 10 & 5 = 0
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 7 : ALL-SM AND");
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
                "SM AND RESULT"
            );

            check_signal(
                1'b1,
                zero[i],
                "SM AND ZERO FLAG"
            );

        end

        // =====================================================
        // TEST 8 : OR
        // 10 | 5 = 15
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 8 : ALL-SM OR");
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
                "SM OR RESULT"
            );

        end

        // =====================================================
        // TEST 9 : XOR
        // 10 ^ 5 = 15
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 9 : ALL-SM XOR");
        $display("----------------------------------------------");

        host_write_command(
            make_rtype(
                6'b000101,
                5'd1,
                5'd2,
                5'd8
            )
        );

        @(posedge clk);

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h0000000F,
                alu_result[i],
                "SM XOR RESULT"
            );

        end

        // =====================================================
        // TEST 10 : ADDI
        //
        // Custom GPU immediate format overlaps:
        //     rd       = instruction[15:11]
        //     immediate = instruction[15:0]
        //
        // Therefore for an immediate value of 20,
        // rd must be zero.
        //
        // opcode = 000110
        // rs1    = R1
        // imm    = 20
        //
        // Correct instruction = 32'h18200014
        //
        // Expected:
        // 10 + 20 = 30
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 10 : ALL-SM ADDI");
        $display("----------------------------------------------");

        host_write_command(
            32'h18200014
        );

        @(posedge clk);

        #1;

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h0000001E,
                alu_result[i],
                "SM ADDI RESULT"
            );

        end

        // =====================================================
        // TEST 11 : MEMORY STORE MISS
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 11 : MEMORY STORE");
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
            "MEMORY CONTROLLER STORE BUSY"
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
        // TEST 12 : MEMORY LOAD MISS
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 12 : MEMORY LOAD MISS");
        $display("----------------------------------------------");

        @(negedge clk);

        load_enable  = 1'b1;
        store_enable = 1'b0;

        base_address = 32'h00000040;
        offset       = 32'h00000000;

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
            "MEMORY CONTROLLER LOAD BUSY"
        );

        @(negedge clk);

        load_enable = 1'b0;

        // =====================================================
        // TEST 13 : L2 CACHE HIT
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 13 : L2 CACHE HIT");
        $display("----------------------------------------------");

        @(negedge clk);

        load_enable = 1'b1;

        #1;

        check_signal(
            1'b1,
            l2_hit,
            "L2 HIT AFTER FILL"
        );

        check_signal(
            1'b0,
            l2_miss,
            "L2 MISS AFTER FILL"
        );

        check_result(
            32'hA5A5A5A5,
            load_data,
            "L2 HIT DATA"
        );

        @(negedge clk);

        load_enable = 1'b0;

        // =====================================================
        // TEST 14 : L2 WRITE HIT
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 14 : L2 WRITE HIT");
        $display("----------------------------------------------");

        @(negedge clk);

        store_enable = 1'b1;
        store_data   = 32'h5A5A5A5A;

        #1;

        check_signal(
            1'b1,
            l2_hit,
            "L2 STORE HIT"
        );

        check_signal(
            1'b0,
            l2_miss,
            "L2 STORE MISS ON HIT"
        );

        check_signal(
            1'b1,
            l2_ready,
            "L2 WRITE HIT READY"
        );

        @(posedge clk);

        #1;

        check_signal(
            1'b1,
            memory_busy,
            "MEMORY BUSY WRITE HIT"
        );

        @(negedge clk);

        store_enable = 1'b0;

        // =====================================================
        // TEST 15 : LOAD UPDATED CACHE DATA
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 15 : READ UPDATED CACHE DATA");
        $display("----------------------------------------------");

        @(negedge clk);

        load_enable = 1'b1;

        #1;

        check_signal(
            1'b1,
            l2_hit,
            "UPDATED DATA CACHE HIT"
        );

        check_result(
            32'h5A5A5A5A,
            load_data,
            "UPDATED CACHE DATA"
        );

        @(negedge clk);

        load_enable = 1'b0;

        // =====================================================
        // TEST 16 : UNALIGNED ADDRESS
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 16 : UNALIGNED MEMORY ACCESS");
        $display("----------------------------------------------");

        @(negedge clk);

        base_address = 32'h00000042;
        offset       = 32'h00000000;

        load_enable  = 1'b1;
        store_enable = 1'b0;

        #1;

        check_signal(
            1'b1,
            alignment_error,
            "UNALIGNED ADDRESS DETECTION"
        );

        @(negedge clk);

        load_enable = 1'b0;

        // =====================================================
        // TEST 17 : SIMULTANEOUS LOAD + STORE
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 17 : INVALID LOAD + STORE");
        $display("----------------------------------------------");

        @(negedge clk);

        load_enable  = 1'b1;
        store_enable = 1'b1;

        #1;

        check_signal(
            1'b0,
            memory_ready_lsu,
            "SIMULTANEOUS ACCESS NOT READY"
        );

        check_signal(
            1'b0,
            l2_ready,
            "L2 REJECTS SIMULTANEOUS ACCESS"
        );

        @(negedge clk);

        load_enable  = 1'b0;
        store_enable = 1'b0;

        // =====================================================
        // TEST 18 : NoC PACKET 1
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 18 : NoC PACKET ROUTING 1");
        $display("----------------------------------------------");

        @(negedge clk);

        in_valid[0] = 1'b1;
        in_dest[0]  = 2'd2;
        in_data[0]  = 32'h12345678;

        #1;

        check_signal(
            1'b1,
            out_valid[2],
            "NoC DEST 2 VALID"
        );

        check_result(
            32'h12345678,
            out_data[2],
            "NoC PACKET 1 DATA"
        );

        check_signal(
            1'b1,
            in_ready[0],
            "NoC INPUT 0 READY"
        );

        @(posedge clk);

        #1;

        check_result(
            32'h00000001,
            packet_count,
            "NoC PACKET COUNT 1"
        );

        @(negedge clk);

        in_valid = '0;

        // =====================================================
        // TEST 19 : NoC PACKET 2
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 19 : NoC PACKET ROUTING 2");
        $display("----------------------------------------------");

        @(negedge clk);

        in_valid[1] = 1'b1;
        in_dest[1]  = 2'd3;
        in_data[1]  = 32'hCAFEBABE;

        #1;

        check_signal(
            1'b1,
            out_valid[3],
            "NoC DEST 3 VALID"
        );

        check_result(
            32'hCAFEBABE,
            out_data[3],
            "NoC PACKET 2 DATA"
        );

        check_signal(
            1'b1,
            in_ready[1],
            "NoC INPUT 1 READY"
        );

        @(posedge clk);

        #1;

        check_result(
            32'h00000002,
            packet_count,
            "NoC PACKET COUNT 2"
        );

        @(negedge clk);

        in_valid = '0;

        // =====================================================
        // TEST 20 : NoC COLLISION
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 20 : NoC DESTINATION COLLISION");
        $display("----------------------------------------------");

        @(negedge clk);

        in_valid[0] = 1'b1;
        in_valid[1] = 1'b1;

        in_dest[0] = 2'd2;
        in_dest[1] = 2'd2;

        in_data[0] = 32'h11111111;
        in_data[1] = 32'h22222222;

        #1;

        check_signal(
            1'b1,
            out_valid[2],
            "NoC COLLISION OUTPUT VALID"
        );

        check_result(
            32'h11111111,
            out_data[2],
            "NoC FIRST PACKET WINS"
        );

        check_signal(
            1'b1,
            in_ready[0],
            "NoC FIRST INPUT ACCEPTED"
        );

        check_signal(
            1'b0,
            in_ready[1],
            "NoC SECOND INPUT BLOCKED"
        );

        @(posedge clk);

        #1;

        check_result(
            32'h00000003,
            packet_count,
            "NoC PACKET COUNT COLLISION"
        );

        @(negedge clk);

        in_valid = '0;

        // =====================================================
        // TEST 21 : HOST READBACK
        //
        // Last host command = ADDI
        // Correct value = 32'h18200014
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 21 : HOST READBACK");
        $display("----------------------------------------------");

        @(negedge clk);

        host_valid = 1'b1;
        host_write = 1'b0;
        host_addr  = 32'h00000000;

        #1;

        check_result(
            32'h18200014,
            host_rdata,
            "HOST COMMAND READBACK"
        );

        // =====================================================
        // TEST 22 : INVALID HOST ACCESS
        // =====================================================

        $display("");
        $display("----------------------------------------------");
        $display("TEST 22 : INVALID HOST ACCESS");
        $display("----------------------------------------------");

        @(negedge clk);

        host_addr = 32'h00000010;

        #1;

        check_result(
            32'h00000000,
            host_rdata,
            "INVALID HOST READ"
        );

        @(negedge clk);

        host_valid = 1'b0;
        host_write = 1'b0;

        // =====================================================
        // FINAL RESULT
        // =====================================================

        $display("");
        $display("======================================================");
        $display("                   FINAL RESULT");
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

        $fdisplay(
            result_fd,
            ""
        );

        $fdisplay(
            result_fd,
            "======================================================"
        );

        $fdisplay(
            result_fd,
            "                   FINAL RESULT"
        );

        $fdisplay(
            result_fd,
            "======================================================"
        );

        $fdisplay(
            result_fd,
            "PASSED : %0d",
            pass_count
        );

        $fdisplay(
            result_fd,
            "FAILED : %0d",
            fail_count
        );

        $fdisplay(
            result_fd,
            "======================================================"
        );

        if (fail_count == 0) begin

            $display("");
            $display("ALL FINAL GPU SYSTEM REGRESSION TESTS PASSED");
            $display("");

            $fdisplay(
                result_fd,
                "ALL FINAL GPU SYSTEM REGRESSION TESTS PASSED"
            );

        end
        else begin

            $display("");
            $display("FINAL GPU SYSTEM REGRESSION TESTS FAILED");
            $display("");

            $fdisplay(
                result_fd,
                "FINAL GPU SYSTEM REGRESSION TESTS FAILED"
            );

        end

        $display("======================================================");

        $fdisplay(
            result_fd,
            "======================================================"
        );

        $fclose(result_fd);

        #10;

        $finish;

    end

endmodule