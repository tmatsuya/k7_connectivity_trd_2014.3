//-----------------------------------------------------------------------------
//
// (c) Copyright 2012-2013 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information of Xilinx, Inc.
// and is protected under U.S. and international copyright and other
// intellectual property laws.
//
// DISCLAIMER
//
// This disclaimer is not a license and does not grant any rights to the
// materials distributed herewith. Except as otherwise provided in a valid
// license issued to you by Xilinx, and to the maximum extent permitted by
// applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL
// FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS,
// IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
// MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE;
// and (2) Xilinx shall not be liable (whether in contract or tort, including
// negligence, or under any other theory of liability) for any loss or damage
// of any kind or nature related to, arising under or in connection with these
// materials, including for any direct, or any indirect, special, incidental,
// or consequential loss or damage (including loss of data, profits, goodwill,
// or any type of loss or damage suffered as a result of any action brought by
// a third party) even if such damage or loss was reasonably foreseeable or
// Xilinx had been advised of the possibility of the same.
//
// CRITICAL APPLICATIONS
//
// Xilinx products are not designed or intended to be fail-safe, or for use in
// any application requiring fail-safe performance, such as life-support or
// safety devices or systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any other
// applications that could lead to death, personal injury, or severe property
// or environmental damage (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and liability of any use of
// Xilinx products in Critical Applications, subject only to applicable laws
// and regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE
// AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : Kintex-7 Connectivity Domain Targeted Reference Design 
//
//-----------------------------------------------------------------------------
//
module axi_vfifo_adapter #(
  parameter NUM_PORTS                 = 4,
  parameter CNTWIDTH                  = 32
  )(
    // DDR3 ports
    output reg                     calib_done = 1'b0,
    input                          axi_ic_mig_shim_rst_n, 

   input                           mcb_clk, 
   input                           calib_done_in,
   
   input            [63:0]      axi_str_rd_tdata_0,
   input            [127:0]     axi_str_rd_tdata_1,
   input            [63:0]      axi_str_rd_tdata_2,
   input            [127:0]     axi_str_rd_tdata_3,
   
   input                        axi_str_rd_tready_0,
   input                        axi_str_rd_tready_1,
   input                        axi_str_rd_tready_2,
   input                        axi_str_rd_tready_3,
        
   input                        axi_str_rd_tvalid_0,
   input                        axi_str_rd_tvalid_1,
   input                        axi_str_rd_tvalid_2,
   input                        axi_str_rd_tvalid_3,

   output [NUM_PORTS-1:0]              ddr3_fifo_empty,

input [CNTWIDTH-1:0] px_vf_rd_data_cnt_0,
input [CNTWIDTH-1:0] px_vf_rd_data_cnt_1,
input [CNTWIDTH-1:0] px_vf_rd_data_cnt_2,
input [CNTWIDTH-1:0] px_vf_rd_data_cnt_3,
output reg [NUM_PORTS-1:0] vfifo_mm2s_channel_full,
input [NUM_PORTS-1:0] vfifo_s2mm_channel_full,
output  s00_arb_req_suppress,
output  s01_arb_req_suppress,
output  s02_arb_req_suppress,
output  s03_arb_req_suppress,
output  ic_reset,
input [NUM_PORTS-1:0]                    vfifo_idle,
input                              axi_str_rd_aclk_0,
input                              axi_str_rd_aclk_1,
input                              axi_str_rd_aclk_2,
input                              axi_str_rd_aclk_3

);

  // ----------------
  // -- Parameters --
  // ----------------
  
reg [NUM_PORTS-1:0] vfifo_mm2s_channel_full_250;
reg [NUM_PORTS-1:0] vfifo_mm2s_channel_full_200_d1;
reg [NUM_PORTS-1:0] vfifo_s2mm_channel_full_reg;
wire axi_ic_mig_shim_rst_n_sync;

assign s00_arb_req_suppress= vfifo_s2mm_channel_full_reg[0];
assign s01_arb_req_suppress= vfifo_s2mm_channel_full_reg[1];
assign s02_arb_req_suppress= vfifo_s2mm_channel_full_reg[2];
assign s03_arb_req_suppress= vfifo_s2mm_channel_full_reg[3];

 //- thresholds set based on read port FIFO depth chosen
 /*
  * For ports #0 and #2, read port has deeper packet mode FIFO enabled 
  * for connection to XGEMAC; port #1 and #3 have normal shallow FIFO
  */
  always @(posedge axi_str_rd_aclk_0)
    vfifo_mm2s_channel_full_250[0] <= (px_vf_rd_data_cnt_0 > 32'h0180) ? 1'b1
                                      : 1'b0;

  always @(posedge axi_str_rd_aclk_1)
    vfifo_mm2s_channel_full_250[1] <= (px_vf_rd_data_cnt_1 > 32'h00B0) ? 1'b1
                                      : 1'b0;

  always @(posedge axi_str_rd_aclk_2)
    vfifo_mm2s_channel_full_250[2] <= (px_vf_rd_data_cnt_2 > 32'h0180) ? 1'b1
                                      : 1'b0;

  always @(posedge axi_str_rd_aclk_3)
    vfifo_mm2s_channel_full_250[3] <= (px_vf_rd_data_cnt_3 > 32'h00B0) ? 1'b1
                                      : 1'b0;

  //- Clock domain crossing
  always @(posedge mcb_clk)
  begin
    vfifo_mm2s_channel_full_200_d1  <= vfifo_mm2s_channel_full_250;
    vfifo_mm2s_channel_full <= vfifo_mm2s_channel_full_200_d1;
  end

  always @(posedge mcb_clk)
    vfifo_s2mm_channel_full_reg <= vfifo_s2mm_channel_full;

  always @(posedge mcb_clk)
    calib_done  <= calib_done_in;

  synchronizer_simple #(.DATA_WIDTH (1)) sync_to_user_clk_1
  (
    .data_in          (axi_ic_mig_shim_rst_n),
    .new_clk          (mcb_clk),
    .data_out         (axi_ic_mig_shim_rst_n_sync)
  );


  assign ic_reset = calib_done & axi_ic_mig_shim_rst_n_sync;

  //- Figure out all empty

    localparam TIMEOUT_CYCLE  = 64;

    reg [NUM_PORTS-1:0] axis_ic_empty;
    reg [NUM_PORTS-1:0] axis_vf_empty;

    reg [6:0]   to_cntr_0;
    reg [6:0]   to_cntr_1;
    reg [6:0]   to_cntr_2;
    reg [6:0]   to_cntr_3;

    always @(posedge axi_str_rd_aclk_0)
    begin
      axis_ic_empty[0]  <= ((px_vf_rd_data_cnt_0 == 0) & ~axi_str_rd_tvalid_0);
      axis_vf_empty[0]  <= axis_ic_empty[0] & vfifo_idle[0];
    end

    always @(posedge axi_str_rd_aclk_1)
    begin
      axis_ic_empty[1]  <= ((px_vf_rd_data_cnt_1 == 0) & ~axi_str_rd_tvalid_1);
      axis_vf_empty[1]  <= axis_ic_empty[1] & vfifo_idle[1];
    end  

    always @(posedge axi_str_rd_aclk_2)
    begin
      axis_ic_empty[2]  <= ((px_vf_rd_data_cnt_2 == 0) & ~axi_str_rd_tvalid_2);
      axis_vf_empty[2]  <= axis_ic_empty[2] & vfifo_idle[2];
    end  

    always @(posedge axi_str_rd_aclk_3)
    begin
      axis_ic_empty[3]  <= ((px_vf_rd_data_cnt_3 == 0) & ~axi_str_rd_tvalid_3);
      axis_vf_empty[3]  <= axis_ic_empty[3] & vfifo_idle[3];
    end

    //- timeout of 64 clock cycles to make sure both interconnect and vfifo
    //are empty
    always @(posedge axi_str_rd_aclk_0)
    begin
      if (~axis_vf_empty[0])
        to_cntr_0 <= 7'd0;
      else if (axis_vf_empty[0] & ~to_cntr_0[6])
        to_cntr_0 <= to_cntr_0 + 1'b1;
    end

    always @(posedge axi_str_rd_aclk_1)
    begin
      if (~axis_vf_empty[1])
        to_cntr_1 <= 7'd0;
      else if (axis_vf_empty[1] & ~to_cntr_1[6])
        to_cntr_1 <= to_cntr_1 + 1'b1;
    end

    always @(posedge axi_str_rd_aclk_2)
    begin
      if (~axis_vf_empty[2])
        to_cntr_2 <= 7'd0;
      else if (axis_vf_empty[2] & ~to_cntr_2[6])
        to_cntr_2 <= to_cntr_2 + 1'b1;
    end

    always @(posedge axi_str_rd_aclk_3)
    begin
      if (~axis_vf_empty[3])
        to_cntr_3 <= 7'd0;
      else if (axis_vf_empty[3] & ~to_cntr_3[6])
        to_cntr_3 <= to_cntr_3 + 1'b1;
    end

      assign ddr3_fifo_empty = {to_cntr_3[6], to_cntr_2[6], 
                                  to_cntr_1[6], to_cntr_0[6]};



endmodule
