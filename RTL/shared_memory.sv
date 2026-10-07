`timescale 1ns/1ps

module shared_memory #(
    parameter integer ADDR_WIDTH = 8,
    parameter integer DATA_WIDTH = 32,
    parameter integer DEPTH      = 256
)(
    input  logic                  clk,
    input  logic                  reset,

    input  logic                  read_enable,
    input  logic                  write_enable,

    input  logic [ADDR_WIDTH-1:0] address,
    input  logic [DATA_WIDTH-1:0] write_data,

    output logic [DATA_WIDTH-1:0] read_data,
    output logic                  ready
);

    // ============================================================
    // SHARED MEMORY
    // 256 locations x 32 bits
    // ============================================================

    logic [DATA_WIDTH-1:0] memory [0:DEPTH-1];

    integer i;

    // ============================================================
    // MEMORY OPERATION
    // ============================================================

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            read_data <= '0;
            ready     <= 1'b0;

            for (i = 0; i < DEPTH; i = i + 1)
                memory[i] <= '0;

        end

        else begin

            ready <= 1'b0;

            // ----------------------------------------------------
            // WRITE
            // ----------------------------------------------------

            if (write_enable) begin

                memory[address] <= write_data;
                ready           <= 1'b1;

            end

            // ----------------------------------------------------
            // READ
            // ----------------------------------------------------

            else if (read_enable) begin

                read_data <= memory[address];
                ready     <= 1'b1;

            end

        end

    end

endmodule