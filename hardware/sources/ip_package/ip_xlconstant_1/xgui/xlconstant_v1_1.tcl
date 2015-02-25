#Definitional proc to organize widgets for parameters.
proc create_gui { ipview } {
	set Page0 [ ipgui::add_page $ipview  -name "Page 0" -layout vertical]
	set Component_Name [ ipgui::add_param  $ipview  -parent  $Page0  -name Component_Name ]
	set CONST_WIDTH [ipgui::add_param $ipview -parent $Page0 -name CONST_WIDTH]
	set CONST_VAL [ipgui::add_param $ipview -parent $Page0 -name CONST_VAL]
}

proc CONST_WIDTH_updated {ipview} {
	# Procedure called when CONST_WIDTH is updated
	return true
}

proc validate_CONST_WIDTH {ipview} {
	# Procedure called to validate CONST_WIDTH
	return true
}

proc CONST_VAL_updated {ipview} {
	# Procedure called when CONST_VAL is updated
	return true
}

proc validate_CONST_VAL {ipview} {
	# Procedure called to validate CONST_VAL
	return true
}


proc updateModel_CONST_VAL {ipview} {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property modelparam_value [get_property value [ipgui::get_paramspec CONST_VAL -of $ipview ]] [ipgui::get_modelparamspec CONST_VAL -of $ipview ]

	return true
}

proc updateModel_CONST_WIDTH {ipview} {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property modelparam_value [get_property value [ipgui::get_paramspec CONST_WIDTH -of $ipview ]] [ipgui::get_modelparamspec CONST_WIDTH -of $ipview ]

	return true
}

