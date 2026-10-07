module integer_alu (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [3:0]  alu_op,

    output logic [31:0] result,
    output logic        zero
);

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

    always_comb begin

        // Default result
        result = 32'b0;

        case (alu_op)

            ALU_ADD: begin
                result = A + B;
            end

            ALU_SUB: begin
                result = A - B;
            end

            ALU_MUL: begin
                result = A * B;
            end

            ALU_AND: begin
                result = A & B;
            end

            ALU_OR: begin
                result = A | B;
            end

            ALU_XOR: begin
                result = A ^ B;
            end

            ALU_NOT: begin
                result = ~A;
            end

            ALU_SLL: begin
                result = A << B[4:0];
            end

            ALU_SRL: begin
                result = A >> B[4:0];
            end

            ALU_SRA: begin
                result = $signed(A) >>> B[4:0];
            end

            ALU_SLT: begin
                result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            end

            ALU_SLTU: begin
                result = (A < B) ? 32'd1 : 32'd0;
            end

            default: begin
                result = 32'b0;
            end

        endcase

    end

    // Zero flag
    assign zero = (result == 32'b0);

endmodule