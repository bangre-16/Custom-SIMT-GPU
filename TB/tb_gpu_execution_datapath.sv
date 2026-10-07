`timescale 1ns/1ps

module tb_gpu_execution_datapath;

    logic        clk;
    logic        reset;

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] immediate;

    logic        use_immediate;
    logic        fp_enable;

    logic [3:0]  alu_select;
    logic [2:0]  fp_select;

    logic        reg_write;

    logic [31:0] alu_result;
    logic        zero;

    logic [31:0] writeback_data;
    logic        writeback_enable;

    integer pass_count;
    integer fail_count;

    localparam logic [3:0] ALU_ADD = 4'b0000;
    localparam logic [3:0] ALU_SUB = 4'b0001;
    localparam logic [3:0] ALU_MUL = 4'b0010;
    localparam logic [3:0] ALU_AND = 4'b0011;

    localparam logic [2:0] FP_ADD = 3'b000;
    localparam logic [2:0] FP_SUB = 3'b001;
    localparam logic [2:0] FP_MUL = 3'b010;

    gpu_execution_datapath dut (
        .clk(clk),
        .reset(reset),

        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .immediate(immediate),

        .use_immediate(use_immediate),
        .fp_enable(fp_enable),

        .alu_select(alu_select),
        .fp_select(fp_select),

        .reg_write(reg_write),

        .alu_result(alu_result),
        .zero(zero),

        .writeback_data(writeback_data),
        .writeback_enable(writeback_enable)
    );

    /*
     * Clock
     */
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    /*
     * Result checker
     */
    task check_result(
        input logic [31:0] expected_result,
        input logic         expected_zero,
        input logic         expected_writeback,
        input string        test_name
    );
        begin

            #1;

            if ((alu_result === expected_result) &&
                (zero === expected_zero) &&
                (writeback_data === expected_result) &&
                (writeback_enable === expected_writeback)) begin

                $display(
                    "%-25s : PASS | Result=%h Zero=%0d WB=%0d",
                    test_name,
                    alu_result,
                    zero,
                    writeback_enable
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-25s : FAIL | Expected=%h Zero=%0d WB=%0d | Got=%h Zero=%0d WB=%0d",
                    test_name,
                    expected_result,
                    expected_zero,
                    expected_writeback,
                    alu_result,
                    zero,
                    writeback_enable
                );

                fail_count = fail_count + 1;

            end

        end
    endtask


    initial begin

        pass_count = 0;
        fail_count = 0;

        reset = 1'b1;

        rs1_data = 32'b0;
        rs2_data = 32'b0;
        immediate = 32'b0;

        use_immediate = 1'b0;
        fp_enable = 1'b0;

        alu_select = ALU_ADD;
        fp_select = FP_ADD;

        reg_write = 1'b0;

        $display("==============================================");
        $display("       CUSTOM GPU EXECUTION DATAPATH TEST");
        $display("==============================================");

        #12;
        reset = 1'b0;

        /*
         * 1. Integer ADD
         * 10 + 5 = 15
         */
        rs1_data = 32'd10;
        rs2_data = 32'd5;
        use_immediate = 1'b0;
        fp_enable = 1'b0;
        alu_select = ALU_ADD;
        reg_write = 1'b1;

        #10;
        check_result(32'd15, 1'b0, 1'b1, "INTEGER ADD");


        /*
         * 2. Integer SUB
         * 10 - 5 = 5
         */
        rs1_data = 32'd10;
        rs2_data = 32'd5;
        alu_select = ALU_SUB;

        #10;
        check_result(32'd5, 1'b0, 1'b1, "INTEGER SUB");


        /*
         * 3. Integer MUL
         * 6 × 7 = 42
         */
        rs1_data = 32'd6;
        rs2_data = 32'd7;
        alu_select = ALU_MUL;

        #10;
        check_result(32'd42, 1'b0, 1'b1, "INTEGER MUL");


        /*
         * 4. Immediate ADD
         * 20 + 12 = 32
         */
        rs1_data = 32'd20;
        rs2_data = 32'd99;
        immediate = 32'd12;

        use_immediate = 1'b1;
        alu_select = ALU_ADD;

        #10;
        check_result(32'd32, 1'b0, 1'b1, "IMMEDIATE ADD");


        /*
         * 5. Integer zero result
         * 10 - 10 = 0
         */
        rs1_data = 32'd10;
        rs2_data = 32'd10;

        use_immediate = 1'b0;
        alu_select = ALU_SUB;

        #10;
        check_result(32'd0, 1'b1, 1'b1, "INTEGER ZERO");


        /*
         * 6. FP32 ADD
         * 1.0 + 2.0 = 3.0
         */
        rs1_data = 32'h3F800000;
        rs2_data = 32'h40000000;

        fp_enable = 1'b1;
        fp_select = FP_ADD;

        #10;
        check_result(32'h40400000, 1'b0, 1'b1, "FP32 ADD");


        /*
         * 7. FP32 SUB
         * 5.0 - 2.0 = 3.0
         */
        rs1_data = 32'h40A00000;
        rs2_data = 32'h40000000;

        fp_select = FP_SUB;

        #10;
        check_result(32'h40400000, 1'b0, 1'b1, "FP32 SUB");


        /*
         * 8. FP32 MUL
         * 2.0 × 4.0 = 8.0
         */
        rs1_data = 32'h40000000;
        rs2_data = 32'h40800000;

        fp_select = FP_MUL;

        #10;
        check_result(32'h41000000, 1'b0, 1'b1, "FP32 MUL");


        /*
         * 9. Register write disabled
         */
        rs1_data = 32'd10;
        rs2_data = 32'd5;

        fp_enable = 1'b0;
        alu_select = ALU_ADD;
        reg_write = 1'b0;

        #10;
        check_result(32'd15, 1'b0, 1'b0, "WRITEBACK DISABLED");


        $display("----------------------------------------------");
        $display("PASSED : %0d", pass_count);
        $display("FAILED : %0d", fail_count);
        $display("----------------------------------------------");

        if (fail_count == 0)
            $display("ALL GPU EXECUTION DATAPATH TESTS PASSED");
        else
            $display("GPU EXECUTION DATAPATH TESTS FAILED");

        $display("==============================================");

        #10;
        $finish;

    end

endmodule