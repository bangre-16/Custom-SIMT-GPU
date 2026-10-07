`timescale 1ns/1ps

module load_store_unit #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter MEM_DEPTH  = 256
)(
    input  logic                  clk,
    input  logic                  reset,

    // ---------------------------------------------------------
    // CPU / GPU request interface
    // ---------------------------------------------------------
    input  logic                  load_enable,
    input  logic                  store_enable,

    input  logic [ADDR_WIDTH-1:0] base_address,
    input  logic [ADDR_WIDTH-1:0] offset,

    input  logic [DATA_WIDTH-1:0] store_data,

    // ---------------------------------------------------------
    // Memory interface
    // ---------------------------------------------------------
    output logic                  mem_read,
    output logic                  mem_write,

    output logic [ADDR_WIDTH-1:0] mem_address,
    output logic [DATA_WIDTH-1:0] mem_write_data,

    input  logic [DATA_WIDTH-1:0] mem_read_data,

    // ---------------------------------------------------------
    // Result interface
    // ---------------------------------------------------------
    output logic [DATA_WIDTH-1:0] load_data,
    output logic                  ready,
    output logic                  busy,
    output logic                  alignment_error
);

    // =========================================================
    // Internal address
    // =========================================================

    logic [ADDR_WIDTH-1:0] effective_address;

    assign effective_address = base_address + offset;

    // =========================================================
    // Address and memory control
    // =========================================================

    always_comb begin

        // Defaults
        mem_read       = 1'b0;
        mem_write      = 1'b0;

        mem_address    = effective_address;
        mem_write_data = store_data;

        load_data      = mem_read_data;

        ready          = 1'b0;
        busy           = 1'b0;

        alignment_error = 1'b0;

        // -----------------------------------------------------
        // Load
        // -----------------------------------------------------

        if (load_enable && !store_enable) begin

            mem_read = 1'b1;
            ready    = 1'b1;
            busy     = 1'b0;

            // 32-bit word must be 4-byte aligned
            if (effective_address[1:0] != 2'b00)
                alignment_error = 1'b1;

        end

        // -----------------------------------------------------
        // Store
        // -----------------------------------------------------

        else if (store_enable && !load_enable) begin

            mem_write = 1'b1;
            ready     = 1'b1;
            busy      = 1'b0;

            // 32-bit word must be 4-byte aligned
            if (effective_address[1:0] != 2'b00)
                alignment_error = 1'b1;

        end

        // -----------------------------------------------------
        // Invalid simultaneous load/store
        // -----------------------------------------------------

        else if (load_enable && store_enable) begin

            mem_read  = 1'b0;
            mem_write = 1'b0;

            ready = 1'b0;
            busy  = 1'b0;

            alignment_error = 1'b0;

        end

        // -----------------------------------------------------
        // No request
        // -----------------------------------------------------

        else begin

            mem_read  = 1'b0;
            mem_write = 1'b0;

            ready = 1'b0;
            busy  = 1'b0;

        end

    end

endmodule