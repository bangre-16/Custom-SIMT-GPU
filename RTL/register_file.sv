`timescale 1ns/1ps

module register_file #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5
)(
    input  logic                  clk,
    input  logic                  reset,

    // Read ports
    input  logic [ADDR_WIDTH-1:0] read_addr1,
    input  logic [ADDR_WIDTH-1:0] read_addr2,

    output logic [DATA_WIDTH-1:0] read_data1,
    output logic [DATA_WIDTH-1:0] read_data2,

    // Write port
    input  logic                  write_enable,
    input  logic [ADDR_WIDTH-1:0] write_addr,
    input  logic [DATA_WIDTH-1:0] write_data
);

    localparam integer NUM_REGISTERS = 2 ** ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] registers [0:NUM_REGISTERS-1];

    integer i;

    // =========================================================
    // Sequential write logic
    // =========================================================
    always_ff @(posedge clk) begin

        if (reset) begin

            for (i = 0; i < NUM_REGISTERS; i = i + 1) begin
                registers[i] <= '0;
            end

        end
        else begin

            // Register 0 is hardwired to zero
            if (write_enable && (write_addr != '0)) begin
                registers[write_addr] <= write_data;
            end

            registers[0] <= '0;

        end

    end


    // =========================================================
    // Combinational read port 1
    // =========================================================
    always_comb begin

        if (read_addr1 == '0)
            read_data1 = '0;
        else
            read_data1 = registers[read_addr1];

    end


    // =========================================================
    // Combinational read port 2
    // =========================================================
    always_comb begin

        if (read_addr2 == '0)
            read_data2 = '0;
        else
            read_data2 = registers[read_addr2];

    end

endmodule