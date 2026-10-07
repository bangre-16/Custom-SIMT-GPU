`timescale 1ns/1ps

module command_dispatch #(
    parameter NUM_SMS = 4
)(
    input  logic        clk,
    input  logic        reset,

    // ============================================================
    // COMMAND INPUT FROM HOST INTERFACE
    // ============================================================

    input  logic [31:0] command_data,
    input  logic        command_valid,

    // ============================================================
    // INSTRUCTION OUTPUT TO SMs
    // ============================================================

    output logic [31:0] instruction [0:NUM_SMS-1],
    output logic        instruction_valid [0:NUM_SMS-1],

    // ============================================================
    // STATUS
    // ============================================================

    output logic        busy
);

    integer i;

    // ============================================================
    // COMMAND DISPATCH
    // ============================================================

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            busy <= 1'b0;

            for (i = 0; i < NUM_SMS; i = i + 1) begin
                instruction[i]       <= 32'h00000000;
                instruction_valid[i] <= 1'b0;
            end

        end

        else begin

            // Default: instruction valid is a one-cycle pulse
            for (i = 0; i < NUM_SMS; i = i + 1) begin
                instruction_valid[i] <= 1'b0;
            end

            busy <= 1'b0;

            // ----------------------------------------------------
            // Dispatch command to every SM
            // ----------------------------------------------------

            if (command_valid) begin

                busy <= 1'b1;

                for (i = 0; i < NUM_SMS; i = i + 1) begin

                    instruction[i]       <= command_data;
                    instruction_valid[i] <= 1'b1;

                end

            end

        end

    end

endmodule