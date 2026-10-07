`timescale 1ns/1ps

module tb_gpu_control_unit;

    logic [5:0] opcode;

    logic [1:0] execution_unit;

    logic [3:0] alu_select;
    logic [2:0] fp_select;

    logic reg_write;
    logic mem_read;
    logic mem_write;
    logic branch;
    logic use_immediate;

    integer pass_count;
    integer fail_count;


    // =========================================================
    // DUT
    // =========================================================

    gpu_control_unit dut (

        .opcode(opcode),

        .execution_unit(execution_unit),

        .alu_select(alu_select),
        .fp_select(fp_select),

        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .use_immediate(use_immediate)

    );


    // =========================================================
    // Check task
    // =========================================================

    task check_signal(
        input logic expected,
        input logic actual,
        input string test_name
    );

        begin

            if (actual === expected) begin

                $display(
                    "%-25s : PASS | Expected=%b Got=%b",
                    test_name,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-25s : FAIL | Expected=%b Got=%b",
                    test_name,
                    expected,
                    actual
                );

                fail_count = fail_count + 1;

            end

        end

    endtask


    // =========================================================
    // Check 2-bit signal
    // =========================================================

    task check_2bit(
        input logic [1:0] expected,
        input logic [1:0] actual,
        input string test_name
    );

        begin

            if (actual === expected) begin

                $display(
                    "%-25s : PASS | Expected=%b Got=%b",
                    test_name,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-25s : FAIL | Expected=%b Got=%b",
                    test_name,
                    expected,
                    actual
                );

                fail_count = fail_count + 1;

            end

        end

    endtask


    // =========================================================
    // Check 4-bit ALU control
    // =========================================================

    task check_4bit(
        input logic [3:0] expected,
        input logic [3:0] actual,
        input string test_name
    );

        begin

            if (actual === expected) begin

                $display(
                    "%-25s : PASS | Expected=%b Got=%b",
                    test_name,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-25s : FAIL | Expected=%b Got=%b",
                    test_name,
                    expected,
                    actual
                );

                fail_count = fail_count + 1;

            end

        end

    endtask


    // =========================================================
    // Check 3-bit FP control
    // =========================================================

    task check_3bit(
        input logic [2:0] expected,
        input logic [2:0] actual,
        input string test_name
    );

        begin

            if (actual === expected) begin

                $display(
                    "%-25s : PASS | Expected=%b Got=%b",
                    test_name,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-25s : FAIL | Expected=%b Got=%b",
                    test_name,
                    expected,
                    actual
                );

                fail_count = fail_count + 1;

            end

        end

    endtask


    // =========================================================
    // Test sequence
    // =========================================================

    initial begin

        pass_count = 0;
        fail_count = 0;

        opcode = 6'b111111;

        $display("==============================================");
        $display("         CUSTOM GPU CONTROL UNIT TEST");
        $display("==============================================");


        // =====================================================
        // TEST 1 — ADD
        // =====================================================

        opcode = 6'b000000;

        #1;

        check_2bit(
            2'b01,
            execution_unit,
            "ADD EXECUTION UNIT"
        );

        check_4bit(
            4'b0000,
            alu_select,
            "ADD ALU SELECT"
        );

        check_signal(
            1'b1,
            reg_write,
            "ADD REG_WRITE"
        );


        // =====================================================
        // TEST 2 — SUB
        // =====================================================

        opcode = 6'b000001;

        #1;

        check_2bit(
            2'b01,
            execution_unit,
            "SUB EXECUTION UNIT"
        );

        check_4bit(
            4'b0001,
            alu_select,
            "SUB ALU SELECT"
        );


        // =====================================================
        // TEST 3 — MUL
        // =====================================================

        opcode = 6'b000010;

        #1;

        check_2bit(
            2'b01,
            execution_unit,
            "MUL EXECUTION UNIT"
        );

        check_4bit(
            4'b0010,
            alu_select,
            "MUL ALU SELECT"
        );


        // =====================================================
        // TEST 4 — FADD
        // =====================================================

        opcode = 6'b000011;

        #1;

        check_2bit(
            2'b10,
            execution_unit,
            "FADD EXECUTION UNIT"
        );

        check_3bit(
            3'b000,
            fp_select,
            "FADD FP SELECT"
        );

        check_signal(
            1'b1,
            reg_write,
            "FADD REG_WRITE"
        );


        // =====================================================
        // TEST 5 — FFMA
        // =====================================================

        opcode = 6'b000110;

        #1;

        check_2bit(
            2'b10,
            execution_unit,
            "FFMA EXECUTION UNIT"
        );

        check_3bit(
            3'b011,
            fp_select,
            "FFMA FP SELECT"
        );


        // =====================================================
        // TEST 6 — LOAD
        // =====================================================

        opcode = 6'b001010;

        #1;

        check_2bit(
            2'b11,
            execution_unit,
            "LD EXECUTION UNIT"
        );

        check_signal(
            1'b1,
            mem_read,
            "LD MEM_READ"
        );

        check_signal(
            1'b0,
            mem_write,
            "LD MEM_WRITE"
        );

        check_signal(
            1'b1,
            reg_write,
            "LD REG_WRITE"
        );

        check_signal(
            1'b1,
            use_immediate,
            "LD IMMEDIATE"
        );


        // =====================================================
        // TEST 7 — STORE
        // =====================================================

        opcode = 6'b001011;

        #1;

        check_2bit(
            2'b11,
            execution_unit,
            "ST EXECUTION UNIT"
        );

        check_signal(
            1'b0,
            reg_write,
            "ST REG_WRITE"
        );

        check_signal(
            1'b0,
            mem_read,
            "ST MEM_READ"
        );

        check_signal(
            1'b1,
            mem_write,
            "ST MEM_WRITE"
        );


        // =====================================================
        // TEST 8 — BEQ
        // =====================================================

        opcode = 6'b001100;

        #1;

        check_2bit(
            2'b01,
            execution_unit,
            "BEQ EXECUTION UNIT"
        );

        check_signal(
            1'b1,
            branch,
            "BEQ BRANCH"
        );

        check_signal(
            1'b0,
            reg_write,
            "BEQ REG_WRITE"
        );


        // =====================================================
        // TEST 9 — BNE
        // =====================================================

        opcode = 6'b001101;

        #1;

        check_signal(
            1'b1,
            branch,
            "BNE BRANCH"
        );


        // =====================================================
        // TEST 10 — MOV
        // =====================================================

        opcode = 6'b001110;

        #1;

        check_2bit(
            2'b01,
            execution_unit,
            "MOV EXECUTION UNIT"
        );

        check_signal(
            1'b1,
            reg_write,
            "MOV REG_WRITE"
        );

        check_signal(
            1'b1,
            use_immediate,
            "MOV IMMEDIATE"
        );


        // =====================================================
        // TEST 11 — NOP
        // =====================================================

        opcode = 6'b001111;

        #1;

        check_2bit(
            2'b00,
            execution_unit,
            "NOP EXECUTION UNIT"
        );

        check_signal(
            1'b0,
            reg_write,
            "NOP REG_WRITE"
        );

        check_signal(
            1'b0,
            mem_read,
            "NOP MEM_READ"
        );

        check_signal(
            1'b0,
            mem_write,
            "NOP MEM_WRITE"
        );

        check_signal(
            1'b0,
            branch,
            "NOP BRANCH"
        );


        // =====================================================
        // TEST 12 — UNKNOWN OPCODE
        // =====================================================

        opcode = 6'b111111;

        #1;

        check_2bit(
            2'b00,
            execution_unit,
            "UNKNOWN EXECUTION UNIT"
        );

        check_signal(
            1'b0,
            reg_write,
            "UNKNOWN REG_WRITE"
        );

        check_signal(
            1'b0,
            mem_read,
            "UNKNOWN MEM_READ"
        );

        check_signal(
            1'b0,
            mem_write,
            "UNKNOWN MEM_WRITE"
        );


        // =====================================================
        // FINAL RESULT
        // =====================================================

        $display("----------------------------------------------");

        $display(
            "PASSED : %0d",
            pass_count
        );

        $display(
            "FAILED : %0d",
            fail_count
        );

        $display("----------------------------------------------");

        if (fail_count == 0)
            $display("ALL GPU CONTROL UNIT TESTS PASSED");
        else
            $display("GPU CONTROL UNIT TESTS FAILED");

        $display("==============================================");

        #10;

        $finish;

    end

endmodule