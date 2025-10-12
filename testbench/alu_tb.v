//=============================================================================
// Testbench for ALU
// Verifies arithmetic and logic operations
//=============================================================================

`timescale 1ns/1ps

module alu_tb;

    // Testbench signals
    reg [31:0] a, b;
    reg [4:0] alu_op;
    reg saturate;
    wire [31:0] result;
    wire zero, overflow, carry, negative;
    
    // Instantiate ALU
    alu dut (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .saturate(saturate),
        .result(result),
        .zero(zero),
        .overflow(overflow),
        .carry(carry),
        .negative(negative)
    );
    
    // Test stimulus
    initial begin
        $display("ALU Testbench Starting...");
        
        // Initialize signals
        a = 0;
        b = 0;
        alu_op = 0;
        saturate = 0;
        
        // Test 1: ADD operation
        $display("\nTest 1: ADD operation");
        a = 32'h00000010;
        b = 32'h00000020;
        alu_op = 5'b00000; // ADD
        saturate = 0;
        #10;
        $display("a=%d, b=%d, result=%d", a, b, result);
        if (result == 32'h00000030) $display("PASS: ADD");
        else $display("FAIL: ADD");
        
        // Test 2: SUB operation
        $display("\nTest 2: SUB operation");
        a = 32'h00000030;
        b = 32'h00000010;
        alu_op = 5'b00001; // SUB
        saturate = 0;
        #10;
        $display("a=%d, b=%d, result=%d", a, b, result);
        if (result == 32'h00000020) $display("PASS: SUB");
        else $display("FAIL: SUB");
        
        // Test 3: AND operation
        $display("\nTest 3: AND operation");
        a = 32'hFF00FF00;
        b = 32'hF0F0F0F0;
        alu_op = 5'b00010; // AND
        saturate = 0;
        #10;
        $display("a=%h, b=%h, result=%h", a, b, result);
        if (result == 32'hF000F000) $display("PASS: AND");
        else $display("FAIL: AND");
        
        // Test 4: OR operation
        $display("\nTest 4: OR operation");
        a = 32'hFF00FF00;
        b = 32'hF0F0F0F0;
        alu_op = 5'b00011; // OR
        saturate = 0;
        #10;
        $display("a=%h, b=%h, result=%h", a, b, result);
        if (result == 32'hFFF0FFF0) $display("PASS: OR");
        else $display("FAIL: OR");
        
        // Test 5: XOR operation
        $display("\nTest 5: XOR operation");
        a = 32'hFF00FF00;
        b = 32'hF0F0F0F0;
        alu_op = 5'b00100; // XOR
        saturate = 0;
        #10;
        $display("a=%h, b=%h, result=%h", a, b, result);
        if (result == 32'h0FF00FF0) $display("PASS: XOR");
        else $display("FAIL: XOR");
        
        // Test 6: SLL operation
        $display("\nTest 6: SLL operation");
        a = 32'h00000001;
        b = 32'h00000004; // Shift by 4
        alu_op = 5'b00101; // SLL
        saturate = 0;
        #10;
        $display("a=%h, b=%h, result=%h", a, b, result);
        if (result == 32'h00000010) $display("PASS: SLL");
        else $display("FAIL: SLL");
        
        // Test 7: SRL operation
        $display("\nTest 7: SRL operation");
        a = 32'h00000010;
        b = 32'h00000004; // Shift by 4
        alu_op = 5'b00110; // SRL
        saturate = 0;
        #10;
        $display("a=%h, b=%h, result=%h", a, b, result);
        if (result == 32'h00000001) $display("PASS: SRL");
        else $display("FAIL: SRL");
        
        // Test 8: SRA operation
        $display("\nTest 8: SRA operation");
        a = 32'h80000000; // Negative number
        b = 32'h00000004; // Shift by 4
        alu_op = 5'b00111; // SRA
        saturate = 0;
        #10;
        $display("a=%h, b=%h, result=%h", a, b, result);
        if (result == 32'hF8000000) $display("PASS: SRA");
        else $display("FAIL: SRA");
        
        // Test 9: SLT operation
        $display("\nTest 9: SLT operation");
        a = 32'h00000010;
        b = 32'h00000020;
        alu_op = 5'b01000; // SLT
        saturate = 0;
        #10;
        $display("a=%d, b=%d, result=%d", a, b, result);
        if (result == 32'h00000001) $display("PASS: SLT");
        else $display("FAIL: SLT");
        
        // Test 10: SLTU operation
        $display("\nTest 10: SLTU operation");
        a = 32'hFFFFFFFF; // -1 signed, but large unsigned
        b = 32'h00000001; // 1
        alu_op = 5'b01001; // SLTU
        saturate = 0;
        #10;
        $display("a=%h, b=%h, result=%d", a, b, result);
        if (result == 32'h00000000) $display("PASS: SLTU");
        else $display("FAIL: SLTU");
        
        // Test 11: Saturation operation
        $display("\nTest 11: Saturation operation");
        a = 32'h7FFFFFFF; // Max positive
        b = 32'h00000001; // 1
        alu_op = 5'b00000; // ADD
        saturate = 1;
        #10;
        $display("a=%h, b=%h, result=%h, overflow=%b", a, b, result, overflow);
        if (overflow && result == 32'h7FFFFFFF) $display("PASS: Saturation");
        else $display("FAIL: Saturation");
        
        // Test 12: SAT operation (16-bit saturation)
        $display("\nTest 12: SAT operation");
        a = 32'h00010000; // 65536 (over 16-bit range)
        b = 32'h00000000; // Not used
        alu_op = 5'b10101; // SAT
        saturate = 0;
        #10;
        $display("a=%h, result=%h", a, result);
        if (result == 32'h00007FFF) $display("PASS: SAT");
        else $display("FAIL: SAT");
        
        // Test 13: CLIP operation
        $display("\nTest 13: CLIP operation");
        a = 32'h00001000; // 4096
        b = 32'h00000800; // 2048 (clip limit)
        alu_op = 5'b10110; // CLIP
        saturate = 0;
        #10;
        $display("a=%h, b=%h, result=%h", a, b, result);
        if (result == 32'h00000800) $display("PASS: CLIP");
        else $display("FAIL: CLIP");
        
        // Test 14: ROUND operation
        $display("\nTest 14: ROUND operation");
        a = 32'h00000001; // 1 (odd number)
        b = 32'h00000000; // Not used
        alu_op = 5'b10111; // ROUND
        saturate = 0;
        #10;
        $display("a=%h, result=%h", a, result);
        if (result == 32'h00000002) $display("PASS: ROUND");
        else $display("FAIL: ROUND");
        
        // Test 15: NOT operation
        $display("\nTest 15: NOT operation");
        a = 32'hFF00FF00;
        b = 32'h00000000; // Not used
        alu_op = 5'b01111; // NOT
        saturate = 0;
        #10;
        $display("a=%h, result=%h", a, result);
        if (result == 32'h00FF00FF) $display("PASS: NOT");
        else $display("FAIL: NOT");
        
        // Test 16: NEG operation
        $display("\nTest 16: NEG operation");
        a = 32'h00000010; // 16
        b = 32'h00000000; // Not used
        alu_op = 5'b10000; // NEG
        saturate = 0;
        #10;
        $display("a=%h, result=%h", a, result);
        if (result == 32'hFFFFFFF0) $display("PASS: NEG");
        else $display("FAIL: NEG");
        
        // Test 17: INC operation
        $display("\nTest 17: INC operation");
        a = 32'h0000000F; // 15
        b = 32'h00000000; // Not used
        alu_op = 5'b10001; // INC
        saturate = 0;
        #10;
        $display("a=%h, result=%h", a, result);
        if (result == 32'h00000010) $display("PASS: INC");
        else $display("FAIL: INC");
        
        // Test 18: DEC operation
        $display("\nTest 18: DEC operation");
        a = 32'h00000010; // 16
        b = 32'h00000000; // Not used
        alu_op = 5'b10010; // DEC
        saturate = 0;
        #10;
        $display("a=%h, result=%h", a, result);
        if (result == 32'h0000000F) $display("PASS: DEC");
        else $display("FAIL: DEC");
        
        // Test 19: EQ operation
        $display("\nTest 19: EQ operation");
        a = 32'h00000010;
        b = 32'h00000010;
        alu_op = 5'b10011; // EQ
        saturate = 0;
        #10;
        $display("a=%h, b=%h, result=%h", a, b, result);
        if (result == 32'h00000001) $display("PASS: EQ");
        else $display("FAIL: EQ");
        
        // Test 20: NE operation
        $display("\nTest 20: NE operation");
        a = 32'h00000010;
        b = 32'h00000020;
        alu_op = 5'b10100; // NE
        saturate = 0;
        #10;
        $display("a=%h, b=%h, result=%h", a, b, result);
        if (result == 32'h00000001) $display("PASS: NE");
        else $display("FAIL: NE");
        
        $display("\nALU Testbench Completed");
        $finish;
    end
    
    // Monitor signals
    initial begin
        $monitor("Time=%0t, a=%h, b=%h, alu_op=%b, result=%h, zero=%b, overflow=%b, carry=%b, negative=%b", 
                 $time, a, b, alu_op, result, zero, overflow, carry, negative);
    end

endmodule
