`timescale 1ns/1ps

module l2_cache #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter NUM_LINES  = 16
)(
    input logic                  clk,
    input logic                  reset,

    // =========================================================
    // CPU / GPU INTERFACE
    // =========================================================

    input logic                  read_enable,
    input logic                  write_enable,

    input logic [ADDR_WIDTH-1:0] address,
    input logic [DATA_WIDTH-1:0] write_data,

    output logic [DATA_WIDTH-1:0] read_data,

    output logic                  hit,
    output logic                  miss,
    output logic                  ready,

    // =========================================================
    // MAIN MEMORY INTERFACE
    // =========================================================

    output logic                  mem_read,
    output logic                  mem_write,

    output logic [ADDR_WIDTH-1:0] mem_address,
    output logic [DATA_WIDTH-1:0] mem_write_data,

    input logic [DATA_WIDTH-1:0] mem_read_data
);

    // =========================================================
    // ADDRESS ORGANIZATION
    //
    // 32-bit byte address
    //
    // [31:6] TAG
    // [5:2]  INDEX
    // [1:0]  BYTE OFFSET
    //
    // 16 cache lines
    // =========================================================

    localparam INDEX_WIDTH  = 4;
    localparam OFFSET_WIDTH = 2;
    localparam TAG_WIDTH    = ADDR_WIDTH - INDEX_WIDTH - OFFSET_WIDTH;

    // =========================================================
    // CACHE STORAGE
    // =========================================================

    logic [DATA_WIDTH-1:0] data_array [0:NUM_LINES-1];

    logic [TAG_WIDTH-1:0] tag_array [0:NUM_LINES-1];

    logic valid_array [0:NUM_LINES-1];

    // =========================================================
    // ADDRESS FIELDS
    // =========================================================

    logic [INDEX_WIDTH-1:0] index;
    logic [TAG_WIDTH-1:0]   tag;

    assign index = address[5:2];
    assign tag   = address[ADDR_WIDTH-1:6];

    // =========================================================
    // READ MISS CONTROL
    // =========================================================

    logic                   read_miss_pending;

    logic [INDEX_WIDTH-1:0] pending_index;
    logic [TAG_WIDTH-1:0]   pending_tag;

    // =========================================================
    // CACHE LOOKUP
    // =========================================================

    always_comb begin

        hit = 1'b0;

        if (valid_array[index] &&
            tag_array[index] == tag) begin

            hit = 1'b1;

        end

    end

    // =========================================================
    // CACHE INTERFACE
    // =========================================================

    always_comb begin

        // -----------------------------------------------------
        // DEFAULT VALUES
        // -----------------------------------------------------

        read_data      = '0;

        miss           = 1'b0;
        ready          = 1'b0;

        mem_read       = 1'b0;
        mem_write      = 1'b0;

        mem_address    = address;
        mem_write_data = write_data;

        // =====================================================
        // WAITING FOR MEMORY RESPONSE
        // =====================================================

        if (read_miss_pending) begin

            ready = 1'b1;
            miss  = 1'b1;

            read_data = mem_read_data;

            mem_read  = 1'b0;
            mem_write = 1'b0;

        end

        // =====================================================
        // READ REQUEST
        // =====================================================

        else if (read_enable && !write_enable) begin

            ready = 1'b1;

            if (hit) begin

                // -------------------------------------------------
                // CACHE HIT
                // -------------------------------------------------

                read_data = data_array[index];

                miss     = 1'b0;
                mem_read = 1'b0;

            end

            else begin

                // -------------------------------------------------
                // CACHE MISS
                // -------------------------------------------------

                read_data = '0;

                miss     = 1'b1;
                mem_read = 1'b1;

                mem_address = address;

            end

        end

        // =====================================================
        // WRITE REQUEST
        // =====================================================

        else if (write_enable && !read_enable) begin

            ready = 1'b1;

            // -------------------------------------------------
            // WRITE-THROUGH POLICY
            // -------------------------------------------------

            mem_write      = 1'b1;
            mem_address    = address;
            mem_write_data = write_data;

            if (hit) begin

                miss = 1'b0;

            end

            else begin

                miss = 1'b1;

            end

        end

        // =====================================================
        // SIMULTANEOUS READ + WRITE
        // =====================================================

        else if (read_enable && write_enable) begin

            ready     = 1'b0;
            miss      = 1'b0;

            mem_read  = 1'b0;
            mem_write = 1'b0;

            read_data = '0;

        end

        // =====================================================
        // IDLE
        // =====================================================

        else begin

            ready = 1'b0;
            miss  = 1'b0;

        end

    end

    // =========================================================
    // CACHE UPDATE LOGIC
    // =========================================================

    integer i;

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            read_miss_pending <= 1'b0;

            pending_index <= '0;
            pending_tag   <= '0;

            for (i = 0; i < NUM_LINES; i = i + 1) begin

                valid_array[i] <= 1'b0;
                tag_array[i]   <= '0;
                data_array[i]  <= '0;

            end

        end

        else begin

            // =================================================
            // COMPLETE PREVIOUS READ MISS
            // =================================================

            if (read_miss_pending) begin

                valid_array[pending_index] <= 1'b1;

                tag_array[pending_index] <= pending_tag;

                data_array[pending_index] <= mem_read_data;

                read_miss_pending <= 1'b0;

            end

            // =================================================
            // START NEW READ MISS
            // =================================================

            else if (read_enable &&
                     !write_enable &&
                     !hit) begin

                read_miss_pending <= 1'b1;

                pending_index <= index;

                pending_tag <= tag;

            end

            // =================================================
            // WRITE HIT
            // =================================================

            if (write_enable &&
                !read_enable &&
                hit) begin

                data_array[index] <= write_data;

            end

        end

    end

endmodule