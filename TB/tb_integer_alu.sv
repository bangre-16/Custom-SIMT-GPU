`timescale 1ns/1ps

module tb_integer_alu;

    logic [31:0] A;
    logic [31:0] B;
    logic [3:0]  alu_op;

    logic [31:0] result;
    logic        zero;

    integer pass_count;
    integer fail_count;

    // ALU operation codes
    localparam logic [3:0] ALU_ADD  = 4'b0000;
    localparam logic [3:0] ALU_SUB  = 4'b0001;
    localparam logic [3:0] ALU_MUL  = 4'b0010;
    localparam logic [3:0] ALU_AND  = 4'b0011;
    localparam logic [3:0] ALU_OR   = 4'b0100;
    localparam logic [3:0] ALU_XOR  = 4'b0101;
    localparam logic [3:0] ALU_NOT  = 4'b0110;
    localparam logic [3:0] ALU_SLL  = 4'b0111;
    localparam logic [3:0] ALU_SRL  = 4'b1000;
    localparam logic [3:0] ALU_SRA  = 4'b1001;
    localparam logic [3:0] ALU_SLT  = 4'b1010;
    localparam logic [3:0] ALU_SLTU = 4'b1011;

    // Instantiate ALU
    integer_alu dut (
        .A(A),
        .B(B),
        .alu_op(alu_op),
        .result(result),
        .zero(zero)
    );

    // Task for checking results
    task check_result(
        input logic [31:0] expected,
        input string test_name
    );
        begin
            #1;

            if (result === expected) begin
                $display("%-12s : PASS | A=%0d B=%0d Result=%0d",
                         test_name, A, B, result);
                pass_count = pass_count + 1;
            end
            else begin
                $display("%-12s : FAIL | Expected=%0d Got=%0d",
                         test_name, expected, result);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin

        pass_count = 0;
        fail_count = 0;

        A = 0;
        B = 0;
        alu_op = ALU_ADD;

        $display("========================================");
        $display("      CUSTOM GPU INTEGER ALU TEST");
        $display("========================================");

        // ADD
        A = 32'd10;
        B = 32'd5;
        alu_op = ALU_ADD;
        check_result(32'd15, "ADD");

        // SUB
        A = 32'd10;
        B = 32'd5;
        alu_op = ALU_SUB;
        check_result(32'd5, "SUB");

        // MUL
        A = 32'd10;
        B = 32'd5;
        alu_op = ALU_MUL;
        check_result(32'd50, "MUL");

        // AND
        A = 32'h0F0F0F0F;
        B = 32'h00FF00FF;
        alu_op = ALU_AND;
        check_result(32'h000F000F, "AND");

        // OR
        A = 32'h0F0F0000;
        B = 32'h0000FFFF;
        alu_op = ALU_OR;
        check_result(32'h0F0FFFFF, "OR");

        // XOR
        A = 32'hFFFF0000;
        B = 32'h00FFFF00;
        alu_op = ALU_XOR;
        check_result(32'hFF00FF00, "XOR");

        // NOT
        A = 32'h00000000;
        B = 32'd0;
        alu_op = ALU_NOT;
        check_result(32'hFFFFFFFF, "NOT");

        // SLL
        A = 32'd1;
        B = 32'd4;
        alu_op = ALU_SLL;
        check_result(32'd16, "SLL");

        // SRL
        A = 32'd16;
        B = 32'd2;
        alu_op = ALU_SRL;
        check_result(32'd4, "SRL");

        // SRA
        A = 32'hFFFFFFF0;
        B = 32'd2;
        alu_op = ALU_SRA;
        check_result(32'hFFFFFFFC, "SRA");

        // SLT
        A = 32'd5;
        B = 32'd10;
        alu_op = ALU_SLT;
        check_result(32'd1, "SLT");

        // SLTU
        A = 32'd10;
        B = 32'd5;
        alu_op = ALU_SLTU;
        check_result(32'd0, "SLTU");

        $display("----------------------------------------");
        $display("PASSED : %0d", pass_count);
        $display("FAILED : %0d", fail_count);
        $display("----------------------------------------");

        if (fail_count == 0)
            $display("ALL ALU TESTS PASSED");
        else
            $display("ALU TESTS FAILED");

        $display("========================================");

        #10;
        $finish;

    end

endmodule