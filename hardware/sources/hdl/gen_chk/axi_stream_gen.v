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

module axi_stream_gen #(
    parameter CNT_WIDTH        =  20   ,
    parameter SEQ_END_CNT_WIDTH = 32   ,
    parameter AXIS_TDATA_WIDTH =  128  ,
    parameter NUM_BYTES        = AXIS_TDATA_WIDTH/8,
    parameter AXIS_TKEEP_WIDTH =  16   
)
(
    input                         enable_gen,
    input  [CNT_WIDTH-1:0]        gen_length,
    input  [SEQ_END_CNT_WIDTH-1:0]seq_end_cnt,
    output [AXIS_TDATA_WIDTH-1:0] axi_stream_c2s_tdata,
    output [AXIS_TKEEP_WIDTH-1:0] axi_stream_c2s_tkeep,
    output                        axi_stream_c2s_tvalid ,
    output                        axi_stream_c2s_tlast,
    input                         axi_stream_c2s_tready,

    input                         user_clk,
    input                         reset   

);

  /************** Wire Declaration *******************/
  wire [AXIS_TDATA_WIDTH-1:0]   generated_data;
  /************** Reg Declaration *******************/
  reg  [AXIS_TDATA_WIDTH-1:0]   rx_data_g = 'b0;
  reg                           rx_data_valid_g = 'b0;
  reg                           rx_data_last_g = 'b0;
  reg  [AXIS_TKEEP_WIDTH-1:0]   rx_data_strobe_g = 'b0;
  reg  [AXIS_TKEEP_WIDTH/2-1:0] invalid_bytes = 'b0;
  reg  [15:0]                   byte_cnt_g = 'b0;
  reg  [15:0]                   tag_g = 'b0;
  reg  [SEQ_END_CNT_WIDTH-1:0]  seq_end_cnt_r;
  
  //enumerated states
  parameter IDLE       = 1'b0;
  parameter GEN_PKT    = 1'b1;
  
  reg  cstate = 1'b0;
  reg  nstate = 1'b0;

  // The data generator follows the same data pattern as the checker.
  // It generates packets of a fixed length. This fixed length is gen_length
  // programmed by software
  always @ (posedge user_clk) begin
    if (reset == 1'b1)
      cstate <= IDLE;
    else 
      cstate <= nstate;
  end
  
  always @ (posedge user_clk) begin
      seq_end_cnt_r <= seq_end_cnt;
  end
   
  // if enable generator is set to 0 in a middle of the packet,
  // the generator completes the packet and then stops generating 
  // any more packets
  always@(cstate, enable_gen, byte_cnt_g, axi_stream_c2s_tready) begin
    case (cstate)
      IDLE: begin
        if (enable_gen && axi_stream_c2s_tready) begin
          nstate <= GEN_PKT;
        end else begin
          nstate <= IDLE;
        end
      end
  
      GEN_PKT: begin
        if (byte_cnt_g <= AXIS_TKEEP_WIDTH && axi_stream_c2s_tready) begin
          nstate <= IDLE;
        end else begin
          nstate <= GEN_PKT;
        end
      end
  
      default : begin
        nstate <= IDLE;
      end
  
    endcase
  end
  
  always @(posedge user_clk)
  begin
    if (rx_data_last_g  && !axi_stream_c2s_tready)
      byte_cnt_g <= byte_cnt_g;
    else if (cstate == IDLE) 
      byte_cnt_g <= gen_length - AXIS_TKEEP_WIDTH;
    else if (byte_cnt_g < AXIS_TKEEP_WIDTH && axi_stream_c2s_tready ) 
      byte_cnt_g <= 0;
    else if (axi_stream_c2s_tready) 
      byte_cnt_g <= byte_cnt_g - AXIS_TKEEP_WIDTH;
  end
  
  always @(posedge user_clk)
  begin
    if (rx_data_last_g  && !axi_stream_c2s_tready)
      rx_data_valid_g <= rx_data_valid_g;
    else if (cstate == IDLE && nstate != GEN_PKT) 
      rx_data_valid_g <= 1'b0;
    else 
      rx_data_valid_g <= 1'b1;
  end
  
  always @(posedge user_clk)
  begin
    if (!enable_gen && cstate == IDLE) 
      tag_g <= 0;
    else if (cstate == GEN_PKT && nstate == IDLE && tag_g ==seq_end_cnt_r-1) 
      tag_g <= 0;
    else if (cstate == GEN_PKT && nstate == IDLE) 
      tag_g <= tag_g + 1;
  end
  
  
  always @(posedge user_clk)
  begin
    if (cstate == IDLE) begin
      invalid_bytes <= AXIS_TKEEP_WIDTH - (gen_length % AXIS_TKEEP_WIDTH);
    end
    
    if (rx_data_last_g  && !axi_stream_c2s_tready)
      rx_data_strobe_g <= rx_data_strobe_g;
    else if (cstate == GEN_PKT && nstate == IDLE && invalid_bytes < AXIS_TKEEP_WIDTH) 
      rx_data_strobe_g <= {AXIS_TKEEP_WIDTH{1'b1}} >> invalid_bytes;
    else  
      rx_data_strobe_g <= {AXIS_TKEEP_WIDTH{1'b1}};
  end
  
  always @(posedge user_clk)
  begin
    if (rx_data_last_g  && !axi_stream_c2s_tready)
      rx_data_last_g <= rx_data_last_g;
    else if (cstate == GEN_PKT && nstate == IDLE) 
      rx_data_last_g <= 1;
    else  
      rx_data_last_g <= 0;
  end
  
  assign generated_data = {AXIS_TKEEP_WIDTH{tag_g}};
  
  always @(posedge user_clk)
  begin
    if (rx_data_last_g  && !axi_stream_c2s_tready)
      rx_data_g <= rx_data_g;
    else if (cstate == IDLE ) 
      rx_data_g <=  {generated_data[AXIS_TDATA_WIDTH-1:16],gen_length};
    else if (axi_stream_c2s_tready)  
      rx_data_g <=  {AXIS_TKEEP_WIDTH{tag_g}};
  end
  
  
  
  // Data source for receive data is either looped back 
  // transmit data or data from the generator.
  assign  axi_stream_c2s_tdata  =  rx_data_g; 
  
  assign  axi_stream_c2s_tvalid =  rx_data_valid_g;
  
  assign  axi_stream_c2s_tkeep  =  rx_data_strobe_g; 
  
  assign  axi_stream_c2s_tlast  =  rx_data_last_g; 
  
endmodule
