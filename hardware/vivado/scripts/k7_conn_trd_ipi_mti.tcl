
source k7_conn_gui_ipi_sim.tcl
# Set up Simulations
# Get the current working directory
set CurrWrkDir [pwd]

if [info exists env(MODELSIM)] {
  puts "MODELSIM env pointing to ini exists..."
} elseif {[file exists $CurrWrkDir/modelsim.ini] == 1} {
  set env(MODELSIM) $CurrWrkDir/modelsim.ini
  puts "Setting \$MODELSIM to modelsim.ini"
} else {
  puts "\n\nERROR! modelsim.ini not found!"
  exit
}

set_property target_simulator ModelSim [current_project]
set_property -name modelsim.vsim.more_options -value {+notimingchecks -do "run -all" -do "add log -r" +TESTNAME=basic_test -GSIM_COLLISION_CHECK=NONE -novopt} -objects [get_filesets sim_1]
set_property -name modelsim.vlog_more_options -value {+acc -sv} -objects [get_filesets sim_1]
set_property -name runtime -value {} -objects [get_filesets sim_1]
set_property compxlib.compiled_library_dir {} [current_project]

launch_modelsim -simset sim_1 -mode behavioral
