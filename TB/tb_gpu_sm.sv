`timescale 1ns/1ps

module tb_gpu_sm;

    // ============================================================
    // SIGNALS
    // ============================================================

    logic        clk;
    logic        reset;
    logic [31:0] instruction;

    logic [31:0] pc;
    logic [31:0] alu_result;
    logic        zero;
    logic [31:0] writeback_data;
    logic        writeback_enable;

    integer passed;
    integer failed;


    // ============================================================
    // DUT
    // ============================================================

    gpu_sm dut (

        .clk              (clk),
        .reset            (reset),
        .instruction      (instruction),

        .pc               (pc),
        .alu_result       (alu_result),
        .zero             (zero),
        .writeback_data   (writeback_data),
        .writeback_enable (writeback_enable)

    );


    // ============================================================
    // CLOCK
    // ============================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end


    // ============================================================
    // R-TYPE INSTRUCTION ENCODER
    //
    // [31:26] opcode
    // [25:21] rs1
    // [20:16] rs2
    // [15:11] rd
    // ============================================================

    function automatic [31:0] make_rtype (

        input [5:0] op,
        input [4:0] r1,
        input [4:0] r2,
        input [4:0] rd_addr

    );

        begin

            make_rtype = {

                op,
                r1,
                r2,
                rd_addr,
                11'd0

            };

        end

    endfunction


    // ============================================================
    // I-TYPE / ADDI INSTRUCTION ENCODER
    //
    // ADDI:
    // rs1 + immediate
    // ============================================================

    function automatic [31:0] make_itype (

        input [5:0] op,
        input [4:0] r1,
        input [4:0] rd_addr,
        input [15:0] imm

    );

        begin

            make_itype = 32'd0;

            make_itype[31:26] = op;
            make_itype[25:21] = r1;
            make_itype[20:16] = 5'd0;
            make_itype[15:11] = rd_addr;
            make_itype[15:0]  = imm;

        end

    endfunction


    // ============================================================
    // RESULT CHECK
    // ============================================================

    task automatic check_result (

        input [127:0] test_name,
        input [31:0] expected

    );

        begin

            #1;

            if (alu_result === expected) begin

                $display(
                    "%-22s : PASS | Expected=%h Got=%h",
                    test_name,
                    expected,
                    alu_result
                );

                passed = passed + 1;

            end

            else begin

                $display(
                    "%-22s : FAIL | Expected=%h Got=%h",
                    test_name,
                    expected,
                    alu_result
                );

                failed = failed + 1;

            end

        end

    endtask


    // ============================================================
    // BOOLEAN CHECK
    // ============================================================

    task automatic check_signal (

        input [127:0] test_name,
        input          expected,
        input          actual

    );

        begin

            #1;

            if (actual === expected) begin

                $display(
                    "%-22s : PASS | Expected=%b Got=%b",
                    test_name,
                    expected,
                    actual
                );

                passed = passed + 1;

            end

            else begin

                $display(
                    "%-22s : FAIL | Expected=%b Got=%b",
                    test_name,
                    expected,
                    actual
                );

                failed = failed + 1;

            end

        end

    endtask


    // ============================================================
    // TEST SEQUENCE
    // ============================================================

    initial begin

        passed = 0;
        failed = 0;

        instruction = 32'd0;
        reset       = 1'b1;


        // ========================================================
        // RESET
        // ========================================================

        #12;

        reset = 1'b0;

        #3;


        $display("");
        $display("==================================================");
        $display("          INTEGRATED GPU SM TEST");
        $display("==================================================");
        $display("");


        // ========================================================
        // TEST 1 : ADD
        //
        // R1 = 10
        // R2 = 5
        // R3 = R1 + R2
        //
        // Expected = 15
        // ========================================================

        instruction = make_rtype(

            6'b000000,
            5'd1,
            5'd2,
            5'd3

        );

        check_result(
            "SM ADD",
            32'd15
        );

        @(posedge clk);
        #1;


        // ========================================================
        // TEST 2 : SUB
        //
        // 10 - 5 = 5
        // ========================================================

        instruction = make_rtype(

            6'b000001,
            5'd1,
            5'd2,
            5'd3

        );

        check_result(
            "SM SUB",
            32'd5
        );

        @(posedge clk);
        #1;


        // ========================================================
        // TEST 3 : MUL
        //
        // 10 * 5 = 50
        // ========================================================

        instruction = make_rtype(

            6'b000010,
            5'd1,
            5'd2,
            5'd3

        );

        check_result(
            "SM MUL",
            32'd50
        );

        @(posedge clk);
        #1;


        // ========================================================
        // TEST 4 : AND
        //
        // 10 & 5 = 0
        // ========================================================

        instruction = make_rtype(

            6'b000011,
            5'd1,
            5'd2,
            5'd3

        );

        check_result(
            "SM AND",
            32'd0
        );

        @(posedge clk);
        #1;


        // ========================================================
        // TEST 5 : OR
        //
        // 10 | 5 = 15
        // ========================================================

        instruction = make_rtype(

            6'b000100,
            5'd1,
            5'd2,
            5'd3

        );

        check_result(
            "SM OR",
            32'd15
        );

        @(posedge clk);
        #1;


        // ========================================================
        // TEST 6 : XOR
        //
        // 10 ^ 5 = 15
        // ========================================================

        instruction = make_rtype(

            6'b000101,
            5'd1,
            5'd2,
            5'd3

        );

        check_result(
            "SM XOR",
            32'd15
        );

        @(posedge clk);
        #1;


        // ========================================================
        // TEST 7 : ADDI
        //
        // R1 + 20
        // 10 + 20 = 30
        // ========================================================

        instruction = make_itype(

            6'b000110,
            5'd1,
            5'd4,
            16'd20

        );

        check_result(
            "SM ADDI",
            32'd30
        );

        @(posedge clk);
        #1;


        // ========================================================
        // TEST 8 : ZERO RESULT
        //
        // R1 - R1 = 0
        // ========================================================

        instruction = make_rtype(

            6'b000001,
            5'd1,
            5'd1,
            5'd5

        );

        check_result(
            "SM ZERO RESULT",
            32'd0
        );

        check_signal(
            "SM ZERO FLAG",
            1'b1,
            zero
        );


        // ========================================================
        // CHECK WRITEBACK
        // ========================================================

        check_signal(
            "SM WRITE ENABLE",
            1'b1,
            writeback_enable
        );


        // ========================================================
        // FINAL RESULT
        // ========================================================

        $display("");
        $display("--------------------------------------------------");

        $display(
            "PASSED : %0d",
            passed
        );

        $display(
            "FAILED : %0d",
            failed
        );

        $display("--------------------------------------------------");


        if (failed == 0) begin

            $display(
                "ALL INTEGRATED GPU SM TESTS PASSED"
            );

        end

        else begin

            $display(
                "INTEGRATED GPU SM TESTS FAILED"
            );

        end


        $display("==================================================");
        $display("");


        #10;

        $finish;

    end

endmodule