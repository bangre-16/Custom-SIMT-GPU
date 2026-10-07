`timescale 1ns/1ps

module instruction_memory #(
    parameter ADDR_WIDTH = 10,
    parameter DATA_WIDTH = 32
)(
    input  logic [DATA_WIDTH-1:0] pc,
    output logic [DATA_WIDTH-1:0] instruction
);

    // 1024 bytes / 4 bytes per instruction = 256 instructions
    localparam integer DEPTH = 256;

    logic [DATA_WIDTH-1:0] memory [0:DEPTH-1];

    integer i;
    integer word_index;

    // =========================================================
    // Instruction memory initialization
    // =========================================================
    initial begin

        // Default all memory locations to NOP
        for (i = 0; i < DEPTH; i = i + 1) begin
            memory[i] = 32'h3C000000;
        end

        // -----------------------------------------------------
        // Test program
        // -----------------------------------------------------

        // Address 0x00
        // ADD r1, r2, r3
        memory[0] = 32'b000000_00001_00010_00011_00000000000;

        // Address 0x04
        // FADD r4, r5, r6
        memory[1] = 32'b000011_00100_00101_00110_00000000000;

        // Address 0x08
        // FFMA r7, r8, r9
        memory[2] = 32'b000110_00111_01000_01001_00000000000;

        // Address 0x0C
        // LD r10, r11, immediate 0x0010
        memory[3] = 32'b001010_01010_01011_00000_00000010000;

        // Address 0x10
        // ST r12, r13, immediate 0x0020
        memory[4] = 32'b001011_00000_01100_01101_00000100000;

        // Address 0x14
        // BEQ r1, r2
        memory[5] = 32'b001100_00000_00001_00010_00000000000;

        // Address 0x18
        // NOP
        memory[6] = 32'b001111_00000_00000_00000_00000000000;

    end


    // =========================================================
    // Combinational instruction read
    // =========================================================
    always_comb begin

        // Word-aligned instruction address
        word_index = pc >> 2;

        if (word_index < DEPTH)
            instruction = memory[word_index];
        else
            instruction = 32'h3C000000;   // NOP

    end

endmodule