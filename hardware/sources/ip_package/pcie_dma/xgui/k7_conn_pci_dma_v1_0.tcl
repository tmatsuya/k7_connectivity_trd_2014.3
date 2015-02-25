#Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
	set Page0 [ ipgui::add_page $IPINST  -name "Page 0" -layout vertical]
	set Component_Name [ ipgui::add_param  $IPINST  -parent  $Page0  -name Component_Name ]
	set AXIS_TKEEP_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name AXIS_TKEEP_WIDTH]
	set AXIS_TDATA_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name AXIS_TDATA_WIDTH]
	set CORE_BE_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name CORE_BE_WIDTH]
	set CORE_DATA_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name CORE_DATA_WIDTH]
}

proc update_PARAM_VALUE.AXIS_TKEEP_WIDTH { PARAM_VALUE.AXIS_TKEEP_WIDTH } {
	# Procedure called to update AXIS_TKEEP_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXIS_TKEEP_WIDTH { PARAM_VALUE.AXIS_TKEEP_WIDTH } {
	# Procedure called to validate AXIS_TKEEP_WIDTH
	return true
}

proc update_PARAM_VALUE.AXIS_TDATA_WIDTH { PARAM_VALUE.AXIS_TDATA_WIDTH } {
	# Procedure called to update AXIS_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXIS_TDATA_WIDTH { PARAM_VALUE.AXIS_TDATA_WIDTH } {
	# Procedure called to validate AXIS_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.CORE_BE_WIDTH { PARAM_VALUE.CORE_BE_WIDTH } {
	# Procedure called to update CORE_BE_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CORE_BE_WIDTH { PARAM_VALUE.CORE_BE_WIDTH } {
	# Procedure called to validate CORE_BE_WIDTH
	return true
}

proc update_PARAM_VALUE.CORE_DATA_WIDTH { PARAM_VALUE.CORE_DATA_WIDTH } {
	# Procedure called to update CORE_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CORE_DATA_WIDTH { PARAM_VALUE.CORE_DATA_WIDTH } {
	# Procedure called to validate CORE_DATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.CORE_DATA_WIDTH { MODELPARAM_VALUE.CORE_DATA_WIDTH PARAM_VALUE.CORE_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CORE_DATA_WIDTH}] ${MODELPARAM_VALUE.CORE_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.CORE_BE_WIDTH { MODELPARAM_VALUE.CORE_BE_WIDTH PARAM_VALUE.CORE_BE_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CORE_BE_WIDTH}] ${MODELPARAM_VALUE.CORE_BE_WIDTH}
}

proc update_MODELPARAM_VALUE.AXIS_TDATA_WIDTH { MODELPARAM_VALUE.AXIS_TDATA_WIDTH PARAM_VALUE.AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.AXIS_TKEEP_WIDTH { MODELPARAM_VALUE.AXIS_TKEEP_WIDTH PARAM_VALUE.AXIS_TKEEP_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIS_TKEEP_WIDTH}] ${MODELPARAM_VALUE.AXIS_TKEEP_WIDTH}
}

