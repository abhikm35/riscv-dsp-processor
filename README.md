# Custom RISC-V DSP Processor

A custom RISC-V based Digital Signal Processing (DSP) processor optimized for real-time signal processing applications.

## Overview

This project implements a complete DSP-optimized CPU core with:
- 32-bit RISC-V ISA base with DSP extensions
- Hardware MAC (Multiply-Accumulate) unit
- SIMD instructions for parallel processing
- Optimized memory hierarchy for DSP workloads
- Support for fixed-point arithmetic

## Key Features

### Hardware Components
- **MAC Unit**: Single-cycle multiply-accumulate operations with saturation and rounding
- **SIMD Unit**: Parallel operations on 4x 8-bit or 2x 16-bit data elements
- **ALU**: Extended arithmetic and logic operations with DSP-specific functions
- **Register File**: 32 general-purpose registers with dual-port read
- **Memory Interface**: Optimized for DSP data access patterns
- **Control Unit**: Pipeline control with hazard detection and forwarding

### DSP Optimizations
- Single-cycle MAC operations
- Parallel SIMD processing
- Saturation arithmetic
- Circular addressing modes
- Bit-reverse addressing for FFT
- Hardware-accelerated DSP functions

### Instruction Set Extensions
- **MAC instructions**: `MAC`, `MACI`, `MACU`
- **SIMD instructions**: `ADD4`, `SUB4`, `MUL4`
- **DSP-specific**: `SAT`, `CLIP`, `ROUND`

## Project Structure

```
├── src/                    # Verilog source files
│   ├── riscv_dsp_core.v   # Main processor core
│   ├── alu.v              # Arithmetic Logic Unit
│   ├── mac_unit.v         # MAC unit
│   ├── simd_unit.v        # SIMD unit
│   ├── register_file.v    # Register file
│   ├── instruction_decoder.v # Instruction decoder
│   ├── control_unit.v     # Control unit
│   └── memory_interface.v # Memory interface
├── software/              # C software implementation
│   ├── main.c            # Main application
│   ├── fir_filter.c      # FIR filter implementation
│   ├── fft.c             # FFT implementation
│   └── dsp_math.h        # DSP math library
├── testbench/            # Testbenches
│   ├── mac_unit_tb.v     # MAC unit testbench
│   ├── simd_unit_tb.v    # SIMD unit testbench
│   ├── alu_tb.v          # ALU testbench
│   └── processor_tb.v    # Processor testbench
├── scripts/              # Synthesis scripts
│   └── synthesize.tcl    # Vivado synthesis script
├── constraints/          # Timing constraints
│   └── riscv_dsp_constraints.xdc
└── docs/                 # Documentation
    └── architecture.md   # Architecture documentation
```

## Getting Started

### Prerequisites
- Xilinx Vivado 2020.1 or later
- ModelSim/QuestaSim for simulation
- GCC for C compilation

### Simulation

1. **Run individual component testbenches:**
```bash
# MAC unit testbench
cd testbench
vsim -c -do "run -all" mac_unit_tb

# SIMD unit testbench
vsim -c -do "run -all" simd_unit_tb

# ALU testbench
vsim -c -do "run -all" alu_tb

# Processor testbench
vsim -c -do "run -all" processor_tb
```

2. **Run all testbenches:**
```bash
make test
```

### Synthesis

1. **Run synthesis:**
```bash
cd scripts
vivado -mode batch -source synthesize.tcl
```

2. **View results:**
```bash
# Open Vivado GUI
vivado synth/riscv_dsp_processor.xpr
```

### Software Development

1. **Compile C code:**
```bash
cd software
gcc -o dsp_app main.c fir_filter.c fft.c -lm
```

2. **Run application:**
```bash
./dsp_app
```

## Architecture Details

### Pipeline Stages
1. **IF**: Instruction Fetch
2. **ID**: Instruction Decode & Register Read
3. **EX**: Execute (ALU/MAC/SIMD)
4. **MEM**: Memory Access
5. **WB**: Write Back

### Memory Organization
- **Instruction Memory**: 16KB ROM
- **Data Memory**: 8KB RAM
- **Register File**: 32 x 32-bit registers

### DSP Features
- **Hardware MAC**: Single-cycle multiply-accumulate
- **SIMD Processing**: 4x parallel 8-bit operations
- **Saturation**: Automatic overflow handling
- **Circular Addressing**: For buffer management
- **Bit-Reverse**: For FFT operations

## Performance Characteristics

### Timing
- **Clock Frequency**: 100 MHz (target)
- **MAC Latency**: 1 cycle
- **SIMD Latency**: 1 cycle
- **Memory Access**: 1 cycle

### Resource Usage (Xilinx 7-series)
- **LUTs**: ~2,000
- **FFs**: ~1,500
- **BRAMs**: 4
- **DSPs**: 8

## Applications

### Implemented Algorithms
- **FIR Filters**: Low-pass, high-pass, band-pass
- **FFT/IFFT**: Radix-2 implementation
- **Convolution**: Hardware-accelerated
- **Correlation**: Cross-correlation
- **Digital Modulation**: BPSK, QPSK

### Target Applications
- Audio processing
- Image processing
- Communications systems
- Control systems
- Sensor data processing

## Verification

### Test Coverage
- **Unit Tests**: Individual component verification
- **Integration Tests**: Full processor verification
- **Algorithm Tests**: DSP function verification
- **Performance Tests**: Timing and resource verification

### Test Results
- All unit tests pass
- Integration tests pass
- DSP algorithms verified
- Timing constraints met

## Future Enhancements

### Planned Features
- **Floating-Point Unit**: IEEE 754 support
- **Cache Memory**: Instruction and data caches
- **DMA Controller**: Direct memory access
- **Interrupt Controller**: Real-time processing
- **Debug Interface**: JTAG support

### Optimization Opportunities
- **Pipeline Optimization**: Reduce stalls
- **Memory Bandwidth**: Increase throughput
- **Power Optimization**: Reduce consumption
- **Area Optimization**: Reduce resource usage

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes
4. Add tests
5. Submit pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- RISC-V Foundation for the ISA specification
- Xilinx for FPGA tools and documentation
- Open source DSP algorithm implementations

## Contact

For questions or contributions, please contact the project maintainers.

---

**Note**: This is a research and educational project. For production use, additional verification and optimization may be required.
