`timescale 1ns/1ps

module tb_instruction_decoder_integration;

    // =========================================================
    // Instruction
    // =========================================================

    logic [31:0] instruction;

    // =========================================================
    // Decoder outputs
    // =========================================================

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

    // =========================================================
    // Datapath signals
    // =========================================================

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] alu_result;
    logic        zero;

    // =========================================================
    // Test counters
    // =========================================================

    integer pass_count;
    integer fail_count;

    // =========================================================
    // INSTRUCTION DECODER
    // =========================================================

    instruction_decoder decoder (

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
    // TEST REGISTER FILE
    //
    // R1 = 10
    // R2 = 5
    // =========================================================

    always_comb begin

        case (rs1)

            5'd1:
                rs1_data = 32'd10;

            5'd2:
                rs1_data = 32'd5;

            default:
                rs1_data = 32'd0;

        endcase

        case (rs2)

            5'd1:
                rs2_data = 32'd10;

            5'd2:
                rs2_data = 32'd5;

            default:
                rs2_data = 32'd0;

        endcase

    end

    // =========================================================
    // SIMPLE EXECUTION DATAPATH
    // =========================================================

    always_comb begin

        if (alu_src_imm)

            alu_result =
                rs1_data +
                {{16{immediate[15]}}, immediate};

        else begin

            case (alu_op)

                // ADD
                4'b0000:
                    alu_result = rs1_data + rs2_data;

                // SUB
                4'b0001:
                    alu_result = rs1_data - rs2_data;

                // MUL
                4'b0010:
                    alu_result = rs1_data * rs2_data;

                // AND
                4'b0011:
                    alu_result = rs1_data & rs2_data;

                // OR
                4'b0100:
                    alu_result = rs1_data | rs2_data;

                // XOR
                4'b0101:
                    alu_result = rs1_data ^ rs2_data;

                default:
                    alu_result = 32'b0;

            endcase

        end

    end

    // =========================================================
    // ZERO FLAG
    // =========================================================

    assign zero = (alu_result == 32'b0);

    // =========================================================
    // CHECK RESULT TASK
    // =========================================================

    task check_result;

        input [31:0] expected;
        input [31:0] actual;
        input string test_name;

        begin

            if (actual === expected) begin

                $display(
                    "%-25s : PASS | Expected=%08h Got=%08h",
                    test_name,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-25s : FAIL | Expected=%08h Got=%08h",
                    test_name,
                    expected,
                    actual
                );

                fail_count = fail_count + 1;

            end

        end

    endtask

    // =========================================================
    // CHECK SIGNAL TASK
    // =========================================================

    task check_signal;

        input expected;
        input actual;
        input string test_name;

        begin

            if (actual === expected) begin

                $display(
                    "%-25s : PASS",
                    test_name
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
    // TEST SEQUENCE
    // =========================================================

    initial begin

        pass_count = 0;
        fail_count = 0;

        instruction = 32'b0;

        $display("");
        $display("==================================================");
        $display("      INSTRUCTION DECODER INTEGRATION TEST");
        $display("==================================================");
        $display("");

        // =====================================================
        // TEST 1 : ADD
        //
        // R1 = 10
        // R2 = 5
        // R3 = R1 + R2
        // Expected = 15
        // =====================================================

        instruction =
            32'b000000_00011_00001_00010_00000000000;

        #1;

        $display("ADD");

        check_result(
            32'h0000000F,
            alu_result,
            "ADD"
        );

        // =====================================================
        // TEST 2 : SUB
        //
        // R4 = R1 - R2
        // 10 - 5 = 5
        // =====================================================

        instruction =
            32'b000001_00100_00001_00010_00000000000;

        #1;

        $display("SUB");

        check_result(
            32'h00000005,
            alu_result,
            "SUB"
        );

        // =====================================================
        // TEST 3 : MUL
        //
        // R5 = R1 * R2
        // 10 * 5 = 50
        // =====================================================

        instruction =
            32'b000010_00101_00001_00010_00000000000;

        #1;

        $display("MUL");

        check_result(
            32'h00000032,
            alu_result,
            "MUL"
        );

        // =====================================================
        // TEST 4 : AND
        //
        // 10 & 5 = 0
        // =====================================================

        instruction =
            32'b000011_00110_00001_00010_00000000000;

        #1;

        $display("AND");

        check_result(
            32'h00000000,
            alu_result,
            "AND"
        );

        // =====================================================
        // TEST 5 : OR
        //
        // 10 | 5 = 15
        // =====================================================

        instruction =
            32'b000100_00111_00001_00010_00000000000;

        #1;

        $display("OR");

        check_result(
            32'h0000000F,
            alu_result,
            "OR"
        );

        // =====================================================
        // TEST 6 : XOR
        //
        // 10 ^ 5 = 15
        // =====================================================

        instruction =
            32'b000101_01000_00001_00010_00000000000;

        #1;

        $display("XOR");

        check_result(
            32'h0000000F,
            alu_result,
            "XOR"
        );

        // =====================================================
        // TEST 7 : ADDI
        //
        // IMPORTANT:
        // ADDI opcode = 000110
        //
        // R9 = R1 + 20
        //
        // 10 + 20 = 30
        // =====================================================

        instruction =
            32'b000110_01001_00001_00000_00000010100;

        #1;

        $display("ADDI");

        $display(
            "ADDI DEBUG : Opcode=%b RD=%0d RS1=%0d IMM=%0d IMM_HEX=%h ALUSRC=%b",
            opcode,
            rd,
            rs1,
            $signed(immediate),
            immediate,
            alu_src_imm
        );

        check_signal(
            1'b1,
            alu_src_imm,
            "ADDI DECODE"
        );

        check_result(
            32'h0000001E,
            alu_result,
            "ADDI"
        );

        // =====================================================
        // TEST 8 : ZERO FLAG
        //
        // 10 - 10 = 0
        // =====================================================

        instruction =
            32'b000001_01010_00001_00001_00000000000;

        #1;

        check_result(
            32'h00000000,
            alu_result,
            "ZERO RESULT"
        );

        check_signal(
            1'b1,
            zero,
            "ZERO FLAG"
        );

        // =====================================================
        // FINAL RESULT
        // =====================================================

        $display("");
        $display("--------------------------------------------------");

        $display(
            "PASSED : %0d",
            pass_count
        );

        $display(
            "FAILED : %0d",
            fail_count
        );

        $display("--------------------------------------------------");

        if (fail_count == 0) begin

            $display("ALL INSTRUCTION DECODER INTEGRATION TESTS PASSED");

        end
        else begin

            $display("INSTRUCTION DECODER INTEGRATION TESTS FAILED");

        end

        $display("==================================================");
        $display("");

        #10;

        $finish;

    end

endmodule