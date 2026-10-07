`timescale 1ns/1ps

module multi_sm_gpu #(
    parameter NUM_SMS = 4
)(
    input  logic clk,
    input  logic reset,

    // Common instruction broadcast to all SMs
    input  logic [31:0] instruction,

    // Outputs from each SM
    output logic [31:0] pc [0:NUM_SMS-1],
    output logic [31:0] alu_result [0:NUM_SMS-1],
    output logic        zero [0:NUM_SMS-1],
    output logic [31:0] writeback_data [0:NUM_SMS-1],
    output logic        writeback_enable [0:NUM_SMS-1]
);

    // ============================================================
    // MULTI-SM GPU
    //
    // NUM_SMS independent GPU cores are instantiated.
    //
    // The same instruction is broadcast to every SM.
    // Each SM has its own:
    //   - Program Counter
    //   - Register File
    //   - ALU
    //   - Writeback path
    //
    // This demonstrates independent SM execution.
    // ============================================================

    genvar i;

    generate

        for (i = 0; i < NUM_SMS; i = i + 1) begin : SM

            gpu_core gpu_core_inst (

                .clk(clk),
                .reset(reset),

                .instruction(instruction),

                .pc(pc[i]),
                .alu_result(alu_result[i]),
                .zero(zero[i]),
                .writeback_data(writeback_data[i]),
                .writeback_enable(writeback_enable[i])

            );

        end

    endgenerate

endmodule