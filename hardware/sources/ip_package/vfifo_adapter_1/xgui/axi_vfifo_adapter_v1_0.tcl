# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
	set Page0 [ipgui::add_page $IPINST -name "Page 0" -layout vertical]
	set Component_Name [ipgui::add_param $IPINST -parent $Page0 -name Component_Name]
	set CNTWIDTH [ipgui::add_param $IPINST -parent $Page0 -name CNTWIDTH]
	set NUM_PORTS [ipgui::add_param $IPINST -parent $Page0 -name NUM_PORTS]
}

proc update_PARAM_VALUE.CNTWIDTH { PARAM_VALUE.CNTWIDTH } {
	# Procedure called to update CNTWIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CNTWIDTH { PARAM_VALUE.CNTWIDTH } {
	# Procedure called to validate CNTWIDTH
	return true
}

proc update_PARAM_VALUE.NUM_PORTS { PARAM_VALUE.NUM_PORTS } {
	# Procedure called to update NUM_PORTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_PORTS { PARAM_VALUE.NUM_PORTS } {
	# Procedure called to validate NUM_PORTS
	return true
}


proc update_MODELPARAM_VALUE.NUM_PORTS { MODELPARAM_VALUE.NUM_PORTS PARAM_VALUE.NUM_PORTS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_PORTS}] ${MODELPARAM_VALUE.NUM_PORTS}
}

proc update_MODELPARAM_VALUE.CNTWIDTH { MODELPARAM_VALUE.CNTWIDTH PARAM_VALUE.CNTWIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CNTWIDTH}] ${MODELPARAM_VALUE.CNTWIDTH}
}

