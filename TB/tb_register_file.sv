`timescale 1ns/1ps

module tb_register_file;

    logic clk;
    logic reset;

    logic [4:0] read_addr1;
    logic [4:0] read_addr2;

    logic [31:0] read_data1;
    logic [31:0] read_data2;

    logic        write_enable;
    logic [4:0]  write_addr;
    logic [31:0] write_data;

    integer pass_count;
    integer fail_count;

    // =========================================================
    // DUT
    // =========================================================
    register_file dut (
        .clk(clk),
        .reset(reset),

        .read_addr1(read_addr1),
        .read_addr2(read_addr2),

        .read_data1(read_data1),
        .read_data2(read_data2),

        .write_enable(write_enable),
        .write_addr(write_addr),
        .write_data(write_data)
    );


    // =========================================================
    // Clock generation
    // =========================================================
    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end


    // =========================================================
    // Check task
    // =========================================================
    task check_value(
        input logic [31:0] expected,
        input logic [31:0] actual,
        input string test_name
    );
        begin

            if (actual === expected) begin

                $display(
                    "%-20s : PASS | Expected=%h Got=%h",
                    test_name,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "%-20s : FAIL | Expected=%h Got=%h",
                    test_name,
                    expected,
                    actual
                );

                fail_count = fail_count + 1;

            end

        end
    endtask


    // =========================================================
    // Test sequence
    // =========================================================
    initial begin

        pass_count = 0;
        fail_count = 0;

        reset       = 1'b1;
        read_addr1  = 5'd0;
        read_addr2  = 5'd0;

        write_enable = 1'b0;
        write_addr   = 5'd0;
        write_data   = 32'd0;

        $display("==============================================");
        $display("       CUSTOM GPU REGISTER FILE TEST");
        $display("==============================================");


        // =====================================================
        // TEST 1
        // Reset register file
        // =====================================================

        #12;

        reset = 1'b0;

        #2;

        read_addr1 = 5'd1;
        read_addr2 = 5'd2;

        #1;

        check_value(
            32'h00000000,
            read_data1,
            "RESET REG1"
        );

        check_value(
            32'h00000000,
            read_data2,
            "RESET REG2"
        );


        // =====================================================
        // TEST 2
        // Write register 1
        // =====================================================

        @(negedge clk);

        write_enable = 1'b1;
        write_addr   = 5'd1;
        write_data   = 32'h12345678;

        @(posedge clk);

        #1;

        write_enable = 1'b0;

        read_addr1 = 5'd1;

        #1;

        check_value(
            32'h12345678,
            read_data1,
            "WRITE REG1"
        );


        // =====================================================
        // TEST 3
        // Write register 2
        // =====================================================

        @(negedge clk);

        write_enable = 1'b1;
        write_addr   = 5'd2;
        write_data   = 32'hAABBCCDD;

        @(posedge clk);

        #1;

        write_enable = 1'b0;

        read_addr2 = 5'd2;

        #1;

        check_value(
            32'hAABBCCDD,
            read_data2,
            "WRITE REG2"
        );


        // =====================================================
        // TEST 4
        // Simultaneous dual read
        // =====================================================

        read_addr1 = 5'd1;
        read_addr2 = 5'd2;

        #1;

        check_value(
            32'h12345678,
            read_data1,
            "DUAL READ PORT1"
        );

        check_value(
            32'hAABBCCDD,
            read_data2,
            "DUAL READ PORT2"
        );


        // =====================================================
        // TEST 5
        // Write another register
        // =====================================================

        @(negedge clk);

        write_enable = 1'b1;
        write_addr   = 5'd10;
        write_data   = 32'hDEADBEEF;

        @(posedge clk);

        #1;

        write_enable = 1'b0;

        read_addr1 = 5'd10;

        #1;

        check_value(
            32'hDEADBEEF,
            read_data1,
            "WRITE REG10"
        );


        // =====================================================
        // TEST 6
        // Register isolation
        // =====================================================

        read_addr1 = 5'd1;
        read_addr2 = 5'd10;

        #1;

        check_value(
            32'h12345678,
            read_data1,
            "REG1 ISOLATION"
        );

        check_value(
            32'hDEADBEEF,
            read_data2,
            "REG10 ISOLATION"
        );


        // =====================================================
        // TEST 7
        // Attempt to write register 0
        // Register 0 must remain zero
        // =====================================================

        @(negedge clk);

        write_enable = 1'b1;
        write_addr   = 5'd0;
        write_data   = 32'hFFFFFFFF;

        @(posedge clk);

        #1;

        write_enable = 1'b0;

        read_addr1 = 5'd0;

        #1;

        check_value(
            32'h00000000,
            read_data1,
            "REG0 PROTECTION"
        );


        // =====================================================
        // TEST 8
        // Verify previously written registers remain intact
        // =====================================================

        read_addr1 = 5'd1;
        read_addr2 = 5'd2;

        #1;

        check_value(
            32'h12345678,
            read_data1,
            "REG1 RETENTION"
        );

        check_value(
            32'hAABBCCDD,
            read_data2,
            "REG2 RETENTION"
        );


        // =====================================================
        // Final result
        // =====================================================

        $display("----------------------------------------------");

        $display(
            "PASSED : %0d",
            pass_count
        );

        $display(
            "FAILED : %0d",
            fail_count
        );

        $display("----------------------------------------------");

        if (fail_count == 0)
            $display("ALL REGISTER FILE TESTS PASSED");
        else
            $display("REGISTER FILE TESTS FAILED");

        $display("==============================================");

        #10;

        $finish;

    end

endmodule