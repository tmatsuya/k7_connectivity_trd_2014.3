###############################################################################
# This XDC is intended for use with the Xilinx KC705 Development Board with a 
# xc7k325t-ffg900-2 part
###############################################################################
##---------------------------------------------------------------------------------------
## 10GBASE-R constraints
##---------------------------------------------------------------------------------------
##GT Ref clk
set_property LOC C8 [get_ports xphy0_refclk_p]
set_property LOC C7 [get_ports xphy0_refclk_n]

set_false_path -from [get_ports perst_n]
set_property IOSTANDARD LVCMOS25 [get_ports perst_n]
set_property PULLUP true [get_ports perst_n]
set_property LOC G25 [get_ports perst_n]

## 100 MHz Reference Clock
set_property LOC IBUFDS_GTE2_X0Y1 [get_cells refclk_ibuf]

# Timing constraints
#create_clock -name ref_clk -period 10 [get_ports pcie_clk_p]
create_clock -period 10 [get_ports pcie_clk_p]

### Comment the following lines for different quad instance
###---------- Set placement for gt0_gtx_wrapper_i/GTX_DUAL ------
set_property LOC GTXE2_CHANNEL_X0Y12 [get_cells k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/Ethernet_Path/ten_gig_eth_pcs_pma_0/inst/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i]

###---------- Set placement for gt1_gtx_wrapper_i/GTX_DUAL ------
set_property LOC GTXE2_CHANNEL_X0Y13 [get_cells k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/Ethernet_Path/ten_gig_eth_pcs_pma_1/inst/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i]

### Uncomment the following lines for different quad instance
###---------- Set placement for gt0_gtx_wrapper_i/GTX_DUAL ------
#set_property LOC GTXE2_CHANNEL_X0Y10 [get_cells network_path_inst_0/ten_gig_eth_pcs_pma_inst/inst/*/gtxe2_i]
#
###---------- Set placement for gt1_gtx_wrapper_i/GTX_DUAL ------
#set_property LOC GTXE2_CHANNEL_X0Y15 [get_cells network_path_inst_1/ten_gig_eth_pcs_pma_inst/inst/*/gtxe2_i]

## Enable use of VR/VP pins as normal IO 
set_property DCI_CASCADE {32 34} [get_iobanks 33]

## SFP TX Disable loc
set_property LOC D29  [get_ports {sfp_tx_disable[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {sfp_tx_disable[0]}]

set_property LOC G30  [get_ports {sfp_tx_disable[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {sfp_tx_disable[1]}]

##-------------------------------------
## LED Status Pinout   (bottom to top)
##-------------------------------------

set_property LOC AA8  [get_ports {led[1]}]
set_property LOC AC9  [get_ports {led[2]}]
set_property LOC AB9  [get_ports {led[3]}]
set_property LOC AE26 [get_ports {led[4]}]
set_property LOC G19  [get_ports {led[5]}]
set_property LOC E18  [get_ports {led[6]}]
set_property LOC F16  [get_ports {led[7]}]

set_property IOSTANDARD LVCMOS15 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {led[7]}]

set_property SLEW SLOW [get_ports led]
set_property DRIVE 4 [get_ports led]

#This LED behind FMC glowing indicates FMC Connected to the right HPC
set_property LOC F21 [get_ports {fmc_ok_led}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc_ok_led}]
  #GBTCLK0_FSEL0
set_property LOC H24 [get_ports {fmc_gbtclk0_fsel[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc_gbtclk0_fsel[0]}]
  #GBTCLK0_FSEL1
set_property LOC H25 [get_ports {fmc_gbtclk0_fsel[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc_gbtclk0_fsel[1]}]
  # FMC Clock programmed to 312.5MHz
set_property LOC E21 [get_ports {fmc_clk_312_5}]
set_property IOSTANDARD LVCMOS25 [get_ports {fmc_clk_312_5}]

#create_clock -name clk_ref_p -period 5 [get_ports clk_ref_p]

set_property IOSTANDARD DIFF_SSTL15 [get_ports clk_ref_n]
set_property LOC AD11 [get_ports clk_ref_n]      

set_property IOSTANDARD DIFF_SSTL15 [get_ports clk_ref_p]
set_property LOC AD12 [get_ports clk_ref_p]   

# Domain Crossing Constraints
#create_clock -name userclk2 -period 4.0 [get_nets user_clk]
create_clock -name clk156 -period 6.400 [get_nets clk156]
#create_clock -name dclk -period 12.800 [get_pins k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/xgbaser_gt_wrapper_inst_0/dclk_bufg_inst/O]
#create_clock -name refclk -period 3.200 [get_pins k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/ten_gig_eth_pcs_pma_0/inst/ten_gig_eth_pcs_pma_clock_reset_block/ibufds_inst/O]
#create_clock -name rxoutclk0 -period 3.103 [get_pins k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/Ethernet_Path/ten_gig_eth_pcs_pma_0/inst/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i/RXOUTCLK]
#create_clock -name rxoutclk1 -period 3.103 [get_pins k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/Ethernet_Path/ten_gig_eth_pcs_pma_1/inst/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i/RXOUTCLK]
#create_clock -name txoutclk0 -period 3.103 [get_pins k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/Ethernet_Path/ten_gig_eth_pcs_pma_0/inst/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i/TXOUTCLK]
#create_clock -name txoutclk1 -period 3.103 [get_pins k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/Ethernet_Path/ten_gig_eth_pcs_pma_1/inst/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i/TXOUTCLK]

#create_clock -name clk50 -period 5.000 [get_pins k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/DDR_Memory/mcb_clk] 
#set_clock_sense -positive clk_divide_reg[1]_i_1/O
#create_clock -name gtxe2_txoutclk -period 10.0 [get_pins k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/PCIe_Path/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtx_channel.gtxe2_channel_i/TXOUTCLK]

#create_generated_clock -name clk_125mhz_mux \
#    -source [get_pins k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/PCIe_Path/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I0] \
#    -divide_by 1 \
#   [get_pins k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/PCIe_Path/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/O]

#create_generated_clock -name clk_250mhz_mux \
#      -source [get_pins k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/PCIe_Path/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I1] \
#      -divide_by 1 -add -master_clock [get_clocks -of [get_pins k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/PCIe_Path/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I1]] \
#      [get_pins k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/PCIe_Path/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/O]

#set_clock_groups -name pcieclkmux -physically_exclusive -group clk_125mhz_mux -group clk_250mhz_mux

#set userclk1 [get_clocks -of_objects [get_pins k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/PCIe_Path/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT2]]
#set userclk2 [get_clocks -of_objects [get_pins k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/PCIe_Path/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT3]]

set_clock_groups -name async_mig_pcie -asynchronous \
  -group [get_clocks -include_generated_clocks sys_clk] \
  -group [get_clocks -include_generated_clocks userclk2]

#set_clock_groups -name async_mig_clk50 -asynchronous \
#  -group [get_clocks -include_generated_clocks sys_clk] \
#  -group [get_clocks clk50]

#set_clock_groups -name async_clk50_pcie -asynchronous \
#  -group [get_clocks clk50] \
#  -group [get_clocks -include_generated_clocks $userclk2]

set_clock_groups -name async_mig_xgemac -asynchronous \
  -group [get_clocks -include_generated_clocks sys_clk] \
  -group [get_clocks -include_generated_clocks clk156]

set_clock_groups -name async_userclk2_xgemac -asynchronous \
  -group [get_clocks -include_generated_clocks userclk2] \
  -group [get_clocks -include_generated_clocks clk156]

set_clock_groups -name async_txusrclk_xgemac -asynchronous \
  -group [get_clocks -include_generated_clocks k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/Ethernet_Path/ten_gig_eth_pcs_pma_0/inst/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i/TXOUTCLK] \
  -group [get_clocks -include_generated_clocks clk156]

set_clock_groups -name async_txusrclk_xgemac -asynchronous \
  -group [get_clocks -include_generated_clocks k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/Ethernet_Path/ten_gig_eth_pcs_pma_1/inst/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i/TXOUTCLK] \
  -group [get_clocks -include_generated_clocks clk156]

set_clock_groups -name async_xgemac_clk50 -asynchronous \
   -group [get_clocks -include_generated_clocks clk156] \
   -group [get_clocks sys_clk]


set_clock_groups -name async_rxusrclk_userclk2 -asynchronous \
  -group [get_clocks  -include_generated_clocks k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/Ethernet_Path/ten_gig_eth_pcs_pma_0/inst/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i/RXOUTCLK] \
  -group [get_clocks  -include_generated_clocks userclk2]
  
  set_clock_groups -name async_rxusrclk_userclk2 -asynchronous \
    -group [get_clocks  -include_generated_clocks k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/Ethernet_Path/ten_gig_eth_pcs_pma_1/inst/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i/RXOUTCLK] \
    -group [get_clocks  -include_generated_clocks userclk2]

set_clock_groups -name async_rxusrclk_clk156 -asynchronous \
  -group [get_clocks  -include_generated_clocks k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/Ethernet_Path/ten_gig_eth_pcs_pma_0/inst/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i/RXOUTCLK] \
  -group [get_clocks  -include_generated_clocks clk156]

set_clock_groups -name async_rxusrclk_clk156 -asynchronous \
  -group [get_clocks  -include_generated_clocks k7_connectivity_trd_wrapper_i/k7_connectivity_trd_i/Ethernet_Path/ten_gig_eth_pcs_pma_1/inst/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i/RXOUTCLK] \
  -group [get_clocks  -include_generated_clocks clk156]
#----------------------------------------
# FLASH programming - BPI Sync Mode fast 
#----------------------------------------

set_property IOSTANDARD LVCMOS25 [get_ports emcclk]
set_property LOC R24 [get_ports emcclk]

#PMBUS LOC
set_property LOC AG17  [get_ports pmbus_clk]
set_property LOC Y14  [get_ports pmbus_data]
set_property LOC AB14  [get_ports pmbus_alert]
set_property IOSTANDARD LVCMOS15 [get_ports pmbus_clk]
set_property IOSTANDARD LVCMOS15 [get_ports pmbus_data]
set_property IOSTANDARD LVCMOS15 [get_ports pmbus_alert]

#set_max_delay 10 -datapath_only -from [get_pins k7_connectivity_wrapper_i/k7_connectivity_trd_i/reset_top_0/user_reset_i/C] -to [get_pins k7_connectivity_trd_i/user_reg_slave_inst/kc705_pvt_monitor/test_controller/processor/internal_reset_flop/D]

#set_max_delay 10 -datapath_only -from [get_pins k7_connectivity_wrapper_i/k7_connectivity_trd_i/reset_top_0/user_reset_i/C] -to [get_pins k7_connectivity_trd_i/user_reg_slave_inst/rst_int_reg/PRE]
##
#set_max_delay 10 -datapath_only -from [get_pins k7_connectivity_wrapper_i/k7_connectivity_trd_i/reset_top_0/user_reset_i/C] -to [get_pins k7_connectivity_trd_i/user_reg_slave_inst/kc705_pvt_monitor/test_controller/processor/run_flop/D]

#set_max_delay 10 -datapath_only -from [get_pins k7_connectivity_wrapper_i/k7_connectivity_trd_i/reset_top_0/user_reset_i/C] -to [get_pins k7_connectivity_trd_i/user_reg_slave_inst/rst_r_reg/PRE]

