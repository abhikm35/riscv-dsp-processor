//=============================================================================
// RISC-V DSP Processor Core
// Main processor module integrating all components
//=============================================================================

module riscv_dsp_core (
    input wire clk,
    input wire rst_n,
    input wire [31:0] external_data_in,
    output reg [31:0] external_data_out,
    output reg        processor_ready,
    
    // Debug/verification outputs
    output wire [31:0] pc,
    output wire [31:0] instruction,
    output wire [31:0] pc_plus_4,
    output wire [4:0]  rs1, rs2, rd,
    output wire [31:0] reg_data1, reg_data2,
    output wire [31:0] reg_write_data,
    output wire        reg_write,
    output wire [31:0] alu_result,
    output wire        alu_zero, alu_overflow, alu_carry, alu_negative,
    output wire [4:0]  alu_op,
    output wire [31:0] mac_result,
    output wire        mac_overflow, mac_underflow,
    output wire [1:0]  mac_mode,
    output wire        mac_enable,
    output wire        saturate, round,
    output wire [31:0] simd_result,
    output wire        simd_overflow,
    output wire [2:0]  simd_op,
    output wire [1:0]  simd_width,
    output wire        simd_enable,
    output wire [31:0] mem_read_data,
    output wire        mem_read, mem_write, mem_ready,
    output wire        branch, jump,
    output wire [31:0] branch_target,
    output wire        branch_taken
);

    // Internal signals (only those not exposed as outputs)
    wire [31:0] pc_next;
    reg [31:0] pc_current;  // Current PC register
    
    // Instruction decoder signals
    wire [6:0]  opcode;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [31:0] imm32;
    
    // Control unit signals
    wire        pc_stall, if_stall, id_stall, ex_stall, mem_stall, wb_stall;
    wire        if_flush, id_flush, ex_flush, mem_flush, wb_flush;
    wire [1:0]  forward_a, forward_b;
    wire        hazard_detected;
    
    // Pipeline registers
    reg [31:0] pc_if, pc_id, pc_ex, pc_mem, pc_wb;
    reg [31:0] instruction_if, instruction_id, instruction_ex, instruction_mem, instruction_wb;
    reg [31:0] reg_data1_id, reg_data1_ex;
    reg [31:0] reg_data2_id, reg_data2_ex;
    reg [31:0] imm32_id, imm32_ex;
    reg [4:0]  rd_id, rd_ex, rd_mem, rd_wb;
    reg [4:0]  rs1_id, rs1_ex;
    reg [4:0]  rs2_id, rs2_ex;
    reg        reg_write_id, reg_write_ex, reg_write_mem, reg_write_wb;
    reg        mem_read_id, mem_read_ex, mem_read_mem;
    reg        mem_write_id, mem_write_ex, mem_write_mem;
    reg        branch_id, branch_ex;
    reg        jump_id, jump_ex;
    reg [4:0]  alu_op_id, alu_op_ex;
    reg [2:0]  simd_op_id, simd_op_ex;
    reg [1:0]  simd_width_id, simd_width_ex;
    reg [1:0]  mac_mode_id, mac_mode_ex;
    reg        mac_enable_id, mac_enable_ex;
    reg        simd_enable_id, simd_enable_ex;
    reg        saturate_id, saturate_ex;
    reg        round_id, round_ex;
    
    // Execution stage results
    reg [31:0] alu_result_ex, alu_result_mem, alu_result_wb;
    reg [31:0] mac_result_ex, mac_result_mem, mac_result_wb;
    reg [31:0] simd_result_ex, simd_result_mem, simd_result_wb;
    reg [31:0] mem_read_data_mem, mem_read_data_wb;
    
    // Forwarding multiplexers
    wire [31:0] forward_data1, forward_data2;
    
    // Branch and jump logic
    wire jump_taken;
    wire [31:0] jump_target;
    
    // Component instantiations
    instruction_decoder decoder (
        .instruction(instruction_id),
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7),
        .imm12(),
        .imm20(),
        .imm32(imm32),
        .alu_op(alu_op),
        .simd_op(simd_op),
        .simd_width(simd_width),
        .mac_mode(mac_mode),
        .mac_enable(mac_enable),
        .simd_enable(simd_enable),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .branch(branch),
        .jump(jump),
        .saturate(saturate),
        .round(round)
    );
    
    register_file reg_file (
        .clk(clk),
        .rst_n(rst_n),
        .we(reg_write_wb),
        .raddr1(rs1_id),
        .raddr2(rs2_id),
        .waddr(rd_wb),
        .wdata(reg_write_data),
        .rdata1(reg_data1),
        .rdata2(reg_data2)
    );
    
    alu alu_unit (
        .a(forward_data1),
        .b(forward_data2),
        .alu_op(alu_op_ex),
        .saturate(saturate_ex),
        .result(alu_result),
        .zero(alu_zero),
        .overflow(alu_overflow),
        .carry(alu_carry),
        .negative(alu_negative)
    );
    
    mac_unit mac_unit_inst (
        .clk(clk),
        .rst_n(rst_n),
        .enable(mac_enable_ex),
        .a(forward_data1),
        .b(forward_data2),
        .c(imm32_ex),
        .mode(mac_mode_ex),
        .saturate(saturate_ex),
        .round(round_ex),
        .result(mac_result),
        .overflow(mac_overflow),
        .underflow(mac_underflow)
    );
    
    simd_unit simd_unit_inst (
        .clk(clk),
        .rst_n(rst_n),
        .enable(simd_enable_ex),
        .a(forward_data1),
        .b(forward_data2),
        .op(simd_op_ex),
        .width(simd_width_ex),
        .shift_amt(imm32_ex[2:0]),
        .result(simd_result),
        .overflow(simd_overflow)
    );
    
    memory_interface mem_interface (
        .clk(clk),
        .rst_n(rst_n),
        .pc(pc_if),
        .instruction(instruction),
        .if_stall(if_stall),
        .addr(alu_result_ex),
        .write_data(forward_data2),
        .mem_read(mem_read_ex),
        .mem_write(mem_write_ex),
        .mem_width(funct3),
        .mem_signed(1'b1),
        .read_data(mem_read_data),
        .mem_ready(mem_ready),
        .circular_addr(1'b0),
        .base_addr(32'h0),
        .buffer_size(32'h0),
        .bit_reverse(1'b0),
        .fft_size_log2(5'h0)
    );
    
    control_unit control_unit_inst (
        .clk(clk),
        .rst_n(rst_n),
        .instruction(instruction_ex),
        .rd_ex(rd_ex),
        .rd_mem(rd_mem),
        .rd_wb(rd_wb),
        .reg_write_ex(reg_write_ex),
        .reg_write_mem(reg_write_mem),
        .reg_write_wb(reg_write_wb),
        .mem_read_ex(mem_read_ex),
        .branch_taken(branch_taken),
        .jump_taken(jump_taken),
        .pc_stall(pc_stall),
        .if_stall(if_stall),
        .id_stall(id_stall),
        .ex_stall(ex_stall),
        .mem_stall(mem_stall),
        .wb_stall(wb_stall),
        .if_flush(if_flush),
        .id_flush(id_flush),
        .ex_flush(ex_flush),
        .mem_flush(mem_flush),
        .wb_flush(wb_flush),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .hazard_detected(hazard_detected)
    );
    
    // Forwarding multiplexers
    assign forward_data1 = (forward_a == 2'b10) ? alu_result_mem :
                          (forward_a == 2'b01) ? reg_write_data :
                          reg_data1_ex;
    
    assign forward_data2 = (forward_b == 2'b10) ? alu_result_mem :
                          (forward_b == 2'b01) ? reg_write_data :
                          reg_data2_ex;
    
    // Branch and jump logic
    assign branch_taken = branch_ex && alu_zero;
    assign jump_taken = jump_ex;
    assign branch_target = pc_ex + imm32_ex;
    assign jump_target = (opcode == 7'b1100111) ? (reg_data1_ex + imm32_ex) : (pc_ex + imm32_ex);
    
    // PC logic
    assign pc_plus_4 = pc_current + 4;
    assign pc_next = (branch_taken) ? branch_target :
                    (jump_taken) ? jump_target :
                    pc_plus_4;
    
    // Pipeline register updates
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all pipeline registers
            pc_current <= 32'h1000;  // Start at address 0x1000 (valid instruction memory)
            pc_if <= 32'h1000;
            pc_id <= 32'h0;
            pc_ex <= 32'h0;
            pc_mem <= 32'h0;
            pc_wb <= 32'h0;
            instruction_if <= 32'h00000013;  // NOP instruction
            instruction_id <= 32'h00000013;  // NOP instruction
            instruction_ex <= 32'h00000013;  // NOP instruction
            instruction_mem <= 32'h00000013; // NOP instruction
            instruction_wb <= 32'h00000013;  // NOP instruction
            // ... (reset all other pipeline registers)
            processor_ready <= 1'b0;
        end else begin
            // IF stage
            if (!pc_stall) begin
                pc_current <= pc_next;
                pc_if <= pc_next;
            end
            if (!if_stall) begin
                instruction_if <= instruction;
            end
            
            // ID stage
            if (!id_stall) begin
                pc_id <= pc_if;
                instruction_id <= instruction_if;
                reg_data1_id <= reg_data1;
                reg_data2_id <= reg_data2;
                imm32_id <= imm32;
                rd_id <= rd;
                rs1_id <= rs1;
                rs2_id <= rs2;
                reg_write_id <= reg_write;
                mem_read_id <= mem_read;
                mem_write_id <= mem_write;
                branch_id <= branch;
                jump_id <= jump;
                alu_op_id <= alu_op;
                simd_op_id <= simd_op;
                simd_width_id <= simd_width;
                mac_mode_id <= mac_mode;
                mac_enable_id <= mac_enable;
                simd_enable_id <= simd_enable;
                saturate_id <= saturate;
                round_id <= round;
            end
            
            // EX stage
            if (!ex_stall) begin
                pc_ex <= pc_id;
                instruction_ex <= instruction_id;
                reg_data1_ex <= reg_data1_id;
                reg_data2_ex <= reg_data2_id;
                imm32_ex <= imm32_id;
                rd_ex <= rd_id;
                rs1_ex <= rs1_id;
                rs2_ex <= rs2_id;
                reg_write_ex <= reg_write_id;
                mem_read_ex <= mem_read_id;
                mem_write_ex <= mem_write_id;
                branch_ex <= branch_id;
                jump_ex <= jump_id;
                alu_op_ex <= alu_op_id;
                simd_op_ex <= simd_op_id;
                simd_width_ex <= simd_width_id;
                mac_mode_ex <= mac_mode_id;
                mac_enable_ex <= mac_enable_id;
                simd_enable_ex <= simd_enable_id;
                saturate_ex <= saturate_id;
                round_ex <= round_id;
            end
            
            // MEM stage
            if (!mem_stall) begin
                pc_mem <= pc_ex;
                instruction_mem <= instruction_ex;
                alu_result_mem <= alu_result;
                mac_result_mem <= mac_result;
                simd_result_mem <= simd_result;
                mem_read_data_mem <= mem_read_data;
                rd_mem <= rd_ex;
                reg_write_mem <= reg_write_ex;
                mem_read_mem <= mem_read_ex;
                mem_write_mem <= mem_write_ex;
            end
            
            // WB stage
            if (!wb_stall) begin
                pc_wb <= pc_mem;
                instruction_wb <= instruction_mem;
                alu_result_wb <= alu_result_mem;
                mac_result_wb <= mac_result_mem;
                simd_result_wb <= simd_result_mem;
                mem_read_data_wb <= mem_read_data_mem;
                rd_wb <= rd_mem;
                reg_write_wb <= reg_write_mem;
            end
            
            processor_ready <= 1'b1;
        end
    end
    
    // Write-back data selection
    assign reg_write_data = (mem_read_mem) ? mem_read_data_wb :
                           (mac_enable_ex) ? mac_result_wb :
                           (simd_enable_ex) ? simd_result_wb :
                           alu_result_wb;
    
    // External interface
    assign pc = pc_current;
    assign external_data_out = alu_result_wb;
    
    // Debug/verification outputs
    assign instruction = instruction_if;
    assign pc_plus_4 = pc_current + 4;
    assign rs1 = rs1_id;
    assign rs2 = rs2_id;
    assign rd = rd_wb;
    assign reg_data1 = reg_data1_id;
    assign reg_data2 = reg_data2_id;
    assign reg_write = reg_write_wb;
    assign alu_result = alu_result_ex;
    // ALU flags come directly from ALU module (not pipelined)
    // These are already connected to output ports in the ALU instantiation
    assign alu_op = alu_op_ex;
    // MAC signals come directly from MAC module (not pipelined)
    // These are already connected to output ports in the MAC instantiation
    assign mac_mode = mac_mode_ex;
    assign mac_enable = mac_enable_ex;
    assign saturate = saturate_ex;
    assign round = round_ex;
    // SIMD signals come directly from SIMD module (not pipelined)
    // These are already connected to output ports in the SIMD instantiation
    assign simd_op = simd_op_ex;
    assign simd_width = simd_width_ex;
    assign simd_enable = simd_enable_ex;
    assign mem_read_data = mem_read_data_mem;
    assign mem_read = mem_read_ex;
    assign mem_write = mem_write_ex;
    assign mem_ready = 1'b1; // Assume memory is always ready
    assign branch = branch_ex;
    assign jump = jump_ex;
    // branch_target is calculated as a wire, not pipelined
    // branch_taken is calculated as a wire, not pipelined

endmodule
