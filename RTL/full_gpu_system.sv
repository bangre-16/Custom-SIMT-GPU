`timescale 1ns/1ps

module full_gpu_system #(
    parameter NUM_SMS   = 4,
    parameter NUM_NODES = 4
)(
    // =========================================================
    // CLOCK / RESET
    // =========================================================

    input logic clk,
    input logic reset,

    // =========================================================
    // HOST INTERFACE
    // =========================================================

    input logic        host_valid,
    input logic        host_write,
    input logic [31:0] host_addr,
    input logic [31:0] host_wdata,

    output logic [31:0] host_rdata,
    output logic        host_ready,

    // =========================================================
    // GPU COMMAND / DISPATCH
    // =========================================================

    output logic [31:0] command_data,
    output logic        command_valid,
    output logic        dispatch_busy,

    output logic [31:0] instruction [0:NUM_SMS-1],
    output logic        instruction_valid [0:NUM_SMS-1],

    // =========================================================
    // MULTI-SM GPU OUTPUTS
    // =========================================================

    output logic [31:0] pc [0:NUM_SMS-1],
    output logic [31:0] alu_result [0:NUM_SMS-1],
    output logic        zero [0:NUM_SMS-1],
    output logic [31:0] writeback_data [0:NUM_SMS-1],
    output logic        writeback_enable [0:NUM_SMS-1],

    // =========================================================
    // MEMORY SUBSYSTEM INPUTS
    // =========================================================

    input logic        load_enable,
    input logic        store_enable,

    input logic [31:0] base_address,
    input logic [31:0] offset,

    input logic [31:0] store_data,

    // =========================================================
    // MEMORY SUBSYSTEM OUTPUTS
    // =========================================================

    output logic [31:0] load_data,

    output logic        memory_ready,
    output logic        memory_busy,
    output logic        memory_ready_lsu,
    output logic        memory_busy_lsu,
    output logic        alignment_error,

    output logic        l2_hit,
    output logic        l2_miss,
    output logic        l2_ready,

    // =========================================================
    // NoC INPUT PACKETS
    // =========================================================

    input logic [NUM_NODES-1:0] in_valid,

    input logic [NUM_NODES-1:0][1:0] in_dest,

    input logic [NUM_NODES-1:0][31:0] in_data,

    // =========================================================
    // NoC OUTPUT PACKETS
    // =========================================================

    output logic [NUM_NODES-1:0] out_valid,

    output logic [NUM_NODES-1:0][31:0] out_data,

    output logic [NUM_NODES-1:0] in_ready,

    output logic [31:0] packet_count
);

    // =========================================================
    // GPU SYSTEM
    //
    // Host
    //   ↓
    // Host Interface
    //   ↓
    // Command Dispatch
    //   ↓
    // Multi-SM GPU
    // =========================================================

    gpu_system #(
        .NUM_SMS(NUM_SMS)
    ) gpu_system_inst (

        .clk(clk),
        .reset(reset),

        .host_valid(host_valid),
        .host_write(host_write),
        .host_addr(host_addr),
        .host_wdata(host_wdata),

        .host_rdata(host_rdata),
        .host_ready(host_ready),

        .command_data(command_data),
        .command_valid(command_valid),

        .dispatch_busy(dispatch_busy),

        .instruction(instruction),
        .instruction_valid(instruction_valid),

        .pc(pc),
        .alu_result(alu_result),
        .zero(zero),
        .writeback_data(writeback_data),
        .writeback_enable(writeback_enable)

    );

    // =========================================================
    // MEMORY SUBSYSTEM
    //
    // LSU
    //   ↓
    // L2 Cache
    //   ↓
    // Memory Controller
    // =========================================================

    memory_subsystem memory_subsystem_inst (

        .clk(clk),
        .reset(reset),

        .load_enable(load_enable),
        .store_enable(store_enable),

        .base_address(base_address),
        .offset(offset),

        .store_data(store_data),

        .load_data(load_data),

        .ready(memory_ready_lsu),
        .busy(memory_busy_lsu),
        .alignment_error(alignment_error),

        .l2_hit(l2_hit),
        .l2_miss(l2_miss),
        .l2_ready(l2_ready),

        .memory_ready(memory_ready),
        .memory_busy(memory_busy)

    );

    // =========================================================
    // NETWORK-ON-CHIP
    // =========================================================

    noc #(
        .NUM_NODES(NUM_NODES),
        .DATA_WIDTH(32),
        .DEST_WIDTH(2)
    ) noc_inst (

        .clk(clk),
        .reset(reset),

        .in_valid(in_valid),
        .in_dest(in_dest),
        .in_data(in_data),

        .out_valid(out_valid),
        .out_data(out_data),

        .in_ready(in_ready),

        .packet_count(packet_count)

    );

endmodule