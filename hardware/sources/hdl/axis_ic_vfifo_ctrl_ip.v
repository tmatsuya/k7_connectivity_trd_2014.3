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
// File       : axis_ic_vfifo_ctrl_ip.v
//
//-----------------------------------------------------------------------------
//
(* CORE_GENERATION_INFO = "k7_connectivity_trd,k7_connectivity_trd_v1_4,{VENDOR_ID=16'h10EE,CORE_DATA_WIDTH=128,NUM_LANES=8}" *)
module axis_ic_vfifo_ctrl_ip #(
  parameter AXIS_TDATA_WIDTH          = 128,
  parameter AXI_MIG_DATA_WIDTH        = 512,
  parameter AWIDTH                    = 32,
  parameter DWIDTH                    = AXIS_TDATA_WIDTH,
  parameter NUM_PORTS                 = 4,
  parameter ID_WIDTH                  = 2,
  parameter CNTWIDTH                  = 32
  )(
    // DDR3 ports
    output [13:0]                  ddr_addr,             
    output reg                     calib_done = 1'b0,
`ifdef KC705_PVTMON
    input [11:0]                   device_temp,
`endif
    input                          axi_ic_mig_shim_rst_n, 
    input                          clk_ref_p,
    input                          clk_ref_n,

    output [2:0]                   ddr_ba,               
    output                         ddr_cas_n,            
    output                         ddr_ck_p,               
    output                         ddr_ck_n,             
    output                         ddr_cke,              
    output                         ddr_cs_n,             
    output [7:0]                   ddr_dm,               
    inout  [63:0]                  ddr_dq,               
    inout  [7:0]                   ddr_dqs_p,              
    inout  [7:0]                   ddr_dqs_n,            
    output                         ddr_odt,              
    output                         ddr_ras_n,            
    output                         ddr_reset_n,          
    output                         ddr_we_n,             
    
   output                           mcb_clk, 
   output                           mcb_rst,
   // AXI streaming Interface for Write port 
   input  [NUM_PORTS-1:0]              axi_str_wr_tlast,
   input  [(AXIS_TDATA_WIDTH*NUM_PORTS)-1:0]     axi_str_wr_tdata,
   input  [NUM_PORTS-1:0]              axi_str_wr_tvalid,
   input  [(AXIS_TDATA_WIDTH/8*NUM_PORTS)-1:0]  axi_str_wr_tkeep,
   output [NUM_PORTS-1:0]              axi_str_wr_tready,
   input  [NUM_PORTS-1:0]              axi_str_wr_aclk, 

   // AXI streaming Interface for Read port 
   output [NUM_PORTS-1:0]              axi_str_rd_tlast,
   output [(DWIDTH*NUM_PORTS)-1:0]     axi_str_rd_tdata,
   output [NUM_PORTS-1:0]              axi_str_rd_tvalid,
   output [(DWIDTH/8*NUM_PORTS)-1:0]   axi_str_rd_tkeep,
   input  [NUM_PORTS-1:0]              axi_str_rd_tready,
   input  [NUM_PORTS-1:0]              axi_str_rd_aclk, 
    
   input  [NUM_PORTS-1:0]              wr_reset_n, 
   input  [NUM_PORTS-1:0]              rd_reset_n, 
   output [NUM_PORTS-1:0]              ddr3_fifo_empty,
   input                               user_reset

);

  // ----------------
  // -- Parameters --
  // ----------------
  
  localparam  AXI_VFIFO_DATA_WIDTH    = AXIS_TDATA_WIDTH;

wire [CNTWIDTH-1:0] px_vf_rd_data_cnt_0;
wire [CNTWIDTH-1:0] px_vf_rd_data_cnt_1;
wire [CNTWIDTH-1:0] px_vf_rd_data_cnt_2;
wire [CNTWIDTH-1:0] px_vf_rd_data_cnt_3;
wire [CNTWIDTH-1:0] px_vf_wr_data_cnt [NUM_PORTS-1:0];
wire [15:0]         px_rd_tuser [NUM_PORTS-1:0];
wire [AXIS_TDATA_WIDTH-1:0]   px_str_rd_tdata [NUM_PORTS-1:0];
wire [(AXIS_TDATA_WIDTH/8)-1:0]   px_str_rd_tkeep [NUM_PORTS-1:0];
wire [AXIS_TDATA_WIDTH-1:0]   px_str_wr_tdata [NUM_PORTS-1:0];
wire [15:0]   px_str_wr_tuser [NUM_PORTS-1:0];
wire [(AXIS_TDATA_WIDTH/8)-1:0]   px_str_wr_tkeep [NUM_PORTS-1:0];

  wire                  axis_wr_mux_tvalid;
  wire                  axis_wr_mux_tready;
  wire                  axis_wr_mux_tlast;
  wire [1:0]            axis_wr_mux_tdest;
  wire [63:0]           axis_wr_mux_tkeep;
  wire [511:0]          axis_wr_mux_tdata;

  wire                  axis_rd_mux_tvalid;
  wire                  axis_rd_mux_tready;
  wire                  axis_rd_mux_tlast;
  wire [1:0]            axis_rd_mux_tdest;
  wire [63:0]           axis_rd_mux_tkeep;
  wire [511:0]          axis_rd_mux_tdata;

wire [31:0]                             s_axi_awaddr;
wire [7:0]                              s_axi_awlen;
wire [2:0]                              s_axi_awsize;
wire [1:0]                              s_axi_awburst;
wire [0:0]                              s_axi_awlock;
wire [3:0]                              s_axi_awcache;
wire [2:0]                              s_axi_awprot;
wire [3:0]                              s_axi_awqos;
wire                                    s_axi_awvalid;
wire                                    s_axi_awready;
wire [AXI_MIG_DATA_WIDTH-1:0]           s_axi_wdata;
wire [AXI_MIG_DATA_WIDTH/8-1:0]         s_axi_wstrb;
wire                                    s_axi_wlast;
wire                                    s_axi_wvalid;
wire                                    s_axi_wready;
wire [1:0]                              s_axi_bresp;
wire                                    s_axi_bvalid;
wire                                    s_axi_bready;
wire [31:0]                             s_axi_araddr;
wire [7:0]                              s_axi_arlen;
wire [2:0]                              s_axi_arsize;
wire [1:0]                              s_axi_arburst;
wire [0:0]                              s_axi_arlock;
wire [3:0]                              s_axi_arcache;
wire [2:0]                              s_axi_arprot;
wire [3:0]                              s_axi_arqos;
wire                                    s_axi_arvalid;
wire                                    s_axi_arready;
wire [AXI_MIG_DATA_WIDTH-1:0]           s_axi_rdata;
wire [1:0]                              s_axi_rresp;
wire                                    s_axi_rlast;
wire                                    s_axi_rvalid;
wire                                    s_axi_rready;
wire [ID_WIDTH-1:0]                     s_axi_awid;
wire [ID_WIDTH-1:0]                     s_axi_arid;
wire [ID_WIDTH-1:0]                     s_axi_bid;
wire [ID_WIDTH-1:0]                     s_axi_rid;

wire [NUM_PORTS-1:0]                    vfifo_idle;
wire    vf_s2mm_overrun;
reg [NUM_PORTS-1:0] vfifo_mm2s_channel_full_250;
reg [NUM_PORTS-1:0] vfifo_mm2s_channel_full_200_d1;
reg [NUM_PORTS-1:0] vfifo_mm2s_channel_full;
wire  calib_done_i;
wire  ic_reset;
genvar ii;
genvar jj;
genvar i;

wire [NUM_PORTS-1:0] vfifo_s2mm_channel_full;
reg [NUM_PORTS-1:0] vfifo_s2mm_channel_full_reg;

wire axi_ic_mig_shim_rst_n_sync;

 //- thresholds set based on read port FIFO depth chosen
 /*
  * For ports #0 and #2, read port has deeper packet mode FIFO enabled 
  * for connection to XGEMAC; port #1 and #3 have normal shallow FIFO
  */
  always @(posedge axi_str_rd_aclk[0])
    vfifo_mm2s_channel_full_250[0] <= (px_vf_rd_data_cnt_0 > 32'h0180) ? 1'b1
                                      : 1'b0;

  always @(posedge axi_str_rd_aclk[1])
    vfifo_mm2s_channel_full_250[1] <= (px_vf_rd_data_cnt_1 > 32'h00B0) ? 1'b1
                                      : 1'b0;

  always @(posedge axi_str_rd_aclk[2])
    vfifo_mm2s_channel_full_250[2] <= (px_vf_rd_data_cnt_2 > 32'h0180) ? 1'b1
                                      : 1'b0;

  always @(posedge axi_str_rd_aclk[3])
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
    calib_done  <= calib_done_i;

  synchronizer_simple #(.DATA_WIDTH (1)) sync_to_user_clk_1
  (
    .data_in          (axi_ic_mig_shim_rst_n),
    .new_clk          (mcb_clk),
    .data_out         (axi_ic_mig_shim_rst_n_sync)
  );


  assign ic_reset = calib_done & axi_ic_mig_shim_rst_n_sync;

generate
  begin: assign_output
    for (ii = 0; ii<NUM_PORTS; ii=ii+1)
    begin
  
    assign axi_str_rd_tdata[((AXIS_TDATA_WIDTH*ii)+(AXIS_TDATA_WIDTH-1)) : AXIS_TDATA_WIDTH*ii] = px_str_rd_tdata[ii];
    assign axi_str_rd_tkeep[(((AXIS_TDATA_WIDTH/8)*ii)+((AXIS_TDATA_WIDTH/8)-1)) : (AXIS_TDATA_WIDTH/8)*ii] = px_str_rd_tkeep[ii];

    end
  end
endgenerate

generate
  begin: assign_input
    for (jj=0; jj<NUM_PORTS; jj=jj+1)
    begin
    assign px_str_wr_tdata[jj] = axi_str_wr_tdata[((AXIS_TDATA_WIDTH*jj)+(AXIS_TDATA_WIDTH-1)) : (AXIS_TDATA_WIDTH*jj)];
    assign px_str_wr_tkeep[jj] = axi_str_wr_tkeep[(((AXIS_TDATA_WIDTH/8)*jj)+((AXIS_TDATA_WIDTH/8)-1)) : ((AXIS_TDATA_WIDTH/8)*jj)];
    end
  end
endgenerate


  //- Instance of 4x1 Write Stream interconnect
  axis_ic_4x1_wr  axis_ic_4x1_wr_inst (
      .ACLK (mcb_clk),
      .ARESETN (ic_reset),
      //.ACLKEN (1'b1),
      .S00_AXIS_ACLK (axi_str_wr_aclk[0]),
      .S01_AXIS_ACLK (axi_str_wr_aclk[1]),
      .S02_AXIS_ACLK (axi_str_wr_aclk[2]),
      .S03_AXIS_ACLK (axi_str_wr_aclk[3]),
      .S00_AXIS_ARESETN (wr_reset_n[0]),
      .S01_AXIS_ARESETN (wr_reset_n[1]),
      .S02_AXIS_ARESETN (wr_reset_n[2]),
      .S03_AXIS_ARESETN (wr_reset_n[3]),
      //.S00_AXIS_ACLKEN (1'b1),
      //.S01_AXIS_ACLKEN (1'b1),
      //.S02_AXIS_ACLKEN (1'b1),
      //.S03_AXIS_ACLKEN (1'b1),
      .S00_AXIS_TVALID (axi_str_wr_tvalid[0]),
      .S01_AXIS_TVALID (axi_str_wr_tvalid[1]),
      .S02_AXIS_TVALID (axi_str_wr_tvalid[2]),
      .S03_AXIS_TVALID (axi_str_wr_tvalid[3]),
      .S00_AXIS_TREADY (axi_str_wr_tready[0]),
      .S01_AXIS_TREADY (axi_str_wr_tready[1]),
      .S02_AXIS_TREADY (axi_str_wr_tready[2]),
      .S03_AXIS_TREADY (axi_str_wr_tready[3]),
      .S00_AXIS_TDATA (px_str_wr_tdata[0]),
      .S01_AXIS_TDATA (px_str_wr_tdata[1]),
      .S02_AXIS_TDATA (px_str_wr_tdata[2]),
      .S03_AXIS_TDATA (px_str_wr_tdata[3]),
      .S00_AXIS_TKEEP (px_str_wr_tkeep[0]),
      .S01_AXIS_TKEEP (px_str_wr_tkeep[1]),
      .S02_AXIS_TKEEP (px_str_wr_tkeep[2]),
      .S03_AXIS_TKEEP (px_str_wr_tkeep[3]),
      .S00_AXIS_TLAST (axi_str_wr_tlast[0]),
      .S01_AXIS_TLAST (axi_str_wr_tlast[1]),
      .S02_AXIS_TLAST (axi_str_wr_tlast[2]),
      .S03_AXIS_TLAST (axi_str_wr_tlast[3]),
      .S00_AXIS_TDEST (2'b00),
      .S01_AXIS_TDEST (2'b01),
      .S02_AXIS_TDEST (2'b10),
      .S03_AXIS_TDEST (2'b11),
      .S00_FIFO_DATA_COUNT  (px_vf_wr_data_cnt[0]),
      .S01_FIFO_DATA_COUNT  (px_vf_wr_data_cnt[1]),
      .S02_FIFO_DATA_COUNT  (px_vf_wr_data_cnt[2]),
      .S03_FIFO_DATA_COUNT  (px_vf_wr_data_cnt[3]),
      .S00_ARB_REQ_SUPPRESS(vfifo_s2mm_channel_full_reg[0]),
      .S01_ARB_REQ_SUPPRESS(vfifo_s2mm_channel_full_reg[1]),
      .S02_ARB_REQ_SUPPRESS(vfifo_s2mm_channel_full_reg[2]),
      .S03_ARB_REQ_SUPPRESS(vfifo_s2mm_channel_full_reg[3]),
      .M00_AXIS_ACLK (mcb_clk),
      //.M00_AXIS_ACLKEN (1'b1),
      .M00_AXIS_ARESETN (ic_reset),
      .M00_AXIS_TVALID (axis_wr_mux_tvalid),
      .M00_AXIS_TREADY (axis_wr_mux_tready),
      .M00_AXIS_TDATA (axis_wr_mux_tdata),
      .M00_AXIS_TKEEP (axis_wr_mux_tkeep),
      .M00_AXIS_TLAST (axis_wr_mux_tlast),
      .M00_AXIS_TDEST (axis_wr_mux_tdest)
  );

  //- Instance of 1x4 Read Stream Interconnect
  axis_ic_1x4_rd  axis_ic_1x4_rd_inst (
      .ACLK (mcb_clk),
      .ARESETN (ic_reset),
      //.ACLKEN (1'b1),
      .S00_AXIS_ACLK (mcb_clk),
      .S00_AXIS_ARESETN (ic_reset), //calib_done & axi_ic_mig_shim_rst_n),
      //.S00_AXIS_ACLKEN (1'b1),
      .S00_AXIS_TVALID (axis_rd_mux_tvalid),
      .S00_AXIS_TREADY (axis_rd_mux_tready),
      .S00_AXIS_TDATA (axis_rd_mux_tdata),
      .S00_AXIS_TKEEP (axis_rd_mux_tkeep),
      .S00_AXIS_TLAST (axis_rd_mux_tlast),
      .S00_AXIS_TDEST (axis_rd_mux_tdest),
      .M00_AXIS_ACLK (axi_str_rd_aclk[0]),
      .M01_AXIS_ACLK (axi_str_rd_aclk[1]),
      .M02_AXIS_ACLK (axi_str_rd_aclk[2]),
      .M03_AXIS_ACLK (axi_str_rd_aclk[3]),
      .M00_AXIS_ARESETN (rd_reset_n[0]),
      .M01_AXIS_ARESETN (rd_reset_n[1]),
      .M02_AXIS_ARESETN (rd_reset_n[2]),
      .M03_AXIS_ARESETN (rd_reset_n[3]),
      //.M00_AXIS_ACLKEN (1'b1),
      //.M01_AXIS_ACLKEN (1'b1),
      //.M02_AXIS_ACLKEN (1'b1),
      //.M03_AXIS_ACLKEN (1'b1),
      .M00_AXIS_TVALID (axi_str_rd_tvalid[0]),
      .M01_AXIS_TVALID (axi_str_rd_tvalid[1]),
      .M02_AXIS_TVALID (axi_str_rd_tvalid[2]),
      .M03_AXIS_TVALID (axi_str_rd_tvalid[3]),
      .M00_AXIS_TREADY (axi_str_rd_tready[0]),
      .M01_AXIS_TREADY (axi_str_rd_tready[1]),
      .M02_AXIS_TREADY (axi_str_rd_tready[2]),
      .M03_AXIS_TREADY (axi_str_rd_tready[3]),
      .M00_AXIS_TDATA (px_str_rd_tdata[0]),
      .M01_AXIS_TDATA (px_str_rd_tdata[1]),
      .M02_AXIS_TDATA (px_str_rd_tdata[2]),
      .M03_AXIS_TDATA (px_str_rd_tdata[3]),
      .M00_AXIS_TLAST (axi_str_rd_tlast[0]),
      .M01_AXIS_TLAST (axi_str_rd_tlast[1]),
      .M02_AXIS_TLAST (axi_str_rd_tlast[2]),
      .M03_AXIS_TLAST (axi_str_rd_tlast[3]),
      .M00_AXIS_TKEEP (px_str_rd_tkeep[0]),
      .M01_AXIS_TKEEP (px_str_rd_tkeep[1]),
      .M02_AXIS_TKEEP (px_str_rd_tkeep[2]),
      .M03_AXIS_TKEEP (px_str_rd_tkeep[3]),
      .M00_FIFO_DATA_COUNT  (px_vf_rd_data_cnt_0),
      .M01_FIFO_DATA_COUNT  (px_vf_rd_data_cnt_1),
      .M02_FIFO_DATA_COUNT  (px_vf_rd_data_cnt_2),
      .M03_FIFO_DATA_COUNT  (px_vf_rd_data_cnt_3)
      //.S00_ARB_REQ_SUPPRESS(1'b0)
  );

  //- Instance of AXI-VFIFO Controller
  axi_vfifo_ctrl_ip axi_vfifo_ctrl_inst (
      .aclk (mcb_clk),
      .aresetn (ic_reset),
      .s_axis_tvalid (axis_wr_mux_tvalid),
      .s_axis_tready (axis_wr_mux_tready),
      .s_axis_tdata (axis_wr_mux_tdata),
      .s_axis_tkeep (axis_wr_mux_tkeep),
      .s_axis_tstrb ({64{1'b1}}),
      .s_axis_tlast (axis_wr_mux_tlast),
      .s_axis_tid   (2'b00),
      .s_axis_tdest (axis_wr_mux_tdest),
      .m_axis_tvalid (axis_rd_mux_tvalid),
      .m_axis_tready (axis_rd_mux_tready),
      .m_axis_tdata (axis_rd_mux_tdata),
      .m_axis_tstrb (),
      .m_axis_tkeep (axis_rd_mux_tkeep),
      .m_axis_tlast (axis_rd_mux_tlast),
      .m_axis_tid (),
      .m_axis_tdest (axis_rd_mux_tdest),

      .m_axi_awid (s_axi_awid),
      .m_axi_awaddr (s_axi_awaddr),
      .m_axi_awlen (s_axi_awlen),
      .m_axi_awsize (s_axi_awsize),
      .m_axi_awburst (s_axi_awburst),
      .m_axi_awlock (s_axi_awlock),
      .m_axi_awcache (s_axi_awcache),
      .m_axi_awprot (s_axi_awprot),
      .m_axi_awqos (s_axi_awqos),
      .m_axi_awregion (),
      .m_axi_awuser (),
      .m_axi_awvalid (s_axi_awvalid),
      .m_axi_awready (s_axi_awready),
      .m_axi_wdata (s_axi_wdata),
      .m_axi_wstrb (s_axi_wstrb),
      .m_axi_wuser (),
      .m_axi_wlast (s_axi_wlast),
      .m_axi_wvalid (s_axi_wvalid),
      .m_axi_wready (s_axi_wready),
      .m_axi_bid (s_axi_bid),
      .m_axi_bresp (s_axi_bid),
      .m_axi_buser (1'b0),
      .m_axi_bvalid (s_axi_bvalid),
      .m_axi_bready (s_axi_bready),
      .m_axi_arid (s_axi_arid),
      .m_axi_araddr (s_axi_araddr),
      .m_axi_arlen (s_axi_arlen),
      .m_axi_arsize (s_axi_arsize),
      .m_axi_arburst (s_axi_arburst),
      .m_axi_arlock (s_axi_arlock),
      .m_axi_arcache (s_axi_arcache),
      .m_axi_arprot (s_axi_arprot),
      .m_axi_arqos (s_axi_arqos),
      .m_axi_arregion (),
      .m_axi_aruser (),
      .m_axi_arvalid (s_axi_arvalid),
      .m_axi_arready (s_axi_arready),
      .m_axi_rid (s_axi_rid),
      .m_axi_rdata (s_axi_rdata),
      .m_axi_rresp (s_axi_rresp),
      .m_axi_ruser (1'b0),
      .m_axi_rlast (s_axi_rlast),
      .m_axi_rvalid (s_axi_rvalid),
      .m_axi_rready (s_axi_rready),
      .vfifo_s2mm_channel_full (vfifo_s2mm_channel_full),
      .vfifo_mm2s_channel_full (vfifo_mm2s_channel_full),
      .vfifo_mm2s_rresp_err_intr  (),
      .vfifo_s2mm_bresp_err_intr  (),
      .vfifo_s2mm_overrun_err_intr  (vf_s2mm_overrun),
      .vfifo_mm2s_channel_empty (),
      .vfifo_idle (vfifo_idle)
    );

  //- Figure out all empty

    localparam TIMEOUT_CYCLE  = 64;

    reg [NUM_PORTS-1:0] axis_ic_empty;
    reg [NUM_PORTS-1:0] axis_vf_empty;

    reg [6:0]   to_cntr_0;
    reg [6:0]   to_cntr_1;
    reg [6:0]   to_cntr_2;
    reg [6:0]   to_cntr_3;

    always @(posedge axi_str_rd_aclk[0])
    begin
      axis_ic_empty[0]  <= ((px_vf_rd_data_cnt_0 == 0) & ~axi_str_rd_tvalid[0]);
      axis_vf_empty[0]  <= axis_ic_empty[0] & vfifo_idle[0];
    end

    always @(posedge axi_str_rd_aclk[1])
    begin
      axis_ic_empty[1]  <= ((px_vf_rd_data_cnt_1 == 0) & ~axi_str_rd_tvalid[1]);
      axis_vf_empty[1]  <= axis_ic_empty[1] & vfifo_idle[1];
    end  

    always @(posedge axi_str_rd_aclk[2])
    begin
      axis_ic_empty[2]  <= ((px_vf_rd_data_cnt_2 == 0) & ~axi_str_rd_tvalid[2]);
      axis_vf_empty[2]  <= axis_ic_empty[2] & vfifo_idle[2];
    end  

    always @(posedge axi_str_rd_aclk[3])
    begin
      axis_ic_empty[3]  <= ((px_vf_rd_data_cnt_3 == 0) & ~axi_str_rd_tvalid[3]);
      axis_vf_empty[3]  <= axis_ic_empty[3] & vfifo_idle[3];
    end

    //- timeout of 64 clock cycles to make sure both interconnect and vfifo
    //are empty
    always @(posedge axi_str_rd_aclk[0])
    begin
      if (~axis_vf_empty[0])
        to_cntr_0 <= 7'd0;
      else if (axis_vf_empty[0] & ~to_cntr_0[6])
        to_cntr_0 <= to_cntr_0 + 1'b1;
    end

    always @(posedge axi_str_rd_aclk[1])
    begin
      if (~axis_vf_empty[1])
        to_cntr_1 <= 7'd0;
      else if (axis_vf_empty[1] & ~to_cntr_1[6])
        to_cntr_1 <= to_cntr_1 + 1'b1;
    end

    always @(posedge axi_str_rd_aclk[2])
    begin
      if (~axis_vf_empty[2])
        to_cntr_2 <= 7'd0;
      else if (axis_vf_empty[2] & ~to_cntr_2[6])
        to_cntr_2 <= to_cntr_2 + 1'b1;
    end

    always @(posedge axi_str_rd_aclk[3])
    begin
      if (~axis_vf_empty[3])
        to_cntr_3 <= 7'd0;
      else if (axis_vf_empty[3] & ~to_cntr_3[6])
        to_cntr_3 <= to_cntr_3 + 1'b1;
    end

      assign ddr3_fifo_empty = {to_cntr_3[6], to_cntr_2[6], 
                                  to_cntr_1[6], to_cntr_0[6]};


  //- Instance of MIG - DDR3 controller
mig_axi_mm #(
 
) mig_inst (
  .ui_clk                                (mcb_clk               ),
  .ui_clk_sync_rst                       (mcb_rst               ),
  .ddr3_addr                             (ddr_addr              ),
  .ddr3_ba                               (ddr_ba                ),
  .ddr3_cas_n                            (ddr_cas_n             ),
  .ddr3_ck_p                             (ddr_ck_p              ),
  .ddr3_ck_n                             (ddr_ck_n              ),
  .ddr3_cke                              (ddr_cke               ),
  .ddr3_cs_n                             (ddr_cs_n              ),
  .ddr3_dm                               (ddr_dm                ),
  .ddr3_odt                              (ddr_odt               ),
  .ddr3_ras_n                            (ddr_ras_n             ),
  .ddr3_reset_n                          (ddr_reset_n           ),
  .ddr3_we_n                             (ddr_we_n              ),
  .ddr3_dq                               (ddr_dq                ),
  .ddr3_dqs_p                            (ddr_dqs_p             ),
  .ddr3_dqs_n                            (ddr_dqs_n             ),
  //.clk_ref_p                             (clk_ref_p             ),
  //.clk_ref_n                             (clk_ref_n             ),
  .sys_clk_p                             (clk_ref_p             ),
  .sys_clk_n                             (clk_ref_n             ),
  .app_sr_active                         (), 
  .app_ref_ack                           (),
  .app_zq_ack                            (),
  .sys_rst                               (user_reset),
  .init_calib_complete                   (calib_done_i            ),   
  .app_sr_req                            (1'b0),
  .app_ref_req                           (1'b0),
  .app_zq_req                            (1'b0),
`ifdef KC705_PVTMON  
    //- Disable use of XADC in MIG
  .device_temp_i                         (device_temp           ), 
`endif  
  .aresetn                               (ic_reset),  //calib_done & axi_ic_mig_shim_rst_n ),
  .s_axi_awid                            (s_axi_awid            ),
  .s_axi_awaddr                          (s_axi_awaddr          ),
  .s_axi_awlen                           (s_axi_awlen           ),
  .s_axi_awsize                          (s_axi_awsize          ),
  .s_axi_awburst                         (s_axi_awburst         ),
  .s_axi_awlock                          (s_axi_awlock          ),
  .s_axi_awcache                         (s_axi_awcache         ),
  .s_axi_awprot                          (s_axi_awprot          ),
  .s_axi_awqos                           (s_axi_awqos           ),
  .s_axi_awvalid                         (s_axi_awvalid         ),
  .s_axi_awready                         (s_axi_awready         ),
  .s_axi_wdata                           (s_axi_wdata           ),
  .s_axi_wstrb                           (s_axi_wstrb           ),
  .s_axi_wlast                           (s_axi_wlast           ),
  .s_axi_wvalid                          (s_axi_wvalid          ),
  .s_axi_wready                          (s_axi_wready          ),
  .s_axi_bid                             (s_axi_bid             ),
  .s_axi_bresp                           (s_axi_bresp           ),
  .s_axi_bvalid                          (s_axi_bvalid          ),
  .s_axi_bready                          (s_axi_bready          ),
  .s_axi_arid                            (s_axi_arid            ),
  .s_axi_araddr                          (s_axi_araddr          ),
  .s_axi_arlen                           (s_axi_arlen           ),
  .s_axi_arsize                          (s_axi_arsize          ),
  .s_axi_arburst                         (s_axi_arburst         ),
  .s_axi_arlock                          (s_axi_arlock          ),
  .s_axi_arcache                         (s_axi_arcache         ),
  .s_axi_arprot                          (s_axi_arprot          ),
  .s_axi_arqos                           (s_axi_arqos           ),
  .s_axi_arvalid                         (s_axi_arvalid         ),
  .s_axi_arready                         (s_axi_arready         ),
  .s_axi_rid                             (s_axi_rid             ),
  .s_axi_rdata                           (s_axi_rdata           ),
  .s_axi_rresp                           (s_axi_rresp           ),
  .s_axi_rlast                           (s_axi_rlast           ),
  .s_axi_rvalid                          (s_axi_rvalid          ),
  .s_axi_rready                          (s_axi_rready          )
); 

endmodule
