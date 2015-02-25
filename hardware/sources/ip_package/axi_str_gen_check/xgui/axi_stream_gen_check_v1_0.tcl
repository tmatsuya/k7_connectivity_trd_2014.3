#Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
	set Page0 [ ipgui::add_page $IPINST  -name "Page 0" -layout vertical]
	set Component_Name [ ipgui::add_param  $IPINST  -parent  $Page0  -name Component_Name ]
	set AXIS_TKEEP_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name AXIS_TKEEP_WIDTH]
	set AXIS_TDATA_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name AXIS_TDATA_WIDTH]
	set SEQ_END_CNT_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name SEQ_END_CNT_WIDTH]
	set CNT_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name CNT_WIDTH]
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

proc update_PARAM_VALUE.SEQ_END_CNT_WIDTH { PARAM_VALUE.SEQ_END_CNT_WIDTH } {
	# Procedure called to update SEQ_END_CNT_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SEQ_END_CNT_WIDTH { PARAM_VALUE.SEQ_END_CNT_WIDTH } {
	# Procedure called to validate SEQ_END_CNT_WIDTH
	return true
}

proc update_PARAM_VALUE.CNT_WIDTH { PARAM_VALUE.CNT_WIDTH } {
	# Procedure called to update CNT_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CNT_WIDTH { PARAM_VALUE.CNT_WIDTH } {
	# Procedure called to validate CNT_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.CNT_WIDTH { MODELPARAM_VALUE.CNT_WIDTH PARAM_VALUE.CNT_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CNT_WIDTH}] ${MODELPARAM_VALUE.CNT_WIDTH}
}

proc update_MODELPARAM_VALUE.SEQ_END_CNT_WIDTH { MODELPARAM_VALUE.SEQ_END_CNT_WIDTH PARAM_VALUE.SEQ_END_CNT_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SEQ_END_CNT_WIDTH}] ${MODELPARAM_VALUE.SEQ_END_CNT_WIDTH}
}

proc update_MODELPARAM_VALUE.AXIS_TDATA_WIDTH { MODELPARAM_VALUE.AXIS_TDATA_WIDTH PARAM_VALUE.AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.AXIS_TKEEP_WIDTH { MODELPARAM_VALUE.AXIS_TKEEP_WIDTH PARAM_VALUE.AXIS_TKEEP_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIS_TKEEP_WIDTH}] ${MODELPARAM_VALUE.AXIS_TKEEP_WIDTH}
}

