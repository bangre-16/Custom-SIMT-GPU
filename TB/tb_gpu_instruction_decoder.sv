`timescale 1ns/1ps

module tb_instruction_decoder;

    logic [31:0] instruction;

    logic [5:0] opcode;
    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [15:0] immediate;

    logic reg_write;
    logic mem_read;
    logic mem_write;
    logic branch;
    logic fp_enable;
    logic alu_src_imm;

    logic [3:0] alu_op;
    logic [2:0] fp_op;

    integer passed;
    integer failed;


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
    // CHECK TASK
    // =========================================================

    task automatic check_test;

        input [5:0]  exp_opcode;
        input [4:0]  exp_rd;
        input [4:0]  exp_rs1;
        input [4:0]  exp_rs2;
        input [15:0] exp_imm;
        input        exp_reg_write;
        input        exp_mem_read;
        input        exp_mem_write;
        input        exp_branch;
        input        exp_fp_enable;
        input        exp_alu_src_imm;

        input string test_name;

        begin

            #1;

            if (
                opcode       === exp_opcode &&
                rd           === exp_rd &&
                rs1          === exp_rs1 &&
                rs2          === exp_rs2 &&
                immediate    === exp_imm &&
                reg_write    === exp_reg_write &&
                mem_read     === exp_mem_read &&
                mem_write    === exp_mem_write &&
                branch       === exp_branch &&
                fp_enable    === exp_fp_enable &&
                alu_src_imm  === exp_alu_src_imm
            ) begin

                $display(
                    "%-18s : PASS | OP=%0d RD=%0d RS1=%0d RS2=%0d IMM=%h",
                    test_name,
                    opcode,
                    rd,
                    rs1,
                    rs2,
                    immediate
                );

                passed = passed + 1;

            end
            else begin

                $display(
                    "%-18s : FAIL | Expected OP=%0d RD=%0d RS1=%0d RS2=%0d IMM=%h | Got OP=%0d RD=%0d RS1=%0d RS2=%0d IMM=%h",
                    test_name,
                    exp_opcode,
                    exp_rd,
                    exp_rs1,
                    exp_rs2,
                    exp_imm,
                    opcode,
                    rd,
                    rs1,
                    rs2,
                    immediate
                );

                failed = failed + 1;

            end

        end

    endtask


    // =========================================================
    // TESTS
    // =========================================================

    initial begin

        passed = 0;
        failed = 0;

        instruction = 32'b0;

        $display("");
        $display("==============================================");
        $display("       CUSTOM GPU INSTRUCTION DECODER TEST");
        $display("==============================================");


        // -----------------------------------------------------
        // ADD
        // opcode = 0
        // rd = 3
        // rs1 = 1
        // rs2 = 2
        // -----------------------------------------------------

        instruction =
            32'b000000_00011_00001_00010_00000000000;

        check_test(
            6'd0,
            5'd3,
            5'd1,
            5'd2,
            16'h0000,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            "ADD_DECODE"
        );


        // -----------------------------------------------------
        // SUB
        // -----------------------------------------------------

        instruction =
            32'b000001_00100_00001_00010_00000000000;

        check_test(
            6'd1,
            5'd4,
            5'd1,
            5'd2,
            16'h0000,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            "SUB_DECODE"
        );


        // -----------------------------------------------------
        // MUL
        // -----------------------------------------------------

        instruction =
            32'b000010_00101_00001_00010_00000000000;

        check_test(
            6'd2,
            5'd5,
            5'd1,
            5'd2,
            16'h0000,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            "MUL_DECODE"
        );


        // -----------------------------------------------------
        // AND
        // -----------------------------------------------------

        instruction =
            32'b000011_00110_00001_00010_00000000000;

        check_test(
            6'd3,
            5'd6,
            5'd1,
            5'd2,
            16'h0000,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            "AND_DECODE"
        );


        // -----------------------------------------------------
        // OR
        // -----------------------------------------------------

        instruction =
            32'b000100_00111_00001_00010_00000000000;

        check_test(
            6'd4,
            5'd7,
            5'd1,
            5'd2,
            16'h0000,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            "OR_DECODE"
        );


        // -----------------------------------------------------
        // XOR
        // -----------------------------------------------------

        instruction =
            32'b000101_01000_00001_00010_00000000000;

        check_test(
            6'd5,
            5'd8,
            5'd1,
            5'd2,
            16'h0000,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            "XOR_DECODE"
        );


        // -----------------------------------------------------
        // ADD IMMEDIATE
        //
        // rd  = 10
        // rs1 = 1
        // imm = 20
        // -----------------------------------------------------

        instruction =
            32'b000110_01010_00001_0000000000010100;

        check_test(
            6'd6,
            5'd10,
            5'd1,
            5'd0,
            16'h0014,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            "ADDI_DECODE"
        );


        // -----------------------------------------------------
        // NEGATIVE IMMEDIATE
        //
        // rd  = 10
        // rs1 = 1
        // imm = -5 = FFFB
        // -----------------------------------------------------

        instruction =
            32'b000110_01010_00001_1111111111111011;

        check_test(
            6'd6,
            5'd10,
            5'd1,
            5'd0,
            16'hFFFB,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            "NEG_IMMEDIATE"
        );


        // -----------------------------------------------------
        // FADD
        // -----------------------------------------------------

        instruction =
            32'b000111_00100_00101_00110_00000000000;

        check_test(
            6'd7,
            5'd4,
            5'd5,
            5'd6,
            16'h0000,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            "FADD_DECODE"
        );


        // -----------------------------------------------------
        // LOAD
        // -----------------------------------------------------

        instruction =
            32'b001011_01010_01011_0000000000010101;

        check_test(
            6'd11,
            5'd10,
            5'd11,
            5'd0,
            16'h0015,
            1'b1,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            "LD_DECODE"
        );


        // -----------------------------------------------------
        // STORE
        // -----------------------------------------------------

        instruction =
            32'b001100_00000_01100_01101_00000000100;

        check_test(
            6'd12,
            5'd0,
            5'd12,
            5'd13,
            16'h0084,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            1'b1,
            "ST_DECODE"
        );


        // -----------------------------------------------------
        // BEQ
        // -----------------------------------------------------

        instruction =
            32'b001101_00000_00001_00010_00000000000;

        check_test(
            6'd13,
            5'd0,
            5'd1,
            5'd2,
            16'h0000,
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            "BEQ_DECODE"
        );


        // -----------------------------------------------------
        // NOP
        // -----------------------------------------------------

        instruction =
            32'b010000_00000_00000_00000_00000000000;

        check_test(
            6'd16,
            5'd0,
            5'd0,
            5'd0,
            16'h0000,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            "NOP_DECODE"
        );


        // =====================================================
        // FINAL RESULT
        // =====================================================

        $display("----------------------------------------------");
        $display("PASSED : %0d", passed);
        $display("FAILED : %0d", failed);
        $display("----------------------------------------------");

        if (failed == 0)
            $display("ALL INSTRUCTION DECODER TESTS PASSED");
        else
            $display("INSTRUCTION DECODER TESTS FAILED");

        $display("==============================================");

        #10;

        $finish;

    end

endmodule