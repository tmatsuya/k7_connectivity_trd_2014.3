# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  #Adding Page
  set Page_0  [  ipgui::add_page $IPINST -name "Page 0" -display_name {Page 0}]
  set_property tooltip {Page 0} ${Page_0}
  set Component_Name  [  ipgui::add_param $IPINST -name "Component_Name" -parent ${Page_0} -display_name {Component Name}]
  set_property tooltip {Component Name} ${Component_Name}
  set TDEST_VAL  [  ipgui::add_param $IPINST -name "TDEST_VAL" -parent ${Page_0} -display_name {TDEST VAL}]
  set_property tooltip {TDEST VAL} ${TDEST_VAL}
  set FIFO_CNT_WIDTH  [  ipgui::add_param $IPINST -name "FIFO_CNT_WIDTH" -parent ${Page_0} -display_name {Fifo Cnt Width}]
  set_property tooltip {Fifo Cnt Width} ${FIFO_CNT_WIDTH}
  set ADDRESS_FILTER_EN  [  ipgui::add_param $IPINST -name "ADDRESS_FILTER_EN" -parent ${Page_0} -display_name {Address Filter En}]
  set_property tooltip {Address Filter En} ${ADDRESS_FILTER_EN}


}

proc update_PARAM_VALUE.TDEST_VAL { PARAM_VALUE.TDEST_VAL } {
	# Procedure called to update TDEST_VAL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TDEST_VAL { PARAM_VALUE.TDEST_VAL } {
	# Procedure called to validate TDEST_VAL
	return true
}

proc update_PARAM_VALUE.FIFO_CNT_WIDTH { PARAM_VALUE.FIFO_CNT_WIDTH } {
	# Procedure called to update FIFO_CNT_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FIFO_CNT_WIDTH { PARAM_VALUE.FIFO_CNT_WIDTH } {
	# Procedure called to validate FIFO_CNT_WIDTH
	return true
}

proc update_PARAM_VALUE.ADDRESS_FILTER_EN { PARAM_VALUE.ADDRESS_FILTER_EN } {
	# Procedure called to update ADDRESS_FILTER_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADDRESS_FILTER_EN { PARAM_VALUE.ADDRESS_FILTER_EN } {
	# Procedure called to validate ADDRESS_FILTER_EN
	return true
}


proc update_MODELPARAM_VALUE.ADDRESS_FILTER_EN { MODELPARAM_VALUE.ADDRESS_FILTER_EN PARAM_VALUE.ADDRESS_FILTER_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADDRESS_FILTER_EN}] ${MODELPARAM_VALUE.ADDRESS_FILTER_EN}
}

proc update_MODELPARAM_VALUE.FIFO_CNT_WIDTH { MODELPARAM_VALUE.FIFO_CNT_WIDTH PARAM_VALUE.FIFO_CNT_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FIFO_CNT_WIDTH}] ${MODELPARAM_VALUE.FIFO_CNT_WIDTH}
}

proc update_MODELPARAM_VALUE.TDEST_VAL { MODELPARAM_VALUE.TDEST_VAL PARAM_VALUE.TDEST_VAL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TDEST_VAL}] ${MODELPARAM_VALUE.TDEST_VAL}
}

