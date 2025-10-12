# Custom RISC-V DSP Processor Architecture

## Overview
This project implements a custom RISC-V based DSP processor optimized for digital signal processing tasks.

## Key Features
- 32-bit RISC-V ISA base with DSP extensions
- Hardware MAC (Multiply-Accumulate) unit
- SIMD instructions for parallel processing
- Optimized memory hierarchy for DSP workloads
- Support for fixed-point arithmetic

## Processor Architecture

### Core Components
1. **Fetch Unit**: Instruction fetch and decode
2. **Execution Unit**: ALU, MAC, SIMD operations
3. **Register File**: 32 general-purpose registers
4. **Memory Interface**: Instruction and data memory
5. **Control Unit**: Pipeline control and hazard detection

### Instruction Set Extensions
- MAC instructions: `MAC`, `MACI`, `MACU`
- SIMD instructions: `ADD4`, `SUB4`, `MUL4`
- DSP-specific: `SAT`, `CLIP`, `ROUND`

### Memory Organization
- Instruction Memory: 16KB ROM
- Data Memory: 8KB RAM
- Register File: 32 x 32-bit registers

### Pipeline Stages
1. **IF**: Instruction Fetch
2. **ID**: Instruction Decode & Register Read
3. **EX**: Execute (ALU/MAC/SIMD)
4. **MEM**: Memory Access
5. **WB**: Write Back

## DSP Optimizations
- Single-cycle MAC operations
- Parallel SIMD processing
- Saturation arithmetic
- Circular addressing modes
- Bit-reverse addressing for FFT

## Target Applications
- FIR/IIR filters
- FFT/IFFT operations
- Convolution
- Correlation
- Digital modulation/demodulation
