`timescale 1ns/1ps

module memory_controller #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DEPTH      = 256
)(
    input  logic                  clk,
    input  logic                  reset,

    // CPU / GPU side request interface
    input  logic                  read_enable,
    input  logic                  write_enable,
    input  logic [ADDR_WIDTH-1:0] address,
    input  logic [DATA_WIDTH-1:0] write_data,

    output logic [DATA_WIDTH-1:0] read_data,
    output logic                  ready,
    output logic                  busy,

    // Memory-side interface
    output logic                  mem_read,
    output logic                  mem_write,
    output logic [ADDR_WIDTH-1:0] mem_address,
    output logic [DATA_WIDTH-1:0] mem_write_data,
    input  logic [DATA_WIDTH-1:0] mem_read_data
);

    // =========================================================
    // INTERNAL MEMORY
    // =========================================================

    logic [DATA_WIDTH-1:0] memory [0:DEPTH-1];

    integer k;

    // =========================================================
    // ADDRESS INDEX
    // Word-addressed memory
    // =========================================================

    logic [$clog2(DEPTH)-1:0] address_index;

    assign address_index = address[$clog2(DEPTH)+1:2];

    // =========================================================
    // MEMORY CONTROLLER
    // =========================================================

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            read_data     <= '0;
            ready         <= 1'b1;
            busy          <= 1'b0;

            mem_read      <= 1'b0;
            mem_write     <= 1'b0;
            mem_address   <= '0;
            mem_write_data <= '0;

            for (k = 0; k < DEPTH; k = k + 1)
                memory[k] <= '0;

        end
        else begin

            // Default interface status
            ready     <= 1'b1;
            busy      <= 1'b0;
            mem_read  <= 1'b0;
            mem_write <= 1'b0;

            // -------------------------------------------------
            // WRITE REQUEST
            // -------------------------------------------------

            if (write_enable) begin

                busy          <= 1'b1;
                ready         <= 1'b0;

                mem_write     <= 1'b1;
                mem_address   <= address;
                mem_write_data <= write_data;

                memory[address_index] <= write_data;

            end

            // -------------------------------------------------
            // READ REQUEST
            // -------------------------------------------------

            else if (read_enable) begin

                busy        <= 1'b1;
                ready       <= 1'b0;

                mem_read    <= 1'b1;
                mem_address <= address;

                read_data   <= memory[address_index];

            end

        end

    end

endmodule