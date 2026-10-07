`timescale 1ns/1ps

module program_counter #(
    parameter WIDTH = 32
)(
    input  logic             clk,
    input  logic             reset,

    input  logic             branch_enable,
    input  logic [WIDTH-1:0] branch_target,

    output logic [WIDTH-1:0] pc
);

    // =========================================================
    // PC update
    // =========================================================
    always_ff @(posedge clk) begin

        if (reset) begin

            pc <= '0;

        end
        else if (branch_enable) begin

            pc <= branch_target;

        end
        else begin

            pc <= pc + 32'd4;

        end

    end

endmodule