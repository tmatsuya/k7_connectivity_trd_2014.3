namespace eval xlconstant_v1_1_utils {

  proc upgrade_from_xlconstant_v1_0 {xciValues} {

    namespace import ::xcoUpgradeLib::\*
    upvar $xciValues valueArray
    renamePort   "const"   "dout"  valueArray
    namespace forget ::xcoUpgradeLib::\*
  }
}
