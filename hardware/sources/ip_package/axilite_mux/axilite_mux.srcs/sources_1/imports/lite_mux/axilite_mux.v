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

module axilite_mux
(
input [15:0]  w_strb_in,
input [127:0] w_data_in,
input         ar_valid_in,
input         ar_ready_in,
input [31:0]  ar_addr_in,
input         user_clk,
input[31:0]   r_data_in,
output[127:0] r_data_out ,
output[31:0]  w_data_out

);

  reg [3:0] rd_addr_nibble = 4'd0;
  
    //- Extract out valid write data based on strobe
  assign w_data_out = w_strb_in[0] ? w_data_in[31:0] :
                  w_strb_in[4] ? w_data_in[63:32] :
                  w_strb_in[8] ? w_data_in[95:64] :
                  w_data_in[127:96];

    //- Latch onto the read address lowest nibble
  always @(posedge user_clk)
    if (ar_valid_in & ar_ready_in)
      rd_addr_nibble  <= ar_addr_in[3:0];

    //- Place the read 32-bit data into the appropriate 128-bit r_data_in
    //  location based on address nibble latched above
  assign r_data_out = (rd_addr_nibble == 4'hC) ? {r_data_in,96'd0} :
                            (rd_addr_nibble == 4'h8) ? {32'd0,r_data_in,64'd0} :
                            (rd_addr_nibble == 4'h4) ? {64'd0,r_data_in,32'd0} :
                            {96'd0,r_data_in};


endmodule
