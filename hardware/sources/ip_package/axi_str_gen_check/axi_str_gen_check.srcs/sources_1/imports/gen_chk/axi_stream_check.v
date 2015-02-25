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

module axi_stream_check #(
    parameter CNT_WIDTH        =  20   ,
    parameter SEQ_END_CNT_WIDTH = 32   ,
    parameter AXIS_TDATA_WIDTH =  128  ,
    parameter NUM_BYTES        = AXIS_TDATA_WIDTH/8,
    parameter AXIS_TKEEP_WIDTH =  16   
)
(
    input                         enable_check,
    input  [CNT_WIDTH-1:0]        check_length,
    input  [SEQ_END_CNT_WIDTH-1:0]seq_end_cnt,
    input  [AXIS_TDATA_WIDTH-1:0] axi_stream_s2c_tdata,
    input  [AXIS_TKEEP_WIDTH-1:0] axi_stream_s2c_tkeep,
    input                         axi_stream_s2c_tvalid,
    input                         axi_stream_s2c_tlast,
    output                        axi_stream_s2c_tready,
    output reg                    error_flag,

    input                         user_clk,
    input                         reset   

);

  /************** Wire Declaration *******************/
  wire [AXIS_TDATA_WIDTH-1:0]   expected_data;

  /************** Reg Declaration *******************/
  reg  [AXIS_TDATA_WIDTH-1:0]   tx_data_c = 'b0;
  reg                           tx_data_valid_c = 'b0;
  reg  [AXIS_TKEEP_WIDTH-1:0]   tx_data_strobe_c;
  reg  [15:0]                   tx_pkt_length = 'b0;
  reg                           tx_data_last_c = 'b0;
  reg  [15:0]                   byte_cnt_c = 'b0;
  reg  [15:0]                   expected_tag_c = 'b0;
  reg  [15:0]                   next_expected_tag_c = 'b0;
  reg                           data_mismatch_0;
  reg                           data_mismatch_1;
  reg  [AXIS_TKEEP_WIDTH/2-1:0] i = 0;
  reg  [SEQ_END_CNT_WIDTH-1:0]  seq_end_cnt_r;


  // The Checker compares transmitted data against the expected data.
  // The expected data has the following pattern
  // The first DW (128 bits/16 bytes) of a packet carries 
  // the length info in the first 2 bytes and a 2 byte  
  // tag repeated seven times. All subsequent DW have the
  // the tag number repeated 8 times. 
  // The tag num increments by 1 from one packet to the
  // next
  
  assign expected_data = {AXIS_TKEEP_WIDTH/2{expected_tag_c}};
  
  always @ (posedge user_clk)
  begin
    tx_data_c         <= axi_stream_s2c_tdata;
    tx_data_valid_c   <= axi_stream_s2c_tvalid;
    tx_pkt_length     <= check_length;
    tx_data_strobe_c  <= axi_stream_s2c_tkeep;
    tx_data_last_c    <= axi_stream_s2c_tlast;
  end  

  always @ (posedge user_clk) begin
      seq_end_cnt_r <= seq_end_cnt;
  end
  
  // The data comparison is spilt over two processes to help with timing. 
  always @ (posedge user_clk) 
  begin
    if (!enable_check ) begin
        data_mismatch_0 <= 1'b0;
    end else if (tx_data_valid_c && byte_cnt_c == 0) begin
      if (tx_data_c[AXIS_TDATA_WIDTH/2-1:0] != {expected_data[AXIS_TDATA_WIDTH/2-1:16],tx_pkt_length}) begin
        data_mismatch_0 <= 1'b1;
      end    
    end else if (tx_data_valid_c && tx_data_last_c) begin
      for (i= 0; i <AXIS_TKEEP_WIDTH/2; i= i+1) begin  
        if (tx_data_strobe_c[i]  == 1 && tx_data_c[(i*8)+:8] != expected_data[(i*8)+:8]) begin
          data_mismatch_0 <= 1'b1; 
        end  
      end
    end else if (tx_data_valid_c) begin
      if (tx_data_c[AXIS_TDATA_WIDTH/2-1:0] != expected_data[AXIS_TDATA_WIDTH/2-1:0]) begin    
        data_mismatch_0 <= 1'b1;  
      end  
    end 
    
  end  
  
  always @ (posedge user_clk) 
  begin
    if (!enable_check) begin
        data_mismatch_1 <= 1'b0;
    end else if (tx_data_valid_c && tx_data_last_c) begin
      for (i= AXIS_TKEEP_WIDTH/2; i <AXIS_TKEEP_WIDTH; i= i+1) begin  
        if (tx_data_strobe_c[i]  == 1 && tx_data_c[(i*8)+:8] != expected_data[(i*8)+:8]) begin
          data_mismatch_1 <= 1'b1; 
        end  
      end
    end else if (tx_data_valid_c) begin
      if (tx_data_c[AXIS_TDATA_WIDTH-1:AXIS_TDATA_WIDTH/2] != expected_data[AXIS_TDATA_WIDTH-1:AXIS_TDATA_WIDTH/2]) begin    
        data_mismatch_1 <= 1'b1;  
      end  
    end 
    
  end  
  
  // data_mismatch is a sticky bit. The software polls this
  // register at regular intervals. 
  // This bit is set only when enable_check is 1
  always @ (posedge user_clk)
  begin
    error_flag <= 1'b0;
  end
  
  
  // Expected tag is updated at the end of a packet  
  always @ (posedge user_clk) 
  begin
    if (reset || !enable_check ) begin
      expected_tag_c <= 0;
      next_expected_tag_c <= 0;
    end else if (tx_data_valid_c && byte_cnt_c == 0 && tx_data_c[AXIS_TDATA_WIDTH-1:AXIS_TDATA_WIDTH-16]==seq_end_cnt_r-1) begin
      next_expected_tag_c <= 0;  
    end else if (tx_data_valid_c && byte_cnt_c == 0) begin
      next_expected_tag_c <= tx_data_c[AXIS_TDATA_WIDTH-1:AXIS_TDATA_WIDTH-16]+1;  
    end else if (tx_data_valid_c && tx_data_last_c) begin
      expected_tag_c <= next_expected_tag_c;  
    end  
  end  
  
  // Could use axi_stream_s2c_tlast to determine the start of
  // the next packet, but byte count allows to check
  // the actual payload length
  always @(posedge user_clk)
  begin
    if (reset == 1'b1 ) begin
      byte_cnt_c <= 0;
    end else if (tx_data_valid_c && byte_cnt_c == 0) begin
      byte_cnt_c <= tx_data_c[15:0] - AXIS_TKEEP_WIDTH;
    end else if (tx_data_valid_c && byte_cnt_c < AXIS_TKEEP_WIDTH) begin
      byte_cnt_c <= 0;
    end else if (tx_data_valid_c) begin
      byte_cnt_c <= byte_cnt_c - AXIS_TKEEP_WIDTH;
    end
  end

  assign axi_stream_s2c_tready=1'b1;


endmodule
