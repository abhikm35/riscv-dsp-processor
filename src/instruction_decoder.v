//=============================================================================
// Instruction Decoder for RISC-V DSP Processor
// Decodes RISC-V instructions and DSP extensions
//=============================================================================

module instruction_decoder (
    input wire [31:0] instruction,
    output reg [6:0]  opcode,
    output reg [4:0]  rd,       // Destination register
    output reg [2:0]  funct3,
    output reg [4:0]  rs1,      // Source register 1
    output reg [4:0]  rs2,      // Source register 2
    output reg [6:0]  funct7,
    output reg [11:0] imm12,    // 12-bit immediate
    output reg [19:0] imm20,    // 20-bit immediate
    output reg [31:0] imm32,    // 32-bit sign-extended immediate
    output reg [4:0]  alu_op,   // ALU operation
    output reg [2:0]  simd_op,  // SIMD operation
    output reg [1:0]  simd_width, // SIMD data width
    output reg [1:0]  mac_mode, // MAC mode
    output reg        mac_enable, // MAC enable
    output reg        simd_enable, // SIMD enable
    output reg        mem_read, // Memory read
    output reg        mem_write, // Memory write
    output reg        reg_write, // Register write
    output reg        branch,   // Branch instruction
    output reg        jump,     // Jump instruction
    output reg        saturate, // Saturation enable
    output reg        round     // Rounding enable
);

    // Extract basic instruction fields
    always @(*) begin
        opcode = instruction[6:0];
        rd = instruction[11:7];
        funct3 = instruction[14:12];
        rs1 = instruction[19:15];
        rs2 = instruction[24:20];
        funct7 = instruction[31:25];
        
        // Extract immediates based on instruction type
        case (opcode)
            7'b0110011: begin // R-type
                imm12 = 12'h0;
                imm20 = 20'h0;
                imm32 = 32'h0;
            end
            7'b0010011: begin // I-type
                imm12 = instruction[31:20];
                imm20 = 20'h0;
                imm32 = {{20{instruction[31]}}, instruction[31:20]};
            end
            7'b0100011: begin // S-type
                imm12 = {instruction[31:25], instruction[11:7]};
                imm20 = 20'h0;
                imm32 = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            7'b1100011: begin // B-type
                imm12 = 12'h0;
                imm20 = 20'h0;
                imm32 = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end
            7'b1101111: begin // J-type
                imm12 = 12'h0;
                imm20 = instruction[31:12];
                imm32 = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end
            7'b1100111: begin // I-type (JALR)
                imm12 = instruction[31:20];
                imm20 = 20'h0;
                imm32 = {{20{instruction[31]}}, instruction[31:20]};
            end
            default: begin
                imm12 = 12'h0;
                imm20 = 20'h0;
                imm32 = 32'h0;
            end
        endcase
        
        // Initialize control signals
        alu_op = 5'b00000;
        simd_op = 3'b000;
        simd_width = 2'b00;
        mac_mode = 2'b00;
        mac_enable = 1'b0;
        simd_enable = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        reg_write = 1'b0;
        branch = 1'b0;
        jump = 1'b0;
        saturate = 1'b0;
        round = 1'b0;
        
        // Decode instruction
        case (opcode)
            7'b0110011: begin // R-type instructions
                reg_write = 1'b1;
                case (funct3)
                    3'b000: begin // ADD/SUB
                        if (funct7[5] == 1'b1) begin
                            alu_op = 5'b00001; // SUB
                        end else begin
                            alu_op = 5'b00000; // ADD
                        end
                    end
                    3'b001: alu_op = 5'b00101; // SLL
                    3'b010: alu_op = 5'b01000; // SLT
                    3'b011: alu_op = 5'b01001; // SLTU
                    3'b100: alu_op = 5'b00100; // XOR
                    3'b101: begin // SRL/SRA
                        if (funct7[5] == 1'b1) begin
                            alu_op = 5'b00111; // SRA
                        end else begin
                            alu_op = 5'b00110; // SRL
                        end
                    end
                    3'b110: alu_op = 5'b00011; // OR
                    3'b111: alu_op = 5'b00010; // AND
                endcase
                
                // DSP extensions for R-type
                if (funct7 == 7'b0000001) begin // MAC instruction
                    mac_enable = 1'b1;
                    mac_mode = funct3[1:0];
                    saturate = funct3[2];
                    round = 1'b1;
                end else if (funct7 == 7'b0000010) begin // SIMD instruction
                    simd_enable = 1'b1;
                    simd_op = funct3;
                    simd_width = {funct7[1:0]};
                end
            end
            
            7'b0010011: begin // I-type instructions
                reg_write = 1'b1;
                case (funct3)
                    3'b000: alu_op = 5'b00000; // ADDI
                    3'b001: alu_op = 5'b00101; // SLLI
                    3'b010: alu_op = 5'b01000; // SLTI
                    3'b011: alu_op = 5'b01001; // SLTUI
                    3'b100: alu_op = 5'b00100; // XORI
                    3'b101: begin // SRLI/SRAI
                        if (funct7[5] == 1'b1) begin
                            alu_op = 5'b00111; // SRAI
                        end else begin
                            alu_op = 5'b00110; // SRLI
                        end
                    end
                    3'b110: alu_op = 5'b00011; // ORI
                    3'b111: alu_op = 5'b00010; // ANDI
                endcase
            end
            
            7'b0000011: begin // Load instructions
                reg_write = 1'b1;
                mem_read = 1'b1;
                alu_op = 5'b00000; // ADD for address calculation
            end
            
            7'b0100011: begin // Store instructions
                mem_write = 1'b1;
                alu_op = 5'b00000; // ADD for address calculation
            end
            
            7'b1100011: begin // Branch instructions
                branch = 1'b1;
                case (funct3)
                    3'b000: alu_op = 5'b10011; // BEQ
                    3'b001: alu_op = 5'b10100; // BNE
                    3'b100: alu_op = 5'b01000; // BLT
                    3'b101: alu_op = 5'b01000; // BGE
                    3'b110: alu_op = 5'b01001; // BLTU
                    3'b111: alu_op = 5'b01001; // BGEU
                endcase
            end
            
            7'b1101111: begin // JAL
                reg_write = 1'b1;
                jump = 1'b1;
                alu_op = 5'b00000;
            end
            
            7'b1100111: begin // JALR
                reg_write = 1'b1;
                jump = 1'b1;
                alu_op = 5'b00000;
            end
            
            // Custom DSP instructions (opcode = 7'b0001011)
            7'b0001011: begin
                reg_write = 1'b1;
                case (funct3)
                    3'b000: begin // SAT
                        alu_op = 5'b10101;
                        saturate = 1'b1;
                    end
                    3'b001: begin // CLIP
                        alu_op = 5'b10110;
                        saturate = 1'b1;
                    end
                    3'b010: begin // ROUND
                        alu_op = 5'b10111;
                        round = 1'b1;
                    end
                    3'b011: begin // BIT_REVERSE (for FFT)
                        alu_op = 5'b11100;
                    end
                    3'b100: begin // CIRCULAR_ADDR
                        alu_op = 5'b11101;
                    end
                    default: alu_op = 5'b00000;
                endcase
            end
        endcase
    end

endmodule
