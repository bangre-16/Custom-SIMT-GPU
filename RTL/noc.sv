`timescale 1ns/1ps

module noc #(
    parameter NUM_NODES  = 4,
    parameter DATA_WIDTH = 32,
    parameter DEST_WIDTH = 2
)(
    input  logic clk,
    input  logic reset,

    // =========================================================
    // INPUT PACKETS
    // =========================================================

    input  logic [NUM_NODES-1:0] in_valid,

    input logic [NUM_NODES-1:0][DEST_WIDTH-1:0] in_dest,

    input logic [NUM_NODES-1:0][DATA_WIDTH-1:0] in_data,

    // =========================================================
    // OUTPUT PACKETS
    // =========================================================

    output logic [NUM_NODES-1:0] out_valid,

    output logic [NUM_NODES-1:0][DATA_WIDTH-1:0] out_data,

    // =========================================================
    // INPUT READY
    // =========================================================

    output logic [NUM_NODES-1:0] in_ready,

    // =========================================================
    // PACKET COUNTER
    // =========================================================

    output logic [31:0] packet_count
);

    integer comb_i;
    integer comb_j;

    // =========================================================
    // COMBINATIONAL ROUTING
    // =========================================================

    always_comb begin

        // Default outputs
        out_valid = '0;
        out_data  = '0;
        in_ready  = '0;

        // -----------------------------------------------------
        // Route every valid input to its destination output.
        //
        // If multiple inputs request the same destination,
        // the first input gets the output.
        // -----------------------------------------------------

        for (comb_i = 0; comb_i < NUM_NODES; comb_i = comb_i + 1) begin

            for (comb_j = 0; comb_j < NUM_NODES; comb_j = comb_j + 1) begin

                if ((in_valid[comb_j] == 1'b1) &&
                    (in_dest[comb_j] == comb_i)) begin

                    // Only accept the first packet
                    // targeting this output.
                    if (out_valid[comb_i] == 1'b0) begin

                        out_valid[comb_i] = 1'b1;

                        out_data[comb_i] = in_data[comb_j];

                        in_ready[comb_j] = 1'b1;

                    end

                end

            end

        end

    end

    // =========================================================
    // PACKET COUNTER
    // =========================================================

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            packet_count <= 32'd0;

        end
        else begin

            packet_count <= packet_count
                          + out_valid[0]
                          + out_valid[1]
                          + out_valid[2]
                          + out_valid[3];

        end

    end

endmodule