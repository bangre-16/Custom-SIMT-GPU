`timescale 1ns/1ps

module tb_multi_sm_gpu;

    // ============================================================
    // PARAMETERS
    // ============================================================

    parameter NUM_SMS = 4;


    // ============================================================
    // CLOCK / RESET
    // ============================================================

    logic clk;
    logic reset;


    // ============================================================
    // COMMON INSTRUCTION
    // ============================================================

    logic [31:0] instruction;


    // ============================================================
    // MULTI-SM OUTPUTS
    // ============================================================

    logic [31:0] pc [0:NUM_SMS-1];

    logic [31:0] alu_result [0:NUM_SMS-1];

    logic zero [0:NUM_SMS-1];

    logic [31:0] writeback_data [0:NUM_SMS-1];

    logic writeback_enable [0:NUM_SMS-1];


    // ============================================================
    // TEST COUNTERS
    // ============================================================

    integer pass_count;
    integer fail_count;

    integer i;


    // ============================================================
    // DEVICE UNDER TEST
    // ============================================================

    multi_sm_gpu #(
        .NUM_SMS(NUM_SMS)
    ) dut (

        .clk(clk),
        .reset(reset),

        .instruction(instruction),

        .pc(pc),
        .alu_result(alu_result),
        .zero(zero),

        .writeback_data(writeback_data),
        .writeback_enable(writeback_enable)

    );


    // ============================================================
    // CLOCK
    // ============================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end


    // ============================================================
    // INSTRUCTION GENERATION
    // ============================================================

    function automatic [31:0] make_rtype;

        input [5:0] opcode_in;
        input [4:0] rs1_in;
        input [4:0] rs2_in;
        input [4:0] rd_in;

        begin

            make_rtype = {
                opcode_in,
                rs1_in,
                rs2_in,
                rd_in,
                11'b0
            };

        end

    endfunction


    function automatic [31:0] make_addi;

        input [5:0] opcode_in;
        input [4:0] rs1_in;
        input [15:0] imm_in;

        begin

            make_addi = {
                opcode_in,
                rs1_in,
                5'b00000,
                imm_in
            };

        end

    endfunction


    // ============================================================
    // CHECK 32-BIT RESULT
    // ============================================================

    task check_result;

        input [31:0] expected;
        input [31:0] actual;
        input string test_name;
        input integer sm_id;

        begin

            if (actual === expected) begin

                $display(
                    "%-25s : PASS | SM%0d | Expected=%08h Got=%08h",
                    test_name,
                    sm_id,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-25s : FAIL | SM%0d | Expected=%08h Got=%08h",
                    test_name,
                    sm_id,
                    expected,
                    actual
                );

                fail_count = fail_count + 1;

            end

        end

    endtask


    // ============================================================
    // CHECK 1-BIT SIGNAL
    // ============================================================

    task check_signal;

        input logic expected;
        input logic actual;
        input string test_name;
        input integer sm_id;

        begin

            if (actual === expected) begin

                $display(
                    "%-25s : PASS | SM%0d | Expected=%0d Got=%0d",
                    test_name,
                    sm_id,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-25s : FAIL | SM%0d | Expected=%0d Got=%0d",
                    test_name,
                    sm_id,
                    expected,
                    actual
                );

                fail_count = fail_count + 1;

            end

        end

    endtask


    // ============================================================
    // MAIN TEST
    // ============================================================

    initial begin

        pass_count = 0;
        fail_count = 0;

        instruction = 32'd0;

        reset = 1'b1;


        // ========================================================
        // HEADER
        // ========================================================

        $display("");

        $display("======================================================");

        $display("              CUSTOM GPU MULTI-SM TEST");

        $display("======================================================");

        $display("");


        // ========================================================
        // RESET
        // ========================================================

        #12;

        reset = 1'b0;

        #2;


        // ========================================================
        // TEST 1 : ALL SMs RESET
        //
        // Expected:
        // PC = 0
        // ========================================================

        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h00000000,
                pc[i],
                "RESET PC",
                i
            );

        end


        // ========================================================
        // TEST 2 : ADD
        //
        // R1 = 10
        // R2 = 5
        //
        // R3 = R1 + R2
        //
        // Expected = 15
        // ========================================================

        instruction = make_rtype(
            6'b000000,
            5'd1,
            5'd2,
            5'd3
        );

        #1;


        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h0000000F,
                alu_result[i],
                "ADD RESULT",
                i
            );

            check_result(
                32'h0000000F,
                writeback_data[i],
                "ADD WRITEBACK",
                i
            );

            check_signal(
                1'b1,
                writeback_enable[i],
                "ADD WRITE ENABLE",
                i
            );

            check_signal(
                1'b0,
                zero[i],
                "ADD ZERO",
                i
            );

        end


        // ========================================================
        // TEST 3 : CLOCK / PC UPDATE
        //
        // IMPORTANT:
        //
        // gpu_core updates PC on every positive clock edge.
        //
        // One positive edge occurred while leaving reset.
        // The explicit @(posedge clk) below causes another
        // positive edge.
        //
        // Therefore PC is:
        //
        // 0 -> 4 -> 8
        //
        // Expected PC = 8
        // ========================================================

        @(posedge clk);

        #1;


        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h00000008,
                pc[i],
                "PC AFTER ADD",
                i
            );

        end


        // ========================================================
        // TEST 4 : SUB
        //
        // R4 = R1 - R2
        //
        // 10 - 5 = 5
        // ========================================================

        instruction = make_rtype(
            6'b000001,
            5'd1,
            5'd2,
            5'd4
        );

        #1;


        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h00000005,
                alu_result[i],
                "SUB RESULT",
                i
            );

            check_result(
                32'h00000005,
                writeback_data[i],
                "SUB WRITEBACK",
                i
            );

            check_signal(
                1'b1,
                writeback_enable[i],
                "SUB WRITE ENABLE",
                i
            );

            check_signal(
                1'b0,
                zero[i],
                "SUB ZERO",
                i
            );

        end


        // ========================================================
        // TEST 5 : MUL
        //
        // 10 * 5 = 50
        // ========================================================

        instruction = make_rtype(
            6'b000010,
            5'd1,
            5'd2,
            5'd5
        );

        #1;


        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h00000032,
                alu_result[i],
                "MUL RESULT",
                i
            );

        end


        // ========================================================
        // TEST 6 : AND
        //
        // 10 & 5 = 0
        // ========================================================

        instruction = make_rtype(
            6'b000011,
            5'd1,
            5'd2,
            5'd6
        );

        #1;


        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h00000000,
                alu_result[i],
                "AND RESULT",
                i
            );

            check_signal(
                1'b1,
                zero[i],
                "AND ZERO FLAG",
                i
            );

        end


        // ========================================================
        // TEST 7 : OR
        //
        // 10 | 5 = 15
        // ========================================================

        instruction = make_rtype(
            6'b000100,
            5'd1,
            5'd2,
            5'd7
        );

        #1;


        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h0000000F,
                alu_result[i],
                "OR RESULT",
                i
            );

        end


        // ========================================================
        // TEST 8 : XOR
        //
        // 10 ^ 5 = 15
        // ========================================================

        instruction = make_rtype(
            6'b000101,
            5'd1,
            5'd2,
            5'd8
        );

        #1;


        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h0000000F,
                alu_result[i],
                "XOR RESULT",
                i
            );

        end


        // ========================================================
        // TEST 9 : ADDI
        //
        // R1 = 10
        // Immediate = 20
        //
        // 10 + 20 = 30
        // ========================================================

        instruction = make_addi(
            6'b000110,
            5'd1,
            16'd20
        );

        #1;


        $display("");

        $display(
            "ADDI DEBUG : Opcode=%06b RS1=%0d IMM=%0d IMM_HEX=%04h",
            instruction[31:26],
            instruction[25:21],
            instruction[15:0],
            instruction[15:0]
        );


        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h0000001E,
                alu_result[i],
                "ADDI RESULT",
                i
            );

            check_result(
                32'h0000001E,
                writeback_data[i],
                "ADDI WRITEBACK",
                i
            );

            check_signal(
                1'b1,
                writeback_enable[i],
                "ADDI WRITE ENABLE",
                i
            );

            check_signal(
                1'b0,
                zero[i],
                "ADDI ZERO",
                i
            );

        end


        // ========================================================
        // TEST 10 : MULTI-SM INDEPENDENCE
        //
        // Every SM receives the same instruction.
        // Every SM must independently produce 30.
        // ========================================================

        $display("");

        $display("----------------------------------------------");

        $display("MULTI-SM INDEPENDENCE CHECK");

        $display("----------------------------------------------");


        for (i = 0; i < NUM_SMS; i = i + 1) begin

            check_result(
                32'h0000001E,
                alu_result[i],
                "SM INDEPENDENCE",
                i
            );

        end


        // ========================================================
        // FINAL RESULT
        // ========================================================

        $display("");

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

            $display("ALL MULTI-SM GPU TESTS PASSED");

            $display("");

        end
        else begin

            $display("");

            $display("MULTI-SM GPU TESTS FAILED");

            $display("");

        end


        $display("======================================================");


        #10;

        $finish;

    end

endmodule