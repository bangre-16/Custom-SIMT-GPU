`timescale 1ns/1ps

module simt_controller #(
    parameter integer NUM_LANES = 4
)(
    input  logic                         clk,
    input  logic                         reset,

    // Instruction broadcast to the warp
    input  logic [31:0]                  instruction_in,

    // Initial/updated active-thread mask
    input  logic [NUM_LANES-1:0]         active_mask_in,

    // Enable for controller operation
    input  logic                         enable,

    // Branch control
    input  logic                         branch_taken,
    input  logic [NUM_LANES-1:0]         branch_mask,

    // Outputs
    output logic [31:0]                  instruction_out,
    output logic [NUM_LANES-1:0]         active_mask_out,
    output logic [NUM_LANES-1:0]         lane_enable,
    output logic                         warp_active
);

    // ============================================================
    // SIMT CONTROLLER
    //
    // All lanes receive the same instruction.
    // Only lanes whose active-mask bit is 1 are enabled.
    //
    // branch_taken = 1:
    //     active lanes are replaced by branch_mask.
    //
    // branch_taken = 0:
    //     current active mask is preserved.
    // ============================================================

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            instruction_out <= 32'b0;
            active_mask_out <= {NUM_LANES{1'b1}};
            lane_enable     <= {NUM_LANES{1'b0}};
            warp_active     <= 1'b0;

        end

        else if (enable) begin

            // Broadcast same instruction to all lanes
            instruction_out <= instruction_in;

            // Apply branch mask when branch is taken
            if (branch_taken)
                active_mask_out <= branch_mask;
            else
                active_mask_out <= active_mask_in;

            // Lane enables follow the selected active mask
            if (branch_taken)
                lane_enable <= branch_mask;
            else
                lane_enable <= active_mask_in;

            // Warp is active if at least one lane is active
            if (branch_taken)
                warp_active <= |branch_mask;
            else
                warp_active <= |active_mask_in;

        end

        else begin

            lane_enable <= active_mask_out;
            warp_active <= |active_mask_out;

        end

    end

endmodule