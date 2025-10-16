# RISC-V DSP Processor UVM Testbench Documentation

## 📋 Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Component Details](#component-details)
4. [Data Flow](#data-flow)
5. [Transaction Flow](#transaction-flow)
6. [Assertions](#assertions)
7. [Coverage](#coverage)
8. [Usage](#usage)

---

## 🎯 Overview

This document provides a comprehensive explanation of the UVM (Universal Verification Methodology) testbench for the RISC-V DSP Processor. The testbench implements a complete verification environment with driver, monitor, scoreboard, and assertion-based verification.

### Key Features
- **UVM-based verification environment**
- **Comprehensive stimulus generation**
- **Real-time monitoring and checking**
- **SystemVerilog Assertions (SVA)**
- **Functional and code coverage**
- **Pipeline-aware verification**

---

## 🏗️ Architecture

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           UVM TESTBENCH ENVIRONMENT                              │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐             │
│  │   UVM TEST      │    │   UVM ENV       │    │   UVM AGENT     │             │
│  │ riscv_dsp_test  │───▶│ riscv_dsp_env   │───▶│ riscv_dsp_agent │             │
│  │                 │    │                 │    │                 │             │
│  │ • run_phase()   │    │ • build_phase() │    │ • build_phase() │             │
│  │ • Creates env   │    │ • Creates agent │    │ • Creates driver │             │
│  │                 │    │ • Creates sb    │    │ • Creates mon    │             │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘             │
│           │                       │                       │                     │
│           │                       │                       ▼                     │
│           │                       │              ┌─────────────────┐           │
│           │                       │              │   UVM DRIVER    │           │
│           │                       │              │ riscv_dsp_driver│           │
│           │                       │              │                 │           │
│           │                       │              │ • run_phase()   │           │
│           │                       │              │ • drive_item()  │           │
│           │                       │              │ • reset_dut()   │           │
│           │                       │              └─────────────────┘           │
│           │                       │                       │                     │
│           │                       │                       ▼                     │
│           │                       │              ┌─────────────────┐           │
│           │                       │              │   UVM MONITOR   │           │
│           │                       │              │riscv_dsp_monitor│           │
│           │                       │              │                 │           │
│           │                       │              │ • run_phase()   │           │
│           │                       │              │ • collect_data()│           │
│           │                       │              │ • send_to_sb()  │           │
│           │                       │              └─────────────────┘           │
│           │                       │                       │                     │
│           │                       │                       ▼                     │
│           │                       │              ┌─────────────────┐           │
│           │                       │              │  UVM SEQUENCER  │           │
│           │                       │              │riscv_dsp_seq     │           │
│           │                       │              │                 │           │
│           │                       │              │ • body()        │           │
│           │                       │              │ • create_items()│           │
│           │                       │              │ • send_items()  │           │
│           │                       │              └─────────────────┘           │
│           │                       │                       │                     │
│           │                       ▼                       │                     │
│           │              ┌─────────────────┐             │                     │
│           │              │ UVM SCOREBOARD   │◀────────────┘                     │
│           │              │riscv_dsp_scoreboard│                                  │
│           │              │                 │                                    │
│           │              │ • check_item()   │                                    │
│           │              │ • verify_alu()   │                                    │
│           │              │ • verify_mac()   │                                    │
│           │              │ • verify_simd()  │                                    │
│           │              │ • statistics     │                                    │
│           │              └─────────────────┘                                    │
│           │                                                                     │
│           └─────────────────────────────────────────────────────────────────────┘
│                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│                           INTERFACE LAYER                                       │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                        riscv_dsp_if INTERFACE                              │ │
│  │                                                                             │ │
│  │  ┌─────────────────┐              ┌─────────────────┐                      │ │
│  │  │   DRIVER CB     │              │  MONITOR CB     │                      │ │
│  │  │   (cb)          │              │  (monitor_cb)    │                      │ │
│  │  │                 │              │                 │                      │ │
│  │  │ • @(posedge clk)│              │ • @(posedge clk)│                      │ │
│  │  │ • Drives DUT    │              │ • Samples DUT   │                      │ │
│  │  │ • Input signals │              │ • Output signals│                      │ │
│  │  └─────────────────┘              └─────────────────┘                      │ │
│  │                                                                             │ │
│  │  Signals:                                                                   │ │
│  │  • Control: rst_n, processor_ready                                        │ │
│  │  • PC: pc, pc_plus_4                                                       │ │
│  │  • Instruction: instruction, rs1, rs2, rd                                 │ │
│  │  • Register: rs1_data, rs2_data, reg_write_data                           │ │
│  │  • ALU: alu_result, alu_op, alu_zero, alu_overflow                       │ │
│  │  • MAC: mac_result, mac_mode, mac_enable                                   │ │
│  │  • SIMD: simd_result, simd_op, simd_width                                  │ │
│  │  • Memory: mem_addr, mem_data_in, mem_data_out                            │ │
│  │  • Branch: branch, jump, branch_target, branch_taken                      │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│                           DEVICE UNDER TEST (DUT)                              │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                        riscv_dsp_core                                       │ │
│  │                                                                             │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │ │
│  │  │    IF       │  │    ID       │  │    EX       │  │    MEM      │        │ │
│  │  │   STAGE     │  │   STAGE     │  │   STAGE     │  │   STAGE     │        │ │
│  │  │             │  │             │  │             │  │             │        │ │
│  │  │ • PC        │  │ • Decode    │  │ • ALU       │  │ • Memory    │        │ │
│  │  │ • Fetch     │  │ • Register  │  │ • MAC       │  │ • Branch    │        │ │
│  │  │ • Memory    │  │ • Control   │  │ • SIMD      │  │ • Forward   │        │ │
│  │  │             │  │             │  │             │  │             │        │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │ │
│  │       │                │                │                │                │ │
│  │       ▼                ▼                ▼                ▼                │ │
│  │  ┌─────────────────────────────────────────────────────────────────────────┐ │ │
│  │  │                            WB STAGE                                     │ │ │
│  │  │                                                                         │ │ │
│  │  │ • Register Write                                                        │ │ │
│  │  │ • Result Selection                                                      │ │ │
│  │  │ • Pipeline Completion                                                   │ │ │
│  │  └─────────────────────────────────────────────────────────────────────────┘ │ │
│  │                                                                             │ │
│  │  Sub-modules:                                                               │ │
│  │  • instruction_decoder.v                                                    │ │
│  │  • control_unit.v                                                           │ │
│  │  • register_file.v                                                          │ │
│  │  • alu.v                                                                    │ │
│  │  • mac_unit.v                                                               │ │
│  │  • simd_unit.v                                                              │ │
│  │  • memory_interface.v                                                       │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Component Details

### 1. UVM Test (`riscv_dsp_test`)

**Purpose**: Top-level test that orchestrates the entire verification process.

```systemverilog
class riscv_dsp_test extends uvm_test;
    // Creates and configures the verification environment
    virtual function void build_phase(uvm_phase phase);
        env = riscv_dsp_env::type_id::create("env", this);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        #1000; // Run for 1000 time units
        phase.drop_objection(this);
    endtask
endclass
```

**Responsibilities**:
- Creates the UVM environment
- Controls test duration
- Manages UVM phases

### 2. UVM Environment (`riscv_dsp_env`)

**Purpose**: Container for all verification components.

```systemverilog
class riscv_dsp_env extends uvm_env;
    riscv_dsp_agent agent;
    riscv_dsp_scoreboard sb;
    
    virtual function void build_phase(uvm_phase phase);
        agent = riscv_dsp_agent::type_id::create("agent", this);
        sb = riscv_dsp_scoreboard::type_id::create("sb", this);
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        agent.monitor.ap.connect(sb.ap);
    endfunction
endclass
```

**Responsibilities**:
- Instantiates agent and scoreboard
- Connects analysis ports
- Manages component hierarchy

### 3. UVM Agent (`riscv_dsp_agent`)

**Purpose**: Contains driver, monitor, and sequencer.

```systemverilog
class riscv_dsp_agent extends uvm_agent;
    riscv_dsp_driver driver;
    riscv_dsp_monitor monitor;
    uvm_sequencer #(riscv_dsp_seq_item) sequencer;
    
    virtual function void build_phase(uvm_phase phase);
        driver = riscv_dsp_driver::type_id::create("driver", this);
        monitor = riscv_dsp_monitor::type_id::create("monitor", this);
        sequencer = uvm_sequencer #(riscv_dsp_seq_item)::type_id::create("sequencer", this);
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
endclass
```

**Responsibilities**:
- Creates driver, monitor, sequencer
- Connects driver to sequencer
- Provides interface to environment

### 4. UVM Driver (`riscv_dsp_driver`)

**Purpose**: Drives stimulus to the DUT through the interface.

```systemverilog
class riscv_dsp_driver extends uvm_driver #(riscv_dsp_seq_item);
    virtual riscv_dsp_if vif;
    
    virtual task run_phase(uvm_phase phase);
        // Apply reset
        reset_dut();
        
        // Drive test items
        forever begin
            seq_item_port.get_next_item(req);
            drive_item(req);
            seq_item_port.item_done();
        end
    endtask
    
    virtual task reset_dut();
        vif.cb.rst_n <= 1'b0;
        repeat(10) @(posedge vif.clk);
        vif.cb.rst_n <= 1'b1;
        repeat(5) @(posedge vif.clk);
    endtask
    
    virtual task drive_item(riscv_dsp_seq_item item);
        // Drive stimulus based on item type
        case (item.opcode)
            OP_R_TYPE: drive_alu_instruction(item);
            OP_MAC:    drive_mac_instruction(item);
            OP_SIMD:   drive_simd_instruction(item);
        endcase
    endtask
endclass
```

**Responsibilities**:
- Applies reset to DUT
- Drives stimulus based on sequence items
- Manages timing and synchronization

### 5. UVM Monitor (`riscv_dsp_monitor`)

**Purpose**: Observes DUT behavior and creates transactions.

```systemverilog
class riscv_dsp_monitor extends uvm_monitor;
    virtual riscv_dsp_if vif;
    uvm_analysis_port #(riscv_dsp_seq_item) ap;
    
    virtual task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.clk);
            if (vif.monitor_cb.processor_ready) begin
                collect_data();
            end
        end
    endtask
    
    virtual task collect_data();
        riscv_dsp_seq_item item = riscv_dsp_seq_item::type_id::create("item");
        
        // Sample DUT outputs
        item.pc = vif.monitor_cb.pc;
        item.instruction = vif.monitor_cb.instruction;
        item.alu_result = vif.monitor_cb.alu_result;
        item.mac_result = vif.monitor_cb.mac_result;
        item.simd_result = vif.monitor_cb.simd_result;
        
        // Send to scoreboard
        ap.write(item);
    endtask
endclass
```

**Responsibilities**:
- Samples DUT outputs on every clock cycle
- Creates transaction items
- Sends data to scoreboard via analysis port

### 6. UVM Scoreboard (`riscv_dsp_scoreboard`)

**Purpose**: Verifies DUT functionality against expected behavior.

```systemverilog
class riscv_dsp_scoreboard extends uvm_scoreboard;
    uvm_analysis_imp #(riscv_dsp_seq_item, riscv_dsp_scoreboard) ap;
    
    int total_transactions = 0;
    int passed_transactions = 0;
    int failed_transactions = 0;
    
    virtual function void write(riscv_dsp_seq_item item);
        total_transactions++;
        
        case (item.opcode)
            OP_R_TYPE: verify_alu(item);
            OP_MAC:    verify_mac(item);
            OP_SIMD:   verify_simd(item);
            default:   `uvm_warning("SCOREBOARD", "Unknown opcode")
        endcase
    endfunction
    
    virtual function void verify_alu(riscv_dsp_seq_item item);
        logic [31:0] expected_result;
        
        case (item.alu_op)
            ALU_ADD: expected_result = item.rs1_data + item.rs2_data;
            ALU_SUB: expected_result = item.rs1_data - item.rs2_data;
            // ... other ALU operations
        endcase
        
        if (item.result == expected_result) begin
            passed_transactions++;
            `uvm_info("SCOREBOARD", "ALU transaction PASSED", UVM_MEDIUM)
        end else begin
            failed_transactions++;
            `uvm_error("SCOREBOARD", $sformatf("ALU transaction FAILED: Expected %0h, Got %0h", 
                     expected_result, item.result))
        end
    endfunction
endclass
```

**Responsibilities**:
- Receives transactions from monitor
- Implements reference model
- Compares actual vs expected results
- Maintains statistics

### 7. Transaction Item (`riscv_dsp_seq_item`)

**Purpose**: Data structure containing all relevant information for verification.

```systemverilog
class riscv_dsp_seq_item extends uvm_sequence_item;
    // Instruction fields
    rand logic [31:0] instruction;
    rand logic [4:0]  rs1, rs2, rd;
    rand logic [31:0] imm;
    
    // Operation types
    rand opcode_t opcode;
    rand alu_op_t alu_op;
    rand mac_mode_t mac_mode;
    rand simd_op_t simd_op;
    
    // Data
    rand logic [31:0] rs1_data, rs2_data;
    rand logic [31:0] result;
    
    // Flags
    rand logic overflow, underflow, zero, negative, carry;
    
    // UVM field macros for automatic methods
    `uvm_object_utils_begin(riscv_dsp_seq_item)
        `uvm_field_int(instruction, UVM_ALL_ON)
        `uvm_field_int(rs1, UVM_ALL_ON)
        `uvm_field_int(rs2, UVM_ALL_ON)
        `uvm_field_int(rd, UVM_ALL_ON)
        `uvm_field_int(result, UVM_ALL_ON)
    `uvm_object_utils_end
endclass
```

**Responsibilities**:
- Encapsulates all verification data
- Provides randomization capabilities
- Enables automatic methods via UVM macros

---

## 🔄 Data Flow

### Phase 1: UVM Initialization

```
1. UVM Test starts
   ↓
2. riscv_dsp_test.run_phase() creates riscv_dsp_env
   ↓
3. riscv_dsp_env.build_phase() creates:
   - riscv_dsp_agent
   - riscv_dsp_scoreboard
   ↓
4. riscv_dsp_agent.build_phase() creates:
   - riscv_dsp_driver
   - riscv_dsp_monitor
   - riscv_dsp_sequencer
   ↓
5. riscv_dsp_env.connect_phase() connects:
   - monitor.ap → scoreboard.ap
   - driver.seq_item_port → sequencer.seq_item_export
```

### Phase 2: Test Execution

```
6. riscv_dsp_seq.body() creates test items:
   - add_item (ALU ADD test)
   - sub_item (ALU SUB test)
   - mac_item (MAC test)
   - simd_item (SIMD test)
   ↓
7. Driver receives items and drives DUT:
   - Applies reset
   - Drives stimulus through interface
   - Waits for completion
   ↓
8. Monitor samples DUT outputs:
   - Collects PC, instruction, results
   - Creates transaction items
   - Sends to scoreboard
   ↓
9. Scoreboard verifies results:
   - Checks ALU operations
   - Verifies MAC calculations
   - Validates SIMD results
   - Reports pass/fail
```

---

## 📊 Transaction Flow Diagram

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   SEQUENCE  │───▶│   DRIVER    │───▶│     DUT     │───▶│   MONITOR   │
│             │    │             │    │             │    │             │
│ Creates     │    │ Drives      │    │ Processes   │    │ Samples     │
│ test items  │    │ stimulus    │    │ instructions│    │ outputs     │
│             │    │             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │                   │
       │                   │                   │                   ▼
       │                   │                   │            ┌─────────────┐
       │                   │                   │            │ SCOREBOARD  │
       │                   │                   │            │             │
       │                   │                   │            │ Verifies    │
       │                   │                   │            │ results     │
       │                   │                   │            │             │
       └───────────────────┼───────────────────┼────────────▶└─────────────┘
                           │                   │
                           ▼                   ▼
                   ┌─────────────┐    ┌─────────────┐
                   │ INTERFACE   │    │ INTERFACE   │
                   │ (Driver CB) │    │(Monitor CB) │
                   │             │    │             │
                   │ Inputs to   │    │ Outputs from│
                   │ DUT         │    │ DUT         │
                   └─────────────┘    └─────────────┘
```

### Detailed Transaction Flow

1. **Sequence Creation**:
   ```
   riscv_dsp_seq.body() → Creates riscv_dsp_seq_item
   ```

2. **Driver Processing**:
   ```
   Driver gets item → Drives stimulus → Waits for completion
   ```

3. **DUT Processing**:
   ```
   IF Stage → ID Stage → EX Stage → MEM Stage → WB Stage
   ```

4. **Monitor Collection**:
   ```
   Monitor samples → Creates transaction → Sends to scoreboard
   ```

5. **Scoreboard Verification**:
   ```
   Scoreboard receives → Implements reference model → Compares results
   ```

---

## 🔍 Assertions

The testbench includes comprehensive SystemVerilog Assertions (SVA) for verification:

### 1. Instruction Fetch Assertion

```systemverilog
property instruction_fetch_property;
    @(posedge clk)
    disable iff (!rst_n)
    (riscv_if.processor_ready && riscv_if.pc >= 32'h1000) |-> 
    (riscv_if.instruction[1:0] == 2'b11);
endproperty

assert_instruction_fetch: assert property (instruction_fetch_property)
    else `uvm_error("ASSERT", "Instruction fetch assertion failed")
```

**Purpose**: Ensures all fetched instructions have valid RISC-V encoding (bottom 2 bits = 11).

### 2. Register Write Assertion

```systemverilog
property register_write_property;
    @(posedge clk)
    disable iff (!rst_n)
    riscv_if.reg_write |-> (riscv_if.rd != 5'b0);
endproperty

assert_register_write: assert property (register_write_property)
    else `uvm_error("ASSERT", "Register write assertion failed")
```

**Purpose**: Ensures register writes never target register x0 (which is hardwired to zero).

### 3. MAC Mode Assertion

```systemverilog
property mac_mode_property;
    @(posedge clk)
    disable iff (!rst_n)
    riscv_if.mac_enable |-> (riscv_if.mac_mode inside {MAC_SIGNED, MAC_UNSIGNED, MAC_MIXED});
endproperty

assert_mac_mode: assert property (mac_mode_property)
    else `uvm_error("ASSERT", "MAC mode assertion failed")
```

**Purpose**: Ensures MAC operations use valid mode settings.

### 4. Pipeline Consistency Assertion

```systemverilog
property pipeline_consistency_property;
    @(posedge clk)
    disable iff (!rst_n)
    riscv_if.processor_ready |-> (riscv_if.pc_plus_4 == riscv_if.pc + 4);
endproperty

assert_pipeline_consistency: assert property (pipeline_consistency_property)
    else `uvm_error("ASSERT", "Pipeline consistency assertion failed")
```

**Purpose**: Ensures PC+4 calculation is correct.

---

## 📈 Coverage

The testbench implements comprehensive coverage collection:

### 1. Functional Coverage

```systemverilog
covergroup riscv_dsp_cg @(posedge clk);
    // ALU operation coverage
    alu_op_cp: coverpoint riscv_if.alu_op {
        bins add = {riscv_dsp_pkg::ALU_ADD};
        bins sub = {riscv_dsp_pkg::ALU_SUB};
        bins and_op = {riscv_dsp_pkg::ALU_AND};
        bins or_op = {riscv_dsp_pkg::ALU_OR};
        bins xor_op = {riscv_dsp_pkg::ALU_XOR};
    }
    
    // MAC mode coverage
    mac_mode_cp: coverpoint riscv_if.mac_mode {
        bins signed_mode = {riscv_dsp_pkg::MAC_SIGNED};
        bins unsigned_mode = {riscv_dsp_pkg::MAC_UNSIGNED};
        bins mixed_mode = {riscv_dsp_pkg::MAC_MIXED};
    }
    
    // SIMD operation coverage
    simd_op_cp: coverpoint riscv_if.simd_op {
        bins add4 = {riscv_dsp_pkg::SIMD_ADD4};
        bins sub4 = {riscv_dsp_pkg::SIMD_SUB4};
    }
    
    // Cross coverage
    alu_mac_cross: cross alu_op_cp, mac_mode_cp;
endgroup
```

### 2. Code Coverage

The testbench enables:
- **Line Coverage**: Ensures all lines of code are executed
- **Branch Coverage**: Ensures all conditional branches are taken
- **Expression Coverage**: Ensures all expressions are evaluated
- **FSM Coverage**: Ensures all state machine states are visited

### 3. Assertion Coverage

Tracks which assertions are triggered and their pass/fail rates.

---

## 🎮 Usage

### Running the Testbench

1. **Environment Setup**:
   ```bash
   # Switch to tcsh shell
   tcsh
   
   # Source Cadence tools
   source /tools/software/cadence/setup.csh
   
   # Navigate to testbench directory
   cd /nethome/amojumdar6/riscv-dsp-processor/sim/behav
   ```

2. **Run Simulation**:
   ```bash
   make xrun
   ```

3. **View Results**:
   ```bash
   # View waveforms
   make simvision
   
   # View coverage
   make coverage
   
   # Interactive debugging
   make verisium
   ```

### Test Configuration

The testbench can be configured through:

1. **UVM Configuration Database**:
   ```systemverilog
   uvm_config_db#(virtual riscv_dsp_if)::set(this, "*", "vif", riscv_if);
   ```

2. **Command Line Arguments**:
   ```bash
   xrun +testname=my_test +uvm_testname=riscv_dsp_test
   ```

3. **Environment Variables**:
   ```bash
   export UVM_TESTNAME=riscv_dsp_test
   ```

### Adding New Tests

1. **Create New Sequence**:
   ```systemverilog
   class my_test_seq extends riscv_dsp_seq;
       virtual task body();
           // Create custom test items
           riscv_dsp_seq_item item;
           item = riscv_dsp_seq_item::type_id::create("item");
           item.randomize();
           start_item(item);
           finish_item(item);
       endtask
   endclass
   ```

2. **Create New Test**:
   ```systemverilog
   class my_test extends riscv_dsp_test;
       virtual task run_phase(uvm_phase phase);
           my_test_seq seq = my_test_seq::type_id::create("seq");
           seq.start(env.agent.sequencer);
       endtask
   endclass
   ```

---

## 📋 Summary

This UVM testbench provides:

✅ **Complete verification environment** with driver, monitor, scoreboard
✅ **Comprehensive stimulus generation** for ALU, MAC, and SIMD operations  
✅ **Real-time monitoring** of DUT behavior
✅ **Automated checking** against reference model
✅ **SystemVerilog Assertions** for property verification
✅ **Functional and code coverage** collection
✅ **Pipeline-aware verification** for RISC-V DSP processor

The testbench follows UVM best practices and provides a robust foundation for verifying the RISC-V DSP processor functionality.

---

## 🔗 Related Files

- `riscv_dsp_tb_top.sv` - Top-level testbench module
- `riscv_dsp_pkg.sv` - UVM package with classes and types
- `riscv_dsp_if.sv` - SystemVerilog interface
- `riscv_dsp_driver.sv` - UVM driver
- `riscv_dsp_monitor.sv` - UVM monitor  
- `riscv_dsp_scoreboard.sv` - UVM scoreboard
- `riscv_dsp_core.v` - Device Under Test (DUT)
