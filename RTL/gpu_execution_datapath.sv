`timescale 1ns/1ps

module gpu_execution_datapath (
    input  logic        clk,
    input  logic        reset,

    // Register file interface
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,

    // Immediate
    input  logic [31:0] immediate,

    // Control signals
    input  logic        use_immediate,
    input  logic        fp_enable,

    input  logic [3:0]  alu_select,
    input  logic [2:0]  fp_select,

    input  logic        reg_write,

    // Datapath outputs
    output logic [31:0] alu_result,
    output logic        zero,

    output logic [31:0] writeback_data,
    output logic        writeback_enable
);

    logic [31:0] operand_b;

    logic [31:0] int_result;
    logic [31:0] fp_result;

    logic int_zero;
    logic fp_zero;

    /*
     * Operand B selection
     */
    always_comb begin
        if (use_immediate)
            operand_b = immediate;
        else
            operand_b = rs2_data;
    end

    /*
     * Integer ALU
     */
    integer_alu int_alu (
        .A(rs1_data),
        .B(operand_b),
        .alu_op(alu_select),
        .result(int_result),
        .zero(int_zero)
    );

    /*
     * FP32 ALU
     */
    fp32_alu fp_alu (
        .A(rs1_data),
        .B(operand_b),
        .C(32'b0),
        .fp_op(fp_select),
        .result(fp_result),
        .zero(fp_zero)
    );

    /*
     * Result selection
     */
    always_comb begin

        if (fp_enable) begin
            alu_result = fp_result;
            zero       = fp_zero;
        end
        else begin
            alu_result = int_result;
            zero       = int_zero;
        end

    end

    /*
     * Write-back path
     */
    always_comb begin

        writeback_data   = alu_result;
        writeback_enable = reg_write;

    end

endmodule