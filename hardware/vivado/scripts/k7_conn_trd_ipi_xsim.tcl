# Vivado Launch Script in batch mode

source k7_conn_gui_ipi_sim.tcl
launch_xsim -simset sim_1 -mode behavioral
run all
