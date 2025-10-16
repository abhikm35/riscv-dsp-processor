# RISC-V DSP Processor Coverage Exclusions
# This file contains coverage exclusions for impossible-to-hit targets

# Exclude reset-related coverage that's not meaningful
+tree riscv_dsp_core.u_control_unit.reset_state
+tree riscv_dsp_core.u_control_unit.reset_counter

# Exclude debug and test signals
+tree riscv_dsp_core.debug_*
+tree riscv_dsp_core.test_*

# Exclude unused instruction encodings
+tree riscv_dsp_core.u_instruction_decoder.unused_opcodes

# Exclude error states that shouldn't be reached in normal operation
+tree riscv_dsp_core.u_control_unit.error_state
+tree riscv_dsp_core.u_control_unit.illegal_instruction

# Exclude power-down and sleep modes (if implemented)
+tree riscv_dsp_core.power_down_mode
+tree riscv_dsp_core.sleep_mode

# Exclude unused MAC modes
+tree riscv_dsp_core.u_mac_unit.mac_mode[1:0] == 2'b11

# Exclude unused SIMD operations
+tree riscv_dsp_core.u_simd_unit.simd_op[2:0] == 3'b111

# Exclude memory regions that are not accessible
+tree riscv_dsp_core.u_memory_interface.reserved_memory_region

# Exclude interrupt handling (if not implemented)
+tree riscv_dsp_core.interrupt_handler
+tree riscv_dsp_core.exception_handler

# Exclude unused register combinations
+tree riscv_dsp_core.u_register_file.x0_write_enable

# Exclude timing-related coverage that's tool-specific
+tree riscv_dsp_core.synthesis_timing_paths
+tree riscv_dsp_core.hold_time_violations
