# PlanAhead Launch Script
set design_top k7_connectivity_trd
set sim_top board
set device xc7k325t-2-ffg900
set proj_dir runs_ipi
#set impl_const ../../sources/constraints/k7_conn_trd_ipi.xdc

create_project -name ${design_top} -force -dir "../${proj_dir}" -part ${device}

# Project Settings

#set_property top ${design_top} [current_fileset]

add_files -fileset constrs_1 -norecurse ../../sources/constraints/k7_conn_trd_ipi.xdc
set_property used_in_synthesis true [get_files ../../sources/constraints/k7_conn_trd_ipi.xdc]

set_property ip_repo_paths ../../sources/ip_package [current_fileset]
update_ip_catalog

#implementation setting
#set_property STEPS.OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
#set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1] 

#Temporary WA
set_param bd.skipSupportedIPCheck 1

source k7_conn_ipi_sim.tcl
#set_param bd.propagate.alwaysInfCheck 1
validate_bd_design
save_bd_design
close_bd_design $design_top


#file mkdir ../${proj_dir}/k7_connectivity_trd.srcs/sources_1/bd/k7_connectivity_trd/ui

#file copy -force bd_b9bc1e51.ui ../${proj_dir}/k7_connectivity_trd.srcs/sources_1/bd/k7_connectivity_trd/ui/bd_b9bc1e51.ui

open_bd_design ../${proj_dir}/k7_connectivity_trd.srcs/sources_1/bd/k7_connectivity_trd/$design_top.bd

make_wrapper -files [get_files ../runs_ipi/k7_connectivity_trd.srcs/sources_1/bd/k7_connectivity_trd/k7_connectivity_trd.bd] -top
import_files -force -norecurse ../runs_ipi/k7_connectivity_trd.srcs/sources_1/bd/k7_connectivity_trd/hdl/k7_connectivity_trd_wrapper.v

import_files -norecurse ../../sources/hdl/k7_connectivity_trd_top.v

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

####################
# Set up Simulations
# Get the current working directory
#set CurrWrkDir [pwd]
#
##if [info exists env(MODELSIM)] {
##  puts "MODELSIM env pointing to ini exists..."
##} elseif {[file exists $CurrWrkDir/modelsim.ini] == 1} {
##  set env(MODELSIM) $CurrWrkDir/modelsim.ini
##  puts "Setting \$MODELSIM to modelsim.ini"
##} else {
##  puts "\n\nERROR! modelsim.ini not found!"
##  exit
##}
##
##set_property runtime {} [get_filesets sim_1]
##set_property -name modelsim.vlog_more_options -value +acc -objects [get_filesets sim_1]
##set_property -name modelsim.vsim_more_options -value {+notimingchecks -do "../../../../wave.do; run -all" +TESTNAME=basic_test -GSIM_COLLISION_CHECK=NONE } -objects [get_filesets sim_1]
##set_property compxlib.compiled_library_dir {} [current_project]
##
#set_property top ${top} [get_filesets sim_1]
#set_property include_dirs { ../../sources/testbench ../../sources/testbench/dsport ../../sources/include ../../sources/hdl/gen_chk ./} [get_filesets sim_1]
#set_property verilog_define { {SIMULATION=1} {USE_DDR3_FIFO=1} {x1Gb=1} {sg125=1} {x8=1} {USE_PIPE_SIM=1}} [get_filesets sim_1]
#
set_property top ${sim_top} [get_filesets sim_1]
set_property verilog_define { {USE_VIVADO=1} {SIMULATION=1} {USE_DDR3_FIFO=1} {x1Gb=1} {sg125=1} {x8=1} {USE_PIPE_SIM=1} {IPI_FLOW=1} } [get_filesets sim_1]
set_property runtime {} [get_filesets sim_1]
set_property -name xsim.more_options -value {-testplusarg TESTNAME=basic_test} -objects [get_filesets sim_1]

read_verilog "../../sources/testbench/board.v"
read_verilog "../../sources/testbench/dsport/xilinx_pcie_2_1_rport_7x.v"
read_verilog "../../sources/testbench/dsport/pcie_2_1_rport_7x.v"
read_verilog "../../sources/testbench/dsport/pcie_axi_trn_bridge.v"
read_verilog "../../sources/testbench/dsport/pci_exp_usrapp_com.v"
read_verilog "../../sources/testbench/dsport/pci_exp_usrapp_tx.v"
read_verilog "../../sources/testbench/dsport/pci_exp_usrapp_cfg.v"
read_verilog "../../sources/testbench/dsport/pci_exp_usrapp_rx.v"
read_verilog "../../sources/testbench/dsport/pci_exp_usrapp_pl.v"
read_verilog "../../sources/testbench/k7_connectivity_trd_pcie_7x_0_0_gt_top_pipe_mode.v"
read_verilog "../../sources/testbench/k7_connectivity_trd_pcie_7x_0_0_pipe_clock.v"
read_verilog "../../sources/ip_cores/dma/netlist/eval/dma_back_end_axi.vp"
#set_property USED_IN simulation [get_files ../../sources/ip_cores/dma/models/dma_back_end_axi/dma_back_end_axi_model.v] 
set_property USED_IN simulation [get_files ../../sources/testbench/board.v] 
set_property USED_IN simulation [get_files ../../sources/testbench/dsport/xilinx_pcie_2_1_rport_7x.v] 
set_property USED_IN simulation [get_files ../../sources/testbench/dsport/pcie_2_1_rport_7x.v] 
set_property USED_IN simulation [get_files ../../sources/testbench/dsport/pcie_axi_trn_bridge.v] 
set_property USED_IN simulation [get_files ../../sources/testbench/dsport/pci_exp_usrapp_com.v] 
set_property USED_IN simulation [get_files ../../sources/testbench/dsport/pci_exp_usrapp_tx.v] 
set_property USED_IN simulation [get_files ../../sources/testbench/dsport/pci_exp_usrapp_cfg.v] 
set_property USED_IN simulation [get_files ../../sources/testbench/dsport/pci_exp_usrapp_rx.v] 
set_property USED_IN simulation [get_files ../../sources/testbench/dsport/pci_exp_usrapp_pl.v] 
set_property USED_IN simulation [get_files ../../sources/ip_cores/dma/netlist/eval/dma_back_end_axi.vp] 
set_property USED_IN simulation [get_files ../../sources/testbench/k7_connectivity_trd_pcie_7x_0_0_gt_top_pipe_mode.v]
set_property USED_IN simulation [get_files ../../sources/testbench/k7_connectivity_trd_pcie_7x_0_0_pipe_clock.v]


update_compile_order -fileset sources_1
set_property top ${sim_top} [get_filesets sim_1]

#generate_target all [get_files ../runs/k7_connectivity_trd.srcs/sources_1/ip/pcie_x8gen2_axi_st_ip/pcie_x8gen2_axi_st_ip.xci]
##add_files -fileset sim_1 -norecurse ../runs/k7_connectivity_trd.srcs/sources_1/ip/pcie_x8gen2_axi_st_ip/pcie_x8gen2_axi_st_ip/source/pcie_x8gen2_axi_st_ip_gt_top_pipe_mode.v
#
#generate_target all [get_files  ../runs/k7_connectivity_trd.srcs/sources_1/ip/mig_axi_mm/mig_axi_mm.xci]
#set_property include_dirs {../runs/k7_connectivity_trd.srcs/sources_1/ip/mig_axi_mm/mig_axi_mm/example_design/sim} [get_filesets sim_1]

add_files -norecurse ../runs_ipi/k7_connectivity_trd.srcs/sources_1/bd/k7_connectivity_trd/ip/k7_connectivity_trd_mig_7series_0_0/k7_connectivity_trd_mig_7series_0_0/example_design/sim/ddr3_model.v

set_property include_dirs { ../runs_ipi/k7_connectivity_trd.srcs/sources_1/bd/k7_connectivity_trd/ip/k7_connectivity_trd_mig_7series_0_0/k7_connectivity_trd_mig_7series_0_0/example_design/sim/ ../../sources/testbench/include ../../sources/testbench ../../sources/testbench/dsport} [get_filesets sim_1]
set_property USED_IN simulation [get_files ../runs_ipi/k7_connectivity_trd.srcs/sources_1/bd/k7_connectivity_trd/ip/k7_connectivity_trd_mig_7series_0_0/k7_connectivity_trd_mig_7series_0_0/example_design/sim/ddr3_model.v] 

update_compile_order -fileset sources_1
