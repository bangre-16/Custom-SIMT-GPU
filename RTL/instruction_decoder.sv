`timescale 1ns/1ps

module instruction_decoder (

    input  logic [31:0] instruction,

    output logic [5:0]  opcode,
    output logic [4:0]  rd,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [15:0] immediate,

    output logic        reg_write,
    output logic        mem_read,
    output logic        mem_write,
    output logic        branch,
    output logic        fp_enable,
    output logic        alu_src_imm,

    output logic [3:0]  alu_op,
    output logic [2:0]  fp_op
);

    // =========================================================
    // OPCODES
    // =========================================================

    localparam logic [5:0] OP_ADD  = 6'b000000;
    localparam logic [5:0] OP_SUB  = 6'b000001;
    localparam logic [5:0] OP_MUL  = 6'b000010;

    localparam logic [5:0] OP_AND  = 6'b000011;
    localparam logic [5:0] OP_OR   = 6'b000100;
    localparam logic [5:0] OP_XOR  = 6'b000101;

    localparam logic [5:0] OP_ADDI = 6'b000110;

    localparam logic [5:0] OP_FADD = 6'b000111;
    localparam logic [5:0] OP_FSUB = 6'b001000;
    localparam logic [5:0] OP_FMUL = 6'b001001;
    localparam logic [5:0] OP_FFMA = 6'b001010;

    localparam logic [5:0] OP_LD   = 6'b001011;
    localparam logic [5:0] OP_ST   = 6'b001100;

    localparam logic [5:0] OP_BEQ  = 6'b001101;
    localparam logic [5:0] OP_BNE  = 6'b001110;

    localparam logic [5:0] OP_MOV  = 6'b001111;
    localparam logic [5:0] OP_NOP  = 6'b010000;


    // =========================================================
    // ALU OPERATIONS
    // =========================================================

    localparam logic [3:0] ALU_ADD = 4'b0000;
    localparam logic [3:0] ALU_SUB = 4'b0001;
    localparam logic [3:0] ALU_MUL = 4'b0010;
    localparam logic [3:0] ALU_AND = 4'b0011;
    localparam logic [3:0] ALU_OR  = 4'b0100;
    localparam logic [3:0] ALU_XOR = 4'b0101;


    // =========================================================
    // FP OPERATIONS
    // =========================================================

    localparam logic [2:0] FP_ADD = 3'b000;
    localparam logic [2:0] FP_SUB = 3'b001;
    localparam logic [2:0] FP_MUL = 3'b010;
    localparam logic [2:0] FP_FMA = 3'b011;


    // =========================================================
    // FIELD EXTRACTION
    // =========================================================

    always_comb begin

        opcode = instruction[31:26];

        rd  = instruction[25:21];
        rs1 = instruction[20:16];

        rs2 = 5'b0;
        immediate = 16'b0;

        case (instruction[31:26])

            OP_ADD,
            OP_SUB,
            OP_MUL,
            OP_AND,
            OP_OR,
            OP_XOR,
            OP_FADD,
            OP_FSUB,
            OP_FMUL,
            OP_FFMA: begin

                rs2 = instruction[15:11];
                immediate = 16'b0;

            end

            OP_ADDI,
            OP_LD,
            OP_ST,
            OP_MOV: begin

                rs2 = 5'b0;
                immediate = instruction[15:0];

            end

            OP_BEQ,
            OP_BNE: begin

                rs2 = instruction[15:11];
                immediate = 16'b0;

            end

            default: begin

                rs2 = 5'b0;
                immediate = 16'b0;

            end

        endcase

    end


    // =========================================================
    // CONTROL DECODER
    // =========================================================

    always_comb begin

        // Default values
        reg_write   = 1'b0;
        mem_read    = 1'b0;
        mem_write   = 1'b0;
        branch      = 1'b0;
        fp_enable   = 1'b0;
        alu_src_imm = 1'b0;

        alu_op = ALU_ADD;
        fp_op  = FP_ADD;


        case (instruction[31:26])

            // -------------------------------------------------
            // ADD
            // -------------------------------------------------

            OP_ADD: begin
                reg_write = 1'b1;
                alu_op = ALU_ADD;
            end


            // -------------------------------------------------
            // SUB
            // -------------------------------------------------

            OP_SUB: begin
                reg_write = 1'b1;
                alu_op = ALU_SUB;
            end


            // -------------------------------------------------
            // MUL
            // -------------------------------------------------

            OP_MUL: begin
                reg_write = 1'b1;
                alu_op = ALU_MUL;
            end


            // -------------------------------------------------
            // AND
            // -------------------------------------------------

            OP_AND: begin
                reg_write = 1'b1;
                alu_op = ALU_AND;
            end


            // -------------------------------------------------
            // OR
            // -------------------------------------------------

            OP_OR: begin
                reg_write = 1'b1;
                alu_op = ALU_OR;
            end


            // -------------------------------------------------
            // XOR
            // -------------------------------------------------

            OP_XOR: begin
                reg_write = 1'b1;
                alu_op = ALU_XOR;
            end


            // -------------------------------------------------
            // ADD IMMEDIATE
            // -------------------------------------------------

            OP_ADDI: begin
                reg_write   = 1'b1;
                alu_src_imm = 1'b1;
                alu_op      = ALU_ADD;
            end


            // -------------------------------------------------
            // FADD
            // -------------------------------------------------

            OP_FADD: begin
                reg_write = 1'b1;
                fp_enable = 1'b1;
                fp_op = FP_ADD;
            end


            // -------------------------------------------------
            // FSUB
            // -------------------------------------------------

            OP_FSUB: begin
                reg_write = 1'b1;
                fp_enable = 1'b1;
                fp_op = FP_SUB;
            end


            // -------------------------------------------------
            // FMUL
            // -------------------------------------------------

            OP_FMUL: begin
                reg_write = 1'b1;
                fp_enable = 1'b1;
                fp_op = FP_MUL;
            end


            // -------------------------------------------------
            // FFMA
            // -------------------------------------------------

            OP_FFMA: begin
                reg_write = 1'b1;
                fp_enable = 1'b1;
                fp_op = FP_FMA;
            end


            // -------------------------------------------------
            // LOAD
            // -------------------------------------------------

            OP_LD: begin
                reg_write   = 1'b1;
                mem_read    = 1'b1;
                alu_src_imm = 1'b1;
                alu_op      = ALU_ADD;
            end


            // -------------------------------------------------
            // STORE
            // -------------------------------------------------

            OP_ST: begin
                reg_write   = 1'b0;
                mem_write   = 1'b1;
                alu_src_imm = 1'b1;
                alu_op      = ALU_ADD;
            end


            // -------------------------------------------------
            // BEQ
            // -------------------------------------------------

            OP_BEQ: begin
                branch = 1'b1;
                alu_op = ALU_SUB;
            end


            // -------------------------------------------------
            // BNE
            // -------------------------------------------------

            OP_BNE: begin
                branch = 1'b1;
                alu_op = ALU_SUB;
            end


            // -------------------------------------------------
            // MOV
            // -------------------------------------------------

            OP_MOV: begin
                reg_write   = 1'b1;
                alu_src_imm = 1'b1;
                alu_op      = ALU_ADD;
            end


            // -------------------------------------------------
            // NOP
            // -------------------------------------------------

            OP_NOP: begin
                reg_write   = 1'b0;
                mem_read    = 1'b0;
                mem_write   = 1'b0;
                branch      = 1'b0;
                fp_enable   = 1'b0;
                alu_src_imm = 1'b0;
            end


            // -------------------------------------------------
            // UNKNOWN
            // -------------------------------------------------

            default: begin
                reg_write   = 1'b0;
                mem_read    = 1'b0;
                mem_write   = 1'b0;
                branch      = 1'b0;
                fp_enable   = 1'b0;
                alu_src_imm = 1'b0;

                alu_op = ALU_ADD;
                fp_op  = FP_ADD;
            end

        endcase

    end

endmodule