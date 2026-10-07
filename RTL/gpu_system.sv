`timescale 1ns/1ps

module gpu_system #(
    parameter NUM_SMS = 4
)(
    input  logic        clk,
    input  logic        reset,

    // =========================================================
    // HOST INTERFACE
    // =========================================================

    input  logic        host_valid,
    input  logic        host_write,
    input  logic [31:0] host_addr,
    input  logic [31:0] host_wdata,

    output logic [31:0] host_rdata,
    output logic        host_ready,

    // =========================================================
    // HOST -> DISPATCH STATUS
    // =========================================================

    output logic [31:0] command_data,
    output logic        command_valid,

    output logic        dispatch_busy,

    // =========================================================
    // DISPATCH -> SMs
    // =========================================================

    output logic [31:0] instruction [0:NUM_SMS-1],
    output logic        instruction_valid [0:NUM_SMS-1],

    // =========================================================
    // MULTI-SM GPU OUTPUTS
    // =========================================================

    output logic [31:0] pc [0:NUM_SMS-1],

    output logic [31:0] alu_result [0:NUM_SMS-1],

    output logic        zero [0:NUM_SMS-1],

    output logic [31:0] writeback_data [0:NUM_SMS-1],

    output logic        writeback_enable [0:NUM_SMS-1]
);

    // =========================================================
    // HOST INTERFACE
    // =========================================================

    host_interface host_interface_inst (

        .clk(clk),
        .reset(reset),

        .host_valid(host_valid),
        .host_write(host_write),
        .host_addr(host_addr),
        .host_wdata(host_wdata),

        .host_rdata(host_rdata),
        .host_ready(host_ready),

        .command_data(command_data),
        .command_valid(command_valid)

    );

    // =========================================================
    // COMMAND / DISPATCH UNIT
    // =========================================================

    command_dispatch #(
        .NUM_SMS(NUM_SMS)
    ) command_dispatch_inst (

        .clk(clk),
        .reset(reset),

        .command_data(command_data),
        .command_valid(command_valid),

        .instruction(instruction),
        .instruction_valid(instruction_valid),

        .busy(dispatch_busy)

    );

    // =========================================================
    // MULTI-SM GPU
    //
    // The command dispatch unit broadcasts the same instruction
    // to all SMs.
    //
    // multi_sm_gpu also broadcasts the common instruction to
    // every independent GPU core.
    // =========================================================

    multi_sm_gpu #(
        .NUM_SMS(NUM_SMS)
    ) multi_sm_gpu_inst (

        .clk(clk),
        .reset(reset),

        // All dispatched instructions are identical.
        // Use SM0 instruction as the common broadcast.
        .instruction(instruction[0]),

        .pc(pc),
        .alu_result(alu_result),
        .zero(zero),
        .writeback_data(writeback_data),
        .writeback_enable(writeback_enable)

    );

endmodule