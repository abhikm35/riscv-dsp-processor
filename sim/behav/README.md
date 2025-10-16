# RISC-V DSP Processor Verification Environment

This directory contains the Cadence verification environment for the RISC-V DSP processor, adapted from the DV onboarding project to use industry-standard verification tools and methodologies.

## Overview

The verification environment provides:
- **UVM-style verification** with SystemVerilog classes
- **Constrained random verification** (CRV) capabilities
- **SystemVerilog assertions** (SVA) for design verification
- **Coverage analysis** using Verdi
- **Waveform debugging** with Verisium Debug
- **Automated testing** with Makefile targets

## Directory Structure

```
sim/behav/
├── Makefile                    # Cadence simulation Makefile
├── link_files.py              # Python script for creating symlinks
├── exclusions.el              # Coverage exclusions file
├── Include/
│   └── riscv_dsp_processor.include  # Source file list
└── WORKSPACE/                 # Generated simulation workspace
    └── sym_links/             # Symbolic links to source files
```

## Verification Components

### Testbench Architecture
- **riscv_dsp_tb_top.sv**: Top-level testbench with UVM environment
- **riscv_dsp_pkg.sv**: SystemVerilog package with types and classes
- **riscv_dsp_if.sv**: Interface definition for DUT communication
- **riscv_dsp_driver.sv**: UVM driver for stimulus generation
- **riscv_dsp_monitor.sv**: UVM monitor for response collection
- **riscv_dsp_scoreboard.sv**: UVM scoreboard for functional verification

### Verification Features
- **UVM Environment**: Complete UVM test environment with agent, driver, monitor, and scoreboard
- **Constrained Random Testing**: Random instruction generation with constraints
- **SystemVerilog Assertions**: Design verification assertions for:
  - Reset functionality
  - ALU overflow detection
  - MAC saturation behavior
  - Memory access validation
  - Register write constraints
  - Branch target alignment
  - SIMD operation validation
  - MAC mode validation
  - Instruction fetch validation

### Coverage Analysis
- **Functional Coverage**: Instruction type coverage, operation mode coverage
- **Code Coverage**: Line, toggle, condition, branch, FSM coverage
- **Cross Coverage**: ALU operations × MAC modes, MAC modes × saturation
- **Exclusion File**: `exclusions.el` for impossible-to-hit coverage targets

## Usage

### Prerequisites
1. Sign Cadence EULA for Xcelium, Verisium Debug, and Verdi
2. SSH to `ece-rschsrv.ece.gatech.edu` with X11 forwarding
3. Switch to tcsh shell: `tcsh`
4. Source Cadence tools: `source /tools/software/cadence/setup.csh`
5. Set up Verisium Debug environment variables in `.my-cshrc`:
   ```bash
   setenv VERISIUM_DEBUG_ROOT "/tools/software/cadence/verisumdbg/latest"
   setenv PATH "${PATH}:${VERISIUM_DEBUG_ROOT}/bin:${VERISIUM_DEBUG_ROOT}/tools/bin"
   ```

### Running Simulations

#### Basic Simulation
```bash
cd sim/behav
make xrun                    # Compile and simulate
make simvision              # View waveforms
make run_and_view           # Run simulation and open waveforms
```

#### Component-Specific Testing
```bash
make test-mac               # Test MAC unit only
make test-simd              # Test SIMD unit only
make test-alu               # Test ALU only
make test-processor         # Test full processor
```

#### Coverage Analysis
```bash
make vcs                    # Compile with coverage
make coverage               # Open Verdi coverage analysis
```

#### Debugging
```bash
make verisium               # Run with Verisium Debug GUI
```

### Available Makefile Targets

| Target | Description |
|--------|-------------|
| `help` | Show help message |
| `clean` | Remove WORKSPACE directory |
| `link` | Generate symbolic links |
| `xrun` | Compile & simulate with Xcelium |
| `simvision` | View waveform database |
| `run_and_view` | xrun + simvision |
| `verisium` | Run with Verisium Debug GUI |
| `vcs` | Compile with VCS |
| `verdi` | Open Verdi waveform viewer |
| `coverage` | Open coverage analysis in Verdi |
| `test-mac` | Test MAC unit only |
| `test-simd` | Test SIMD unit only |
| `test-alu` | Test ALU only |
| `test-processor` | Test full processor |

## Verification Methodology

### Test Plan Structure
1. **Functional Testing**: Basic instruction execution
2. **Boundary Testing**: Edge cases and overflow conditions
3. **Data Flow Testing**: Memory read/write operations
4. **Timing Testing**: Reset and clock domain verification
5. **Assertion Testing**: Internal behavior verification
6. **Random Testing**: Constrained random instruction sequences

### Coverage Goals
- **Target Coverage**: 96% overall coverage for DUT
- **Coverage Types**: Line, toggle, condition, branch, FSM, assertion
- **Exclusions**: Use `exclusions.el` for impossible-to-hit targets

### Assertion Categories
- **Reset Assertions**: Verify reset behavior
- **ALU Assertions**: Verify arithmetic operations and flags
- **MAC Assertions**: Verify multiply-accumulate operations
- **Memory Assertions**: Verify memory access protocols
- **Control Assertions**: Verify instruction execution flow
- **SIMD Assertions**: Verify parallel processing operations

## Debugging Tips

### Verisium Debug
1. Use "Hierarchy" tab to navigate design
2. Right-click signals to "Send to Wave"
3. Use play button to run simulation
4. Reset simulation with back button to add new signals

### Coverage Analysis
1. Load exclusions file in Verdi: Exclusion > Load Exclusions from File
2. Focus on DUT coverage, not testbench coverage
3. Use cross-coverage to identify missing test scenarios

### Common Issues
- **Compilation Errors**: Check include file paths and syntax
- **Simulation Hangs**: Verify reset sequence and clock generation
- **Low Coverage**: Add more test cases or check exclusions
- **Assertion Failures**: Review design behavior and assertion logic

## Integration with DV Onboarding

This verification environment follows the same patterns as the DV onboarding project:

### Similarities
- **UVM Architecture**: Driver, monitor, scoreboard pattern
- **Cadence Tools**: Xcelium, Verisium Debug, Verdi
- **Coverage-Driven**: Target 96% coverage
- **Assertion-Based**: SystemVerilog assertions for verification
- **Randomized Testing**: Constrained random verification

### Adaptations for RISC-V DSP
- **Complex DUT**: Full processor vs. simple calculator
- **Multiple Units**: ALU, MAC, SIMD, memory interface
- **Instruction Set**: RISC-V ISA with DSP extensions
- **Pipeline Architecture**: Multi-stage execution pipeline

## Future Enhancements

### Planned Features
- **Floating-Point Verification**: IEEE 754 compliance testing
- **Cache Verification**: Instruction and data cache testing
- **DMA Verification**: Direct memory access testing
- **Interrupt Verification**: Real-time interrupt handling
- **Performance Verification**: Timing and throughput analysis

### Optimization Opportunities
- **Test Generation**: Automated test case generation
- **Coverage Closure**: Advanced coverage analysis techniques
- **Regression Testing**: Automated regression test suites
- **Formal Verification**: Property-based verification methods

## Resources

### SystemVerilog and UVM
- [ChipVerify SystemVerilog](https://www.chipverify.com/systemverilog/)
- [Doulos UVM Tutorial](https://www.doulos.com/knowhow/systemverilog/systemverilog-tutorials/)

### Verification Methodology
- [SystemVerilog Assertions](https://www.systemverilog.io/verification/sva-basics/)
- [Constrained Random Verification](https://www.chipverify.com/verification/constraint-random-verification)
- [Code Coverage](https://www.chipverify.com/verification/code-coverage)

### Cadence Tools
- [Xcelium User Guide](https://www.cadence.com/content/dam/cadence-www/global/en_US/documents/tools/digital-design-and-signoff/xcelium-simulator-datasheet.pdf)
- [Verisium Debug Documentation](https://www.cadence.com/content/dam/cadence-www/global/en_US/documents/tools/digital-design-and-signoff/verisium-debug-datasheet.pdf)
- [Verdi Coverage Documentation](https://www.cadence.com/content/dam/cadence-www/global/en_US/documents/tools/digital-design-and-signoff/verdi-coverage-datasheet.pdf)

---

**Note**: This verification environment is designed for educational and research purposes. For production use, additional verification and optimization may be required.
