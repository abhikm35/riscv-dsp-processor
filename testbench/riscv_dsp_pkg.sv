//=============================================================================
// RISC-V DSP Processor Package
// SystemVerilog package for verification environment
//=============================================================================

package riscv_dsp_pkg;

    // Import SystemVerilog standard library
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Parameters
    parameter int DATA_WIDTH = 32;
    parameter int ADDR_WIDTH = 32;
    parameter int REG_WIDTH = 5;
    parameter int INSTR_WIDTH = 32;
    
    // Instruction types
    typedef enum logic [6:0] {
        OP_R_TYPE = 7'b0110011,  // R-type instructions
        OP_I_TYPE = 7'b0010011,   // I-type instructions
        OP_S_TYPE = 7'b0100011,   // S-type instructions
        OP_B_TYPE = 7'b1100011,   // B-type instructions
        OP_U_TYPE = 7'b0110111,   // U-type instructions
        OP_J_TYPE = 7'b1101111,   // J-type instructions
        OP_MAC    = 7'b1110011,   // MAC instruction
        OP_SIMD   = 7'b1111011    // SIMD instruction
    } opcode_t;

    // ALU operations
    typedef enum logic [4:0] {
        ALU_ADD  = 5'b00000,
        ALU_SUB  = 5'b00001,
        ALU_SLL  = 5'b00010,
        ALU_SLT  = 5'b00011,
        ALU_SLTU = 5'b00100,
        ALU_XOR  = 5'b00101,
        ALU_SRL  = 5'b00110,
        ALU_SRA  = 5'b00111,
        ALU_OR   = 5'b01000,
        ALU_AND  = 5'b01001,
        ALU_MAC  = 5'b01010,
        ALU_SIMD = 5'b01011
    } alu_op_t;

    // MAC modes
    typedef enum logic [1:0] {
        MAC_SIGNED   = 2'b00,
        MAC_UNSIGNED = 2'b01,
        MAC_MIXED    = 2'b10,
        MAC_RESERVED = 2'b11
    } mac_mode_t;

    // SIMD operations
    typedef enum logic [2:0] {
        SIMD_ADD4 = 3'b000,
        SIMD_SUB4 = 3'b001,
        SIMD_MUL4 = 3'b010,
        SIMD_AND4 = 3'b011,
        SIMD_OR4  = 3'b100,
        SIMD_XOR4 = 3'b101,
        SIMD_SAT  = 3'b110,
        SIMD_CLIP = 3'b111
    } simd_op_t;

    // Sequence item class
    class riscv_dsp_seq_item extends uvm_sequence_item;
        
        // Instruction fields
        rand logic [INSTR_WIDTH-1:0] instruction;
        rand logic [REG_WIDTH-1:0]   rs1, rs2, rd;
        rand logic [DATA_WIDTH-1:0]  imm;
        rand opcode_t                opcode;
        rand alu_op_t                alu_op;
        rand mac_mode_t              mac_mode;
        rand simd_op_t               simd_op;
        
        // Control signals
        rand logic                   mem_read, mem_write, reg_write;
        rand logic                   branch, jump;
        rand logic                   saturate, round;
        
        // Data
        rand logic [DATA_WIDTH-1:0]  rs1_data, rs2_data;
        rand logic [DATA_WIDTH-1:0]  mem_data;
        rand logic [ADDR_WIDTH-1:0]  mem_addr;
        
        // MAC specific
        rand logic [DATA_WIDTH-1:0] mac_a, mac_b, mac_c;
        logic [DATA_WIDTH-1:0] mac_result;
        logic mac_overflow, mac_underflow;
        logic mac_enable;
        
        // SIMD specific
        rand logic [DATA_WIDTH-1:0] simd_a, simd_b;
        logic [DATA_WIDTH-1:0] simd_result;
        logic simd_overflow;
        rand logic [1:0]            simd_width;
        logic simd_enable;
        
        // ALU results
        logic [DATA_WIDTH-1:0] result;
        logic zero, overflow, carry, negative;
        
        // Memory interface
        logic [DATA_WIDTH-1:0] mem_data_in, mem_data_out;
        logic mem_valid;
        
        // Branch and jump
        logic branch_taken;
        logic [ADDR_WIDTH-1:0] branch_target;
        
        // Register write data
        logic [DATA_WIDTH-1:0] reg_write_data;
        
        // Constructor
        function new(string name = "riscv_dsp_seq_item");
            super.new(name);
        endfunction
        
        // UVM field macros
        `uvm_object_utils_begin(riscv_dsp_seq_item)
            `uvm_field_int(instruction, UVM_ALL_ON)
            `uvm_field_int(rs1, UVM_ALL_ON)
            `uvm_field_int(rs2, UVM_ALL_ON)
            `uvm_field_int(rd, UVM_ALL_ON)
            `uvm_field_int(imm, UVM_ALL_ON)
            `uvm_field_enum(opcode_t, opcode, UVM_ALL_ON)
            `uvm_field_enum(alu_op_t, alu_op, UVM_ALL_ON)
            `uvm_field_enum(mac_mode_t, mac_mode, UVM_ALL_ON)
            `uvm_field_enum(simd_op_t, simd_op, UVM_ALL_ON)
            `uvm_field_int(mem_read, UVM_ALL_ON)
            `uvm_field_int(mem_write, UVM_ALL_ON)
            `uvm_field_int(reg_write, UVM_ALL_ON)
            `uvm_field_int(branch, UVM_ALL_ON)
            `uvm_field_int(jump, UVM_ALL_ON)
            `uvm_field_int(saturate, UVM_ALL_ON)
            `uvm_field_int(round, UVM_ALL_ON)
            `uvm_field_int(rs1_data, UVM_ALL_ON)
            `uvm_field_int(rs2_data, UVM_ALL_ON)
            `uvm_field_int(mem_data, UVM_ALL_ON)
            `uvm_field_int(mem_addr, UVM_ALL_ON)
            `uvm_field_int(mac_a, UVM_ALL_ON)
            `uvm_field_int(mac_b, UVM_ALL_ON)
            `uvm_field_int(mac_c, UVM_ALL_ON)
            `uvm_field_int(simd_a, UVM_ALL_ON)
            `uvm_field_int(simd_b, UVM_ALL_ON)
            `uvm_field_int(simd_width, UVM_ALL_ON)
        `uvm_object_utils_end
        
    endclass : riscv_dsp_seq_item

    // Simple test class
    class riscv_dsp_test extends uvm_test;
        
        // Constructor
        function new(string name = "riscv_dsp_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction
        
        // UVM field macros
        `uvm_component_utils(riscv_dsp_test)
        
        // Run phase
        virtual task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            
            `uvm_info("TEST", "Starting RISC-V DSP Processor Test", UVM_MEDIUM)
            
            // Wait for some time
            #1000;
            
            `uvm_info("TEST", "Test completed", UVM_MEDIUM)
            
            phase.drop_objection(this);
        endtask
        
    endclass : riscv_dsp_test

endpackage : riscv_dsp_pkg
