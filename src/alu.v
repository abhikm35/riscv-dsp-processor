//=============================================================================
// Arithmetic Logic Unit (ALU) with DSP extensions
// Supports standard RISC-V operations plus DSP-specific functions
//=============================================================================

module alu (
    input wire [31:0] a,        // First operand
    input wire [31:0] b,        // Second operand
    input wire [4:0]  alu_op,   // ALU operation
    input wire        saturate, // Enable saturation
    output reg [31:0] result,   // ALU result
    output reg        zero,     // Zero flag
    output reg        overflow, // Overflow flag
    output reg        carry,    // Carry flag
    output reg        negative  // Negative flag
);

    // Internal signals
    reg [32:0] temp_result;
    reg [31:0] saturated_result;
    
    // ALU operations
    always @(*) begin
        case (alu_op)
            // Standard RISC-V operations
            5'b00000: temp_result = {1'b0, a + b};           // ADD
            5'b00001: temp_result = {1'b0, a - b};           // SUB
            5'b00010: temp_result = {1'b0, a & b};           // AND
            5'b00011: temp_result = {1'b0, a | b};           // OR
            5'b00100: temp_result = {1'b0, a ^ b};           // XOR
            5'b00101: temp_result = {1'b0, a << b[4:0]};     // SLL
            5'b00110: temp_result = {1'b0, a >> b[4:0]};     // SRL
            5'b00111: temp_result = {1'b0, $signed(a) >>> b[4:0]}; // SRA
            5'b01000: temp_result = {1'b0, a < b ? 32'h1 : 32'h0}; // SLT
            5'b01001: temp_result = {1'b0, $unsigned(a) < $unsigned(b) ? 32'h1 : 32'h0}; // SLTU
            
            // DSP-specific operations
            5'b01010: temp_result = {1'b0, a + b + 1};       // ADDI (with increment)
            5'b01011: temp_result = {1'b0, a - b - 1};       // SUBI (with decrement)
            5'b01100: temp_result = {1'b0, a << 1};          // LSL1 (logical shift left 1)
            5'b01101: temp_result = {1'b0, a >> 1};          // LSR1 (logical shift right 1)
            5'b01110: temp_result = {1'b0, $signed(a) >>> 1}; // ASR1 (arithmetic shift right 1)
            5'b01111: temp_result = {1'b0, ~a};              // NOT
            5'b10000: temp_result = {1'b0, -a};              // NEG
            5'b10001: temp_result = {1'b0, a + 1};           // INC
            5'b10010: temp_result = {1'b0, a - 1};           // DEC
            5'b10011: temp_result = {1'b0, a == b ? 32'h1 : 32'h0}; // EQ
            5'b10100: temp_result = {1'b0, a != b ? 32'h1 : 32'h0}; // NE
            
            // Saturation operations
            5'b10101: begin // SAT (saturate to 16-bit)
                if (a[31:15] == 17'h0 || a[31:15] == 17'h1FFFF) begin
                    temp_result = {1'b0, a[15:0]};
                end else if (a[31] == 1'b0) begin
                    temp_result = {1'b0, 32'h00007FFF}; // Positive saturation
                end else begin
                    temp_result = {1'b0, 32'hFFFF8000}; // Negative saturation
                end
            end
            5'b10110: begin // CLIP (clip to range)
                if (a >= b) begin
                    temp_result = {1'b0, b};
                end else if (a <= -b) begin
                    temp_result = {1'b0, -b};
                end else begin
                    temp_result = {1'b0, a};
                end
            end
            5'b10111: begin // ROUND (round to nearest)
                temp_result = {1'b0, a + (a[0] ? 1 : 0)};
            end
            
            // Bit manipulation operations
            5'b11000: temp_result = {1'b0, a & (32'h1 << b[4:0])}; // BIT_TEST
            5'b11001: temp_result = {1'b0, a | (32'h1 << b[4:0])}; // BIT_SET
            5'b11010: temp_result = {1'b0, a & ~(32'h1 << b[4:0])}; // BIT_CLEAR
            5'b11011: temp_result = {1'b0, a ^ (32'h1 << b[4:0])}; // BIT_TOGGLE
            
            default: temp_result = {1'b0, 32'h0};
        endcase
        
        // Apply saturation if enabled
        if (saturate && (alu_op == 5'b00000 || alu_op == 5'b00001)) begin
            if (temp_result[32] != temp_result[31]) begin // Overflow detected
                if (temp_result[31] == 1'b0) begin
                    saturated_result = 32'h7FFFFFFF; // Positive saturation
                end else begin
                    saturated_result = 32'h80000000; // Negative saturation
                end
            end else begin
                saturated_result = temp_result[31:0];
            end
        end else begin
            saturated_result = temp_result[31:0];
        end
        
        result = saturated_result;
        
        // Set flags
        zero = (saturated_result == 32'h0);
        overflow = (temp_result[32] != temp_result[31]) && (alu_op == 5'b00000 || alu_op == 5'b00001);
        carry = temp_result[32];
        negative = saturated_result[31];
    end

endmodule
