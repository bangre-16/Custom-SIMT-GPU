`timescale 1ns/1ps

module tb_instruction_memory;

    logic [31:0] pc;
    logic [31:0] instruction;

    integer pass_count;
    integer fail_count;


    // =========================================================
    // DUT
    // =========================================================

    instruction_memory dut (
        .pc(pc),
        .instruction(instruction)
    );


    // =========================================================
    // Check task
    // =========================================================

    task check_instruction(
        input logic [31:0] expected,
        input string test_name
    );

        begin

            #1;

            if (instruction === expected) begin

                $display(
                    "%-25s : PASS | Expected=%h Got=%h",
                    test_name,
                    expected,
                    instruction
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-25s : FAIL | Expected=%h Got=%h",
                    test_name,
                    expected,
                    instruction
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

        pc = 32'h00000000;

        $display("==============================================");
        $display("       CUSTOM GPU INSTRUCTION MEMORY TEST");
        $display("==============================================");


        // =====================================================
        // TEST 1 — Address 0x00
        // ADD
        // =====================================================

        pc = 32'h00000000;

        check_instruction(
            32'b000000_00001_00010_00011_00000000000,
            "IMEM ADDRESS 0x00"
        );


        // =====================================================
        // TEST 2 — Address 0x04
        // FADD
        // =====================================================

        pc = 32'h00000004;

        check_instruction(
            32'b000011_00100_00101_00110_00000000000,
            "IMEM ADDRESS 0x04"
        );


        // =====================================================
        // TEST 3 — Address 0x08
        // FFMA
        // =====================================================

        pc = 32'h00000008;

        check_instruction(
            32'b000110_00111_01000_01001_00000000000,
            "IMEM ADDRESS 0x08"
        );


        // =====================================================
        // TEST 4 — Address 0x0C
        // LD
        // =====================================================

        pc = 32'h0000000C;

        check_instruction(
            32'b001010_01010_01011_00000_00000010000,
            "IMEM ADDRESS 0x0C"
        );


        // =====================================================
        // TEST 5 — Address 0x10
        // ST
        // =====================================================

        pc = 32'h00000010;

        check_instruction(
            32'b001011_00000_01100_01101_00000100000,
            "IMEM ADDRESS 0x10"
        );


        // =====================================================
        // TEST 6 — Address 0x14
        // BEQ
        // =====================================================

        pc = 32'h00000014;

        check_instruction(
            32'b001100_00000_00001_00010_00000000000,
            "IMEM ADDRESS 0x14"
        );


        // =====================================================
        // TEST 7 — Address 0x18
        // NOP
        // =====================================================

        pc = 32'h00000018;

        check_instruction(
            32'b001111_00000_00000_00000_00000000000,
            "IMEM ADDRESS 0x18"
        );


        // =====================================================
        // TEST 8 — Unused address
        // Should return NOP
        // =====================================================

        pc = 32'h00000100;

        check_instruction(
            32'h3C000000,
            "UNUSED ADDRESS"
        );


        // =====================================================
        // TEST 9 — Later instruction
        // =====================================================

        pc = 32'h0000001C;

        check_instruction(
            32'h3C000000,
            "IMEM NOP ADDRESS"
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
            $display("ALL INSTRUCTION MEMORY TESTS PASSED");
        else
            $display("INSTRUCTION MEMORY TESTS FAILED");

        $display("==============================================");

        #10;

        $finish;

    end

endmodule