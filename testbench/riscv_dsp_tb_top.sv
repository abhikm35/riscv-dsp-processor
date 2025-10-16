//=============================================================================
// RISC-V DSP Processor Top-Level Testbench
// SystemVerilog testbench with UVM-style verification and assertions
//=============================================================================

module riscv_dsp_tb_top;
    
    import uvm_pkg::*;
    import riscv_dsp_pkg::*;
    `include "uvm_macros.svh"
    
    // Clock and reset
    logic clk = 1'b0;
    logic rst_n;
    
    // Instantiate interface
    riscv_dsp_if riscv_if(.clk(clk));
    
    // Instantiate DUT
    riscv_dsp_core dut (
        .clk(clk),
        .rst_n(riscv_if.rst_n),
        .external_data_in(riscv_if.external_data_in),
        .external_data_out(riscv_if.external_data_out),
        .processor_ready(riscv_if.processor_ready),
        
        // Debug/verification outputs
        .pc(riscv_if.pc),
        .instruction(riscv_if.instruction),
        .pc_plus_4(riscv_if.pc_plus_4),
        .rs1(riscv_if.rs1),
        .rs2(riscv_if.rs2),
        .rd(riscv_if.rd),
        .reg_data1(riscv_if.rs1_data),
        .reg_data2(riscv_if.rs2_data),
        .reg_write_data(riscv_if.reg_write_data),
        .reg_write(riscv_if.reg_write),
        .alu_result(riscv_if.alu_result),
        .alu_zero(riscv_if.alu_zero),
        .alu_overflow(riscv_if.alu_overflow),
        .alu_carry(riscv_if.alu_carry),
        .alu_negative(riscv_if.alu_negative),
        .alu_op(riscv_if.alu_op),
        .mac_result(riscv_if.mac_result),
        .mac_overflow(riscv_if.mac_overflow),
        .mac_underflow(riscv_if.mac_underflow),
        .mac_mode(riscv_if.mac_mode),
        .mac_enable(riscv_if.mac_enable),
        .saturate(riscv_if.saturate),
        .round(riscv_if.round),
        .simd_result(riscv_if.simd_result),
        .simd_overflow(riscv_if.simd_overflow),
        .simd_op(riscv_if.simd_op),
        .simd_width(riscv_if.simd_width),
        .simd_enable(riscv_if.simd_enable),
        .mem_read_data(riscv_if.mem_data_out),
        .mem_read(riscv_if.mem_read),
        .mem_write(riscv_if.mem_write),
        .mem_ready(riscv_if.mem_valid),
        .branch(riscv_if.branch),
        .jump(riscv_if.jump),
        .branch_target(riscv_if.branch_target),
        .branch_taken(riscv_if.branch_taken)
    );
    
    // Additional interface connections for signals not directly connected
    assign riscv_if.mac_a = riscv_if.rs1_data;  // Use rs1_data as MAC input A
    assign riscv_if.mac_b = riscv_if.rs2_data;  // Use rs2_data as MAC input B
    assign riscv_if.mac_c = riscv_if.reg_write_data; // Use reg_write_data as MAC input C
    assign riscv_if.simd_a = riscv_if.rs1_data;  // Use rs1_data as SIMD input A
    assign riscv_if.simd_b = riscv_if.rs2_data;  // Use rs2_data as SIMD input B
    assign riscv_if.mem_addr = riscv_if.alu_result;  // Use ALU result as memory address
    assign riscv_if.mem_data_in = riscv_if.rs2_data; // Use rs2_data as memory write data
    
    // Clock generation
    always #5 clk = ~clk;
    
    // All UVM classes are now defined in riscv_dsp_pkg.sv
    
    // Initial block
    initial begin
        // Configure UVM
        uvm_config_db#(virtual riscv_dsp_if)::set(null, "*", "vif", riscv_if);
        
        // Run test
        run_test("riscv_dsp_test");
    end
    
    // Waveform dumping
    initial begin
        `ifdef CADENCE
        $shm_open("riscv_dsp_waves.shm");
        $shm_probe("AC");
        `endif
    end
    
    // ==================== SYSTEMVERILOG ASSERTIONS ====================
    
    // Reset assertion
    property reset_property;
        @(posedge clk)
        !rst_n |=> (riscv_if.processor_ready == 1'b0);
    endproperty
    assert_reset: assert property (reset_property)
        else `uvm_error("ASSERT", "Reset assertion failed")
    
    // ALU overflow assertion
    property alu_overflow_property;
        @(posedge clk)
        disable iff (!rst_n)
        (riscv_if.alu_op == riscv_dsp_pkg::ALU_ADD) && 
        (riscv_if.rs1_data[31] == riscv_if.rs2_data[31]) &&
        (riscv_if.alu_result[31] != riscv_if.rs1_data[31])
        |-> riscv_if.alu_overflow;
    endproperty
    assert_alu_overflow: assert property (alu_overflow_property)
        else `uvm_error("ASSERT", "ALU overflow assertion failed")
    
    // MAC saturation assertion
    property mac_saturation_property;
        @(posedge clk)
        disable iff (!rst_n)
        riscv_if.mac_enable && riscv_if.saturate && riscv_if.mac_overflow
        |-> (riscv_if.mac_result == 32'h7FFFFFFF || riscv_if.mac_result == 32'h80000000);
    endproperty
    assert_mac_saturation: assert property (mac_saturation_property)
        else `uvm_error("ASSERT", "MAC saturation assertion failed")
    
    // Memory access assertion
    property memory_access_property;
        @(posedge clk)
        disable iff (!rst_n)
        (riscv_if.mem_read || riscv_if.mem_write) |-> riscv_if.mem_valid;
    endproperty
    assert_memory_access: assert property (memory_access_property)
        else `uvm_error("ASSERT", "Memory access assertion failed")
    
    // Register write assertion
    property register_write_property;
        @(posedge clk)
        disable iff (!rst_n)
        riscv_if.reg_write |-> (riscv_if.rd != 5'h0);
    endproperty
    assert_register_write: assert property (register_write_property)
        else `uvm_error("ASSERT", "Register write assertion failed")
    
    // Branch target assertion
    property branch_target_property;
        @(posedge clk)
        disable iff (!rst_n)
        riscv_if.branch_taken |-> (riscv_if.branch_target[1:0] == 2'b00);
    endproperty
    assert_branch_target: assert property (branch_target_property)
        else `uvm_error("ASSERT", "Branch target assertion failed")
    
    // SIMD operation assertion
    property simd_operation_property;
        @(posedge clk)
        disable iff (!rst_n)
        riscv_if.simd_enable |-> (riscv_if.simd_op inside {riscv_dsp_pkg::SIMD_ADD4, 
                                                           riscv_dsp_pkg::SIMD_SUB4, 
                                                           riscv_dsp_pkg::SIMD_MUL4,
                                                           riscv_dsp_pkg::SIMD_AND4,
                                                           riscv_dsp_pkg::SIMD_OR4,
                                                           riscv_dsp_pkg::SIMD_XOR4,
                                                           riscv_dsp_pkg::SIMD_SAT,
                                                           riscv_dsp_pkg::SIMD_CLIP});
    endproperty
    assert_simd_operation: assert property (simd_operation_property)
        else `uvm_error("ASSERT", "SIMD operation assertion failed")
    
    // MAC mode assertion
    property mac_mode_property;
        @(posedge clk)
        disable iff (!rst_n)
        riscv_if.mac_enable |-> (riscv_if.mac_mode inside {riscv_dsp_pkg::MAC_SIGNED, 
                                                          riscv_dsp_pkg::MAC_UNSIGNED, 
                                                          riscv_dsp_pkg::MAC_MIXED});
    endproperty
    assert_mac_mode: assert property (mac_mode_property)
        else `uvm_error("ASSERT", "MAC mode assertion failed")
    
    // Instruction fetch assertion - only check when PC is valid
    property instruction_fetch_property;
        @(posedge clk)
        disable iff (!rst_n)
        (riscv_if.processor_ready && riscv_if.pc >= 32'h1000) |-> (riscv_if.instruction[1:0] == 2'b11);
    endproperty
    assert_instruction_fetch: assert property (instruction_fetch_property)
        else `uvm_error("ASSERT", "Instruction fetch assertion failed")
    
    // Coverage assertions
    covergroup riscv_dsp_cg @(posedge clk);
        alu_op_cp: coverpoint riscv_if.alu_op {
            bins add = {riscv_dsp_pkg::ALU_ADD};
            bins sub = {riscv_dsp_pkg::ALU_SUB};
            bins and_op = {riscv_dsp_pkg::ALU_AND};
            bins or_op = {riscv_dsp_pkg::ALU_OR};
            bins xor_op = {riscv_dsp_pkg::ALU_XOR};
            bins sll = {riscv_dsp_pkg::ALU_SLL};
            bins srl = {riscv_dsp_pkg::ALU_SRL};
            bins sra = {riscv_dsp_pkg::ALU_SRA};
            bins slt = {riscv_dsp_pkg::ALU_SLT};
            bins sltu = {riscv_dsp_pkg::ALU_SLTU};
            bins mac = {riscv_dsp_pkg::ALU_MAC};
            bins simd = {riscv_dsp_pkg::ALU_SIMD};
        }
        
        mac_mode_cp: coverpoint riscv_if.mac_mode {
            bins signed_mode = {riscv_dsp_pkg::MAC_SIGNED};
            bins unsigned_mode = {riscv_dsp_pkg::MAC_UNSIGNED};
            bins mixed_mode = {riscv_dsp_pkg::MAC_MIXED};
        }
        
        simd_op_cp: coverpoint riscv_if.simd_op {
            bins add4 = {riscv_dsp_pkg::SIMD_ADD4};
            bins sub4 = {riscv_dsp_pkg::SIMD_SUB4};
            bins mul4 = {riscv_dsp_pkg::SIMD_MUL4};
            bins and4 = {riscv_dsp_pkg::SIMD_AND4};
            bins or4 = {riscv_dsp_pkg::SIMD_OR4};
            bins xor4 = {riscv_dsp_pkg::SIMD_XOR4};
            bins sat = {riscv_dsp_pkg::SIMD_SAT};
            bins clip = {riscv_dsp_pkg::SIMD_CLIP};
        }
        
        overflow_cp: coverpoint riscv_if.alu_overflow {
            bins no_overflow = {1'b0};
            bins overflow = {1'b1};
        }
        
        mac_overflow_cp: coverpoint riscv_if.mac_overflow {
            bins no_mac_overflow = {1'b0};
            bins mac_overflow = {1'b1};
        }
        
        saturation_cp: coverpoint riscv_if.saturate {
            bins no_saturation = {1'b0};
            bins saturation = {1'b1};
        }
        
        rounding_cp: coverpoint riscv_if.round {
            bins no_rounding = {1'b0};
            bins rounding = {1'b1};
        }
        
        // Cross coverage
        alu_mac_cross: cross alu_op_cp, mac_mode_cp;
        mac_sat_cross: cross mac_mode_cp, saturation_cp;
        simd_width_cross: cross simd_op_cp, riscv_if.simd_width;
    endgroup
    
    // Instantiate coverage group
    riscv_dsp_cg riscv_cg = new();

endmodule : riscv_dsp_tb_top
