`timescale 1ns/1ps

module tb_instruction_decoder;

    logic [31:0] instruction;

    logic [5:0]  opcode;
    logic [4:0]  rd;
    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [15:0] immediate;

    logic        reg_write;
    logic        mem_read;
    logic        mem_write;
    logic        branch;
    logic        fp_enable;
    logic        alu_src_imm;

    logic [3:0]  alu_op;
    logic [2:0]  fp_op;

    integer pass_count;
    integer fail_count;


    // =========================================================
    // DUT
    // =========================================================

    instruction_decoder dut (

        .instruction(instruction),

        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .immediate(immediate),

        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .fp_enable(fp_enable),
        .alu_src_imm(alu_src_imm),

        .alu_op(alu_op),
        .fp_op(fp_op)

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
                    "%-20s : PASS | Expected=%b Got=%b",
                    test_name,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-20s : FAIL | Expected=%b Got=%b",
                    test_name,
                    expected,
                    actual
                );

                fail_count = fail_count + 1;

            end

        end

    endtask


    // =========================================================
    // Check 5-bit signal
    // =========================================================

    task check_5bit(
        input logic [4:0] expected,
        input logic [4:0] actual,
        input string test_name
    );

        begin

            if (actual === expected) begin

                $display(
                    "%-20s : PASS | Expected=%0d Got=%0d",
                    test_name,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-20s : FAIL | Expected=%0d Got=%0d",
                    test_name,
                    expected,
                    actual
                );

                fail_count = fail_count + 1;

            end

        end

    endtask


    // =========================================================
    // Check 6-bit opcode
    // =========================================================

    task check_opcode(
        input logic [5:0] expected,
        input logic [5:0] actual,
        input string test_name
    );

        begin

            if (actual === expected) begin

                $display(
                    "%-20s : PASS | Opcode=%b",
                    test_name,
                    actual
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-20s : FAIL | Expected=%b Got=%b",
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

        instruction = 32'b0;

        $display("==============================================");
        $display("       CUSTOM GPU INSTRUCTION DECODER TEST");
        $display("==============================================");


        // =====================================================
        // TEST 1 — ADD
        //
        // opcode = 000000
        // rd = 1
        // rs1 = 2
        // rs2 = 3
        // =====================================================

        instruction = 32'b000000_00001_00010_00011_00000000000;

        #1;

        check_opcode(
            6'b000000,
            opcode,
            "ADD OPCODE"
        );

        check_5bit(
            5'd1,
            rd,
            "ADD RD"
        );

        check_5bit(
            5'd2,
            rs1,
            "ADD RS1"
        );

        check_5bit(
            5'd3,
            rs2,
            "ADD RS2"
        );

        check_signal(
            1'b1,
            reg_write,
            "ADD REG_WRITE"
        );

        check_signal(
            1'b0,
            fp_enable,
            "ADD FP_ENABLE"
        );


        // =====================================================
        // TEST 2 — FADD
        // =====================================================

        instruction = 32'b000011_00100_00101_00110_00000000000;

        #1;

        check_opcode(
            6'b000011,
            opcode,
            "FADD OPCODE"
        );

        check_5bit(
            5'd4,
            rd,
            "FADD RD"
        );

        check_5bit(
            5'd5,
            rs1,
            "FADD RS1"
        );

        check_5bit(
            5'd6,
            rs2,
            "FADD RS2"
        );

        check_signal(
            1'b1,
            reg_write,
            "FADD REG_WRITE"
        );

        check_signal(
            1'b1,
            fp_enable,
            "FADD FP_ENABLE"
        );


        // =====================================================
        // TEST 3 — FFMA
        // =====================================================

        instruction = 32'b000110_00111_01000_01001_00000000000;

        #1;

        check_opcode(
            6'b000110,
            opcode,
            "FFMA OPCODE"
        );

        check_5bit(
            5'd7,
            rd,
            "FFMA RD"
        );

        check_5bit(
            5'd8,
            rs1,
            "FFMA RS1"
        );

        check_5bit(
            5'd9,
            rs2,
            "FFMA RS2"
        );

        check_signal(
            1'b1,
            reg_write,
            "FFMA REG_WRITE"
        );

        check_signal(
            1'b1,
            fp_enable,
            "FFMA FP_ENABLE"
        );


        // =====================================================
        // TEST 4 — LOAD
        // =====================================================

        instruction = 32'b001010_01010_01011_00000_00000010101;

        #1;

        check_opcode(
            6'b001010,
            opcode,
            "LD OPCODE"
        );

        check_5bit(
            5'd10,
            rd,
            "LD RD"
        );

        check_5bit(
            5'd11,
            rs1,
            "LD RS1"
        );

        check_signal(
            1'b1,
            reg_write,
            "LD REG_WRITE"
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
            alu_src_imm,
            "LD IMM_SELECT"
        );


        // =====================================================
        // TEST 5 — STORE
        // =====================================================

        instruction = 32'b001011_00000_01100_01101_00000000100;

        #1;

        check_opcode(
            6'b001011,
            opcode,
            "ST OPCODE"
        );

        check_5bit(
            5'd12,
            rs1,
            "ST RS1"
        );

        check_5bit(
            5'd13,
            rs2,
            "ST RS2"
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
        // TEST 6 — BEQ
        // =====================================================

        instruction = 32'b001100_00000_00001_00010_00000000000;

        #1;

        check_opcode(
            6'b001100,
            opcode,
            "BEQ OPCODE"
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
        // TEST 7 — NOP
        // =====================================================

        instruction = 32'b001111_00000_00000_00000_00000000000;

        #1;

        check_opcode(
            6'b001111,
            opcode,
            "NOP OPCODE"
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
            $display("ALL INSTRUCTION DECODER TESTS PASSED");
        else
            $display("INSTRUCTION DECODER TESTS FAILED");

        $display("==============================================");

        #10;

        $finish;

    end

endmodule