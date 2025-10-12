//=============================================================================
// Register File for RISC-V DSP Processor
// 32 general-purpose registers with dual-port read and single-port write
//=============================================================================

module register_file (
    input wire clk,
    input wire rst_n,
    input wire we,              // Write enable
    input wire [4:0]  raddr1,   // Read address 1
    input wire [4:0]  raddr2,   // Read address 2
    input wire [4:0]  waddr,    // Write address
    input wire [31:0] wdata,    // Write data
    output reg [31:0] rdata1,   // Read data 1
    output reg [31:0] rdata2    // Read data 2
);

    // Register file storage
    reg [31:0] registers [0:31];
    
    // Initialize registers
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'h0;
        end
    end
    
    // Read operations (combinational)
    always @(*) begin
        if (raddr1 == 5'h0) begin
            rdata1 = 32'h0; // x0 is always zero
        end else begin
            rdata1 = registers[raddr1];
        end
        
        if (raddr2 == 5'h0) begin
            rdata2 = 32'h0; // x0 is always zero
        end else begin
            rdata2 = registers[raddr2];
        end
    end
    
    // Write operation (sequential)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'h0;
            end
        end else if (we && waddr != 5'h0) begin // x0 cannot be written
            registers[waddr] <= wdata;
        end
    end

endmodule
