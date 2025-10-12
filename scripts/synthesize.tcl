#=============================================================================
# Synthesis Script for RISC-V DSP Processor
# Target: Xilinx Vivado
#=============================================================================

# Set project name and directory
set project_name "riscv_dsp_processor"
set project_dir "./synth"

# Create project
create_project $project_name $project_dir -part xc7a35tcpg236-1 -force

# Add source files
add_files -norecurse {
    ../src/riscv_dsp_core.v
    ../src/alu.v
    ../src/mac_unit.v
    ../src/simd_unit.v
    ../src/register_file.v
    ../src/instruction_decoder.v
    ../src/control_unit.v
    ../src/memory_interface.v
}

# Add constraint files
add_files -fileset constrs_1 -norecurse {
    ../constraints/riscv_dsp_constraints.xdc
}

# Set top module
set_property top riscv_dsp_core [current_fileset]

# Set synthesis strategy
set_property strategy Vivado_Synthesis_Defaults [get_runs synth_1]

# Set implementation strategy
set_property strategy Vivado_Implementation_Defaults [get_runs impl_1]

# Launch synthesis
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Check synthesis results
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    error "Synthesis failed"
}

# Generate reports
open_run synth_1 -name synth_1
report_utilization -file $project_dir/utilization_synth.rpt
report_timing -file $project_dir/timing_synth.rpt
report_power -file $project_dir/power_synth.rpt

# Launch implementation
launch_runs impl_1 -jobs 4
wait_on_run impl_1

# Check implementation results
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    error "Implementation failed"
}

# Generate implementation reports
open_run impl_1 -name impl_1
report_utilization -file $project_dir/utilization_impl.rpt
report_timing -file $project_dir/timing_impl.rpt
report_power -file $project_dir/power_impl.rpt
report_drc -file $project_dir/drc_impl.rpt

# Generate bitstream
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

puts "Synthesis and implementation completed successfully!"
puts "Reports generated in $project_dir/"
