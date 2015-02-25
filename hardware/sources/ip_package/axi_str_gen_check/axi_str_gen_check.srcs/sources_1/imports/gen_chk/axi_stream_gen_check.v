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

`timescale 1ps / 1ps

module axi_stream_gen_check #(
    parameter CNT_WIDTH          =  20 ,
    parameter SEQ_END_CNT_WIDTH  =  32 ,
    parameter AXIS_TDATA_WIDTH   =  128,
    parameter AXIS_TKEEP_WIDTH   =  16
)
(
   
    input                             enable_loopback,
    input                             enable_gen,
    input                             enable_check,
    input [CNT_WIDTH-1:0]             gen_length,
    input [CNT_WIDTH-1:0]             check_length,
    input [SEQ_END_CNT_WIDTH-1:0]     seq_end_cnt,
    input [AXIS_TDATA_WIDTH-1:0]      axi_stream_s2c_tdata,
    input [AXIS_TKEEP_WIDTH-1:0]      axi_stream_s2c_tkeep,
    input                             axi_stream_s2c_tvalid,
    input                             axi_stream_s2c_tlast,
    output                            axi_stream_s2c_tready,
    output  [AXIS_TDATA_WIDTH-1:0]    axi_stream_c2s_tdata,
    output  [AXIS_TKEEP_WIDTH-1:0]    axi_stream_c2s_tkeep,
    output                            axi_stream_c2s_tvalid,
    output                            axi_stream_c2s_tlast,
    input                             axi_stream_c2s_tready,
    output                            error_flag,

    input                             s_axis_s2c_aclk,
    input                             s_axis_c2s_aclk,
    input                             s_axis_s2c_areset_n,    
    input                             s_axis_c2s_areset_n         

);

  wire [AXIS_TDATA_WIDTH-1:0]     axi_stream_c2s_tdata_i;
  wire [AXIS_TKEEP_WIDTH-1:0]     axi_stream_c2s_tkeep_i;
  wire                            axi_stream_c2s_tlast_i;
  wire                            axi_stream_c2s_tvalid_i;
  wire                            axi_stream_c2s_tready_i;
 

    //If enable_loopback is asserted, connect s2c data from DMA back to c2s
    //Otherwise axi_stream_gen block drives the data in the c2s direction while
    //enable_gen is asserted. The generator block also handles tready throttling from DMA
    //In the s2c direction, data is monitored by the check block when enable_check
    //is asserted 
    assign user_clk=s_axis_s2c_aclk;
    
    assign reset=~s_axis_s2c_areset_n;
    
    assign axi_stream_c2s_tdata = enable_loopback ? axi_stream_s2c_tdata :
                                      axi_stream_c2s_tdata_i;
    assign axi_stream_c2s_tvalid = enable_loopback ? axi_stream_s2c_tvalid :
                                      axi_stream_c2s_tvalid_i;
    assign axi_stream_c2s_tlast = enable_loopback ? axi_stream_s2c_tlast :
                                      axi_stream_c2s_tlast_i;
    assign axi_stream_c2s_tkeep = enable_loopback ? axi_stream_s2c_tkeep :
                                      axi_stream_c2s_tkeep_i;
    assign axi_stream_s2c_tready = enable_loopback ? axi_stream_c2s_tready :
                                      axi_stream_c2s_tready_i;
    
    //Instantiate axi_stream_gen and axi_stream_check modules
    
    axi_stream_gen # (
          .CNT_WIDTH        (CNT_WIDTH        ),
          .SEQ_END_CNT_WIDTH(SEQ_END_CNT_WIDTH),
          .AXIS_TDATA_WIDTH (AXIS_TDATA_WIDTH ),
          .AXIS_TKEEP_WIDTH (AXIS_TKEEP_WIDTH )
    ) axi_stream_gen_i (
          .enable_gen            (enable_gen             ),
          .gen_length            (gen_length             ),
          .seq_end_cnt           (seq_end_cnt            ),
          .axi_stream_c2s_tready (axi_stream_c2s_tready  ),
          .axi_stream_c2s_tdata  (axi_stream_c2s_tdata_i ),
          .axi_stream_c2s_tkeep  (axi_stream_c2s_tkeep_i ),
          .axi_stream_c2s_tvalid (axi_stream_c2s_tvalid_i),
          .axi_stream_c2s_tlast  (axi_stream_c2s_tlast_i ),
          .user_clk              (user_clk               ),
          .reset                 (reset                  )
    );

             
    axi_stream_check # (
          .CNT_WIDTH        (CNT_WIDTH       ),
          .AXIS_TDATA_WIDTH (AXIS_TDATA_WIDTH),
          .AXIS_TKEEP_WIDTH (AXIS_TKEEP_WIDTH)
    ) axi_stream_check_i (
          .enable_check           (enable_check           ),
          .check_length           (check_length           ),  
          .seq_end_cnt            (seq_end_cnt            ),
          .axi_stream_s2c_tready  (axi_stream_c2s_tready_i),
          .axi_stream_s2c_tdata   (axi_stream_s2c_tdata   ),
          .axi_stream_s2c_tkeep   (axi_stream_s2c_tkeep   ),
          .axi_stream_s2c_tvalid  (axi_stream_s2c_tvalid  ),
          .axi_stream_s2c_tlast   (axi_stream_s2c_tlast   ),
          .error_flag             (error_flag             ),
          .user_clk               (user_clk               ),
          .reset                  (reset                  )
    );


endmodule
