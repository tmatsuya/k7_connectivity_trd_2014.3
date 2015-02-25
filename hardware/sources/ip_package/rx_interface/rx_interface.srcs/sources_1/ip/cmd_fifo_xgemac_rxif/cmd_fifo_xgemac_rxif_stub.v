// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.3.0 (lin64) Build 980735 Sun Aug 10 20:51:28 MDT 2014
// Date        : Mon Aug 11 14:32:50 2014
// Host        : xhd-lin64re92 running 64-bit Red Hat Enterprise Linux Client release 5.9 (Tikanga)
// Command     : write_verilog -force -mode synth_stub
//               /wrk/paeg/users/bokkaab/trd_2014.3/k7_connectivity_trd_2014.3/hardware/sources/ip_package/rx_interface/rx_interface.srcs/sources_1/ip/cmd_fifo_xgemac_rxif/cmd_fifo_xgemac_rxif_stub.v
// Design      : cmd_fifo_xgemac_rxif
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v12_0,Vivado 2014.3.0" *)
module cmd_fifo_xgemac_rxif(clk, rst, din, wr_en, rd_en, dout, full, empty)
/* synthesis syn_black_box black_box_pad_pin="clk,rst,din[15:0],wr_en,rd_en,dout[15:0],full,empty" */;
  input clk;
  input rst;
  input [15:0]din;
  input wr_en;
  input rd_en;
  output [15:0]dout;
  output full;
  output empty;
endmodule
