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
//


`timescale 1ps / 1ps

module  k7_conn_pci_dma #
(
    parameter CORE_DATA_WIDTH = 128,
    parameter  CORE_BE_WIDTH = 16,
    parameter AXIS_TDATA_WIDTH=128,
    parameter AXIS_TKEEP_WIDTH=16
 )   

  (
      // PCI Express slot PERST# reset signal
    input                          perst_n,      
      // PCIe differential reference clock input
    input                          ref_clk,   
      // PCIe differential transmit output
    output  [7:0]        tx_p,         
    output  [7:0]        tx_n,         
      // PCIe differential receive output
    input   [7:0]        rx_p,         
    input   [7:0]        rx_n,     
//        input                          axi4lite_s_clk, 
//        input                          axi_str_c2s0_clk, 
//        input                          axi_str_c2s1_clk, 
//        input                          axi_str_s2c0_clk, 
//        input                          axi_str_s2c1_clk, 
  output [31:0]                           axi4lite_s_awaddr,
  output                                  axi4lite_s_awvalid,
  input                                   axi4lite_s_awready,
  output [31:0]                           axi4lite_s_wdata,
  output [3:0]                            axi4lite_s_wstrb,
  output                                  axi4lite_s_wvalid,
  input                                   axi4lite_s_wready,
  input                                   axi4lite_s_bvalid,
  output                                  axi4lite_s_bready,
  input [1:0]                             axi4lite_s_bresp,
  output [31:0]                           axi4lite_s_araddr,
  input                                   axi4lite_s_arready,
  output                                  axi4lite_s_arvalid,
  input [31:0]                            axi4lite_s_rdata,
  input [1:0]                             axi4lite_s_rresp,
  output                                  axi4lite_s_rready,
  input                                   axi4lite_s_rvalid,

  output    [63:0]                        axi_str_s2c0_tuser,      
  output                                  axi_str_s2c0_tlast,              
  output    [AXIS_TDATA_WIDTH-1:0]        axi_str_s2c0_tdata,             
  output    [AXIS_TKEEP_WIDTH-1:0]        axi_str_s2c0_tkeep,
  output                                  axi_str_s2c0_tvalid,          
  input                                  axi_str_s2c0_tready,         
  output                                  axi_str_s2c0_aresetn,

   input     [63:0]                        axi_str_c2s0_tuser,      
  input                                  axi_str_c2s0_tlast,              
   input   [AXIS_TDATA_WIDTH-1:0]        axi_str_c2s0_tdata,             
   input   [AXIS_TKEEP_WIDTH-1:0]        axi_str_c2s0_tkeep,
    input                                axi_str_c2s0_tvalid,          
     output                               axi_str_c2s0_tready,          
     output                               axi_str_c2s0_aresetn,

  output    [63:0]                        axi_str_s2c1_tuser,      
  output                                  axi_str_s2c1_tlast,              
   output   [AXIS_TDATA_WIDTH-1:0]        axi_str_s2c1_tdata,             
   output   [AXIS_TKEEP_WIDTH-1:0]        axi_str_s2c1_tkeep,
   output                                 axi_str_s2c1_tvalid,          
    input                                axi_str_s2c1_tready,          
   output                                 axi_str_s2c1_aresetn,

    input  [63:0]                        axi_str_c2s1_tuser,      
    input                                axi_str_c2s1_tlast,              
   input   [AXIS_TDATA_WIDTH-1:0]        axi_str_c2s1_tdata,             
   input   [AXIS_TKEEP_WIDTH-1:0]        axi_str_c2s1_tkeep,
    input                                axi_str_c2s1_tvalid,          
     output                               axi_str_c2s1_tready,          
     output                               axi_str_c2s1_aresetn,

    output  [2:0]                         pl_initial_link_width,
     output [1:0]                         pl_lane_reversal_mode,
      output                              pl_link_gen2_capable,
       output                             pl_link_partner_gen2_supported,
     output                               pl_link_upcfg_capable,
    output  [5:0]                         pl_ltssm_state,

    input                                pl_directed_link_auton,
    input  [1:0]                         pl_directed_link_change,
     input                               pl_directed_link_speed,
    input  [1:0]                         pl_directed_link_width,
     output                               pl_sel_lnk_rate,
     output [1:0]                         pl_sel_lnk_width,

    output [11:0]                        fc_cpld,
    output [7:0]                         fc_cplh,
    output [11:0]                        fc_npd,
    output [7:0]                         fc_nph,
    output [11:0]                        fc_pd,
    output [7:0]                         fc_ph,
    input [2:0]                         fc_sel,

   // - PCIe-AXI TX interface
   output [CORE_DATA_WIDTH-1:0]    s_axis_tx_tdata_mon,
   output                 s_axis_tx_tlast_mon,
   output                 s_axis_tx_tvalid_mon,
   inout              s_axis_tx_tready_mon,
   output [3:0]           s_axis_tx_tuser_mon,
   
   // - PCIe-AXI RX interface
   output [CORE_DATA_WIDTH-1:0]    m_axis_rx_tdata_mon,
   output                 m_axis_rx_tlast_mon,
   output                 m_axis_rx_tvalid_mon,
   inout                m_axis_rx_tready_mon,
   output [21:0]          m_axis_rx_tuser_mon,

//  input                                        pipe_pclk_in,
//  input  [7:0]                                 pipe_rxusrclk_in,
//  input                                        pipe_rxoutclk_in,
//  input                                        pipe_dclk_in,
//  input                                        pipe_oobclk_in,
//  input                                        pipe_userclk1_in,
//  input                                        pipe_userclk2_in,
//  input                                        pipe_mmcm_lock_in,

//  output                                        pipe_txoutclk_out,
//  output                                        pipe_rxoutclk_out,
//  output                                        pipe_pclk_sel_out,
//  output                                        pipe_gen3_out,

  output                                          user_clk,
  output                                          user_lnk_up,
  output                                          user_reset_out,
  output    [15:0]                                cfg_lstatus,
  output    [7:0]                                 clk_period_in_ns,
  input                                           user_reset,
    output    [2:0]                               cfg_pcie_link_state
  );



  // ----------------
  // -- Parameters --
  // ----------------

  localparam  CORE_REMAIN_WIDTH       = 4;

  
    //- PCIe specific parameters
  localparam  PCIE_EXT_CLK            = "TRUE";  
  localparam  VENDOR_ID               = 16'h10EE; 
  localparam  DEVICE_ID               = 16'h7082; // K7, x8, Gen2,
  localparam  DEVICE_SN               = 64'h0;
 
  localparam  C_FAMILY  = "kintex7";

// -------------------
// -- Local Signals --
// -------------------

// Xilinx Hard Core Instantiation

  wire                                  user_lnk_up_c;

  wire   [5:0]                          tx_buf_av;
  wire                                  tx_err_drop;
  wire                                  tx_cfg_req;
  wire                                  s_axis_tx_tready;
  wire   [AXIS_TDATA_WIDTH-1:0]         s_axis_tx_tdata;
  wire   [AXIS_TKEEP_WIDTH-1:0]         s_axis_tx_tkeep;
  wire   [3:0]                          s_axis_tx_tuser;
  wire                                  s_axis_tx_tlast;
  wire                                  s_axis_tx_tvalid;
  wire                                  tx_cfg_gnt;

  wire   [AXIS_TDATA_WIDTH-1:0]         m_axis_rx_tdata;
  wire   [AXIS_TKEEP_WIDTH-1:0]         m_axis_rx_tkeep;
  wire                                  m_axis_rx_tlast;
  wire                                  m_axis_rx_tvalid;
  wire                                  m_axis_rx_tready;
  wire   [21:0]                         m_axis_rx_tuser;
  wire                                  rx_np_ok;
  wire                                  rx_np_req;

  wire    [11:0]                        fc_cpld;
  wire    [7:0]                         fc_cplh;
  wire    [11:0]                        fc_npd;
  wire    [7:0]                         fc_nph;
  wire    [11:0]                        fc_pd;
  wire    [7:0]                         fc_ph;
  wire    [2:0]                         fc_sel;

  wire    [31:0]                        cfg_do;
  wire                                  cfg_rd_wr_done;
  wire    [31:0]                        cfg_di;
  wire    [3:0]                         cfg_byte_en;
  wire    [9:0]                         cfg_dwaddr;
  wire                                  cfg_wr_en;
  wire                                  cfg_rd_en;
  
  wire                                  cfg_err_cor;
  wire                                  cfg_err_ur;
  wire                                  cfg_err_ecrc;
  wire                                  cfg_err_cpl_timeout;
  wire                                  cfg_err_cpl_abort;
  wire                                  cfg_err_cpl_unexpect;
  wire                                  cfg_err_posted;
  wire                                  cfg_err_locked;
  wire    [47:0]                        cfg_err_tlp_cpl_header;
  wire                                  cfg_err_cpl_rdy;

  wire                                  cfg_interrupt;
  wire                                  cfg_interrupt_rdy;
  wire                                  cfg_interrupt_assert;
  wire    [7:0]                         cfg_interrupt_di;
  wire    [7:0]                         cfg_interrupt_do;
  wire    [2:0]                         cfg_interrupt_mmenable;
  wire                                  cfg_interrupt_msienable;
  wire                                  cfg_interrupt_msixenable;
  wire                                  cfg_interrupt_msixfm;

  wire                                  cfg_turnoff_ok;
  wire                                  cfg_to_turnoff;
  wire                                  cfg_trn_pending;
  wire                                  cfg_pm_wake;

  wire    [7:0]                         cfg_bus_number;
  wire    [4:0]                         cfg_device_number;
  wire    [2:0]                         cfg_function_number;
  wire    [15:0]                        cfg_status;
  wire    [15:0]                        cfg_command;
  wire    [15:0]                        cfg_dstatus;
  wire    [15:0]                        cfg_dcommand;
  wire    [15:0]                        cfg_lcommand;
  wire    [15:0]                        cfg_dcommand2;

  wire    [63:0]                        cfg_dsn;

  wire    [1:0]                         cfg_pmcsr_powerstate;
  wire                                  cfg_err_aer_headerlog_set;
  wire                                  cfg_aer_ecrc_check_en;
  wire                                  cfg_aer_ecrc_gen_en; 
  

reg pipe_mmcm_rst_n = 1'b1;

// Register to improve timing
//FDCP #(

//  .INIT     (1'b1           )

//) user_lnk_up_int_i (

//    .Q      (user_lnk_up    ),
  //  .D      (user_lnk_up_c  ),
 //   .C      (user_clk       ),
 //   .CLR    (1'b0           ),
 //   .PRE    (1'b0           )

//);

  assign tx_cfg_gnt = 1'b1;

 assign    s_axis_tx_tdata_mon=s_axis_tx_tdata;
 assign                s_axis_tx_tlast_mon=s_axis_tx_tlast;
 assign                s_axis_tx_tvalid_mon=s_axis_tx_tvalid;
 assign                s_axis_tx_tready_mon=s_axis_tx_tready;
 assign           s_axis_tx_tuser_mon=s_axis_tx_tuser;

 assign    m_axis_rx_tdata_mon=m_axis_rx_tdata;
 assign                m_axis_rx_tlast_mon=m_axis_rx_tlast;
 assign                m_axis_rx_tvalid_mon=m_axis_rx_tvalid;
 assign                m_axis_rx_tready_mon=m_axis_rx_tready;
 assign          m_axis_rx_tuser_mon=m_axis_rx_tuser;

  /********* SHIM FOR TARGET AXI to AXI-LITE connection ***********/

    //- This shim enabless the 128-bit target AXI master to connect to
    //- 32-bit AXILITE interconnect
    //- All register operations issued by software are read-modify-write
    //- operations i.e. access to all bits of one entire register 

    /*
      In case of writes, it puts the appropriate 32-bit data slice based on
      value of wstrb. 
          wstrb         wdata bit locations
          ---------------------------------
          [0] = 1       [31:0]
          [4] = 1       [63:32]
          [8] = 1       [95:64]
          [12] = 1      [127:96]
          ---------------------------------
          
      In case of reads, it places the 32-bit read data value in the
      appropriate segment in the 128-bit read data bus based on the read
      address' lowest nibble value.
          araddr[3:0]     rdata segment
          -----------------------------
           4'b0000          [31:0]
           4'b0100          [63:32]
           4'b1000          [95:64]
           4'b1100          [127:96]
          -----------------------------
     */

  wire [127:0] rdata, wdata;
  reg [3:0] rd_addr_nibble = 4'd0;
  
    //- Extract out valid write data based on strobe
  assign axi4lite_s_wdata = axi4lite_s_wstrb[0] ? wdata[31:0] :
                  axi4lite_s_wstrb[4] ? wdata[63:32] :
                  axi4lite_s_wstrb[8] ? wdata[95:64] :
                  wdata[127:96];

    //- Latch onto the read address lowest nibble
  always @(posedge user_clk)
    if (axi4lite_s_arvalid & axi4lite_s_arready)
      rd_addr_nibble  <= axi4lite_s_araddr[3:0];

    //- Place the read 32-bit data into the appropriate 128-bit rdata
    //  location based on address nibble latched above
  assign rdata = (rd_addr_nibble == 4'hC) ? {axi4lite_s_rdata,96'd0} :
                            (rd_addr_nibble == 4'h8) ? {32'd0,axi4lite_s_rdata,64'd0} :
                            (rd_addr_nibble == 4'h4) ? {64'd0,axi4lite_s_rdata,32'd0} :
                            {96'd0,axi4lite_s_rdata};

pcie_x8gen2_axi_st_ip pcie_inst (

    // -------------------------------
    // PCI Express (pci_exp) Interface
    // -------------------------------

    // Tx
    .pci_exp_txp                    (tx_p                           ), 
    .pci_exp_txn                    (tx_n                           ), 

    // Rx
    .pci_exp_rxp                    (rx_p                           ), 
    .pci_exp_rxn                    (rx_n                           ), 
  //----------------------------------------------------------------------------------------------------------------//
  // 2. Clocking Interface - For Partial Reconfig Support                                                           //
  //----------------------------------------------------------------------------------------------------------------//
  .pipe_pclk_in                              ( pipe_pclk_in ),
  .pipe_rxusrclk_in                          ( pipe_rxusrclk_in ),
  .pipe_rxoutclk_in                          ( pipe_rxoutclk_in ),
  .pipe_dclk_in                              ( pipe_dclk_in ),
  .pipe_userclk1_in                          ( pipe_userclk1_in ),
  .pipe_userclk2_in                          ( pipe_userclk2_in ),
  .pipe_oobclk_in                            ( pipe_oobclk_in),
  .pipe_mmcm_lock_in                         ( pipe_mmcm_lock_in ),

  .pipe_txoutclk_out                         ( pipe_txoutclk_out ),
  .pipe_rxoutclk_out                         ( pipe_rxoutclk_out ),
  .pipe_pclk_sel_out                         ( pipe_pclk_sel_out ),
  .pipe_gen3_out                             ( pipe_gen3_out ),

    // ---------------------------
    // Transaction (TRN) Interface
    // ---------------------------

    // Common
    .user_clk_out                   (user_clk                       ),
    .user_reset_out                 (user_reset_out                   ),
    .user_lnk_up                    (user_lnk_up_c                  ),

    // Tx
    .tx_buf_av                      (tx_buf_av                      ), 
    .tx_err_drop                    (tx_err_drop                    ), 
    .tx_cfg_req                     (tx_cfg_req                     ), 
    .s_axis_tx_tready               (s_axis_tx_tready               ),
    .s_axis_tx_tdata                (s_axis_tx_tdata                ),
    .s_axis_tx_tkeep                (s_axis_tx_tkeep                ),
    .s_axis_tx_tuser                (s_axis_tx_tuser                ),
    .s_axis_tx_tlast                (s_axis_tx_tlast                ),
    .s_axis_tx_tvalid               (s_axis_tx_tvalid               ),
    .tx_cfg_gnt                     (tx_cfg_gnt                     ), 

    // Rx
    .m_axis_rx_tdata                (m_axis_rx_tdata                ), 
    .m_axis_rx_tkeep                (m_axis_rx_tkeep                ),
    .m_axis_rx_tlast                (m_axis_rx_tlast                ), 
    .m_axis_rx_tvalid               (m_axis_rx_tvalid               ), 
    .m_axis_rx_tready               (m_axis_rx_tready               ), 
    .m_axis_rx_tuser                (m_axis_rx_tuser                ), 
    .rx_np_ok                       (rx_np_ok                       ),
    .rx_np_req                      (rx_np_req                      ), 

    // Flow Control
    .fc_cpld                        (fc_cpld                        ), 
    .fc_cplh                        (fc_cplh                        ), 
    .fc_npd                         (fc_npd                         ), 
    .fc_nph                         (fc_nph                         ), 
    .fc_pd                          (fc_pd                          ), 
    .fc_ph                          (fc_ph                          ), 
    .fc_sel                         (fc_sel                         ), 

    // -----------------------------
    // Configuration (CFG) Interface
    // -----------------------------

    .cfg_mgmt_do                    (cfg_do                         ), 
    .cfg_mgmt_rd_wr_done            (cfg_rd_wr_done                 ), 
    
    .cfg_status                     (cfg_status                     ), 
    .cfg_command                    (cfg_command                    ), 
    .cfg_dstatus                    (cfg_dstatus                    ), 
    .cfg_dcommand                   (cfg_dcommand                   ), 
    .cfg_lstatus                    (cfg_lstatus                    ), 
    .cfg_lcommand                   (cfg_lcommand                   ), 
    .cfg_dcommand2                  (cfg_dcommand2                  ), 
    .cfg_pcie_link_state            (cfg_pcie_link_state            ), 

    .cfg_pmcsr_pme_en               (                               ), 
    .cfg_pmcsr_powerstate           (                               ), 
    .cfg_pmcsr_pme_status           (                               ), 
    .cfg_received_func_lvl_rst      (                               ), 
    .cfg_mgmt_di                    (cfg_di                         ), 
    .cfg_mgmt_byte_en               (cfg_byte_en                    ), 
    .cfg_mgmt_dwaddr                (cfg_dwaddr                     ), 
    .cfg_mgmt_wr_en                 (cfg_wr_en                      ), 
    .cfg_mgmt_rd_en                 (cfg_rd_en                      ), 
    .cfg_mgmt_wr_readonly           (1'b0                           ),

    .cfg_err_ecrc                   (cfg_err_ecrc                   ), 
    .cfg_err_ur                     (cfg_err_ur                     ), 
    .cfg_err_cpl_timeout            (cfg_err_cpl_timeout            ), 
    .cfg_err_cpl_abort              (cfg_err_cpl_abort              ), 
    .cfg_err_cpl_unexpect           (cfg_err_cpl_unexpect           ), 
    .cfg_err_posted                 (cfg_err_posted                 ), 
    .cfg_err_cor                    (cfg_err_cor                    ), 
    .cfg_err_atomic_egress_blocked  (1'b0                           ),
    .cfg_err_internal_cor           (1'b0                           ),
    .cfg_err_malformed              (1'b0                           ),
    .cfg_err_mc_blocked             (1'b0                           ),
    .cfg_err_poisoned               (1'b0                           ),
    .cfg_err_norecovery             (1'b0                           ),
    .cfg_err_tlp_cpl_header         (cfg_err_tlp_cpl_header         ), 
    .cfg_err_cpl_rdy                (cfg_err_cpl_rdy                ), 
    .cfg_err_locked                 (cfg_err_locked                 ), 
    .cfg_err_acs                    (1'b0                           ),
    .cfg_err_internal_uncor         (1'b0                           ),
    .cfg_trn_pending                (cfg_trn_pending                ), 
    .cfg_pm_halt_aspm_l0s           (1'b0                           ),
    .cfg_pm_halt_aspm_l1            (1'b0                           ),
    .cfg_pm_force_state_en          (1'b0                           ),
    .cfg_pm_force_state             (2'b00                          ),
    .cfg_dsn                        (cfg_dsn                        ),
    
    .cfg_interrupt                  (cfg_interrupt                  ), 
    .cfg_interrupt_rdy              (cfg_interrupt_rdy              ), 
    .cfg_interrupt_assert           (cfg_interrupt_assert           ), 
    .cfg_interrupt_di               (cfg_interrupt_di               ), 
    .cfg_interrupt_do               (cfg_interrupt_do               ),
    .cfg_interrupt_mmenable         (cfg_interrupt_mmenable         ),
    .cfg_interrupt_msienable        (cfg_interrupt_msienable        ),
    .cfg_interrupt_msixenable       (cfg_interrupt_msixenable       ),
    .cfg_interrupt_msixfm           (cfg_interrupt_msixfm           ),
    .cfg_interrupt_stat             (1'b0                           ),
    .cfg_pciecap_interrupt_msgnum   (5'b00000                       ),
    

    .cfg_to_turnoff                 (cfg_to_turnoff                 ),
    .cfg_turnoff_ok                 (cfg_turnoff_ok                 ),
    .cfg_bus_number                 (cfg_bus_number                 ),
    .cfg_device_number              (cfg_device_number              ),
    .cfg_function_number            (cfg_function_number            ),
    .cfg_pm_wake                    (cfg_pm_wake                    ), 

    //- RP specific signals
    .cfg_pm_send_pme_to   (1'b0),
    .cfg_ds_bus_number    (8'd0),
    .cfg_ds_device_number (5'd0),
    .cfg_ds_function_number         (3'd0),
    .cfg_mgmt_wr_rw1c_as_rw         (1'b0                           ),
    .cfg_msg_received (),
    .cfg_msg_data (),
    .cfg_bridge_serr_en (),
    .cfg_slot_control_electromech_il_ctl_pulse  (),
    .cfg_root_control_syserr_corr_err_en  (),
    .cfg_root_control_syserr_non_fatal_err_en  (),
    .cfg_root_control_syserr_fatal_err_en  (),
    .cfg_root_control_pme_int_en  (),
    
    .cfg_aer_rooterr_corr_err_reporting_en  (),
    .cfg_aer_rooterr_non_fatal_err_reporting_en  (),
    .cfg_aer_rooterr_fatal_err_reporting_en  (),
    .cfg_aer_rooterr_corr_err_received  (),
    .cfg_aer_rooterr_non_fatal_err_received  (),
    .cfg_aer_rooterr_fatal_err_received  (),

    .cfg_msg_received_err_cor  (),
    .cfg_msg_received_err_non_fatal (),
    .cfg_msg_received_err_fatal  (),
    .cfg_msg_received_pm_as_nak (),
    .cfg_msg_received_pme_to_ack  (),
    .cfg_msg_received_assert_int_a (),
    .cfg_msg_received_assert_int_b (),
    .cfg_msg_received_assert_int_c (),
    .cfg_msg_received_assert_int_d (),
    .cfg_msg_received_deassert_int_a (),
    .cfg_msg_received_deassert_int_b (),
    .cfg_msg_received_deassert_int_c (),
    .cfg_msg_received_deassert_int_d (),
    // ------------------------------------------------
    // Physical Layer Control and Status (PL) Interface
    // ------------------------------------------------

    .pl_directed_link_change        (pl_directed_link_change        ), 
    .pl_directed_link_width         (pl_directed_link_width         ), 
    .pl_directed_link_speed         (pl_directed_link_speed         ), 
    .pl_directed_link_auton         (pl_directed_link_auton         ), 
    .pl_upstream_prefer_deemph      (pl_upstream_prefer_deemph      ), 

    .pl_sel_lnk_rate                (pl_sel_lnk_rate                ),
    .pl_sel_lnk_width               (pl_sel_lnk_width               ),
    .pl_ltssm_state                 (pl_ltssm_state                 ),  
    .pl_lane_reversal_mode          (pl_lane_reversal_mode          ),  
    .pl_phy_lnk_up                  (),
    .pl_tx_pm_state                 (                               ), 
    .pl_rx_pm_state                 (                               ), 
    .pl_link_upcfg_cap              (pl_link_upcfg_capable          ), 
    .pl_link_gen2_cap               (pl_link_gen2_capable           ), 
    .pl_link_partner_gen2_supported (pl_link_partner_gen2_supported ), 
    .pl_initial_link_width          (pl_initial_link_width          ),  
    .pl_directed_change_done        (                               ), 
    
    .pl_received_hot_rst            (            ),      
    .pl_transmit_hot_rst            (1'b0),
    .pl_downstream_deemph_source    (1'b0),

    //-------------------------------------------------------
    // 5. AER Interface
    //-------------------------------------------------------

    .cfg_err_aer_headerlog          (128'h0                         ),
    .cfg_aer_interrupt_msgnum       (5'b00000                       ),
    .cfg_err_aer_headerlog_set      (cfg_err_aer_headerlog_set      ),
    .cfg_aer_ecrc_check_en          (cfg_aer_ecrc_check_en          ),
    .cfg_aer_ecrc_gen_en            (cfg_aer_ecrc_gen_en            ),
    .cfg_vc_tcvc_map                (                               ),
    // -----------------------
    // System  (SYS) Interface
    // -----------------------


    .pipe_mmcm_rst_n                (pipe_mmcm_rst_n                ),    
    .sys_clk                        (ref_clk                        ), 
    
    .sys_rst_n                      (perst_n                      )  


);

// ---------------------------------
// Physical Layer Control and Status
assign pl_upstream_prefer_deemph    = 1'b1;

// -------------------------------
// Device Serial Number Capability

assign cfg_dsn                      = DEVICE_SN;

//+++++++++++++++++++++++++++++++++++++++++++++++++++

// -------------------------
// Packet DMA Instance
// -------------------------

    // always use 250 MHz for GEN2
    assign clk_period_in_ns = 8'h4; 

  assign rx_np_req = 1'b1;

packet_dma_axi # (
    .CORE_DATA_WIDTH               (AXIS_TDATA_WIDTH              ),
    .CORE_BE_WIDTH                 (AXIS_TDATA_WIDTH/8) 
) packet_dma_axi_inst (

    .user_reset                     (user_reset                     ),
    .user_clk                       (user_clk                       ),
    .user_lnk_up                    (user_lnk_up                    ),
    .clk_period_in_ns               (clk_period_in_ns               ),

    .user_interrupt                 (1'b0                           ), 

    // Tx
    .s_axis_tx_tready               (s_axis_tx_tready               ),  
    .s_axis_tx_tdata                (s_axis_tx_tdata                ),  
    .s_axis_tx_tkeep                (s_axis_tx_tkeep                ),  
    .s_axis_tx_tuser                (s_axis_tx_tuser                ),  
    .s_axis_tx_tlast                (s_axis_tx_tlast                ), 
    .s_axis_tx_tvalid               (s_axis_tx_tvalid               ), 
    .tx_buf_av                      (tx_buf_av                      ), 
    .tx_err_drop                    (tx_err_drop                    ), 

    // Rx
    .m_axis_rx_tdata                (m_axis_rx_tdata                ), 
    .m_axis_rx_tkeep                (m_axis_rx_tkeep                ), 
    .m_axis_rx_tlast                (m_axis_rx_tlast                ), 
    .m_axis_rx_tvalid               (m_axis_rx_tvalid               ), 
    .m_axis_rx_tready               (m_axis_rx_tready               ),   
    .m_axis_rx_tuser                (m_axis_rx_tuser                ), 
    .rx_np_ok                       (rx_np_ok                       ), 

    // Flow Control
    .fc_cpld                        (fc_cpld                        ), 
    .fc_cplh                        (fc_cplh                        ), 
    .fc_npd                         (fc_npd                         ), 
    .fc_nph                         (fc_nph                         ), 
    .fc_pd                          (fc_pd                          ), 
    .fc_ph                          (fc_ph                          ), 
    .fc_sel                         (fc_sel                         ), 
    
    .cfg_mgmt_di                    (cfg_di                         ), 
    .cfg_mgmt_byte_en               (cfg_byte_en                    ), 
    .cfg_mgmt_dwaddr                (cfg_dwaddr                     ), 
    .cfg_mgmt_wr_en                 (cfg_wr_en                      ), 
    .cfg_mgmt_rd_en                 (cfg_rd_en                      ), 

    .cfg_err_cor                    (cfg_err_cor                    ), 
    .cfg_err_ur                     (cfg_err_ur                     ), 
    .cfg_err_ecrc                   (cfg_err_ecrc                   ), 
    .cfg_err_cpl_timeout            (cfg_err_cpl_timeout            ), 
    .cfg_err_cpl_abort              (cfg_err_cpl_abort              ), 
    .cfg_err_cpl_unexpect           (cfg_err_cpl_unexpect           ), 
    .cfg_err_posted                 (cfg_err_posted                 ), 
    .cfg_err_locked                 (cfg_err_locked                 ), 
    .cfg_err_tlp_cpl_header         (cfg_err_tlp_cpl_header         ), 
    .cfg_err_cpl_rdy                (cfg_err_cpl_rdy                ), 

    .cfg_interrupt                  (cfg_interrupt                  ), 
    .cfg_interrupt_rdy              (cfg_interrupt_rdy              ), 
    .cfg_interrupt_assert           (cfg_interrupt_assert           ), 
    .cfg_interrupt_di               (cfg_interrupt_di               ), 
    .cfg_interrupt_do               (cfg_interrupt_do               ), 
    .cfg_interrupt_mmenable         (cfg_interrupt_mmenable         ), 
    .cfg_interrupt_msienable        (cfg_interrupt_msienable        ),  
    .cfg_interrupt_msixenable       (cfg_interrupt_msixenable       ), 
    .cfg_interrupt_msixfm           (cfg_interrupt_msixfm           ), 

    .cfg_turnoff_ok                 (cfg_turnoff_ok                 ), 
    .cfg_to_turnoff                 (cfg_to_turnoff                 ), 
    .cfg_trn_pending                (cfg_trn_pending                ), 
    .cfg_pm_wake                    (cfg_pm_wake                    ), 

    .cfg_bus_number                 (cfg_bus_number                 ), 
    .cfg_device_number              (cfg_device_number              ), 
    .cfg_function_number            (cfg_function_number            ), 
    .cfg_status                     (cfg_status                     ), 
    .cfg_command                    (cfg_command                    ), 
    .cfg_dstatus                    (cfg_dstatus                    ), 
    .cfg_dcommand                   (cfg_dcommand                   ), 
    .cfg_lstatus                    (cfg_lstatus                    ), 
    .cfg_lcommand                   (cfg_lcommand                   ), 
    .cfg_dcommand2                  (cfg_dcommand2                  ), 
    .cfg_pcie_link_state            (cfg_pcie_link_state            ), 

    //- AXI-ST S2C-0
    .s2c0_aclk                      (user_clk                       ),
    .s2c0_tvalid                    (axi_str_s2c0_tvalid            ),
    .s2c0_tready                    (axi_str_s2c0_tready            ),
    .s2c0_tlast                     (axi_str_s2c0_tlast             ),
    .s2c0_tdata                     (axi_str_s2c0_tdata             ),
    .s2c0_tkeep                     (axi_str_s2c0_tkeep             ),
    .s2c0_tuser                     (axi_str_s2c0_tuser             ),
    .s2c0_areset_n                  (axi_str_s2c0_aresetn           ),  
      //- AXI-ST C2S-0
    .c2s0_aclk                      (user_clk                       ),  
    .c2s0_tvalid                    (axi_str_c2s0_tvalid            ),
    .c2s0_tready                    (axi_str_c2s0_tready            ),
    .c2s0_tlast                     (axi_str_c2s0_tlast             ),
    .c2s0_tdata                     (axi_str_c2s0_tdata             ),
    .c2s0_tkeep                     (axi_str_c2s0_tkeep             ),
    .c2s0_tuser                     (axi_str_c2s0_tuser             ),
    .c2s0_areset_n                  (axi_str_c2s0_aresetn           ),      
    
    //- AXI-ST S2C-1
    .s2c1_aclk                      (user_clk                       ),
    .s2c1_tvalid                    (axi_str_s2c1_tvalid            ),
    .s2c1_tready                    (axi_str_s2c1_tready            ),
    .s2c1_tlast                     (axi_str_s2c1_tlast             ),
    .s2c1_tdata                     (axi_str_s2c1_tdata             ),
    .s2c1_tkeep                     (axi_str_s2c1_tkeep             ),
    .s2c1_areset_n                  (axi_str_s2c1_aresetn           ),  
    .s2c1_tuser                     (axi_str_s2c1_tuser             ),
      //- AXI-ST C2S-1
    .c2s1_aclk                      (user_clk                       ),  
    .c2s1_tvalid                    (axi_str_c2s1_tvalid            ),
    .c2s1_tready                    (axi_str_c2s1_tready            ),
    .c2s1_tlast                     (axi_str_c2s1_tlast             ),
    .c2s1_tdata                     (axi_str_c2s1_tdata             ),
    .c2s1_tkeep                     (axi_str_c2s1_tkeep             ),
    .c2s1_areset_n                  (axi_str_c2s1_aresetn           ),      
    .c2s1_tuser                     (axi_str_c2s1_tuser             ),
    
    //- AXI Master Lite
    .t_aclk                           (user_clk                       ),
    .t_areset_n                       (~user_reset                    ),
    .t_awvalid                        (axi4lite_s_awvalid             ),
    .t_awready                        (axi4lite_s_awready             ),
    .t_awaddr                         (axi4lite_s_awaddr              ),
    .t_awlen                          (),
    .t_awregion                       (),
    .t_awsize                         (),
    
    .t_wlast                          (                               ),
    .t_wvalid                         (axi4lite_s_wvalid              ),
    .t_wready                         (axi4lite_s_wready              ),
    .t_wdata                          (wdata               ),
    .t_wstrb                          (axi4lite_s_wstrb               ),
    
    .t_bresp                          (axi4lite_s_bresp               ),
    .t_bvalid                         (axi4lite_s_bvalid              ),
    .t_bready                         (axi4lite_s_bready              ),
    
    .t_araddr                         (axi4lite_s_araddr              ),
    .t_arvalid                        (axi4lite_s_arvalid             ),
    .t_arready                        (axi4lite_s_arready             ),
    .t_arlen                          (),
    .t_arregion                       (),
    .t_arsize                         (),

    .t_rdata                          (rdata               ),
    .t_rresp                          (axi4lite_s_rresp               ),
    .t_rvalid                         (axi4lite_s_rvalid              ),
    .t_rlast                          (axi4lite_s_rvalid              ),
    .t_rready                         (axi4lite_s_rready              ) 
);

endmodule

