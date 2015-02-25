# Vivado Launch Script in batch mode

source k7_conn_gui_ipi.tcl

reset_run synth_1 
launch_run [get_runs synth_1]

wait_on_run synth_1

reset_run impl_1
launch_run -to_step write_bitstream [get_runs impl_1]

wait_on_run impl_1
