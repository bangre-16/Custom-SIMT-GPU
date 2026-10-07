`timescale 1ns/1ps

module memory_subsystem #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter NUM_LINES  = 16,
    parameter MEM_DEPTH  = 256
)(
    input  logic clk,
    input  logic reset,

    input  logic load_enable,
    input  logic store_enable,

    input  logic [ADDR_WIDTH-1:0] base_address,
    input  logic [ADDR_WIDTH-1:0] offset,

    input  logic [DATA_WIDTH-1:0] store_data,

    output logic [DATA_WIDTH-1:0] load_data,

    output logic ready,
    output logic busy,
    output logic alignment_error,

    output logic l2_hit,
    output logic l2_miss,
    output logic l2_ready,

    output logic memory_ready,
    output logic memory_busy
);

    // ============================================================
    // LSU SIGNALS
    // ============================================================
    logic lsu_mem_read;
    logic lsu_mem_write;
    logic [ADDR_WIDTH-1:0] lsu_mem_address;
    logic [DATA_WIDTH-1:0] lsu_mem_write_data;
    logic [DATA_WIDTH-1:0] lsu_load_data;
    logic lsu_ready;
    logic lsu_busy;
    logic lsu_alignment_error;

    // ============================================================
    // L2 SIGNALS
    // ============================================================
    logic l2_mem_read;
    logic l2_mem_write;
    logic [ADDR_WIDTH-1:0] l2_mem_address;
    logic [DATA_WIDTH-1:0] l2_mem_write_data;
    logic [DATA_WIDTH-1:0] l2_mem_read_data;

    // ============================================================
    // MEMORY CONTROLLER SIGNALS
    // ============================================================
    logic mc_mem_read;
    logic mc_mem_write;
    logic [ADDR_WIDTH-1:0] mc_mem_address;
    logic [DATA_WIDTH-1:0] mc_mem_write_data;
    logic [DATA_WIDTH-1:0] mc_mem_read_data;

    logic [DATA_WIDTH-1:0] mc_read_data;
    logic mc_ready;
    logic mc_busy;

    // ============================================================
    // INTERNAL GLOBAL MEMORY
    // ============================================================
    logic [DATA_WIDTH-1:0] global_memory [0:MEM_DEPTH-1];

    integer i;
    integer write_index;

    // ============================================================
    // MEMORY ADDRESS FUNCTION
    //
    // GPU memory uses byte addresses.
    //
    // Example:
    // 0x40 >> 2 = 0x10 = word 16
    // 0x80 >> 2 = 0x20 = word 32
    // ============================================================
    function automatic integer get_memory_index(
        input logic [ADDR_WIDTH-1:0] address
    );
        integer temp_index;
        begin
            temp_index = address >> 2;

            if ((temp_index >= 0) && (temp_index < MEM_DEPTH))
                get_memory_index = temp_index;
            else
                get_memory_index = 0;
        end
    endfunction

    // ============================================================
    // GLOBAL MEMORY READ
    // ============================================================
    always_comb begin
        if ((mc_mem_read == 1'b1) ||
            (mc_mem_write == 1'b1))
            mc_mem_read_data = global_memory[get_memory_index(mc_mem_address)];
        else
            mc_mem_read_data = 32'd0;
    end

    // ============================================================
    // GLOBAL MEMORY WRITE
    // ============================================================
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin

            for (i = 0; i < MEM_DEPTH; i = i + 1)
                global_memory[i] <= 32'd0;

        end
        else begin

            if (mc_mem_write) begin

                write_index = get_memory_index(mc_mem_address);

                global_memory[write_index] <= mc_mem_write_data;

            end

        end
    end

    // ============================================================
    // LOAD / STORE UNIT
    // ============================================================
    load_store_unit lsu_inst (

        .clk             (clk),
        .reset           (reset),

        .load_enable     (load_enable),
        .store_enable    (store_enable),

        .base_address    (base_address),
        .offset          (offset),

        .store_data      (store_data),

        .mem_read        (lsu_mem_read),
        .mem_write       (lsu_mem_write),
        .mem_address     (lsu_mem_address),
        .mem_write_data  (lsu_mem_write_data),
        .mem_read_data   (l2_mem_read_data),

        .load_data       (lsu_load_data),
        .ready           (lsu_ready),
        .busy            (lsu_busy),
        .alignment_error (lsu_alignment_error)
    );

    // ============================================================
    // L2 CACHE
    // ============================================================
    l2_cache #(
        .NUM_LINES(NUM_LINES)
    ) l2_inst (

        .clk             (clk),
        .reset           (reset),

        .read_enable     (lsu_mem_read),
        .write_enable    (lsu_mem_write),

        .address         (lsu_mem_address),
        .write_data      (lsu_mem_write_data),

        .read_data       (l2_mem_read_data),

        .hit             (l2_hit),
        .miss            (l2_miss),
        .ready           (l2_ready),

        .mem_read        (l2_mem_read),
        .mem_write       (l2_mem_write),
        .mem_address     (l2_mem_address),
        .mem_write_data  (l2_mem_write_data),
        .mem_read_data   (mc_read_data)
    );

    // ============================================================
    // MEMORY CONTROLLER
    // ============================================================
    memory_controller mc_inst (

        .clk             (clk),
        .reset           (reset),

        .read_enable     (l2_mem_read),
        .write_enable    (l2_mem_write),

        .address         (l2_mem_address),
        .write_data      (l2_mem_write_data),

        .read_data       (mc_read_data),

        .ready           (mc_ready),
        .busy            (mc_busy),

        .mem_read        (mc_mem_read),
        .mem_write       (mc_mem_write),
        .mem_address     (mc_mem_address),
        .mem_write_data  (mc_mem_write_data),
        .mem_read_data   (mc_mem_read_data)
    );

    // ============================================================
    // TOP LEVEL OUTPUTS
    // ============================================================
    assign load_data       = lsu_load_data;
    assign ready           = lsu_ready;
    assign busy            = lsu_busy;
    assign alignment_error = lsu_alignment_error;

    assign memory_ready    = mc_ready;
    assign memory_busy     = mc_busy;

endmodule