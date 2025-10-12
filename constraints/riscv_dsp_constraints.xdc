#=============================================================================
# Timing Constraints for RISC-V DSP Processor
# Target: Xilinx 7-series FPGA
#=============================================================================

# Clock constraints
create_clock -period 10.000 -name clk [get_ports clk]

# Input delay constraints
set_input_delay -clock clk -max 2.000 [get_ports external_data_in]
set_input_delay -clock clk -min 0.500 [get_ports external_data_in]

# Output delay constraints
set_output_delay -clock clk -max 2.000 [get_ports external_data_out]
set_output_delay -clock clk -min 0.500 [get_ports external_data_out]
set_output_delay -clock clk -max 2.000 [get_ports processor_ready]
set_output_delay -clock clk -min 0.500 [get_ports processor_ready]

# Reset constraints
set_false_path -from [get_ports rst_n]

# Clock domain constraints
set_clock_groups -asynchronous -group [get_clocks clk]

# Timing exceptions
set_multicycle_path -setup 2 -from [get_clocks clk] -to [get_clocks clk]
set_multicycle_path -hold 1 -from [get_clocks clk] -to [get_clocks clk]

# DSP-specific timing constraints
# MAC unit timing
set_max_delay -from [get_cells -hier -filter {NAME =~ "*mac_unit*"}] 8.000
set_min_delay -from [get_cells -hier -filter {NAME =~ "*mac_unit*"}] 1.000

# SIMD unit timing
set_max_delay -from [get_cells -hier -filter {NAME =~ "*simd_unit*"}] 8.000
set_min_delay -from [get_cells -hier -filter {NAME =~ "*simd_unit*"}] 1.000

# Memory interface timing
set_max_delay -from [get_cells -hier -filter {NAME =~ "*memory_interface*"}] 6.000
set_min_delay -from [get_cells -hier -filter {NAME =~ "*memory_interface*"}] 1.000

# Power constraints
set_switching_activity -default_static_probability 0.5
set_switching_activity -default_toggle_rate 100

# Area constraints
set_max_fanout 50 [get_cells -hier]
set_max_capacitance 0.5 [get_ports]

# I/O constraints
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports external_data_in]
set_property IOSTANDARD LVCMOS33 [get_ports external_data_out]
set_property IOSTANDARD LVCMOS33 [get_ports processor_ready]

# Pin assignments (example for Basys 3 board)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property PACKAGE_PIN U18 [get_ports rst_n]
set_property PACKAGE_PIN T18 [get_ports external_data_in[0]]
set_property PACKAGE_PIN W19 [get_ports external_data_in[1]]
set_property PACKAGE_PIN T19 [get_ports external_data_in[2]]
set_property PACKAGE_PIN U19 [get_ports external_data_in[3]]
set_property PACKAGE_PIN E19 [get_ports external_data_in[4]]
set_property PACKAGE_PIN U16 [get_ports external_data_in[5]]
set_property PACKAGE_PIN V16 [get_ports external_data_in[6]]
set_property PACKAGE_PIN T15 [get_ports external_data_in[7]]
set_property PACKAGE_PIN V15 [get_ports external_data_in[8]]
set_property PACKAGE_PIN R16 [get_ports external_data_in[9]]
set_property PACKAGE_PIN U17 [get_ports external_data_in[10]]
set_property PACKAGE_PIN V17 [get_ports external_data_in[11]]
set_property PACKAGE_PIN V18 [get_ports external_data_in[12]]
set_property PACKAGE_PIN T17 [get_ports external_data_in[13]]
set_property PACKAGE_PIN U12 [get_ports external_data_in[14]]
set_property PACKAGE_PIN U13 [get_ports external_data_in[15]]
set_property PACKAGE_PIN V13 [get_ports external_data_in[16]]
set_property PACKAGE_PIN V3 [get_ports external_data_in[17]]
set_property PACKAGE_PIN W3 [get_ports external_data_in[18]]
set_property PACKAGE_PIN U3 [get_ports external_data_in[19]]
set_property PACKAGE_PIN P3 [get_ports external_data_in[20]]
set_property PACKAGE_PIN N3 [get_ports external_data_in[21]]
set_property PACKAGE_PIN P1 [get_ports external_data_in[22]]
set_property PACKAGE_PIN L1 [get_ports external_data_in[23]]
set_property PACKAGE_PIN C2 [get_ports external_data_in[24]]
set_property PACKAGE_PIN D2 [get_ports external_data_in[25]]
set_property PACKAGE_PIN E2 [get_ports external_data_in[26]]
set_property PACKAGE_PIN F2 [get_ports external_data_in[27]]
set_property PACKAGE_PIN G2 [get_ports external_data_in[28]]
set_property PACKAGE_PIN H2 [get_ports external_data_in[29]]
set_property PACKAGE_PIN J2 [get_ports external_data_in[30]]
set_property PACKAGE_PIN K2 [get_ports external_data_in[31]]

# Output pin assignments
set_property PACKAGE_PIN L2 [get_ports external_data_out[0]]
set_property PACKAGE_PIN M2 [get_ports external_data_out[1]]
set_property PACKAGE_PIN M1 [get_ports external_data_out[2]]
set_property PACKAGE_PIN N1 [get_ports external_data_out[3]]
set_property PACKAGE_PIN P2 [get_ports external_data_out[4]]
set_property PACKAGE_PIN P4 [get_ports external_data_out[5]]
set_property PACKAGE_PIN M3 [get_ports external_data_out[6]]
set_property PACKAGE_PIN N2 [get_ports external_data_out[7]]
set_property PACKAGE_PIN U1 [get_ports external_data_out[8]]
set_property PACKAGE_PIN U2 [get_ports external_data_out[9]]
set_property PACKAGE_PIN V1 [get_ports external_data_out[10]]
set_property PACKAGE_PIN V2 [get_ports external_data_out[11]]
set_property PACKAGE_PIN W1 [get_ports external_data_out[12]]
set_property PACKAGE_PIN W2 [get_ports external_data_out[13]]
set_property PACKAGE_PIN W4 [get_ports external_data_out[14]]
set_property PACKAGE_PIN W6 [get_ports external_data_out[15]]
set_property PACKAGE_PIN V6 [get_ports external_data_out[16]]
set_property PACKAGE_PIN V7 [get_ports external_data_out[17]]
set_property PACKAGE_PIN U7 [get_ports external_data_out[18]]
set_property PACKAGE_PIN U8 [get_ports external_data_out[19]]
set_property PACKAGE_PIN U9 [get_ports external_data_out[20]]
set_property PACKAGE_PIN U10 [get_ports external_data_out[21]]
set_property PACKAGE_PIN U11 [get_ports external_data_out[22]]
set_property PACKAGE_PIN T10 [get_ports external_data_out[23]]
set_property PACKAGE_PIN T11 [get_ports external_data_out[24]]
set_property PACKAGE_PIN R10 [get_ports external_data_out[25]]
set_property PACKAGE_PIN R11 [get_ports external_data_out[26]]
set_property PACKAGE_PIN P10 [get_ports external_data_out[27]]
set_property PACKAGE_PIN P11 [get_ports external_data_out[28]]
set_property PACKAGE_PIN N10 [get_ports external_data_out[29]]
set_property PACKAGE_PIN N11 [get_ports external_data_out[30]]
set_property PACKAGE_PIN M10 [get_ports external_data_out[31]]

# Processor ready signal
set_property PACKAGE_PIN L3 [get_ports processor_ready]
