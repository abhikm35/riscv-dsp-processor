//=============================================================================
// SIMD (Single Instruction, Multiple Data) Unit
// Performs parallel operations on 4x 8-bit or 2x 16-bit data elements
//=============================================================================

module simd_unit (
    input wire clk,
    input wire rst_n,
    input wire enable,
    input wire [31:0] a,        // First operand
    input wire [31:0] b,        // Second operand
    input wire [2:0]  op,       // SIMD operation (000: ADD4, 001: SUB4, 010: MUL4, 011: AND4, 100: OR4, 101: XOR4, 110: SHIFT4, 111: reserved)
    input wire [1:0]  width,    // Data width (00: 8-bit, 01: 16-bit, 10: reserved, 11: reserved)
    input wire [2:0]  shift_amt, // Shift amount for SHIFT4 operation
    output reg [31:0] result,   // SIMD result
    output reg        overflow  // Overflow flag
);

    // Internal signals for 8-bit operations
    wire [7:0] a0, a1, a2, a3;
    wire [7:0] b0, b1, b2, b3;
    wire [8:0] sum0, sum1, sum2, sum3;
    wire [15:0] mul0, mul1, mul2, mul3;
    reg [7:0] res0, res1, res2, res3;
    
    // Internal signals for 16-bit operations
    wire [15:0] a16_0, a16_1;
    wire [15:0] b16_0, b16_1;
    wire [16:0] sum16_0, sum16_1;
    wire [31:0] mul16_0, mul16_1;
    reg [15:0] res16_0, res16_1;
    
    // Extract 8-bit elements
    assign a0 = a[7:0];
    assign a1 = a[15:8];
    assign a2 = a[23:16];
    assign a3 = a[31:24];
    assign b0 = b[7:0];
    assign b1 = b[15:8];
    assign b2 = b[23:16];
    assign b3 = b[31:24];
    
    // Extract 16-bit elements
    assign a16_0 = a[15:0];
    assign a16_1 = a[31:16];
    assign b16_0 = b[15:0];
    assign b16_1 = b[31:16];
    
    // 8-bit arithmetic operations
    assign sum0 = {1'b0, a0} + {1'b0, b0};
    assign sum1 = {1'b0, a1} + {1'b0, b1};
    assign sum2 = {1'b0, a2} + {1'b0, b2};
    assign sum3 = {1'b0, a3} + {1'b0, b3};
    
    assign mul0 = a0 * b0;
    assign mul1 = a1 * b1;
    assign mul2 = a2 * b2;
    assign mul3 = a3 * b3;
    
    // 16-bit arithmetic operations
    assign sum16_0 = {1'b0, a16_0} + {1'b0, b16_0};
    assign sum16_1 = {1'b0, a16_1} + {1'b0, b16_1};
    
    assign mul16_0 = a16_0 * b16_0;
    assign mul16_1 = a16_1 * b16_1;
    
    // SIMD operation execution
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= 32'h0;
            overflow <= 1'b0;
        end else if (enable) begin
            case (width)
                2'b00: begin // 8-bit operations
                    case (op)
                        3'b000: begin // ADD4
                            res0 <= sum0[8] ? 8'hFF : sum0[7:0];
                            res1 <= sum1[8] ? 8'hFF : sum1[7:0];
                            res2 <= sum2[8] ? 8'hFF : sum2[7:0];
                            res3 <= sum3[8] ? 8'hFF : sum3[7:0];
                            overflow <= sum0[8] | sum1[8] | sum2[8] | sum3[8];
                        end
                        3'b001: begin // SUB4
                            res0 <= (a0 >= b0) ? (a0 - b0) : 8'h0;
                            res1 <= (a1 >= b1) ? (a1 - b1) : 8'h0;
                            res2 <= (a2 >= b2) ? (a2 - b2) : 8'h0;
                            res3 <= (a3 >= b3) ? (a3 - b3) : 8'h0;
                            overflow <= 1'b0;
                        end
                        3'b010: begin // MUL4
                            res0 <= mul0[7:0];
                            res1 <= mul1[7:0];
                            res2 <= mul2[7:0];
                            res3 <= mul3[7:0];
                            overflow <= mul0[15:8] != 8'h0 | mul1[15:8] != 8'h0 | mul2[15:8] != 8'h0 | mul3[15:8] != 8'h0;
                        end
                        3'b011: begin // AND4
                            res0 <= a0 & b0;
                            res1 <= a1 & b1;
                            res2 <= a2 & b2;
                            res3 <= a3 & b3;
                            overflow <= 1'b0;
                        end
                        3'b100: begin // OR4
                            res0 <= a0 | b0;
                            res1 <= a1 | b1;
                            res2 <= a2 | b2;
                            res3 <= a3 | b3;
                            overflow <= 1'b0;
                        end
                        3'b101: begin // XOR4
                            res0 <= a0 ^ b0;
                            res1 <= a1 ^ b1;
                            res2 <= a2 ^ b2;
                            res3 <= a3 ^ b3;
                            overflow <= 1'b0;
                        end
                        3'b110: begin // SHIFT4
                            res0 <= a0 << shift_amt;
                            res1 <= a1 << shift_amt;
                            res2 <= a2 << shift_amt;
                            res3 <= a3 << shift_amt;
                            overflow <= 1'b0;
                        end
                        default: begin
                            res0 <= 8'h0;
                            res1 <= 8'h0;
                            res2 <= 8'h0;
                            res3 <= 8'h0;
                            overflow <= 1'b0;
                        end
                    endcase
                    result <= {res3, res2, res1, res0};
                end
                2'b01: begin // 16-bit operations
                    case (op)
                        3'b000: begin // ADD2
                            res16_0 <= sum16_0[16] ? 16'hFFFF : sum16_0[15:0];
                            res16_1 <= sum16_1[16] ? 16'hFFFF : sum16_1[15:0];
                            overflow <= sum16_0[16] | sum16_1[16];
                        end
                        3'b001: begin // SUB2
                            res16_0 <= (a16_0 >= b16_0) ? (a16_0 - b16_0) : 16'h0;
                            res16_1 <= (a16_1 >= b16_1) ? (a16_1 - b16_1) : 16'h0;
                            overflow <= 1'b0;
                        end
                        3'b010: begin // MUL2
                            res16_0 <= mul16_0[15:0];
                            res16_1 <= mul16_1[15:0];
                            overflow <= mul16_0[31:16] != 16'h0 | mul16_1[31:16] != 16'h0;
                        end
                        default: begin
                            res16_0 <= 16'h0;
                            res16_1 <= 16'h0;
                            overflow <= 1'b0;
                        end
                    endcase
                    result <= {res16_1, res16_0};
                end
                default: begin
                    result <= 32'h0;
                    overflow <= 1'b0;
                end
            endcase
        end
    end

endmodule
