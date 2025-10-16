//=============================================================================
// RISC-V DSP Processor Interface
// SystemVerilog interface for verification
//=============================================================================

// Parameters
parameter int DATA_WIDTH = 32;
parameter int ADDR_WIDTH = 32;
parameter int REG_WIDTH = 5;
parameter int INSTR_WIDTH = 32;

// Interface definition
interface riscv_dsp_if(input logic clk);
    // Control signals
    logic rst_n;
    logic processor_ready;
    
    // External data interface
    logic [DATA_WIDTH-1:0] external_data_in;
    logic [DATA_WIDTH-1:0] external_data_out;
    
    // Program counter
    logic [ADDR_WIDTH-1:0] pc;
    logic [ADDR_WIDTH-1:0] pc_plus_4;
    
    // Instruction
    logic [INSTR_WIDTH-1:0] instruction;
    
    // Register file
    logic [REG_WIDTH-1:0] rs1, rs2, rd;
    logic [DATA_WIDTH-1:0] rs1_data, rs2_data;
    logic [DATA_WIDTH-1:0] reg_write_data;
    logic reg_write;
    
    // ALU
    logic [DATA_WIDTH-1:0] alu_result;
    logic alu_zero, alu_overflow, alu_carry, alu_negative;
    logic [4:0] alu_op;
    
    // MAC unit
    logic [DATA_WIDTH-1:0] mac_a, mac_b, mac_c;
    logic [DATA_WIDTH-1:0] mac_result;
    logic mac_overflow, mac_underflow;
    logic [1:0] mac_mode;
    logic mac_enable;
    logic saturate, round;
    
    // SIMD unit
    logic [DATA_WIDTH-1:0] simd_a, simd_b;
    logic [DATA_WIDTH-1:0] simd_result;
    logic simd_overflow;
    logic [2:0] simd_op;
    logic [1:0] simd_width;
    logic simd_enable;
    
    // Memory interface
    logic [ADDR_WIDTH-1:0] mem_addr;
    logic [DATA_WIDTH-1:0] mem_data_in, mem_data_out;
    logic mem_read, mem_write, mem_valid;
    
    // Branch and jump
    logic branch, jump;
    logic [ADDR_WIDTH-1:0] branch_target;
    logic branch_taken;
    
        // Clocking block for driver
        clocking cb @(posedge clk);
            output rst_n, external_data_in;
            input processor_ready, external_data_out;
            input pc, pc_plus_4, instruction;
            input rs1, rs2, rd, rs1_data, rs2_data, reg_write_data, reg_write;
            input alu_result, alu_zero, alu_overflow, alu_carry, alu_negative, alu_op;
            input mac_a, mac_b, mac_c, mac_result, mac_overflow, mac_underflow, mac_mode, mac_enable;
            input saturate, round;
            input simd_a, simd_b, simd_result, simd_overflow, simd_op, simd_width, simd_enable;
            input mem_addr, mem_data_in, mem_data_out, mem_read, mem_write, mem_valid;
            input branch, jump, branch_target, branch_taken;
        endclocking
        
        // Clocking block for monitor (same as driver for now)
        clocking monitor_cb @(posedge clk);
            input rst_n, external_data_in, processor_ready, external_data_out;
            input pc, pc_plus_4, instruction;
            input rs1, rs2, rd, rs1_data, rs2_data, reg_write_data, reg_write;
            input alu_result, alu_zero, alu_overflow, alu_carry, alu_negative, alu_op;
            input mac_a, mac_b, mac_c, mac_result, mac_overflow, mac_underflow, mac_mode, mac_enable;
            input saturate, round;
            input simd_a, simd_b, simd_result, simd_overflow, simd_op, simd_width, simd_enable;
            input mem_addr, mem_data_in, mem_data_out, mem_read, mem_write, mem_valid;
            input branch, jump, branch_target, branch_taken;
        endclocking
        
        // Modport for driver
        modport DRV (clocking cb, input clk);
        
        // Modport for monitor  
        modport MON (clocking monitor_cb, input clk);
        
        // Direct access modport for testbench
        modport TB (input clk, rst_n, processor_ready, external_data_out, pc, pc_plus_4, instruction,
                    rs1, rs2, rd, rs1_data, rs2_data, reg_write_data, reg_write,
                    alu_result, alu_zero, alu_overflow, alu_carry, alu_negative, alu_op,
                    mac_a, mac_b, mac_c, mac_result, mac_overflow, mac_underflow, mac_mode, mac_enable,
                    saturate, round, simd_a, simd_b, simd_result, simd_overflow, simd_op, simd_width, simd_enable,
                    mem_addr, mem_data_in, mem_data_out, mem_read, mem_write, mem_valid,
                    branch, jump, branch_target, branch_taken,
                    output external_data_in);
    
endinterface : riscv_dsp_if