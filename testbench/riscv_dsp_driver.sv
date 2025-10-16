//=============================================================================
// RISC-V DSP Processor Driver
// UVM-style driver for verification environment
//=============================================================================

class riscv_dsp_driver extends uvm_driver #(riscv_dsp_seq_item);
    
    // Virtual interface
    virtual riscv_dsp_if vif;
    
    // Constructor
    function new(string name = "riscv_dsp_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // UVM field macros
    `uvm_component_utils(riscv_dsp_driver)
    
    // Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual riscv_dsp_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found")
    endfunction
    
    // Run phase
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        // Initialize interface
        vif.cb.rst_n <= 1'b0;
        vif.cb.external_data_in <= 32'h0;
        
        // Reset sequence
        reset_task();
        
        // Main driver loop
        forever begin
            seq_item_port.get_next_item(req);
            drive_item(req);
            seq_item_port.item_done();
        end
    endtask
    
    // Reset task
    virtual task reset_task();
        `uvm_info("DRIVER", "Applying reset", UVM_MEDIUM)
        vif.cb.rst_n <= 1'b0;
        repeat(5) @(vif.cb);
        vif.cb.rst_n <= 1'b1;
        repeat(2) @(vif.cb);
        `uvm_info("DRIVER", "Reset released", UVM_MEDIUM)
    endtask
    
    // Drive item task
    virtual task drive_item(riscv_dsp_seq_item item);
        `uvm_info("DRIVER", $sformatf("Driving item: %s", item.sprint()), UVM_MEDIUM)
        
        // Wait for processor to be ready
        wait(vif.cb.processor_ready);
        
        // Drive external data if needed
        if (item.mem_read || item.mem_write) begin
            vif.cb.external_data_in <= item.mem_data;
        end
        
        // Wait for instruction execution
        repeat(10) @(vif.cb);
        
        `uvm_info("DRIVER", "Item driven successfully", UVM_MEDIUM)
    endtask
    
    // Specific instruction drivers
    virtual task drive_add_instruction(logic [4:0] rs1, logic [4:0] rs2, logic [4:0] rd);
        `uvm_info("DRIVER", $sformatf("Driving ADD instruction: x%d = x%d + x%d", rd, rs1, rs2), UVM_MEDIUM)
        // Implementation would depend on how instructions are loaded into processor
        repeat(5) @(vif.cb);
    endtask
    
    virtual task drive_mac_instruction(logic [4:0] rs1, logic [4:0] rs2, logic [4:0] rd, 
                                      logic [31:0] a, logic [31:0] b, logic [31:0] c,
                                      logic [1:0] mode, logic sat, logic rnd);
        `uvm_info("DRIVER", $sformatf("Driving MAC instruction: x%d = x%d * x%d + %d", rd, rs1, rs2, c), UVM_MEDIUM)
        // MAC instruction implementation
        repeat(3) @(vif.cb);
    endtask
    
    virtual task drive_simd_instruction(logic [4:0] rs1, logic [4:0] rs2, logic [4:0] rd,
                                       logic [2:0] simd_op, logic [1:0] width);
        `uvm_info("DRIVER", $sformatf("Driving SIMD instruction: x%d = SIMD_OP(x%d, x%d)", rd, rs1, rs2), UVM_MEDIUM)
        // SIMD instruction implementation
        repeat(3) @(vif.cb);
    endtask
    
    virtual task drive_memory_instruction(logic [31:0] addr, logic [31:0] data, logic is_write);
        `uvm_info("DRIVER", $sformatf("Driving %s instruction at addr 0x%08h", is_write ? "STORE" : "LOAD", addr), UVM_MEDIUM)
        // Memory instruction implementation
        repeat(5) @(vif.cb);
    endtask
    
    virtual task drive_branch_instruction(logic [31:0] target, logic taken);
        `uvm_info("DRIVER", $sformatf("Driving branch instruction to 0x%08h, taken=%b", target, taken), UVM_MEDIUM)
        // Branch instruction implementation
        repeat(3) @(vif.cb);
    endtask

endclass : riscv_dsp_driver
