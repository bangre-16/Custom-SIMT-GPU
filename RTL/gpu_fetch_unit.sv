module gpu_fetch_unit (
    input  logic        clk,
    input  logic        reset,

    output logic [31:0] pc,
    output logic [31:0] instruction
);

    // ============================================================
    // PROGRAM COUNTER
    // ============================================================

    always_ff @(posedge clk or posedge reset) begin

        if (reset)
            pc <= 32'd0;
        else
            pc <= pc + 32'd4;

    end

    // ============================================================
    // INSTRUCTION MEMORY
    //
    // PC is byte address.
    // Convert to word index using PC[31:2].
    // ============================================================

    logic [31:0] instruction_memory [0:255];

    integer i;

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            for (i = 0; i < 256; i = i + 1)
                instruction_memory[i] <= 32'd0;

            // ----------------------------------------------------
            // Test program
            //
            // ADD  R3 = R1 + R2
            // SUB  R4 = R1 - R2
            // MUL  R5 = R1 * R2
            // AND  R6 = R1 & R2
            // OR   R7 = R1 | R2
            // XOR  R8 = R1 ^ R2
            // ----------------------------------------------------

            instruction_memory[0] <= {
                6'b000000,
                5'd1,
                5'd2,
                5'd3,
                11'd0
            };

            instruction_memory[1] <= {
                6'b000001,
                5'd1,
                5'd2,
                5'd4,
                11'd0
            };

            instruction_memory[2] <= {
                6'b000010,
                5'd1,
                5'd2,
                5'd5,
                11'd0
            };

            instruction_memory[3] <= {
                6'b000011,
                5'd1,
                5'd2,
                5'd6,
                11'd0
            };

            instruction_memory[4] <= {
                6'b000100,
                5'd1,
                5'd2,
                5'd7,
                11'd0
            };

            instruction_memory[5] <= {
                6'b000101,
                5'd1,
                5'd2,
                5'd8,
                11'd0
            };

        end

    end

    // ============================================================
    // INSTRUCTION FETCH
    // ============================================================

    always_comb begin

        instruction = instruction_memory[pc[31:2]];

    end

endmodule