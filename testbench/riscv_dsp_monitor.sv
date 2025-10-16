//=============================================================================
// RISC-V DSP Processor Monitor
// UVM-style monitor for verification environment
//=============================================================================

class riscv_dsp_monitor extends uvm_monitor;
    
    // Virtual interface
    virtual riscv_dsp_if vif;
    
    // Analysis port
    uvm_analysis_port #(riscv_dsp_seq_item) ap;
    
    // Constructor
    function new(string name = "riscv_dsp_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction
    
    // UVM field macros
    `uvm_component_utils(riscv_dsp_monitor)
    
    // Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual riscv_dsp_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found")
    endfunction
    
    // Run phase
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        forever begin
            monitor_transaction();
        end
    endtask
    
    // Monitor transaction task
    virtual task monitor_transaction();
        riscv_dsp_seq_item item;
        
        // Wait for instruction execution
        @(vif.monitor_cb);
        
        // Create transaction item
        item = riscv_dsp_seq_item::type_id::create("monitored_item");
        
        // Capture instruction information
        item.instruction = vif.monitor_cb.instruction;
        item.rs1 = vif.monitor_cb.rs1;
        item.rs2 = vif.monitor_cb.rs2;
        item.rd = vif.monitor_cb.rd;
        item.rs1_data = vif.monitor_cb.rs1_data;
        item.rs2_data = vif.monitor_cb.rs2_data;
        item.reg_write_data = vif.monitor_cb.reg_write_data;
        item.reg_write = vif.monitor_cb.reg_write;
        
        // Capture ALU results
        item.alu_result = vif.monitor_cb.alu_result;
        item.zero = vif.monitor_cb.alu_zero;
        item.overflow = vif.monitor_cb.alu_overflow;
        item.carry = vif.monitor_cb.alu_carry;
        item.negative = vif.monitor_cb.alu_negative;
        item.alu_op = vif.monitor_cb.alu_op;
        
        // Capture MAC results
        item.mac_a = vif.monitor_cb.mac_a;
        item.mac_b = vif.monitor_cb.mac_b;
        item.mac_c = vif.monitor_cb.mac_c;
        item.mac_result = vif.monitor_cb.mac_result;
        item.mac_overflow = vif.monitor_cb.mac_overflow;
        item.mac_underflow = vif.monitor_cb.mac_underflow;
        item.mac_mode = vif.monitor_cb.mac_mode;
        item.mac_enable = vif.monitor_cb.mac_enable;
        item.saturate = vif.monitor_cb.saturate;
        item.round = vif.monitor_cb.round;
        
        // Capture SIMD results
        item.simd_a = vif.monitor_cb.simd_a;
        item.simd_b = vif.monitor_cb.simd_b;
        item.simd_result = vif.monitor_cb.simd_result;
        item.simd_overflow = vif.monitor_cb.simd_overflow;
        item.simd_op = vif.monitor_cb.simd_op;
        item.simd_width = vif.monitor_cb.simd_width;
        item.simd_enable = vif.monitor_cb.simd_enable;
        
        // Capture memory information
        item.mem_addr = vif.monitor_cb.mem_addr;
        item.mem_data_in = vif.monitor_cb.mem_data_in;
        item.mem_data_out = vif.monitor_cb.mem_data_out;
        item.mem_read = vif.monitor_cb.mem_read;
        item.mem_write = vif.monitor_cb.mem_write;
        item.mem_valid = vif.monitor_cb.mem_valid;
        
        // Capture control information
        item.branch = vif.monitor_cb.branch;
        item.jump = vif.monitor_cb.jump;
        item.branch_taken = vif.monitor_cb.branch_taken;
        
        // Extract opcode from instruction
        item.opcode = riscv_dsp_pkg::opcode_t'(item.instruction[6:0]);
        
        // Send to analysis port
        ap.write(item);
        
        `uvm_info("MONITOR", $sformatf("Monitored transaction: PC=0x%08h, Instruction=0x%08h", 
                 vif.monitor_cb.pc, item.instruction), UVM_MEDIUM)
    endtask
    
    // Monitor specific operations
    virtual task monitor_alu_operation();
        riscv_dsp_seq_item item;
        
        // Wait for ALU operation
        @(vif.monitor_cb iff vif.monitor_cb.alu_op != 5'h0);
        
        item = riscv_dsp_seq_item::type_id::create("alu_item");
        item.alu_op = vif.monitor_cb.alu_op;
        item.rs1_data = vif.monitor_cb.rs1_data;
        item.rs2_data = vif.monitor_cb.rs2_data;
        item.result = vif.monitor_cb.alu_result;
        item.zero = vif.monitor_cb.alu_zero;
        item.overflow = vif.monitor_cb.alu_overflow;
        item.carry = vif.monitor_cb.alu_carry;
        item.negative = vif.monitor_cb.alu_negative;
        
        ap.write(item);
        
        `uvm_info("MONITOR", $sformatf("ALU Operation: %s, Result=0x%08h", 
                 item.alu_op.name(), item.result), UVM_MEDIUM)
    endtask
    
    virtual task monitor_mac_operation();
        riscv_dsp_seq_item item;
        
        // Wait for MAC operation
        @(vif.monitor_cb iff vif.monitor_cb.mac_enable);
        
        item = riscv_dsp_seq_item::type_id::create("mac_item");
        item.mac_a = vif.monitor_cb.mac_a;
        item.mac_b = vif.monitor_cb.mac_b;
        item.mac_c = vif.monitor_cb.mac_c;
        item.mac_result = vif.monitor_cb.mac_result;
        item.mac_mode = vif.monitor_cb.mac_mode;
        item.mac_overflow = vif.monitor_cb.mac_overflow;
        item.mac_underflow = vif.monitor_cb.mac_underflow;
        item.saturate = vif.monitor_cb.saturate;
        item.round = vif.monitor_cb.round;
        
        ap.write(item);
        
        `uvm_info("MONITOR", $sformatf("MAC Operation: a=0x%08h, b=0x%08h, c=0x%08h, result=0x%08h", 
                 item.mac_a, item.mac_b, item.mac_c, item.mac_result), UVM_MEDIUM)
    endtask
    
    virtual task monitor_simd_operation();
        riscv_dsp_seq_item item;
        
        // Wait for SIMD operation
        @(vif.monitor_cb iff vif.monitor_cb.simd_enable);
        
        item = riscv_dsp_seq_item::type_id::create("simd_item");
        item.simd_a = vif.monitor_cb.simd_a;
        item.simd_b = vif.monitor_cb.simd_b;
        item.simd_result = vif.monitor_cb.simd_result;
        item.simd_op = vif.monitor_cb.simd_op;
        item.simd_width = vif.monitor_cb.simd_width;
        item.simd_overflow = vif.monitor_cb.simd_overflow;
        
        ap.write(item);
        
        `uvm_info("MONITOR", $sformatf("SIMD Operation: %s, a=0x%08h, b=0x%08h, result=0x%08h", 
                 item.simd_op.name(), item.simd_a, item.simd_b, item.simd_result), UVM_MEDIUM)
    endtask
    
    virtual task monitor_memory_operation();
        riscv_dsp_seq_item item;
        
        // Wait for memory operation
        @(vif.monitor_cb iff (vif.monitor_cb.mem_read || vif.monitor_cb.mem_write));
        
        item = riscv_dsp_seq_item::type_id::create("mem_item");
        item.mem_addr = vif.monitor_cb.mem_addr;
        item.mem_data_in = vif.monitor_cb.mem_data_in;
        item.mem_data_out = vif.monitor_cb.mem_data_out;
        item.mem_read = vif.monitor_cb.mem_read;
        item.mem_write = vif.monitor_cb.mem_write;
        item.mem_valid = vif.monitor_cb.mem_valid;
        
        ap.write(item);
        
        `uvm_info("MONITOR", $sformatf("Memory Operation: %s at addr 0x%08h, data=0x%08h", 
                 item.mem_write ? "WRITE" : "READ", item.mem_addr, 
                 item.mem_write ? item.mem_data_in : item.mem_data_out), UVM_MEDIUM)
    endtask

endclass : riscv_dsp_monitor
