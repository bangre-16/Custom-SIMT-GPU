`timescale 1ns/1ps

module gpu_top #(
    parameter NUM_SMS = 4
)(
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instruction,

    output logic [31:0] pc [0:NUM_SMS-1],
    output logic [31:0] alu_result [0:NUM_SMS-1],
    output logic        zero [0:NUM_SMS-1],
    output logic [31:0] writeback_data [0:NUM_SMS-1],
    output logic        writeback_enable [0:NUM_SMS-1]
);

    // ============================================================
    // MULTI-SM GPU
    // ============================================================

    multi_sm_gpu #(
        .NUM_SMS(NUM_SMS)
    ) multi_sm_gpu_inst (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),

        .pc(pc),
        .alu_result(alu_result),
        .zero(zero),
        .writeback_data(writeback_data),
        .writeback_enable(writeback_enable)
    );

endmodule