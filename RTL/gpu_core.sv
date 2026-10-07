module gpu_core (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instruction,

    output logic [31:0] pc,
    output logic [31:0] alu_result,
    output logic        zero,
    output logic [31:0] writeback_data,
    output logic        writeback_enable
);

    // ============================================================
    // CUSTOM GPU CORE
    // ============================================================

    logic [31:0] registers [0:31];

    // Instruction fields
    logic [5:0] opcode;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] immediate;

    // Control
    logic [3:0] alu_select;
    logic       use_immediate;
    logic       reg_write;

    integer i;

    // ============================================================
    // OPCODES
    // ============================================================
    localparam OP_ADD  = 6'b000000;
    localparam OP_SUB  = 6'b000001;
    localparam OP_MUL  = 6'b000010;
    localparam OP_AND  = 6'b000011;
    localparam OP_OR   = 6'b000100;
    localparam OP_XOR  = 6'b000101;
    localparam OP_ADDI = 6'b000110;

    // ============================================================
    // INSTRUCTION FORMAT
    //
    // [31:26] opcode
    // [25:21] rs1
    // [20:16] rs2
    // [15:11] rd
    // [15:0]  immediate for ADDI
    // ============================================================

    assign opcode = instruction[31:26];
    assign rs1    = instruction[25:21];
    assign rs2    = instruction[20:16];
    assign rd     = instruction[15:11];

    assign immediate = {{16{instruction[15]}},
                        instruction[15:0]};

    // Register reads
    assign rs1_data = (rs1 == 5'd0) ? 32'd0 : registers[rs1];
    assign rs2_data = (rs2 == 5'd0) ? 32'd0 : registers[rs2];

    // ============================================================
    // CONTROL UNIT
    // ============================================================

    always_comb begin

        alu_select    = 4'b0000;
        use_immediate = 1'b0;
        reg_write     = 1'b0;

        case (opcode)

            OP_ADD: begin
                alu_select = 4'b0000;
                reg_write  = 1'b1;
            end

            OP_SUB: begin
                alu_select = 4'b0001;
                reg_write  = 1'b1;
            end

            OP_MUL: begin
                alu_select = 4'b0010;
                reg_write  = 1'b1;
            end

            OP_AND: begin
                alu_select = 4'b0011;
                reg_write  = 1'b1;
            end

            OP_OR: begin
                alu_select = 4'b0100;
                reg_write  = 1'b1;
            end

            OP_XOR: begin
                alu_select = 4'b0101;
                reg_write  = 1'b1;
            end

            OP_ADDI: begin
                alu_select    = 4'b0000;
                use_immediate = 1'b1;
                reg_write     = 1'b1;
            end

            default: begin
                alu_select    = 4'b0000;
                use_immediate = 1'b0;
                reg_write     = 1'b0;
            end

        endcase
    end

    // ============================================================
    // EXECUTION DATAPATH
    // ============================================================

    always_comb begin

        if (use_immediate) begin

            alu_result = rs1_data + immediate;

        end
        else begin

            case (alu_select)

                4'b0000:
                    alu_result = rs1_data + rs2_data;

                4'b0001:
                    alu_result = rs1_data - rs2_data;

                4'b0010:
                    alu_result = rs1_data * rs2_data;

                4'b0011:
                    alu_result = rs1_data & rs2_data;

                4'b0100:
                    alu_result = rs1_data | rs2_data;

                4'b0101:
                    alu_result = rs1_data ^ rs2_data;

                default:
                    alu_result = 32'd0;

            endcase
        end
    end

    // ============================================================
    // ZERO FLAG
    // ============================================================

    assign zero = (alu_result == 32'd0);

    // ============================================================
    // WRITEBACK
    // ============================================================

    assign writeback_data   = alu_result;
    assign writeback_enable = reg_write;

    // ============================================================
    // PROGRAM COUNTER + REGISTER WRITE
    // ============================================================

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            pc <= 32'd0;

            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'd0;

            // Test initialization
            registers[1] <= 32'd10;
            registers[2] <= 32'd5;

        end
        else begin

            pc <= pc + 32'd4;

            if (reg_write && (rd != 5'd0))
                registers[rd] <= alu_result;

        end

    end

endmodule