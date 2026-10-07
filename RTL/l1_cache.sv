`timescale 1ns/1ps

module l1_cache #(
    parameter integer ADDR_WIDTH = 8,
    parameter integer DATA_WIDTH = 32,
    parameter integer NUM_LINES  = 16
)(
    input  logic                     clk,
    input  logic                     reset,

    input  logic                     read_enable,
    input  logic                     write_enable,

    input  logic [ADDR_WIDTH-1:0]    address,
    input  logic [DATA_WIDTH-1:0]    write_data,

    output logic [DATA_WIDTH-1:0]    read_data,
    output logic                     hit,
    output logic                     miss,
    output logic                     ready
);

    // ============================================================
    // ADDRESS ORGANIZATION
    //
    // 8-bit address
    // 16 cache lines
    //
    // INDEX = address[3:0]
    // TAG   = address[7:4]
    // ============================================================

    localparam integer INDEX_WIDTH = 4;
    localparam integer TAG_WIDTH   = ADDR_WIDTH - INDEX_WIDTH;

    logic [DATA_WIDTH-1:0] data_array [0:NUM_LINES-1];
    logic [TAG_WIDTH-1:0]  tag_array  [0:NUM_LINES-1];
    logic                  valid_array[0:NUM_LINES-1];

    logic [INDEX_WIDTH-1:0] index;
    logic [TAG_WIDTH-1:0]   tag;

    integer i;

    assign index = address[INDEX_WIDTH-1:0];
    assign tag   = address[ADDR_WIDTH-1:INDEX_WIDTH];

    // ============================================================
    // CACHE OPERATION
    // ============================================================

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            read_data <= '0;
            hit       <= 1'b0;
            miss      <= 1'b0;
            ready     <= 1'b0;

            for (i = 0; i < NUM_LINES; i = i + 1) begin
                data_array[i]  <= '0;
                tag_array[i]   <= '0;
                valid_array[i] <= 1'b0;
            end

        end

        else begin

            hit   <= 1'b0;
            miss  <= 1'b0;
            ready <= 1'b0;

            // ====================================================
            // WRITE
            // ====================================================

            if (write_enable) begin

                data_array[index]  <= write_data;
                tag_array[index]   <= tag;
                valid_array[index] <= 1'b1;

                ready <= 1'b1;
                hit   <= 1'b1;

            end

            // ====================================================
            // READ
            // ====================================================

            else if (read_enable) begin

                ready <= 1'b1;

                if (valid_array[index] &&
                    tag_array[index] == tag) begin

                    // CACHE HIT
                    read_data <= data_array[index];
                    hit       <= 1'b1;
                    miss      <= 1'b0;

                end

                else begin

                    // CACHE MISS
                    read_data <= '0;
                    hit       <= 1'b0;
                    miss      <= 1'b1;

                end

            end

        end

    end

endmodule