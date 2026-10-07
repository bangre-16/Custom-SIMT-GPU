`timescale 1ns/1ps

module gpu_control_unit (

    input  logic [5:0] opcode,

    output logic [1:0] execution_unit,

    output logic [3:0] alu_select,
    output logic [2:0] fp_select,

    output logic       reg_write,
    output logic       mem_read,
    output logic       mem_write,
    output logic       branch,
    output logic       use_immediate

);

    // =========================================================
    // Execution unit selection
    // =========================================================

    localparam logic [1:0] UNIT_NONE    = 2'b00;
    localparam logic [1:0] UNIT_INTEGER = 2'b01;
    localparam logic [1:0] UNIT_FP32    = 2'b10;
    localparam logic [1:0] UNIT_MEMORY  = 2'b11;


    // =========================================================
    // Opcodes
    // =========================================================

    localparam logic [5:0] OP_ADD  = 6'b000000;
    localparam logic [5:0] OP_SUB  = 6'b000001;
    localparam logic [5:0] OP_MUL  = 6'b000010;

    localparam logic [5:0] OP_FADD = 6'b000011;
    localparam logic [5:0] OP_FSUB = 6'b000100;
    localparam logic [5:0] OP_FMUL = 6'b000101;
    localparam logic [5:0] OP_FFMA = 6'b000110;

    localparam logic [5:0] OP_AND  = 6'b000111;
    localparam logic [5:0] OP_OR   = 6'b001000;
    localparam logic [5:0] OP_XOR  = 6'b001001;

    localparam logic [5:0] OP_LD   = 6'b001010;
    localparam logic [5:0] OP_ST   = 6'b001011;

    localparam logic [5:0] OP_BEQ  = 6'b001100;
    localparam logic [5:0] OP_BNE  = 6'b001101;

    localparam logic [5:0] OP_MOV  = 6'b001110;
    localparam logic [5:0] OP_NOP  = 6'b001111;


    // =========================================================
    // Integer ALU operations
    // =========================================================

    localparam logic [3:0] ALU_ADD = 4'b0000;
    localparam logic [3:0] ALU_SUB = 4'b0001;
    localparam logic [3:0] ALU_MUL = 4'b0010;
    localparam logic [3:0] ALU_AND = 4'b0011;
    localparam logic [3:0] ALU_OR  = 4'b0100;
    localparam logic [3:0] ALU_XOR = 4'b0101;


    // =========================================================
    // FP32 operations
    // =========================================================

    localparam logic [2:0] FP_ADD = 3'b000;
    localparam logic [2:0] FP_SUB = 3'b001;
    localparam logic [2:0] FP_MUL = 3'b010;
    localparam logic [2:0] FP_FMA = 3'b011;


    // =========================================================
    // Control decoding
    // =========================================================

    always_comb begin

        // -----------------------------------------------------
        // Safe defaults
        // -----------------------------------------------------

        execution_unit = UNIT_NONE;

        alu_select = ALU_ADD;
        fp_select  = FP_ADD;

        reg_write = 1'b0;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        branch    = 1'b0;

        use_immediate = 1'b0;


        // -----------------------------------------------------
        // Decode opcode
        // -----------------------------------------------------

        case (opcode)

            // =================================================
            // INTEGER EXECUTION
            // =================================================

            OP_ADD: begin

                execution_unit = UNIT_INTEGER;
                alu_select = ALU_ADD;
                reg_write = 1'b1;

            end


            OP_SUB: begin

                execution_unit = UNIT_INTEGER;
                alu_select = ALU_SUB;
                reg_write = 1'b1;

            end


            OP_MUL: begin

                execution_unit = UNIT_INTEGER;
                alu_select = ALU_MUL;
                reg_write = 1'b1;

            end


            OP_AND: begin

                execution_unit = UNIT_INTEGER;
                alu_select = ALU_AND;
                reg_write = 1'b1;

            end


            OP_OR: begin

                execution_unit = UNIT_INTEGER;
                alu_select = ALU_OR;
                reg_write = 1'b1;

            end


            OP_XOR: begin

                execution_unit = UNIT_INTEGER;
                alu_select = ALU_XOR;
                reg_write = 1'b1;

            end


            // =================================================
            // FP32 EXECUTION
            // =================================================

            OP_FADD: begin

                execution_unit = UNIT_FP32;
                fp_select = FP_ADD;
                reg_write = 1'b1;

            end


            OP_FSUB: begin

                execution_unit = UNIT_FP32;
                fp_select = FP_SUB;
                reg_write = 1'b1;

            end


            OP_FMUL: begin

                execution_unit = UNIT_FP32;
                fp_select = FP_MUL;
                reg_write = 1'b1;

            end


            OP_FFMA: begin

                execution_unit = UNIT_FP32;
                fp_select = FP_FMA;
                reg_write = 1'b1;

            end


            // =================================================
            // LOAD
            // =================================================

            OP_LD: begin

                execution_unit = UNIT_MEMORY;

                mem_read = 1'b1;
                reg_write = 1'b1;
                use_immediate = 1'b1;

                alu_select = ALU_ADD;

            end


            // =================================================
            // STORE
            // =================================================

            OP_ST: begin

                execution_unit = UNIT_MEMORY;

                mem_write = 1'b1;
                use_immediate = 1'b1;

                alu_select = ALU_ADD;

            end


            // =================================================
            // BRANCH EQUAL
            // =================================================

            OP_BEQ: begin

                execution_unit = UNIT_INTEGER;

                branch = 1'b1;
                alu_select = ALU_SUB;

            end


            // =================================================
            // BRANCH NOT EQUAL
            // =================================================

            OP_BNE: begin

                execution_unit = UNIT_INTEGER;

                branch = 1'b1;
                alu_select = ALU_SUB;

            end


            // =================================================
            // MOVE
            // =================================================

            OP_MOV: begin

                execution_unit = UNIT_INTEGER;

                alu_select = ALU_ADD;
                reg_write = 1'b1;
                use_immediate = 1'b1;

            end


            // =================================================
            // NOP
            // =================================================

            OP_NOP: begin

                execution_unit = UNIT_NONE;

            end


            // =================================================
            // UNKNOWN OPCODE
            // =================================================

            default: begin

                execution_unit = UNIT_NONE;

            end

        endcase

    end

endmodule