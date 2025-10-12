//=============================================================================
// Testbench for MAC Unit
// Verifies multiply-accumulate operations with various modes
//=============================================================================

`timescale 1ns/1ps

module mac_unit_tb;

    // Testbench signals
    reg clk;
    reg rst_n;
    reg enable;
    reg [31:0] a, b, c;
    reg [1:0] mode;
    reg saturate, round;
    wire [31:0] result;
    wire overflow, underflow;
    
    // Instantiate MAC unit
    mac_unit dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .a(a),
        .b(b),
        .c(c),
        .mode(mode),
        .saturate(saturate),
        .round(round),
        .result(result),
        .overflow(overflow),
        .underflow(underflow)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        $display("MAC Unit Testbench Starting...");
        
        // Initialize signals
        rst_n = 0;
        enable = 0;
        a = 0;
        b = 0;
        c = 0;
        mode = 0;
        saturate = 0;
        round = 0;
        
        // Reset
        #20 rst_n = 1;
        #10 enable = 1;
        
        // Test 1: Basic signed multiplication
        $display("\nTest 1: Basic signed multiplication");
        a = 32'h00001000; // 4096
        b = 32'h00000002; // 2
        c = 32'h00000000; // 0
        mode = 2'b00; // Signed mode
        saturate = 0;
        round = 0;
        #10;
        $display("a=%d, b=%d, c=%d, result=%d", a, b, c, result);
        if (result == 32'h00002000) $display("PASS: Basic multiplication");
        else $display("FAIL: Basic multiplication");
        
        // Test 2: Accumulation
        $display("\nTest 2: Accumulation");
        a = 32'h00001000; // 4096
        b = 32'h00000003; // 3
        c = 32'h00002000; // 8192
        mode = 2'b00; // Signed mode
        saturate = 0;
        round = 0;
        #10;
        $display("a=%d, b=%d, c=%d, result=%d", a, b, c, result);
        if (result == 32'h00005000) $display("PASS: Accumulation");
        else $display("FAIL: Accumulation");
        
        // Test 3: Unsigned multiplication
        $display("\nTest 3: Unsigned multiplication");
        a = 32'hFFFF0000; // 65535 * 65536
        b = 32'h00010000; // 65536
        c = 32'h00000000; // 0
        mode = 2'b01; // Unsigned mode
        saturate = 0;
        round = 0;
        #10;
        $display("a=%d, b=%d, c=%d, result=%d", a, b, c, result);
        if (result == 32'hFFFF0000) $display("PASS: Unsigned multiplication");
        else $display("FAIL: Unsigned multiplication");
        
        // Test 4: Overflow detection
        $display("\nTest 4: Overflow detection");
        a = 32'h7FFFFFFF; // Max positive
        b = 32'h00000002; // 2
        c = 32'h00000000; // 0
        mode = 2'b00; // Signed mode
        saturate = 0;
        round = 0;
        #10;
        $display("a=%d, b=%d, c=%d, result=%d, overflow=%b", a, b, c, result, overflow);
        if (overflow) $display("PASS: Overflow detected");
        else $display("FAIL: Overflow not detected");
        
        // Test 5: Saturation
        $display("\nTest 5: Saturation");
        a = 32'h7FFFFFFF; // Max positive
        b = 32'h00000002; // 2
        c = 32'h00000000; // 0
        mode = 2'b00; // Signed mode
        saturate = 1;
        round = 0;
        #10;
        $display("a=%d, b=%d, c=%d, result=%d", a, b, c, result);
        if (result == 32'h7FFFFFFF) $display("PASS: Saturation");
        else $display("FAIL: Saturation");
        
        // Test 6: Rounding
        $display("\nTest 6: Rounding");
        a = 32'h00000001; // 1
        b = 32'h00000001; // 1
        c = 32'h00000001; // 1
        mode = 2'b00; // Signed mode
        saturate = 0;
        round = 1;
        #10;
        $display("a=%d, b=%d, c=%d, result=%d", a, b, c, result);
        if (result == 32'h00000003) $display("PASS: Rounding");
        else $display("FAIL: Rounding");
        
        // Test 7: Negative numbers
        $display("\nTest 7: Negative numbers");
        a = 32'hFFFFFFFF; // -1
        b = 32'hFFFFFFFF; // -1
        c = 32'h00000000; // 0
        mode = 2'b00; // Signed mode
        saturate = 0;
        round = 0;
        #10;
        $display("a=%d, b=%d, c=%d, result=%d", a, b, c, result);
        if (result == 32'h00000001) $display("PASS: Negative multiplication");
        else $display("FAIL: Negative multiplication");
        
        // Test 8: Mixed mode
        $display("\nTest 8: Mixed mode");
        a = 32'hFFFFFFFF; // -1 (signed)
        b = 32'h00000002; // 2 (unsigned)
        c = 32'h00000000; // 0
        mode = 2'b10; // Mixed mode
        saturate = 0;
        round = 0;
        #10;
        $display("a=%d, b=%d, c=%d, result=%d", a, b, c, result);
        if (result == 32'hFFFFFFFE) $display("PASS: Mixed mode");
        else $display("FAIL: Mixed mode");
        
        $display("\nMAC Unit Testbench Completed");
        $finish;
    end
    
    // Monitor signals
    initial begin
        $monitor("Time=%0t, a=%h, b=%h, c=%h, result=%h, overflow=%b, underflow=%b", 
                 $time, a, b, c, result, overflow, underflow);
    end

endmodule
