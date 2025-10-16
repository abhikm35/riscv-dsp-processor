//=============================================================================
// Memory Interface for RISC-V DSP Processor
// Handles instruction and data memory access with DSP optimizations
//=============================================================================

module memory_interface (
    input wire clk,
    input wire rst_n,
    
    // Instruction memory interface
    input wire [31:0] pc,           // Program counter
    output reg [31:0] instruction,  // Fetched instruction
    input wire        if_stall,     // IF stage stall
    
    // Data memory interface
    input wire [31:0] addr,         // Memory address
    input wire [31:0] write_data,   // Data to write
    input wire        mem_read,     // Memory read enable
    input wire        mem_write,    // Memory write enable
    input wire [2:0]  mem_width,    // Memory access width (000: 8-bit, 001: 16-bit, 010: 32-bit)
    input wire        mem_signed,   // Signed/unsigned access
    output reg [31:0] read_data,    // Read data
    output reg        mem_ready,    // Memory ready signal
    
    // DSP-specific memory operations
    input wire        circular_addr, // Circular addressing mode
    input wire [31:0] base_addr,     // Base address for circular addressing
    input wire [31:0] buffer_size,   // Buffer size for circular addressing
    input wire        bit_reverse,   // Bit-reverse addressing for FFT
    input wire [4:0]  fft_size_log2  // Log2 of FFT size for bit reversal
);

    // Memory arrays
    reg [31:0] instruction_mem [0:4095]; // 16KB instruction memory
    reg [31:0] data_mem [0:2047];        // 8KB data memory
    
    // Internal signals
    reg [31:0] effective_addr;
    reg [31:0] circular_addr_result;
    reg [31:0] bit_reverse_addr;
    reg [31:0] temp_read_data;
    reg [31:0] temp_write_data;
    
    // Initialize memories
    integer i;
    initial begin
        // Initialize instruction memory with valid RISC-V instructions
        for (i = 0; i < 4096; i = i + 1) begin
            instruction_mem[i] = 32'h00000013; // NOP instruction (ADDI x0, x0, 0)
        end
        // Put some real instructions at PC=0x1000 (index 0x400)
        instruction_mem[1024] = 32'h00000013; // NOP: ADDI x0, x0, 0 (PC=0x1000)
        instruction_mem[1025] = 32'h00100093; // ADDI x1, x0, 1 (PC=0x1004)
        instruction_mem[1026] = 32'h00200113; // ADDI x2, x0, 2 (PC=0x1008)
        instruction_mem[1027] = 32'h00300193; // ADDI x3, x0, 3 (PC=0x100C)
        instruction_mem[1028] = 32'h00400213; // ADDI x4, x0, 4 (PC=0x1010)
        instruction_mem[1029] = 32'h00500293; // ADDI x5, x0, 5 (PC=0x1014)
        
        for (i = 0; i < 2048; i = i + 1) begin
            data_mem[i] = 32'h0;
        end
    end
    
    // Address calculation
    always @(*) begin
        effective_addr = addr;
        
        // Circular addressing
        if (circular_addr) begin
            circular_addr_result = base_addr + ((addr - base_addr) % buffer_size);
            effective_addr = circular_addr_result;
        end
        
        // Bit-reverse addressing for FFT
        if (bit_reverse) begin
            bit_reverse_addr = 32'h0;
            for (i = 0; i < fft_size_log2; i = i + 1) begin
                bit_reverse_addr[i] = effective_addr[fft_size_log2 - 1 - i];
            end
            effective_addr = bit_reverse_addr;
        end
    end
    
    // Instruction fetch
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            instruction <= 32'h00000013; // NOP instruction during reset
        end else if (!if_stall) begin
            if (pc[31:2] < 4096) begin
                instruction <= instruction_mem[pc[31:2]];
            end else begin
                instruction <= 32'h00000013; // NOP for invalid address
            end
        end
    end
    
    // Data memory access
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_data <= 32'h0;
            mem_ready <= 1'b0;
        end else begin
            mem_ready <= 1'b1;
            
            if (mem_read && effective_addr[31:2] < 2048) begin
                case (mem_width)
                    3'b000: begin // 8-bit access
                        case (effective_addr[1:0])
                            2'b00: temp_read_data = {{24{mem_signed ? data_mem[effective_addr[31:2]][7] : 1'b0}}, data_mem[effective_addr[31:2]][7:0]};
                            2'b01: temp_read_data = {{24{mem_signed ? data_mem[effective_addr[31:2]][15] : 1'b0}}, data_mem[effective_addr[31:2]][15:8]};
                            2'b10: temp_read_data = {{24{mem_signed ? data_mem[effective_addr[31:2]][23] : 1'b0}}, data_mem[effective_addr[31:2]][23:16]};
                            2'b11: temp_read_data = {{24{mem_signed ? data_mem[effective_addr[31:2]][31] : 1'b0}}, data_mem[effective_addr[31:2]][31:24]};
                        endcase
                    end
                    3'b001: begin // 16-bit access
                        case (effective_addr[1])
                            1'b0: temp_read_data = {{16{mem_signed ? data_mem[effective_addr[31:2]][15] : 1'b0}}, data_mem[effective_addr[31:2]][15:0]};
                            1'b1: temp_read_data = {{16{mem_signed ? data_mem[effective_addr[31:2]][31] : 1'b0}}, data_mem[effective_addr[31:2]][31:16]};
                        endcase
                    end
                    3'b010: begin // 32-bit access
                        temp_read_data = data_mem[effective_addr[31:2]];
                    end
                    default: temp_read_data = 32'h0;
                endcase
                read_data <= temp_read_data;
            end else if (mem_write && effective_addr[31:2] < 2048) begin
                case (mem_width)
                    3'b000: begin // 8-bit write
                        case (effective_addr[1:0])
                            2'b00: data_mem[effective_addr[31:2]] <= {data_mem[effective_addr[31:2]][31:8], write_data[7:0]};
                            2'b01: data_mem[effective_addr[31:2]] <= {data_mem[effective_addr[31:2]][31:16], write_data[7:0], data_mem[effective_addr[31:2]][7:0]};
                            2'b10: data_mem[effective_addr[31:2]] <= {data_mem[effective_addr[31:2]][31:24], write_data[7:0], data_mem[effective_addr[31:2]][15:0]};
                            2'b11: data_mem[effective_addr[31:2]] <= {write_data[7:0], data_mem[effective_addr[31:2]][23:0]};
                        endcase
                    end
                    3'b001: begin // 16-bit write
                        case (effective_addr[1])
                            1'b0: data_mem[effective_addr[31:2]] <= {data_mem[effective_addr[31:2]][31:16], write_data[15:0]};
                            1'b1: data_mem[effective_addr[31:2]] <= {write_data[15:0], data_mem[effective_addr[31:2]][15:0]};
                        endcase
                    end
                    3'b010: begin // 32-bit write
                        data_mem[effective_addr[31:2]] <= write_data;
                    end
                endcase
                read_data <= 32'h0;
            end else begin
                read_data <= 32'h0;
            end
        end
    end

endmodule
