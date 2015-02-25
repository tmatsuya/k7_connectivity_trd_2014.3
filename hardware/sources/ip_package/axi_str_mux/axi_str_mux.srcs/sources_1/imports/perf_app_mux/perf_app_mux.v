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

module perf_app_mux
(
input                            user_clk,
//input                            c2s0_axis_clk,
//input                            c2s1_axis_clk,
//input                            s2c0_axis_clk,
//input                            s2c1_axis_clk,
//input                            s2c0_app_clk,
//input                            s2c0_perf_clk,
//input                            s2c1_app_clk,
//input                            s2c1_perf_clk,
//input                            c2s0_app_clk,
//input                            c2s0_perf_clk,
//input                            c2s1_app_clk,
//input                            c2s1_perf_clk,
output                           axi_str_s2c0_tvalid_app,
output [127:0]                   axi_str_s2c0_tdata_app,
input                           axi_str_s2c0_tready_app,
output [15:0]                    axi_str_s2c0_tkeep_app,
output                           axi_str_s2c0_tlast_app,
output [1:0]                     axi_str_s2c0_tdest_app,


output                           axi_str_s2c1_tvalid_app,
output [127:0]                           axi_str_s2c1_tdata_app,
input                           axi_str_s2c1_tready_app,
output [15:0]                   axi_str_s2c1_tkeep_app,
output                           axi_str_s2c1_tlast_app,
output [1:0]                     axi_str_s2c1_tdest_app,


output                           axi_str_s2c0_tvalid_perf,
output [127:0]                          axi_str_s2c0_tdata_perf,
input                           axi_str_s2c0_tready_perf,
output [15:0]                   axi_str_s2c0_tkeep_perf,
output                           axi_str_s2c0_tlast_perf,
//output [63:0]                    axi_str_s2c0_tuser_perf,

output                           axi_str_s2c1_tvalid_perf,
output [127:0]                   axi_str_s2c1_tdata_perf,
input                            axi_str_s2c1_tready_perf,
output [15:0]                    axi_str_s2c1_tkeep_perf,
output                           axi_str_s2c1_tlast_perf,
//output [63:0]                    axi_str_s2c1_tuser_perf,

    output [63:0]                   axi_str_c2s0_tuser, 
    input                           axi_str_c2s0_tready, 
    output                          axi_str_c2s0_tvalid, 
    output [127:0]                  axi_str_c2s0_tdata, 
    output                          axi_str_c2s0_tlast, 
    output  [15:0]                  axi_str_c2s0_tkeep,
    
    output [63:0]                   axi_str_c2s1_tuser,
    input                           axi_str_c2s1_tready, 
    output                          axi_str_c2s1_tvalid, 
    output [127:0]                  axi_str_c2s1_tdata, 
    output                          axi_str_c2s1_tlast, 
    output [15:0]                   axi_str_c2s1_tkeep,

    input                           ch0_perf_mode_en,
    input                           ch1_perf_mode_en,
    

    output                          axi_str_c2s0_tready_app,
    input                           axi_str_c2s0_tvalid_app,
    input [127:0]                   axi_str_c2s0_tdata_app,
    input                           axi_str_c2s0_tlast_app,
    input [15:0]                    axi_str_c2s0_tkeep_app,
    
    output                          axi_str_c2s0_tready_perf,    
//    input [63:0]                    axi_str_c2s0_tuser_perf,
    input                           axi_str_c2s0_tvalid_perf,    
    input [127:0]                   axi_str_c2s0_tdata_perf,    
    input                           axi_str_c2s0_tlast_perf,    
    input [15:0]                    axi_str_c2s0_tkeep_perf,
    
    output                          axi_str_c2s1_tready_app,
    input                           axi_str_c2s1_tvalid_app,
    input [127:0]                   axi_str_c2s1_tdata_app,
    input                           axi_str_c2s1_tlast_app,
    input [15:0]                    axi_str_c2s1_tkeep_app,
    
    output                          axi_str_c2s1_tready_perf,    
  //  input [63:0]                    axi_str_c2s1_tuser_perf,
    input                           axi_str_c2s1_tvalid_perf,    
    input [127:0]                   axi_str_c2s1_tdata_perf,    
    input                           axi_str_c2s1_tlast_perf,    
    input [15:0]                    axi_str_c2s1_tkeep_perf,
        
    input                           axi_str_s2c0_tvalid,
    input  [127:0]                  axi_str_s2c0_tdata,
    output                          axi_str_s2c0_tready,
    input   [15:0]                  axi_str_s2c0_tkeep,
    input                           axi_str_s2c0_tlast,
    input   [63:0]                  axi_str_s2c0_tuser,
    
    input                           axi_str_s2c1_tvalid,
    input [127:0]                   axi_str_s2c1_tdata,
    output                          axi_str_s2c1_tready,
    input  [15:0]                   axi_str_s2c1_tkeep,
    input                           axi_str_s2c1_tlast,
    input   [63:0]                  axi_str_s2c1_tuser

);

  // - Multiplexed connection to DMA ports
  /*
   *  When performance mode operation is enabled, DMA ports are connected
   *  to the generator/checker modules otherwise, they are connected to the
   *  applications connected to the respective ports.
   */

  //- Do no write data to Virtual FIFO when GEN/CHK performance mode is
  //  enabled
  assign axi_str_s2c0_tvalid_app = ch0_perf_mode_en ? 1'b0 :
                                          axi_str_s2c0_tvalid;
  assign axi_str_s2c1_tvalid_app = ch1_perf_mode_en ? 1'b0 :
                                          axi_str_s2c1_tvalid;
  assign axi_str_s2c0_tdest_app = 2'b00;
  assign axi_str_s2c1_tdest_app = 2'b10;

  //- Disable data validity to checker when not in GEN/CHK performance mode
  assign axi_str_s2c0_tvalid_perf = ch0_perf_mode_en ? axi_str_s2c0_tvalid :
                                          1'b0;
  assign axi_str_s2c1_tvalid_perf = ch1_perf_mode_en ? axi_str_s2c1_tvalid :
                                          1'b0;
                                          
  assign  axi_str_s2c0_tdata_perf = axi_str_s2c0_tdata;           
  assign  axi_str_s2c0_tuser_perf = axi_str_s2c0_tuser; 
  assign  axi_str_s2c0_tkeep_perf = axi_str_s2c0_tkeep; 
  assign  axi_str_s2c0_tlast_perf = axi_str_s2c0_tlast;      
                
  assign  axi_str_s2c0_tdata_app = axi_str_s2c0_tdata;           
  assign  axi_str_s2c0_tkeep_app = axi_str_s2c0_tkeep; 
  assign  axi_str_s2c0_tlast_app = axi_str_s2c0_tlast;    
  
  assign  axi_str_s2c1_tdata_perf = axi_str_s2c1_tdata;           
  assign  axi_str_s2c1_tuser_perf = axi_str_s2c1_tuser; 
  assign  axi_str_s2c1_tkeep_perf = axi_str_s2c1_tkeep; 
  assign  axi_str_s2c1_tlast_perf = axi_str_s2c1_tlast;      
                
  assign  axi_str_s2c1_tdata_app = axi_str_s2c1_tdata;           
  assign  axi_str_s2c1_tkeep_app = axi_str_s2c1_tkeep; 
  assign  axi_str_s2c1_tlast_app = axi_str_s2c1_tlast;   
  
  assign axi_str_s2c0_tready  = ch0_perf_mode_en ? axi_str_s2c0_tready_perf :
                                  axi_str_s2c0_tready_app;              

  assign axi_str_c2s0_tuser = 64'd0 ;
  
  assign axi_str_s2c1_tready  = ch1_perf_mode_en ? axi_str_s2c1_tready_perf :
                                axi_str_s2c1_tready_app;

  assign axi_str_c2s0_tvalid  = ch0_perf_mode_en  ? axi_str_c2s0_tvalid_perf :
                                  axi_str_c2s0_tvalid_app;
  assign axi_str_c2s0_tdata   = ch0_perf_mode_en  ? axi_str_c2s0_tdata_perf :
                                  axi_str_c2s0_tdata_app;
  assign axi_str_c2s0_tlast   = ch0_perf_mode_en  ? axi_str_c2s0_tlast_perf :
                                  axi_str_c2s0_tlast_app;
  assign axi_str_c2s0_tkeep   = ch0_perf_mode_en  ? axi_str_c2s0_tkeep_perf :
                                  axi_str_c2s0_tkeep_app;

  assign axi_str_c2s0_tready_app = ch0_perf_mode_en  ? 1'b0 :
                                  axi_str_c2s0_tready;
                                 
  assign axi_str_c2s0_tready_perf = ch0_perf_mode_en  ? axi_str_c2s0_tready :
                                   1'b0;
                                  
  assign axi_str_c2s1_tuser = 64'd0 ;

  assign axi_str_c2s1_tvalid  = ch1_perf_mode_en  ? axi_str_c2s1_tvalid_perf :
                                  axi_str_c2s1_tvalid_app;
  assign axi_str_c2s1_tdata   = ch1_perf_mode_en  ? axi_str_c2s1_tdata_perf :
                                  axi_str_c2s1_tdata_app;
  assign axi_str_c2s1_tlast   = ch1_perf_mode_en  ? axi_str_c2s1_tlast_perf :
                                  axi_str_c2s1_tlast_app;
  assign axi_str_c2s1_tkeep   = ch1_perf_mode_en  ? axi_str_c2s1_tkeep_perf :
                                  axi_str_c2s1_tkeep_app;

  assign axi_str_c2s1_tready_app = ch0_perf_mode_en  ? 1'b0 :
                                  axi_str_c2s1_tready;
                                 
  assign axi_str_c2s1_tready_perf = ch0_perf_mode_en  ? axi_str_c2s1_tready :
                                   1'b0;


endmodule
