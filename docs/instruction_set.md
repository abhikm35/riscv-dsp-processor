# RISC-V DSP Processor Instruction Set

## Overview

This document describes the instruction set architecture (ISA) for the custom RISC-V DSP processor, including standard RISC-V instructions and DSP-specific extensions.

## Standard RISC-V Instructions

### Arithmetic Instructions

| Instruction | Format | Description | Example |
|-------------|--------|-------------|---------|
| ADD | R | Add two registers | `add x1, x2, x3` |
| SUB | R | Subtract two registers | `sub x1, x2, x3` |
| ADDI | I | Add immediate to register | `addi x1, x2, 100` |
| SUBI | I | Subtract immediate from register | `subi x1, x2, 100` |

### Logical Instructions

| Instruction | Format | Description | Example |
|-------------|--------|-------------|---------|
| AND | R | Bitwise AND | `and x1, x2, x3` |
| OR | R | Bitwise OR | `or x1, x2, x3` |
| XOR | R | Bitwise XOR | `xor x1, x2, x3` |
| ANDI | I | Bitwise AND with immediate | `andi x1, x2, 0xFF` |
| ORI | I | Bitwise OR with immediate | `ori x1, x2, 0xFF` |
| XORI | I | Bitwise XOR with immediate | `xori x1, x2, 0xFF` |

### Shift Instructions

| Instruction | Format | Description | Example |
|-------------|--------|-------------|---------|
| SLL | R | Shift left logical | `sll x1, x2, x3` |
| SRL | R | Shift right logical | `srl x1, x2, x3` |
| SRA | R | Shift right arithmetic | `sra x1, x2, x3` |
| SLLI | I | Shift left logical immediate | `slli x1, x2, 4` |
| SRLI | I | Shift right logical immediate | `srli x1, x2, 4` |
| SRAI | I | Shift right arithmetic immediate | `srai x1, x2, 4` |

### Comparison Instructions

| Instruction | Format | Description | Example |
|-------------|--------|-------------|---------|
| SLT | R | Set less than (signed) | `slt x1, x2, x3` |
| SLTU | R | Set less than (unsigned) | `sltu x1, x2, x3` |
| SLTI | I | Set less than immediate (signed) | `slti x1, x2, 100` |
| SLTIU | I | Set less than immediate (unsigned) | `sltiu x1, x2, 100` |

### Memory Instructions

| Instruction | Format | Description | Example |
|-------------|--------|-------------|---------|
| LB | I | Load byte (signed) | `lb x1, 100(x2)` |
| LH | I | Load halfword (signed) | `lh x1, 100(x2)` |
| LW | I | Load word | `lw x1, 100(x2)` |
| LBU | I | Load byte (unsigned) | `lbu x1, 100(x2)` |
| LHU | I | Load halfword (unsigned) | `lhu x1, 100(x2)` |
| SB | S | Store byte | `sb x1, 100(x2)` |
| SH | S | Store halfword | `sh x1, 100(x2)` |
| SW | S | Store word | `sw x1, 100(x2)` |

### Branch Instructions

| Instruction | Format | Description | Example |
|-------------|--------|-------------|---------|
| BEQ | B | Branch if equal | `beq x1, x2, label` |
| BNE | B | Branch if not equal | `bne x1, x2, label` |
| BLT | B | Branch if less than (signed) | `blt x1, x2, label` |
| BGE | B | Branch if greater or equal (signed) | `bge x1, x2, label` |
| BLTU | B | Branch if less than (unsigned) | `bltu x1, x2, label` |
| BGEU | B | Branch if greater or equal (unsigned) | `bgeu x1, x2, label` |

### Jump Instructions

| Instruction | Format | Description | Example |
|-------------|--------|-------------|---------|
| JAL | J | Jump and link | `jal x1, label` |
| JALR | I | Jump and link register | `jalr x1, 100(x2)` |

## DSP Extension Instructions

### MAC (Multiply-Accumulate) Instructions

| Instruction | Format | Description | Example |
|-------------|--------|-------------|---------|
| MAC | R | Multiply-accumulate (signed) | `mac x1, x2, x3, x4` |
| MACI | I | Multiply-accumulate with immediate | `maci x1, x2, x3, 100` |
| MACU | R | Multiply-accumulate (unsigned) | `macu x1, x2, x3, x4` |

**MAC Instruction Format:**
```
mac rd, rs1, rs2, rs3
rd = rs1 * rs2 + rs3
```

### SIMD Instructions

| Instruction | Format | Description | Example |
|-------------|--------|-------------|---------|
| ADD4 | R | SIMD add (4x 8-bit) | `add4 x1, x2, x3` |
| SUB4 | R | SIMD subtract (4x 8-bit) | `sub4 x1, x2, x3` |
| MUL4 | R | SIMD multiply (4x 8-bit) | `mul4 x1, x2, x3` |
| AND4 | R | SIMD AND (4x 8-bit) | `and4 x1, x2, x3` |
| OR4 | R | SIMD OR (4x 8-bit) | `or4 x1, x2, x3` |
| XOR4 | R | SIMD XOR (4x 8-bit) | `xor4 x1, x2, x3` |
| SHIFT4 | R | SIMD shift (4x 8-bit) | `shift4 x1, x2, x3` |
| ADD2 | R | SIMD add (2x 16-bit) | `add2 x1, x2, x3` |
| SUB2 | R | SIMD subtract (2x 16-bit) | `sub2 x1, x2, x3` |
| MUL2 | R | SIMD multiply (2x 16-bit) | `mul2 x1, x2, x3` |

### DSP-Specific Instructions

| Instruction | Format | Description | Example |
|-------------|--------|-------------|---------|
| SAT | R | Saturate to 16-bit | `sat x1, x2` |
| CLIP | R | Clip to range | `clip x1, x2, x3` |
| ROUND | R | Round to nearest | `round x1, x2` |
| BIT_REVERSE | R | Bit-reverse for FFT | `bit_reverse x1, x2` |
| CIRCULAR_ADDR | R | Circular addressing | `circular_addr x1, x2, x3` |

## Instruction Encoding

### R-Type Instructions
```
31-25: funct7
24-20: rs2
19-15: rs1
14-12: funct3
11-7:  rd
6-0:   opcode
```

### I-Type Instructions
```
31-20: imm[11:0]
19-15: rs1
14-12: funct3
11-7:  rd
6-0:   opcode
```

### S-Type Instructions
```
31-25: imm[11:5]
24-20: rs2
19-15: rs1
14-12: funct3
11-7:  imm[4:0]
6-0:   opcode
```

### B-Type Instructions
```
31:    imm[12]
30-25: imm[10:5]
24-20: rs2
19-15: rs1
14-12: funct3
11-8:  imm[4:1]
7:     imm[11]
6-0:   opcode
```

### J-Type Instructions
```
31:    imm[20]
30-21: imm[10:1]
20:    imm[11]
19-12: imm[19:12]
11-7:  rd
6-0:   opcode
```

## Register Usage Convention

### General-Purpose Registers
- **x0**: Always zero
- **x1**: Return address (ra)
- **x2**: Stack pointer (sp)
- **x3**: Global pointer (gp)
- **x4**: Thread pointer (tp)
- **x5-x7**: Temporaries (t0-t2)
- **x8**: Frame pointer (fp) / Saved register (s0)
- **x9**: Saved register (s1)
- **x10-x11**: Function arguments / Return values (a0-a1)
- **x12-x17**: Function arguments (a2-a7)
- **x18-x27**: Saved registers (s2-s11)
- **x28-x31**: Temporaries (t3-t6)

### DSP-Specific Register Usage
- **x16-x23**: DSP working registers
- **x24-x27**: DSP coefficient registers
- **x28-x31**: DSP buffer pointer registers

## Addressing Modes

### Standard Addressing
- **Register**: Direct register access
- **Immediate**: Constant values
- **Base+Offset**: Memory addressing

### DSP-Specific Addressing
- **Circular**: Automatic wrap-around for buffers
- **Bit-Reverse**: For FFT operations
- **Stride**: For vector operations

## Exception Handling

### Exception Types
- **Instruction Access Fault**: Invalid instruction address
- **Illegal Instruction**: Unsupported instruction
- **Load Access Fault**: Invalid data address
- **Store Access Fault**: Invalid data address
- **Arithmetic Overflow**: MAC/SIMD overflow
- **Division by Zero**: Unsupported operation

### Exception Handling
- **Exception Vector**: Fixed at address 0x00000000
- **Exception Cause**: Stored in mcause register
- **Exception Address**: Stored in mepc register
- **Exception Return**: mret instruction

## Performance Characteristics

### Instruction Latency
- **Standard RISC-V**: 1 cycle
- **MAC Operations**: 1 cycle
- **SIMD Operations**: 1 cycle
- **Memory Access**: 1 cycle
- **Branch/Jump**: 1 cycle (predicted)

### Throughput
- **Single Issue**: 1 instruction per cycle
- **Pipeline Depth**: 5 stages
- **Hazard Detection**: Automatic
- **Forwarding**: Full forwarding support

## Implementation Notes

### Hardware Requirements
- **MAC Unit**: 32x32 multiplier with 64-bit accumulator
- **SIMD Unit**: 4x 8-bit ALUs or 2x 16-bit ALUs
- **Register File**: 32 registers, dual-port read, single-port write
- **Memory Interface**: 32-bit data width, byte-addressable

### Software Requirements
- **Compiler**: GCC with RISC-V support
- **Assembler**: GNU as with DSP extensions
- **Linker**: GNU ld with custom memory layout
- **Debugger**: GDB with RISC-V support

## Examples

### FIR Filter Implementation
```assembly
# FIR filter loop
fir_loop:
    lw x10, 0(x8)      # Load coefficient
    lw x11, 0(x9)      # Load sample
    mac x12, x10, x11, x12  # Accumulate
    addi x8, x8, 4     # Next coefficient
    addi x9, x9, 4     # Next sample
    addi x13, x13, -1  # Decrement counter
    bne x13, x0, fir_loop
```

### SIMD Processing
```assembly
# SIMD addition
add4 x10, x11, x12     # x10 = x11 + x12 (4x 8-bit)
add2 x13, x14, x15     # x13 = x14 + x15 (2x 16-bit)
```

### Saturation
```assembly
# Saturate result
mac x10, x11, x12, x13 # MAC operation
sat x14, x10           # Saturate to 16-bit
```

This instruction set provides a comprehensive foundation for DSP applications while maintaining compatibility with the RISC-V ecosystem.
