`timescale 1ns/1ps

module gpu_layout_top #(
    parameter NUM_SMS   = 4,
    parameter NUM_NODES = 4
)(
    // =========================================================
    // FPGA CLOCK / RESET
    // =========================================================

    input  logic clk,
    input  logic reset,

    // =========================================================
    // VISIBLE GPU OUTPUTS
    // 4 x 32-bit SM ALU results = 128 pins
    // =========================================================

    output logic [31:0] sm0_alu_result,
    output logic [31:0] sm1_alu_result,
    output logic [31:0] sm2_alu_result,
    output logic [31:0] sm3_alu_result,

    // =========================================================
    // SYSTEM STATUS SIGNATURE
    // Used to keep the memory / cache / NoC paths observable
    // =========================================================

    output logic [31:0] system_signature
);

    // =========================================================
    // INTERNAL HOST SIGNALS
    // =========================================================

    logic        host_valid;
    logic        host_write;
    logic [31:0] host_addr;
    logic [31:0] host_wdata;

    logic [31:0] host_rdata;
    logic        host_ready;

    // =========================================================
    // INTERNAL COMMAND / DISPATCH SIGNALS
    // =========================================================

    logic [31:0] command_data;
    logic        command_valid;
    logic        dispatch_busy;

    logic [31:0] instruction [0:NUM_SMS-1];
    logic        instruction_valid [0:NUM_SMS-1];

    // =========================================================
    // INTERNAL MULTI-SM SIGNALS
    // =========================================================

    logic [31:0] pc [0:NUM_SMS-1];
    logic [31:0] alu_result [0:NUM_SMS-1];
    logic        zero [0:NUM_SMS-1];

    logic [31:0] writeback_data [0:NUM_SMS-1];
    logic        writeback_enable [0:NUM_SMS-1];

    // =========================================================
    // INTERNAL MEMORY SIGNALS
    // =========================================================

    logic        load_enable;
    logic        store_enable;

    logic [31:0] base_address;
    logic [31:0] offset;
    logic [31:0] store_data;

    logic [31:0] load_data;

    logic        memory_ready;
    logic        memory_busy;

    logic        memory_ready_lsu;
    logic        memory_busy_lsu;

    logic        alignment_error;

    logic        l2_hit;
    logic        l2_miss;
    logic        l2_ready;

    // =========================================================
    // INTERNAL NoC SIGNALS
    // =========================================================

    logic [NUM_NODES-1:0] in_valid;
    logic [NUM_NODES-1:0][1:0] in_dest;
    logic [NUM_NODES-1:0][31:0] in_data;

    logic [NUM_NODES-1:0] out_valid;
    logic [NUM_NODES-1:0][31:0] out_data;
    logic [NUM_NODES-1:0] in_ready;

    logic [31:0] packet_count;

    // =========================================================
    // SYNTHESIS ACTIVITY COUNTER
    //
    // Generates deterministic activity so the physical design
    // contains active logic in the major integrated blocks.
    // =========================================================

    logic [7:0] activity_counter;

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin
            activity_counter <= 8'h00;
        end
        else begin
            activity_counter <= activity_counter + 8'h01;
        end

    end

    // =========================================================
    // HOST COMMAND GENERATION
    //
    // Commands are periodically issued to the GPU system.
    //
    // Phase 0 : ADD
    // Phase 1 : SUB
    // Phase 2 : MUL
    // Phase 3 : AND
    // Phase 4 : OR
    // Phase 5 : XOR
    // Phase 6 : ADDI
    // =========================================================

    always_comb begin

        host_valid = 1'b0;
        host_write = 1'b0;

        host_addr = 32'h00000000;

        host_wdata = 32'h00221800;

        case (activity_counter[5:2])

            4'd0: begin
                host_wdata =
                    32'b000000_00001_00010_00011_00000000000;
            end

            4'd1: begin
                host_wdata =
                    32'b000001_00001_00010_00100_00000000000;
            end

            4'd2: begin
                host_wdata =
                    32'b000010_00001_00010_00101_00000000000;
            end

            4'd3: begin
                host_wdata =
                    32'b000011_00001_00010_00110_00000000000;
            end

            4'd4: begin
                host_wdata =
                    32'b000100_00001_00010_00111_00000000000;
            end

            4'd5: begin
                host_wdata =
                    32'b000101_00001_00010_01000_00000000000;
            end

            // Correct custom GPU ADDI encoding:
            // opcode = 000110
            // rs1    = R1
            // immediate = 20
            // rd is zero because the current custom format
            // overlaps rd and immediate bits.
            4'd6: begin
                host_wdata = 32'h18200014;
            end

            default: begin
                host_wdata =
                    32'b000000_00001_00010_00011_00000000000;
            end

        endcase

        // Generate a write pulse periodically.
        if (activity_counter[1:0] == 2'b00) begin
            host_valid = 1'b1;
            host_write = 1'b1;
        end

    end

    // =========================================================
    // MEMORY TRAFFIC GENERATION
    // =========================================================

    always_comb begin

        load_enable  = 1'b0;
        store_enable = 1'b0;

        base_address = 32'h00000040;
        offset       = 32'h00000000;

        store_data = {
            activity_counter,
            activity_counter,
            activity_counter,
            activity_counter
        };

        case (activity_counter[5:2])

            4'd8: begin
                store_enable = 1'b1;
            end

            4'd9: begin
                load_enable = 1'b1;
            end

            4'd10: begin
                load_enable = 1'b1;
            end

            4'd11: begin
                store_enable = 1'b1;
            end

            default: begin
                load_enable  = 1'b0;
                store_enable = 1'b0;
            end

        endcase

    end

    // =========================================================
    // NoC TRAFFIC GENERATION
    // =========================================================

    always_comb begin

        in_valid = '0;
        in_dest  = '0;
        in_data  = '0;

        // Periodically inject packets into NoC input 0.
        if (activity_counter[5:2] == 4'd12) begin

            in_valid[0] = 1'b1;

            in_dest[0] =
                activity_counter[1:0];

            in_data[0] = {
                24'hC0DE00,
                activity_counter
            };

        end

    end

    // =========================================================
    // FULL GPU SYSTEM
    // =========================================================

    full_gpu_system #(
        .NUM_SMS(NUM_SMS),
        .NUM_NODES(NUM_NODES)
    ) full_gpu_system_inst (

        .clk(clk),
        .reset(reset),

        // HOST
        .host_valid(host_valid),
        .host_write(host_write),
        .host_addr(host_addr),
        .host_wdata(host_wdata),

        .host_rdata(host_rdata),
        .host_ready(host_ready),

        // COMMAND / DISPATCH
        .command_data(command_data),
        .command_valid(command_valid),
        .dispatch_busy(dispatch_busy),

        .instruction(instruction),
        .instruction_valid(instruction_valid),

        // MULTI-SM
        .pc(pc),
        .alu_result(alu_result),
        .zero(zero),
        .writeback_data(writeback_data),
        .writeback_enable(writeback_enable),

        // MEMORY
        .load_enable(load_enable),
        .store_enable(store_enable),
        .base_address(base_address),
        .offset(offset),
        .store_data(store_data),

        .load_data(load_data),

        .memory_ready(memory_ready),
        .memory_busy(memory_busy),

        .memory_ready_lsu(memory_ready_lsu),
        .memory_busy_lsu(memory_busy_lsu),

        .alignment_error(alignment_error),

        .l2_hit(l2_hit),
        .l2_miss(l2_miss),
        .l2_ready(l2_ready),

        // NoC
        .in_valid(in_valid),
        .in_dest(in_dest),
        .in_data(in_data),

        .out_valid(out_valid),
        .out_data(out_data),
        .in_ready(in_ready),

        .packet_count(packet_count)

    );

    // =========================================================
    // EXPORT FOUR SM RESULTS
    // =========================================================

    assign sm0_alu_result = alu_result[0];
    assign sm1_alu_result = alu_result[1];
    assign sm2_alu_result = alu_result[2];
    assign sm3_alu_result = alu_result[3];

    // =========================================================
    // SYSTEM SIGNATURE
    //
    // Makes the major subsystem outputs observable at the
    // top-level and discourages synthesis from removing them.
    // =========================================================

    always_comb begin

        system_signature =
              pc[0]
            ^ pc[1]
            ^ pc[2]
            ^ pc[3]
            ^ load_data
            ^ packet_count
            ^ {
                27'h0,
                memory_busy,
                memory_ready,
                alignment_error,
                l2_hit,
                l2_miss,
                l2_ready
              }
            ^ {
                30'h0,
                command_valid,
                dispatch_busy
              };

    end

endmodule