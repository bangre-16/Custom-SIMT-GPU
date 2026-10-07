`timescale 1ns/1ps

module host_interface (

    input  logic        clk,
    input  logic        reset,

    // Host-side interface
    input  logic        host_valid,
    input  logic        host_write,
    input  logic [31:0] host_addr,
    input  logic [31:0] host_wdata,

    output logic [31:0] host_rdata,
    output logic        host_ready,

    // GPU-side command interface
    output logic [31:0] command_data,
    output logic        command_valid
);

    // ============================================================
    // ADDRESS MAP
    // ============================================================

    localparam ADDR_COMMAND = 32'h00000000;

    // ============================================================
    // INTERNAL COMMAND REGISTER
    // ============================================================

    logic [31:0] command_register;

    // ============================================================
    // HOST READY
    // ============================================================

    assign host_ready = 1'b1;

    // ============================================================
    // GPU COMMAND OUTPUT
    // ============================================================

    assign command_data = command_register;

    // ============================================================
    // HOST READ DATA
    // ============================================================

    always_comb begin

        host_rdata = 32'h00000000;

        if (host_valid && !host_write) begin

            case (host_addr)

                ADDR_COMMAND:
                    host_rdata = command_register;

                default:
                    host_rdata = 32'h00000000;

            endcase

        end

    end

    // ============================================================
    // COMMAND REGISTER
    // ============================================================

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            command_register <= 32'h00000000;
            command_valid    <= 1'b0;

        end

        else begin

            // Default: command valid is one-cycle pulse
            command_valid <= 1'b0;

            if (host_valid && host_write) begin

                case (host_addr)

                    ADDR_COMMAND: begin

                        command_register <= host_wdata;
                        command_valid    <= 1'b1;

                    end

                    default: begin

                        command_register <= command_register;
                        command_valid    <= 1'b0;

                    end

                endcase

            end

        end

    end

endmodule