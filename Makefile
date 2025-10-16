#=============================================================================
# Makefile for RISC-V DSP Processor
#=============================================================================

# Variables
PROJECT_NAME = riscv_dsp_processor
VIVADO = vivado
VSIM = vsim
GCC = gcc

# Directories
SRC_DIR = src
TESTBENCH_DIR = testbench
SOFTWARE_DIR = software
SYNTH_DIR = synth
REPORTS_DIR = reports

# Source files
VERILOG_SOURCES = $(wildcard $(SRC_DIR)/*.v)
TESTBENCH_SOURCES = $(wildcard $(TESTBENCH_DIR)/*_tb.v)
SOFTWARE_SOURCES = $(wildcard $(SOFTWARE_DIR)/*.c)

# Default target
all: test synth software

# Test targets
test: test-uvm

test-uvm:
	@echo "Running UVM testbench..."
	@echo "Note: Use 'make xrun' in sim/behav directory for Cadence Xcelium simulation"
	@echo "Or use 'make test' in sim/behav directory for UVM testbench"

# Synthesis target
synth:
	@echo "Running synthesis..."
	$(VIVADO) -mode batch -source scripts/synthesize.tcl
	@echo "Synthesis completed. Check $(SYNTH_DIR)/ for results."

# Software compilation
software: dsp_app

dsp_app: $(SOFTWARE_SOURCES)
	@echo "Compiling DSP application..."
	$(GCC) -o $(SOFTWARE_DIR)/dsp_app $(SOFTWARE_SOURCES) -lm
	@echo "DSP application compiled successfully."

# Clean targets
clean:
	@echo "Cleaning up..."
	rm -rf $(SYNTH_DIR)
	rm -rf $(REPORTS_DIR)
	rm -f $(SOFTWARE_DIR)/dsp_app
	rm -f *.vcd
	rm -f *.wlf
	rm -f transcript
	@echo "Cleanup completed."

clean-synth:
	@echo "Cleaning synthesis files..."
	rm -rf $(SYNTH_DIR)
	@echo "Synthesis cleanup completed."

clean-software:
	@echo "Cleaning software files..."
	rm -f $(SOFTWARE_DIR)/dsp_app
	@echo "Software cleanup completed."

# Help target
help:
	@echo "Available targets:"
	@echo "  all          - Run all tests, synthesis, and compile software"
	@echo "  test         - Run all testbenches"
	@echo "  test-uvm     - Run UVM testbench (redirects to sim/behav)"
	@echo "  synth        - Run synthesis"
	@echo "  software     - Compile DSP application"
	@echo "  dsp_app      - Compile DSP application"
	@echo "  clean        - Clean all generated files"
	@echo "  clean-synth  - Clean synthesis files only"
	@echo "  clean-software - Clean software files only"
	@echo "  help         - Show this help message"

# Phony targets
.PHONY: all test test-uvm synth software dsp_app clean clean-synth clean-software help

# Dependencies
$(SOFTWARE_DIR)/dsp_app: $(SOFTWARE_SOURCES)
