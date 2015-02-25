#Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
	set Page0 [ ipgui::add_page $IPINST  -name "Page 0" -layout vertical]
	set Component_Name [ ipgui::add_param  $IPINST  -parent  $Page0  -name Component_Name ]
	set NUM_C2S [ipgui::add_param $IPINST -parent $Page0 -name NUM_C2S]
	set NUM_S2C [ipgui::add_param $IPINST -parent $Page0 -name NUM_S2C]
}

proc update_PARAM_VALUE.NUM_C2S { PARAM_VALUE.NUM_C2S } {
	# Procedure called to update NUM_C2S when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_C2S { PARAM_VALUE.NUM_C2S } {
	# Procedure called to validate NUM_C2S
	return true
}

proc update_PARAM_VALUE.NUM_S2C { PARAM_VALUE.NUM_S2C } {
	# Procedure called to update NUM_S2C when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_S2C { PARAM_VALUE.NUM_S2C } {
	# Procedure called to validate NUM_S2C
	return true
}


proc update_MODELPARAM_VALUE.NUM_S2C { MODELPARAM_VALUE.NUM_S2C PARAM_VALUE.NUM_S2C } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_S2C}] ${MODELPARAM_VALUE.NUM_S2C}
}

proc update_MODELPARAM_VALUE.NUM_C2S { MODELPARAM_VALUE.NUM_C2S PARAM_VALUE.NUM_C2S } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_C2S}] ${MODELPARAM_VALUE.NUM_C2S}
}

