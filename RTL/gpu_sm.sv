`timescale 1ns/1ps

module gpu_sm (

    input  logic        clk,
    input  logic        reset,

    // Instruction supplied to the SM
    input  logic [31:0] instruction,

    // SM outputs
    output logic [31:0] pc,
    output logic [31:0] alu_result,
    output logic        zero,
    output logic [31:0] writeback_data,
    output logic        writeback_enable

);

    // ============================================================
    // INTEGRATED GPU CORE
    //
    // The GPU Core has already been independently verified.
    // Here we integrate that verified core as the execution engine
    // of the first SM.
    // ============================================================

    gpu_core core_inst (

        .clk              (clk),
        .reset            (reset),
        .instruction      (instruction),

        .pc               (pc),
        .alu_result       (alu_result),
        .zero             (zero),
        .writeback_data   (writeback_data),
        .writeback_enable (writeback_enable)

    );

endmodule