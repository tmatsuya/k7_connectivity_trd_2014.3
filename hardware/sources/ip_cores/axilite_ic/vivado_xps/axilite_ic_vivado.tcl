# Vivado Launch Script

#### Change design settings here #######
set design axilite_ic_vivado 
set top system_stub
set device xc7k325t-2-ffg900 
set proj_dir vivado_proj_1
#set synth_constraints ./v7_xt_conn_synth.xdc
#set impl_constraints ./v7_xt_conn_trd.xdc
########################################

# Project Settings
create_project -name ${design} -force -dir "./${proj_dir}" -part ${device}
set_property source_mgmt_mode DisplayOnly [current_project]
set_property top ${top} [current_fileset]

# Bring in system.xmp from XPS
add_files -norecurse "../xps_system/system.xmp"

# Create top level RTL file from system.xmp
make_wrapper -files [get_files ../xps_system/system.xmp] -top -fileset [get_filesets sources_1] -import

# Set top level file to system_stub
set_property top system_stub [current_fileset]

#Setting Synthesis options
set_property flow {Vivado Synthesis 2012} [get_runs synth_1]

update_compile_order -fileset sources_1
launch_runs synth_1

wait_on_run synth_1

open_run synth_1 -name netlist_1
write_verilog -force ../system.v
