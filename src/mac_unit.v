//=============================================================================
// Hardware MAC (Multiply-Accumulate) Unit
// Optimized for DSP operations with saturation and rounding
//=============================================================================

module mac_unit (
    input wire clk,
    input wire rst_n,
    input wire enable,
    input wire [31:0] a,        // Multiplicand
    input wire [31:0] b,        // Multiplier
    input wire [31:0] c,        // Accumulator input
    input wire [1:0]  mode,     // 00: signed, 01: unsigned, 10: mixed, 11: reserved
    input wire        saturate, // Enable saturation
    input wire        round,    // Enable rounding
    output reg [31:0] result,   // MAC result
    output reg        overflow, // Overflow flag
    output reg        underflow // Underflow flag
);

    // Internal signals
    reg [63:0] product;
    reg [63:0] accumulator;
    reg [63:0] mac_result;
    reg [31:0] saturated_result;
    reg [31:0] rounded_result;
    
    // MAC operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            product <= 64'h0;
            accumulator <= 64'h0;
            mac_result <= 64'h0;
            result <= 32'h0;
            overflow <= 1'b0;
            underflow <= 1'b0;
        end else if (enable) begin
            // Perform multiplication based on mode
            case (mode)
                2'b00: product <= $signed(a) * $signed(b);  // Signed x Signed
                2'b01: product <= $unsigned(a) * $unsigned(b);  // Unsigned x Unsigned
                2'b10: product <= $signed(a) * $unsigned(b);  // Signed x Unsigned
                default: product <= 64'h0;
            endcase
            
            // Accumulate with previous result
            accumulator <= product + c;
            mac_result <= accumulator;
            
            // Check for overflow/underflow
            if (mode[1:0] == 2'b00) begin // Signed mode
                if (mac_result[63] != mac_result[31]) begin
                    overflow <= mac_result[63] == 1'b0;  // Positive overflow
                    underflow <= mac_result[63] == 1'b1; // Negative underflow
                end else begin
                    overflow <= 1'b0;
                    underflow <= 1'b0;
                end
            end else begin // Unsigned mode
                overflow <= mac_result[63:32] != 32'h0;
                underflow <= 1'b0;
            end
            
            // Apply saturation if enabled
            if (saturate) begin
                if (overflow && mode[1:0] == 2'b00) begin
                    saturated_result <= mac_result[63] ? 32'h80000000 : 32'h7FFFFFFF;
                end else if (overflow && mode[1:0] == 2'b01) begin
                    saturated_result <= 32'hFFFFFFFF;
                end else begin
                    saturated_result <= mac_result[31:0];
                end
            end else begin
                saturated_result <= mac_result[31:0];
            end
            
            // Apply rounding if enabled
            if (round) begin
                rounded_result <= saturated_result + (saturated_result[0] ? 1 : 0);
            end else begin
                rounded_result <= saturated_result;
            end
            
            result <= rounded_result;
        end
    end

endmodule
