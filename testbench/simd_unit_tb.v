//=============================================================================
// Testbench for SIMD Unit
// Verifies parallel operations on multiple data elements
//=============================================================================

`timescale 1ns/1ps

module simd_unit_tb;

    // Testbench signals
    reg clk;
    reg rst_n;
    reg enable;
    reg [31:0] a, b;
    reg [2:0] op;
    reg [1:0] width;
    reg [2:0] shift_amt;
    wire [31:0] result;
    wire overflow;
    
    // Instantiate SIMD unit
    simd_unit dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .a(a),
        .b(b),
        .op(op),
        .width(width),
        .shift_amt(shift_amt),
        .result(result),
        .overflow(overflow)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        $display("SIMD Unit Testbench Starting...");
        
        // Initialize signals
        rst_n = 0;
        enable = 0;
        a = 0;
        b = 0;
        op = 0;
        width = 0;
        shift_amt = 0;
        
        // Reset
        #20 rst_n = 1;
        #10 enable = 1;
        
        // Test 1: 8-bit ADD4 operation
        $display("\nTest 1: 8-bit ADD4 operation");
        a = 32'h01020304; // [1, 2, 3, 4]
        b = 32'h05060708; // [5, 6, 7, 8]
        op = 3'b000; // ADD4
        width = 2'b00; // 8-bit
        shift_amt = 0;
        #10;
        $display("a=%h, b=%h, result=%h", a, b, result);
        if (result == 32'h06080A0C) $display("PASS: 8-bit ADD4");
        else $display("FAIL: 8-bit ADD4");
        
        // Test 2: 8-bit SUB4 operation
        $display("\nTest 2: 8-bit SUB4 operation");
        a = 32'h05060708; // [5, 6, 7, 8]
        b = 32'h01020304; // [1, 2, 3, 4]
        op = 3'b001; // SUB4
        width = 2'b00; // 8-bit
        shift_amt = 0;
        #10;
        $display("a=%h, b=%h, result=%h", a, b, result);
        if (result == 32'h04040404) $display("PASS: 8-bit SUB4");
        else $display("FAIL: 8-bit SUB4");
        
        // Test 3: 8-bit MUL4 operation
        $display("\nTest 3: 8-bit MUL4 operation");
        a = 32'h02030405; // [2, 3, 4, 5]
        b = 32'h03040506; // [3, 4, 5, 6]
        op = 3'b010; // MUL4
        width = 2'b00; // 8-bit
        shift_amt = 0;
        #10;
        $display("a=%h, b=%h, result=%h", a, b, result);
        if (result == 32'h060C141E) $display("PASS: 8-bit MUL4");
        else $display("FAIL: 8-bit MUL4");
        
        // Test 4: 8-bit AND4 operation
        $display("\nTest 4: 8-bit AND4 operation");
        a = 32'hFF00FF00; // [255, 0, 255, 0]
        b = 32'hF0F0F0F0; // [240, 240, 240, 240]
        op = 3'b011; // AND4
        width = 2'b00; // 8-bit
        shift_amt = 0;
        #10;
        $display("a=%h, b=%h, result=%h", a, b, result);
        if (result == 32'hF000F000) $display("PASS: 8-bit AND4");
        else $display("FAIL: 8-bit AND4");
        
        // Test 5: 8-bit OR4 operation
        $display("\nTest 5: 8-bit OR4 operation");
        a = 32'hFF00FF00; // [255, 0, 255, 0]
        b = 32'hF0F0F0F0; // [240, 240, 240, 240]
        op = 3'b100; // OR4
        width = 2'b00; // 8-bit
        shift_amt = 0;
        #10;
        $display("a=%h, b=%h, result=%h", a, b, result);
        if (result == 32'hFFF0FFF0) $display("PASS: 8-bit OR4");
        else $display("FAIL: 8-bit OR4");
        
        // Test 6: 8-bit XOR4 operation
        $display("\nTest 6: 8-bit XOR4 operation");
        a = 32'hFF00FF00; // [255, 0, 255, 0]
        b = 32'hF0F0F0F0; // [240, 240, 240, 240]
        op = 3'b101; // XOR4
        width = 2'b00; // 8-bit
        shift_amt = 0;
        #10;
        $display("a=%h, b=%h, result=%h", a, b, result);
        if (result == 32'h0FF00FF0) $display("PASS: 8-bit XOR4");
        else $display("FAIL: 8-bit XOR4");
        
        // Test 7: 8-bit SHIFT4 operation
        $display("\nTest 7: 8-bit SHIFT4 operation");
        a = 32'h01020304; // [1, 2, 3, 4]
        b = 32'h00000000; // Not used for shift
        op = 3'b110; // SHIFT4
        width = 2'b00; // 8-bit
        shift_amt = 3'b001; // Shift by 1
        #10;
        $display("a=%h, shift_amt=%d, result=%h", a, shift_amt, result);
        if (result == 32'h02040608) $display("PASS: 8-bit SHIFT4");
        else $display("FAIL: 8-bit SHIFT4");
        
        // Test 8: 16-bit ADD2 operation
        $display("\nTest 8: 16-bit ADD2 operation");
        a = 32'h00010002; // [1, 2]
        b = 32'h00030004; // [3, 4]
        op = 3'b000; // ADD2
        width = 2'b01; // 16-bit
        shift_amt = 0;
        #10;
        $display("a=%h, b=%h, result=%h", a, b, result);
        if (result == 32'h00040006) $display("PASS: 16-bit ADD2");
        else $display("FAIL: 16-bit ADD2");
        
        // Test 9: 16-bit SUB2 operation
        $display("\nTest 9: 16-bit SUB2 operation");
        a = 32'h00050006; // [5, 6]
        b = 32'h00010002; // [1, 2]
        op = 3'b001; // SUB2
        width = 2'b01; // 16-bit
        shift_amt = 0;
        #10;
        $display("a=%h, b=%h, result=%h", a, b, result);
        if (result == 32'h00040004) $display("PASS: 16-bit SUB2");
        else $display("FAIL: 16-bit SUB2");
        
        // Test 10: 16-bit MUL2 operation
        $display("\nTest 10: 16-bit MUL2 operation");
        a = 32'h00020003; // [2, 3]
        b = 32'h00040005; // [4, 5]
        op = 3'b010; // MUL2
        width = 2'b01; // 16-bit
        shift_amt = 0;
        #10;
        $display("a=%h, b=%h, result=%h", a, b, result);
        if (result == 32'h0008000F) $display("PASS: 16-bit MUL2");
        else $display("FAIL: 16-bit MUL2");
        
        // Test 11: Overflow detection
        $display("\nTest 11: Overflow detection");
        a = 32'h80808080; // [128, 128, 128, 128]
        b = 32'h80808080; // [128, 128, 128, 128]
        op = 3'b000; // ADD4
        width = 2'b00; // 8-bit
        shift_amt = 0;
        #10;
        $display("a=%h, b=%h, result=%h, overflow=%b", a, b, result, overflow);
        if (overflow) $display("PASS: Overflow detected");
        else $display("FAIL: Overflow not detected");
        
        $display("\nSIMD Unit Testbench Completed");
        $finish;
    end
    
    // Monitor signals
    initial begin
        $monitor("Time=%0t, a=%h, b=%h, op=%b, width=%b, result=%h, overflow=%b", 
                 $time, a, b, op, width, result, overflow);
    end

endmodule
