module fp32_alu (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [31:0] C,
    input  logic [2:0]  fp_op,

    output logic [31:0] result,
    output logic        zero
);

    localparam logic [2:0] FP_ADD = 3'b000;
    localparam logic [2:0] FP_SUB = 3'b001;
    localparam logic [2:0] FP_MUL = 3'b010;
    localparam logic [2:0] FP_FMA = 3'b011;


    // =========================================================
    // FP32 ADD FUNCTION
    // =========================================================
    function automatic [31:0] fp32_add_core(
        input logic [31:0] x,
        input logic [31:0] y
    );

        logic sign_x;
        logic sign_y;
        logic sign_r;

        logic [7:0] exp_x;
        logic [7:0] exp_y;
        logic [7:0] exp_r;

        logic [22:0] frac_x;
        logic [22:0] frac_y;

        logic [23:0] mant_x;
        logic [23:0] mant_y;

        logic [24:0] mant_large;
        logic [24:0] mant_small;
        logic [24:0] mant_result;

        logic [7:0] exp_diff;

        integer i;

        begin

            sign_x = x[31];
            sign_y = y[31];

            exp_x = x[30:23];
            exp_y = y[30:23];

            frac_x = x[22:0];
            frac_y = y[22:0];

            exp_r = 8'd0;
            sign_r = 1'b0;

            if (exp_x != 0)
                mant_x = {1'b1, frac_x};
            else
                mant_x = {1'b0, frac_x};

            if (exp_y != 0)
                mant_y = {1'b1, frac_y};
            else
                mant_y = {1'b0, frac_y};


            // -------------------------------------------------
            // Zero cases
            // -------------------------------------------------

            if (x == 32'b0) begin

                fp32_add_core = y;

            end
            else if (y == 32'b0) begin

                fp32_add_core = x;

            end

            // -------------------------------------------------
            // Same sign -> addition
            // -------------------------------------------------

            else if (sign_x == sign_y) begin

                sign_r = sign_x;

                if (exp_x >= exp_y) begin

                    exp_r = exp_x;
                    exp_diff = exp_x - exp_y;

                    if (exp_diff >= 24)
                        mant_small = 25'd0;
                    else
                        mant_small = {1'b0, mant_y} >> exp_diff;

                    mant_large = {1'b0, mant_x};

                end
                else begin

                    exp_r = exp_y;
                    exp_diff = exp_y - exp_x;

                    if (exp_diff >= 24)
                        mant_small = 25'd0;
                    else
                        mant_small = {1'b0, mant_x} >> exp_diff;

                    mant_large = {1'b0, mant_y};

                end

                mant_result = mant_large + mant_small;

                // Normalize carry
                if (mant_result[24]) begin

                    mant_result = mant_result >> 1;

                    if (exp_r != 8'hFF)
                        exp_r = exp_r + 1'b1;

                end

                fp32_add_core =
                    {sign_r, exp_r, mant_result[22:0]};

            end

            // -------------------------------------------------
            // Different signs -> subtraction
            // -------------------------------------------------

            else begin

                if ({exp_x, mant_x} >= {exp_y, mant_y}) begin

                    sign_r = sign_x;
                    exp_r = exp_x;

                    exp_diff = exp_x - exp_y;

                    if (exp_diff >= 24)
                        mant_small = 25'd0;
                    else
                        mant_small = {1'b0, mant_y} >> exp_diff;

                    mant_large = {1'b0, mant_x};

                end
                else begin

                    sign_r = sign_y;
                    exp_r = exp_y;

                    exp_diff = exp_y - exp_x;

                    if (exp_diff >= 24)
                        mant_small = 25'd0;
                    else
                        mant_small = {1'b0, mant_x} >> exp_diff;

                    mant_large = {1'b0, mant_y};

                end

                mant_result = mant_large - mant_small;

                // Result is exactly zero
                if (mant_result == 0) begin

                    fp32_add_core = 32'b0;

                end
                else begin

                    // Normalize after subtraction
                    for (i = 0; i < 24; i = i + 1) begin

                        if ((mant_result[23] == 1'b0) &&
                            (exp_r > 0)) begin

                            mant_result = mant_result << 1;
                            exp_r = exp_r - 1'b1;

                        end

                    end

                    fp32_add_core =
                        {sign_r, exp_r, mant_result[22:0]};

                end

            end

        end

    endfunction


    // =========================================================
    // FP32 MULTIPLY FUNCTION
    // =========================================================
    function automatic [31:0] fp32_mul_core(
        input logic [31:0] x,
        input logic [31:0] y
    );

        logic sign_x;
        logic sign_y;
        logic sign_r;

        logic [7:0] exp_x;
        logic [7:0] exp_y;
        logic [7:0] exp_r;

        logic [22:0] frac_x;
        logic [22:0] frac_y;

        logic [23:0] mant_x;
        logic [23:0] mant_y;

        logic [47:0] product;

        begin

            sign_x = x[31];
            sign_y = y[31];

            exp_x = x[30:23];
            exp_y = y[30:23];

            frac_x = x[22:0];
            frac_y = y[22:0];

            sign_r = sign_x ^ sign_y;

            if (exp_x != 0)
                mant_x = {1'b1, frac_x};
            else
                mant_x = {1'b0, frac_x};

            if (exp_y != 0)
                mant_y = {1'b1, frac_y};
            else
                mant_y = {1'b0, frac_y};


            // Zero multiplication
            if ((x == 32'b0) || (y == 32'b0)) begin

                fp32_mul_core = 32'b0;

            end
            else begin

                product = mant_x * mant_y;

                exp_r = exp_x + exp_y - 8'd127;

                // Normalize product
                if (product[47]) begin

                    product = product >> 1;
                    exp_r = exp_r + 1'b1;

                end

                fp32_mul_core =
                    {sign_r, exp_r, product[45:23]};

            end

        end

    endfunction


    // =========================================================
    // MAIN FP32 ALU
    // =========================================================
    always_comb begin

        case (fp_op)

            FP_ADD: begin
                result = fp32_add_core(A, B);
            end

            FP_SUB: begin
                result = fp32_add_core(
                    A,
                    {~B[31], B[30:0]}
                );
            end

            FP_MUL: begin
                result = fp32_mul_core(A, B);
            end

            FP_FMA: begin
                // Baseline FMA:
                // result = (A * B) + C
                result = fp32_add_core(
                    fp32_mul_core(A, B),
                    C
                );
            end

            default: begin
                result = 32'b0;
            end

        endcase

        zero = (result == 32'b0);

    end

endmodule