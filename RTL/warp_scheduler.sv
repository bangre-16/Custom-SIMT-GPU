`timescale 1ns/1ps

module warp_scheduler #(
    parameter integer NUM_WARPS = 4
)(
    input  logic                     clk,
    input  logic                     reset,

    // 1 = warp is ready to execute
    input  logic [NUM_WARPS-1:0]     ready_mask,

    // Scheduler enable
    input  logic                     schedule_en,

    // Selected warp
    output logic [$clog2(NUM_WARPS)-1:0] selected_warp,

    // 1 when a valid warp has been selected
    output logic                     warp_valid
);

    localparam integer WARP_ID_WIDTH = $clog2(NUM_WARPS);

    logic [WARP_ID_WIDTH-1:0] next_pointer;
    logic [WARP_ID_WIDTH-1:0] selected_next;
    logic                     valid_next;

    integer offset;
    integer index;

    // ============================================================
    // ROUND-ROBIN WARP SELECTION
    // ============================================================

    always_comb begin

        selected_next = next_pointer;
        valid_next    = 1'b0;

        for (offset = 0; offset < NUM_WARPS; offset = offset + 1) begin

            index = next_pointer + offset;

            if (index >= NUM_WARPS)
                index = index - NUM_WARPS;

            if (!valid_next && ready_mask[index]) begin

                selected_next = index[WARP_ID_WIDTH-1:0];
                valid_next    = 1'b1;

            end

        end

    end


    // ============================================================
    // SCHEDULER STATE
    // ============================================================

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            next_pointer  <= '0;
            selected_warp <= '0;
            warp_valid    <= 1'b0;

        end

        else if (schedule_en) begin

            selected_warp <= selected_next;
            warp_valid    <= valid_next;

            // Start next search after selected warp
            if (valid_next) begin

                if (selected_next == NUM_WARPS-1)
                    next_pointer <= '0;

                else
                    next_pointer <= selected_next + 1'b1;

            end

        end
        else begin

            warp_valid <= 1'b0;

        end

    end

endmodule