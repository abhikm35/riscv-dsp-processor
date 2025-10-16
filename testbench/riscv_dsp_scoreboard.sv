//=============================================================================
// RISC-V DSP Processor Scoreboard
// UVM-style scoreboard for functional verification
//=============================================================================

class riscv_dsp_scoreboard extends uvm_scoreboard;
    
    // Analysis port
    uvm_analysis_imp #(riscv_dsp_seq_item, riscv_dsp_scoreboard) ap;
    
    // Reference model results
    riscv_dsp_seq_item ref_item;
    
    // Statistics
    int total_transactions = 0;
    int passed_transactions = 0;
    int failed_transactions = 0;
    
    // Constructor
    function new(string name = "riscv_dsp_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction
    
    // UVM field macros
    `uvm_component_utils(riscv_dsp_scoreboard)
    
    // Write function for analysis port
    virtual function void write(riscv_dsp_seq_item item);
        total_transactions++;
        
        `uvm_info("SCOREBOARD", $sformatf("Received transaction #%0d", total_transactions), UVM_MEDIUM)
        
        // Create reference model result
        ref_item = riscv_dsp_seq_item::type_id::create("ref_item");
        ref_item.copy(item);
        
        // Calculate expected results
        calculate_expected_result(ref_item);
        
        // Compare with actual results
        if (compare_results(item, ref_item)) begin
            passed_transactions++;
            `uvm_info("SCOREBOARD", "Transaction PASSED", UVM_MEDIUM)
        end else begin
            failed_transactions++;
            `uvm_error("SCOREBOARD", "Transaction FAILED")
        end
        
        // Print statistics
        if (total_transactions % 10 == 0) begin
            print_statistics();
        end
    endfunction
    
    // Calculate expected result based on instruction type
    virtual function void calculate_expected_result(riscv_dsp_seq_item item);
        case (item.opcode)
            riscv_dsp_pkg::OP_R_TYPE: begin
                calculate_r_type_result(item);
            end
            riscv_dsp_pkg::OP_I_TYPE: begin
                calculate_i_type_result(item);
            end
            riscv_dsp_pkg::OP_MAC: begin
                calculate_mac_result(item);
            end
            riscv_dsp_pkg::OP_SIMD: begin
                calculate_simd_result(item);
            end
            default: begin
                `uvm_warning("SCOREBOARD", $sformatf("Unknown opcode: %s", item.opcode.name()))
            end
        endcase
    endfunction
    
    // Calculate R-type instruction results
    virtual function void calculate_r_type_result(riscv_dsp_seq_item item);
        case (item.alu_op)
            riscv_dsp_pkg::ALU_ADD: begin
                item.result = item.rs1_data + item.rs2_data;
                item.overflow = ((item.rs1_data[31] == item.rs2_data[31]) && 
                               (item.result[31] != item.rs1_data[31]));
            end
            riscv_dsp_pkg::ALU_SUB: begin
                item.result = item.rs1_data - item.rs2_data;
                item.overflow = ((item.rs1_data[31] != item.rs2_data[31]) && 
                               (item.result[31] != item.rs1_data[31]));
            end
            riscv_dsp_pkg::ALU_AND: begin
                item.result = item.rs1_data & item.rs2_data;
            end
            riscv_dsp_pkg::ALU_OR: begin
                item.result = item.rs1_data | item.rs2_data;
            end
            riscv_dsp_pkg::ALU_XOR: begin
                item.result = item.rs1_data ^ item.rs2_data;
            end
            riscv_dsp_pkg::ALU_SLL: begin
                item.result = item.rs1_data << item.rs2_data[4:0];
            end
            riscv_dsp_pkg::ALU_SRL: begin
                item.result = item.rs1_data >> item.rs2_data[4:0];
            end
            riscv_dsp_pkg::ALU_SRA: begin
                item.result = $signed(item.rs1_data) >>> item.rs2_data[4:0];
            end
            riscv_dsp_pkg::ALU_SLT: begin
                item.result = ($signed(item.rs1_data) < $signed(item.rs2_data)) ? 32'h1 : 32'h0;
            end
            riscv_dsp_pkg::ALU_SLTU: begin
                item.result = (item.rs1_data < item.rs2_data) ? 32'h1 : 32'h0;
            end
        endcase
        
        item.zero = (item.result == 32'h0);
        item.negative = item.result[31];
    endfunction
    
    // Calculate I-type instruction results
    virtual function void calculate_i_type_result(riscv_dsp_seq_item item);
        case (item.alu_op)
            riscv_dsp_pkg::ALU_ADD: begin
                item.result = item.rs1_data + item.imm;
                item.overflow = ((item.rs1_data[31] == item.imm[31]) && 
                               (item.result[31] != item.rs1_data[31]));
            end
            riscv_dsp_pkg::ALU_AND: begin
                item.result = item.rs1_data & item.imm;
            end
            riscv_dsp_pkg::ALU_OR: begin
                item.result = item.rs1_data | item.imm;
            end
            riscv_dsp_pkg::ALU_XOR: begin
                item.result = item.rs1_data ^ item.imm;
            end
            riscv_dsp_pkg::ALU_SLL: begin
                item.result = item.rs1_data << item.imm[4:0];
            end
            riscv_dsp_pkg::ALU_SRL: begin
                item.result = item.rs1_data >> item.imm[4:0];
            end
            riscv_dsp_pkg::ALU_SRA: begin
                item.result = $signed(item.rs1_data) >>> item.imm[4:0];
            end
            riscv_dsp_pkg::ALU_SLT: begin
                item.result = ($signed(item.rs1_data) < $signed(item.imm)) ? 32'h1 : 32'h0;
            end
            riscv_dsp_pkg::ALU_SLTU: begin
                item.result = (item.rs1_data < item.imm) ? 32'h1 : 32'h0;
            end
        endcase
        
        item.zero = (item.result == 32'h0);
        item.negative = item.result[31];
    endfunction
    
    // Calculate MAC instruction results
    virtual function void calculate_mac_result(riscv_dsp_seq_item item);
        logic [63:0] product;
        logic [63:0] mac_result_64;
        
        // Perform multiplication based on mode
        case (item.mac_mode)
            riscv_dsp_pkg::MAC_SIGNED: begin
                product = $signed(item.mac_a) * $signed(item.mac_b);
            end
            riscv_dsp_pkg::MAC_UNSIGNED: begin
                product = $unsigned(item.mac_a) * $unsigned(item.mac_b);
            end
            riscv_dsp_pkg::MAC_MIXED: begin
                product = $signed(item.mac_a) * $unsigned(item.mac_b);
            end
        endcase
        
        // Add accumulator
        mac_result_64 = product + item.mac_c;
        
        // Check for overflow/underflow
        if (item.mac_mode == riscv_dsp_pkg::MAC_SIGNED) begin
            item.mac_overflow = (mac_result_64[63] != mac_result_64[31]);
            item.mac_underflow = item.mac_overflow && mac_result_64[63];
        end else begin
            item.mac_overflow = (mac_result_64[63:32] != 32'h0);
            item.mac_underflow = 1'b0;
        end
        
        // Apply saturation if enabled
        if (item.saturate && item.mac_overflow) begin
            if (item.mac_mode == riscv_dsp_pkg::MAC_SIGNED) begin
                item.result = mac_result_64[63] ? 32'h80000000 : 32'h7FFFFFFF;
            end else begin
                item.result = 32'hFFFFFFFF;
            end
        end else begin
            item.result = mac_result_64[31:0];
        end
        
        // Apply rounding if enabled
        if (item.round) begin
            item.result = item.result + (item.result[0] ? 1 : 0);
        end
    endfunction
    
    // Calculate SIMD instruction results
    virtual function void calculate_simd_result(riscv_dsp_seq_item item);
        case (item.simd_op)
            riscv_dsp_pkg::SIMD_ADD4: begin
                // 4x 8-bit addition
                item.result[7:0]   = item.simd_a[7:0]   + item.simd_b[7:0];
                item.result[15:8]  = item.simd_a[15:8]  + item.simd_b[15:8];
                item.result[23:16] = item.simd_a[23:16] + item.simd_b[23:16];
                item.result[31:24] = item.simd_a[31:24] + item.simd_b[31:24];
            end
            riscv_dsp_pkg::SIMD_SUB4: begin
                // 4x 8-bit subtraction
                item.result[7:0]   = item.simd_a[7:0]   - item.simd_b[7:0];
                item.result[15:8]  = item.simd_a[15:8]  - item.simd_b[15:8];
                item.result[23:16] = item.simd_a[23:16] - item.simd_b[23:16];
                item.result[31:24] = item.simd_a[31:24] - item.simd_b[31:24];
            end
            riscv_dsp_pkg::SIMD_MUL4: begin
                // 4x 8-bit multiplication
                item.result[7:0]   = item.simd_a[7:0]   * item.simd_b[7:0];
                item.result[15:8]  = item.simd_a[15:8]  * item.simd_b[15:8];
                item.result[23:16] = item.simd_a[23:16] * item.simd_b[23:16];
                item.result[31:24] = item.simd_a[31:24] * item.simd_b[31:24];
            end
            riscv_dsp_pkg::SIMD_AND4: begin
                // 4x 8-bit AND
                item.result[7:0]   = item.simd_a[7:0]   & item.simd_b[7:0];
                item.result[15:8]  = item.simd_a[15:8]  & item.simd_b[15:8];
                item.result[23:16] = item.simd_a[23:16] & item.simd_b[23:16];
                item.result[31:24] = item.simd_a[31:24] & item.simd_b[31:24];
            end
            riscv_dsp_pkg::SIMD_OR4: begin
                // 4x 8-bit OR
                item.result[7:0]   = item.simd_a[7:0]   | item.simd_b[7:0];
                item.result[15:8]  = item.simd_a[15:8]  | item.simd_b[15:8];
                item.result[23:16] = item.simd_a[23:16] | item.simd_b[23:16];
                item.result[31:24] = item.simd_a[31:24] | item.simd_b[31:24];
            end
            riscv_dsp_pkg::SIMD_XOR4: begin
                // 4x 8-bit XOR
                item.result[7:0]   = item.simd_a[7:0]   ^ item.simd_b[7:0];
                item.result[15:8]  = item.simd_a[15:8]  ^ item.simd_b[15:8];
                item.result[23:16] = item.simd_a[23:16] ^ item.simd_b[23:16];
                item.result[31:24] = item.simd_a[31:24] ^ item.simd_b[31:24];
            end
        endcase
        
        item.simd_overflow = 1'b0; // SIMD overflow detection would be more complex
    endfunction
    
    // Compare actual vs expected results
    virtual function bit compare_results(riscv_dsp_seq_item actual, riscv_dsp_seq_item expected);
        bit result_match = 1;
        
        // Compare main result
        if (actual.result !== expected.result) begin
            `uvm_error("SCOREBOARD", $sformatf("Result mismatch: Expected=0x%08h, Actual=0x%08h", 
                     expected.result, actual.result))
            result_match = 0;
        end
        
        // Compare flags
        if (actual.zero !== expected.zero) begin
            `uvm_error("SCOREBOARD", $sformatf("Zero flag mismatch: Expected=%b, Actual=%b", 
                     expected.zero, actual.zero))
            result_match = 0;
        end
        
        if (actual.overflow !== expected.overflow) begin
            `uvm_error("SCOREBOARD", $sformatf("Overflow flag mismatch: Expected=%b, Actual=%b", 
                     expected.overflow, actual.overflow))
            result_match = 0;
        end
        
        if (actual.negative !== expected.negative) begin
            `uvm_error("SCOREBOARD", $sformatf("Negative flag mismatch: Expected=%b, Actual=%b", 
                     expected.negative, actual.negative))
            result_match = 0;
        end
        
        // Compare MAC-specific flags
        if (actual.mac_overflow !== expected.mac_overflow) begin
            `uvm_error("SCOREBOARD", $sformatf("MAC overflow flag mismatch: Expected=%b, Actual=%b", 
                     expected.mac_overflow, actual.mac_overflow))
            result_match = 0;
        end
        
        if (actual.mac_underflow !== expected.mac_underflow) begin
            `uvm_error("SCOREBOARD", $sformatf("MAC underflow flag mismatch: Expected=%b, Actual=%b", 
                     expected.mac_underflow, actual.mac_underflow))
            result_match = 0;
        end
        
        return result_match;
    endfunction
    
    // Print statistics
    virtual function void print_statistics();
        `uvm_info("SCOREBOARD", $sformatf("Statistics: Total=%0d, Passed=%0d, Failed=%0d, Pass Rate=%.2f%%", 
                 total_transactions, passed_transactions, failed_transactions,
                 (real'(passed_transactions)/real'(total_transactions))*100.0), UVM_MEDIUM)
    endfunction
    
    // Report phase
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_statistics();
        
        if (failed_transactions > 0) begin
            `uvm_error("SCOREBOARD", $sformatf("Test FAILED: %0d out of %0d transactions failed", 
                     failed_transactions, total_transactions))
        end else begin
            `uvm_info("SCOREBOARD", "Test PASSED: All transactions verified successfully", UVM_MEDIUM)
        end
    endfunction

endclass : riscv_dsp_scoreboard
