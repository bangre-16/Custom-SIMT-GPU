`timescale 1ns/1ps

module tb_gpu_core;

    logic        clk;
    logic        reset;
    logic [31:0] instruction;

    logic [31:0] pc;
    logic [31:0] alu_result;
    logic        zero;
    logic [31:0] writeback_data;
    logic        writeback_enable;

    integer passed;
    integer failed;

    // ============================================================
    // DUT
    // ============================================================

    gpu_core dut (
        .clk              (clk),
        .reset            (reset),
        .instruction      (instruction),
        .pc               (pc),
        .alu_result       (alu_result),
        .zero             (zero),
        .writeback_data   (writeback_data),
        .writeback_enable (writeback_enable)
    );

    // ============================================================
    // CLOCK
    // ============================================================

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end

    // ============================================================
    // INSTRUCTION ENCODERS
    // ============================================================

    function automatic [31:0] make_rtype(
        input [5:0] op,
        input [4:0] r1,
        input [4:0] r2,
        input [4:0] rd
    );

        begin
            make_rtype = {
                op,
                r1,
                r2,
                rd,
                11'd0
            };
        end

    endfunction


    function automatic [31:0] make_itype(
        input [5:0] op,
        input [4:0] r1,
        input [4:0] rd,
        input [15:0] imm
    );

        begin
            make_itype = {
                op,
                r1,
                5'd0,
                rd,
                imm[10:0]
            };

            // For this GPU core ADDI uses the complete
            // lower 16 bits as the immediate.
            make_itype[15:0] = imm;

        end

    endfunction

    // ============================================================
    // CHECK TASK
    // ============================================================

    task automatic check_result(
        input [127:0] test_name,
        input [31:0] expected
    );

        begin

            #1;

            if (alu_result === expected) begin

                $display(
                    "%-18s : PASS | Expected=%h Got=%h",
                    test_name,
                    expected,
                    alu_result
                );

                passed = passed + 1;

            end
            else begin

                $display(
                    "%-18s : FAIL | Expected=%h Got=%h",
                    test_name,
                    expected,
                    alu_result
                );

                failed = failed + 1;

            end

        end

    endtask

    // ============================================================
    // TEST SEQUENCE
    // ============================================================

    initial begin

        passed = 0;
        failed = 0;

        instruction = 32'd0;
        reset       = 1'b1;

        // Reset
        #12;

        reset = 1'b0;

        #3;

        $display("");
        $display("========================================");
        $display("        CUSTOM GPU CORE TEST");
        $display("========================================");

        // --------------------------------------------------------
        // ADD
        // R1 = 10
        // R2 = 5
        // R3 = R1 + R2 = 15
        // --------------------------------------------------------

        instruction = make_rtype(
            6'b000000,
            5'd1,
            5'd2,
            5'd3
        );

        check_result("ADD", 32'd15);

        @(posedge clk);
        #1;

        // --------------------------------------------------------
        // SUB
        // R1 - R2 = 5
        // --------------------------------------------------------

        instruction = make_rtype(
            6'b000001,
            5'd1,
            5'd2,
            5'd3
        );

        check_result("SUB", 32'd5);

        @(posedge clk);
        #1;

        // --------------------------------------------------------
        // MUL
        // 10 * 5 = 50
        // --------------------------------------------------------

        instruction = make_rtype(
            6'b000010,
            5'd1,
            5'd2,
            5'd3
        );

        check_result("MUL", 32'd50);

        @(posedge clk);
        #1;

        // --------------------------------------------------------
        // AND
        // 10 & 5 = 0
        // --------------------------------------------------------

        instruction = make_rtype(
            6'b000011,
            5'd1,
            5'd2,
            5'd3
        );

        check_result("AND", 32'd0);

        @(posedge clk);
        #1;

        // --------------------------------------------------------
        // OR
        // 10 | 5 = 15
        // --------------------------------------------------------

        instruction = make_rtype(
            6'b000100,
            5'd1,
            5'd2,
            5'd3
        );

        check_result("OR", 32'd15);

        @(posedge clk);
        #1;

        // --------------------------------------------------------
        // XOR
        // 10 ^ 5 = 15
        // --------------------------------------------------------

        instruction = make_rtype(
            6'b000101,
            5'd1,
            5'd2,
            5'd3
        );

        check_result("XOR", 32'd15);

        @(posedge clk);
        #1;

        // --------------------------------------------------------
        // ADD IMMEDIATE
        // R1 + 10 = 20
        // --------------------------------------------------------

        instruction = {
            6'b000110,
            5'd1,
            5'd0,
            5'd3,
            11'd0
        };

        // lower 16 bits = immediate 10
        instruction[15:0] = 16'd10;

        check_result("ADD_IMMEDIATE", 32'd20);

        @(posedge clk);
        #1;

        // --------------------------------------------------------
        // ZERO RESULT
        // 10 - 10 = 0
        // --------------------------------------------------------

        instruction = make_rtype(
            6'b000001,
            5'd1,
            5'd1,
            5'd3
        );

        check_result("ZERO_RESULT", 32'd0);

        #1;

        // --------------------------------------------------------
        // ZERO FLAG
        // --------------------------------------------------------

        if (zero === 1'b1) begin

            $display(
                "%-18s : PASS | Zero=%b",
                "ZERO_FLAG",
                zero
            );

            passed = passed + 1;

        end
        else begin

            $display(
                "%-18s : FAIL | Zero=%b",
                "ZERO_FLAG",
                zero
            );

            failed = failed + 1;

        end

        // ========================================================
        // SUMMARY
        // ========================================================

        $display("----------------------------------------");
        $display("PASSED : %0d", passed);
        $display("FAILED : %0d", failed);
        $display("----------------------------------------");

        if (failed == 0) begin

            $display("ALL GPU CORE TESTS PASSED");

        end
        else begin

            $display("GPU CORE TESTS FAILED");

        end

        $display("========================================");

        #10;

        $finish;

    end

endmodule