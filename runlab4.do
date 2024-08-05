# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./data_path.sv"
vlog "./forwarding_control_path.sv"
vlog "./mux_8_1.sv"
vlog "./sign_extender.sv"
vlog "./PIPELINED_CPU.sv"
vlog "./instructmem.sv"
vlog "./datamem.sv"
vlog "./regfile.sv"
vlog "./alu.sv"
#vlog "./PIPELINED_CPU_testbench.sv"
vlog "./muxr.sv"
vlog "./two_AND.sv"
vlog "./D_FF.sv"
vlog "./buffer.sv"
vlog "./and_.sv"
vlog "./or_.sv"
vlog "./xor_.sv"
vlog "./full_adder.sv"
vlog "./forwarding_unit.sv"
vlog "./regfile_movk.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work PIPELINED_CPU_testbench

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do pipeline_wav.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
