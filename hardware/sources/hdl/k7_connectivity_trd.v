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
// File       : k7_connectivity_trd.v
//
// Revision History
// ----------------
// Version       Description
//        
// 1.0           Initial Release, ISE 14.1
// 1.1           ISE 14.2 update 
//               AXI Stream Interconnect and AXI VFIFO IP inclusion
// 1.2           ISE 14.3 update, Vivado 2012.3 support 
// 1.3           Vivado 2012.4 support 
// 1.4           Vivado 2013.1 support 
//-----------------------------------------------------------------------------
//


`timescale 1ps / 1ps

(* CORE_GENERATION_INFO = "k7_connectivity_trd,k7_connectivity_trd_v1_4,{VENDOR_ID=16'h10EE,CORE_DATA_WIDTH=128,NUM_LANES=8}" *)
module k7_connectivity_trd #
(
    parameter NUM_LANES = 8,
    parameter  CNTWIDTH = 32,
    parameter  ADDRESS_FILTERING = 1,
    parameter PL_FAST_TRAIN = "FALSE"
  )
  (
      // PCI Express slot PERST# reset signal
    input                          perst_n,      
      // PCIe differential reference clock input
    input                          pcie_clk_p,   
    input                          pcie_clk_n,   
      // PCIe differential transmit output
    output  [NUM_LANES-1:0]        tx_p,         
    output  [NUM_LANES-1:0]        tx_n,         
      // PCIe differential receive output
    input   [NUM_LANES-1:0]        rx_p,         
    input   [NUM_LANES-1:0]        rx_n,         

    input                          xphy0_refclk_p, 
    input                          xphy0_refclk_n, 
    output [1:0]                   sfp_tx_disable, 
    output                         xphy0_txp, 
    output                         xphy0_txn, 
    input                          xphy0_rxp, 
    input                          xphy0_rxn,
`ifdef SIMULATION    
    input                          xphy0_signal_detect,
    input [4:0]                    xphy0_prtad, 
`endif
    output                         xphy1_txp, 
    output                         xphy1_txn, 
    input                          xphy1_rxp, 
    input                          xphy1_rxn,
`ifdef SIMULATION    
    input                          xphy1_signal_detect,
    input [4:0]                    xphy1_prtad, 
`endif    

    input                          clk_ref_p,
    input                          clk_ref_n,
`ifdef USE_DDR3_FIFO
    // DDR3 ports

    output [13:0]                  ddr3_addr,             
    output [2:0]                   ddr3_ba,               
    output                         ddr3_cas_n,            
    output                         ddr3_ck_p,               
    output                         ddr3_ck_n,             
    output                         ddr3_cke,              
    output                         ddr3_cs_n,             
    output [7:0]                   ddr3_dm,               
    inout  [63:0]                  ddr3_dq,               
    inout  [7:0]                   ddr3_dqs_p,              
    inout  [7:0]                   ddr3_dqs_n,            
    output                         ddr3_odt,              
    output                         ddr3_ras_n,            
    output                         ddr3_reset_n,          
    output                         ddr3_we_n,             
`endif    
`ifdef KC705_PVTMON
        //- Power monitoring for KC705
    inout                          pmbus_clk,
    inout                          pmbus_data,
    input                          pmbus_alert,
`endif    
    input                          emcclk,
    output                         fmc_ok_led,
    input [1:0]                    fmc_gbtclk0_fsel,
    output                         fmc_clk_312_5,
    // Diagnostic LEDs
    output  [7:1]                  led           

  );



  // ----------------
  // -- Parameters --
  // ----------------
  


  localparam  CORE_DATA_WIDTH         = 128;
  localparam  CORE_BE_WIDTH           = 16;
  localparam  CORE_REMAIN_WIDTH       = 4;

  localparam  AXIS_TDATA_WIDTH          = CORE_DATA_WIDTH;
  localparam  AXIS_TUSER_WIDTH          = 64;
  localparam  AXIS_TKEEP_WIDTH          = (AXIS_TDATA_WIDTH/8);  
  
  localparam  LED_CTR_WIDTH           = 26;   // Sets period of LED flashing

    //- PCIe specific parameters
  localparam  PCIE_EXT_CLK            = "TRUE";  
  localparam  VENDOR_ID               = 16'h10EE; 
  localparam  DEVICE_ID               = 16'h7082; // K7, x8, Gen2,
  localparam  DEVICE_SN               = 64'h0;
    //- Packet FIFO specific parameters
  localparam  AXI_VFIFO_DATA_WIDTH    = 128;
  localparam  AXI_MIG_DATA_WIDTH      = 512;
  localparam  NUM_PORTS = 4;
  localparam  AWIDTH = 32;
  localparam  DWIDTH = CORE_DATA_WIDTH;
  localparam  ID_WIDTH                 = 2;
    //- async fifo count width used in Packet FIFO
    //- XGEMAC specific parameters
  localparam  AXIS_XGEMAC_TDATA_WIDTH = 64;
  localparam  AXIS_XGEMAC_TKEEP_WIDTH = (AXIS_XGEMAC_TDATA_WIDTH/8);
  //- Address maps
  localparam C_AXILITE_DATA_WIDTH = 32;
  localparam C_AXILITE_ADDR_WIDTH = 32;
    //- Offset range for user space registers
  localparam C_BASE_USER_REG  = 32'h0000_9000;
  localparam C_HIGH_USER_REG  = 32'h0000_9FFF;
 
  localparam  C_FAMILY  = "kintex7";

  // -------------------
  // -- Local Signals --
  // -------------------
  
  // Clock and Reset
  wire                                  ref_clk;
  wire                                  perst_n_c;
  
  wire [31:0]                           axi4lite_s_awaddr;
  wire                                  axi4lite_s_awvalid;
  wire                                  axi4lite_s_awready;
  wire [CORE_DATA_WIDTH-1:0]            axi4lite_s_wdata;
  wire [CORE_BE_WIDTH-1:0]              axi4lite_s_wstrb;
  wire                                  axi4lite_s_wvalid;
  wire                                  axi4lite_s_wready;
  wire                                  axi4lite_s_bvalid;
  wire                                  axi4lite_s_bready;
  wire [1:0]                            axi4lite_s_bresp;
  wire [31:0]                           axi4lite_s_araddr;
  wire                                  axi4lite_s_arready;
  wire                                  axi4lite_s_arvalid;
  wire [CORE_DATA_WIDTH-1:0]            axi4lite_s_rdata;
  wire [1:0]                            axi4lite_s_rresp;
  wire                                  axi4lite_s_rready;
  wire                                  axi4lite_s_rvalid;

  wire    [63:0]                        axi_str_s2c0_tuser;      
  wire                                  axi_str_s2c0_tlast;              
  wire    [AXIS_TDATA_WIDTH-1:0]        axi_str_s2c0_tdata;             
  wire    [AXIS_TKEEP_WIDTH-1:0]        axi_str_s2c0_tkeep;
  wire                                  axi_str_s2c0_tvalid;          
  wire                                  axi_str_s2c0_tready;          
  wire                                  axi_str_s2c0_aresetn;
  wire                                  axi_str_s2c0_tvalid_app;          
  wire                                  axi_str_s2c0_tvalid_perf;          

  wire    [63:0]                        axi_str_c2s0_tuser;      
  wire                                  axi_str_c2s0_tlast;              
  wire    [AXIS_TDATA_WIDTH-1:0]        axi_str_c2s0_tdata;             
  wire    [AXIS_TKEEP_WIDTH-1:0]        axi_str_c2s0_tkeep;
  wire                                  axi_str_c2s0_tvalid;          
  wire                                  axi_str_c2s0_tready;          
  wire                                  axi_str_c2s0_aresetn;

  wire    [63:0]                        axi_str_s2c1_tuser;      
  wire                                  axi_str_s2c1_tlast;              
  wire    [AXIS_TDATA_WIDTH-1:0]        axi_str_s2c1_tdata;             
  wire    [AXIS_TKEEP_WIDTH-1:0]        axi_str_s2c1_tkeep;
  wire                                  axi_str_s2c1_tvalid;          
  wire                                  axi_str_s2c1_tready;          
  wire                                  axi_str_s2c1_aresetn;
  wire                                  axi_str_s2c1_tvalid_app;          
  wire                                  axi_str_s2c1_tvalid_perf;          

  wire    [63:0]                        axi_str_c2s1_tuser;      
  wire                                  axi_str_c2s1_tlast;              
  wire    [AXIS_TDATA_WIDTH-1:0]        axi_str_c2s1_tdata;             
  wire    [AXIS_TKEEP_WIDTH-1:0]        axi_str_c2s1_tkeep;
  wire                                  axi_str_c2s1_tvalid;          
  wire                                  axi_str_c2s1_tready;          
  wire                                  axi_str_c2s1_aresetn;

  wire                                  axi_str_s2c0_tready_app;          

  wire    [63:0]                        axi_str_c2s0_tuser_app;      
  wire                                  axi_str_c2s0_tlast_app;              
  wire    [AXIS_TDATA_WIDTH-1:0]        axi_str_c2s0_tdata_app;             
  wire    [AXIS_TKEEP_WIDTH-1:0]        axi_str_c2s0_tkeep_app;
  wire                                  axi_str_c2s0_tvalid_app;          

  wire                                  axi_str_s2c1_tready_app;          

  wire    [63:0]                        axi_str_c2s1_tuser_app;      
  wire                                  axi_str_c2s1_tlast_app;              
  wire    [AXIS_TDATA_WIDTH-1:0]        axi_str_c2s1_tdata_app;             
  wire    [AXIS_TKEEP_WIDTH-1:0]        axi_str_c2s1_tkeep_app;
  wire                                  axi_str_c2s1_tvalid_app;          
  
  wire                                  axi_str_s2c0_tready_perf;          

  wire    [63:0]                        axi_str_c2s0_tuser_perf;      
  wire                                  axi_str_c2s0_tlast_perf;              
  wire    [AXIS_TDATA_WIDTH-1:0]        axi_str_c2s0_tdata_perf;             
  wire    [AXIS_TKEEP_WIDTH-1:0]        axi_str_c2s0_tkeep_perf;
  wire                                  axi_str_c2s0_tvalid_perf;          

  wire                                  axi_str_s2c1_tready_perf;          

  wire    [63:0]                        axi_str_c2s1_tuser_perf;      
  wire                                  axi_str_c2s1_tlast_perf;              
  wire    [AXIS_TDATA_WIDTH-1:0]        axi_str_c2s1_tdata_perf;             
  wire    [AXIS_TKEEP_WIDTH-1:0]        axi_str_c2s1_tkeep_perf;
  wire                                  axi_str_c2s1_tvalid_perf;          

  wire                                  ch0_perf_mode_en;
  wire                                  ch1_perf_mode_en;

  wire                                  app0_en_gen;
  wire                                  app0_en_chk;
  wire                                  app0_en_lpbk;
  wire                                  app0_chk_status;
  wire [15:0]                           app0_pkt_len;
  wire [31:0]                           app0_cnt_wrap;

  wire                                  app1_en_gen;
  wire                                  app1_en_chk;
  wire                                  app1_en_lpbk;
  wire                                  app1_chk_status;
  wire [15:0]                           app1_pkt_len;
  wire [31:0]                           app1_cnt_wrap;

  wire  [11:0]                          init_fc_cpld;
  wire  [7:0]                           init_fc_cplh;
  wire  [11:0]                          init_fc_npd;
  wire  [7:0]                           init_fc_nph;
  wire  [11:0]                          init_fc_pd;
  wire  [7:0]                           init_fc_ph;

  wire  [31:0]                          tx_pcie_byte_cnt;
  wire  [31:0]                          rx_pcie_byte_cnt;
  wire  [31:0]                          tx_pcie_payload_cnt;
  wire  [31:0]                          rx_pcie_payload_cnt;
 
  reg     [LED_CTR_WIDTH-1:0]           led_ctr;
  reg                                   lane_width_error;
  reg     [LED_CTR_WIDTH-1:0]           led156_ctr;
  reg     [LED_CTR_WIDTH-1:0]           test_clk_ctr;

// -------------------
// -- Local Signals --
// -------------------

// Xilinx Hard Core Instantiation

  wire                                  user_clk;
  wire                                  user_reset;
  wire                                  user_lnk_up;
  wire                                  user_reset_c;
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
  wire    [15:0]                        cfg_lstatus;
  wire    [15:0]                        cfg_lcommand;
  wire    [15:0]                        cfg_dcommand2;
  wire    [2:0]                         cfg_pcie_link_state;
  wire    [63:0]                        cfg_dsn;

  wire    [1:0]                         cfg_pmcsr_powerstate;
  wire    [2:0]                         pl_initial_link_width;
  wire    [1:0]                         pl_lane_reversal_mode;
  wire                                  pl_link_gen2_capable;
  wire                                  pl_link_partner_gen2_supported;
  wire                                  pl_link_upcfg_capable;
  wire    [5:0]                         pl_ltssm_state;
  wire                                  pl_received_hot_rst;
  wire                                  pl_directed_link_auton;
  wire    [1:0]                         pl_directed_link_change;
  wire                                  pl_directed_link_speed;
  wire    [1:0]                         pl_directed_link_width;
  wire                                  pl_upstream_prefer_deemph;
  wire                                  pl_sel_lnk_rate;
  wire    [1:0]                         pl_sel_lnk_width;
  wire                                  cfg_err_aer_headerlog_set;
  wire                                  cfg_aer_ecrc_check_en;
  wire                                  cfg_aer_ecrc_gen_en; 
  
  wire    [7:0]                         clk_period_in_ns;

  wire    [CNTWIDTH-1:0]                        mac0_rd_data_count; 
  wire    [CNTWIDTH-1:0]                        mac1_rd_data_count; 
  
  wire                                  xgemac_clk_156;
  
  wire [7:0]                            xphy0_status;
  wire [7:0]                            xphy1_status;
  wire                                  xphy0_tx_fault;
  wire                                  xphy1_tx_fault;
  

  wire                                  nw0_reset;  
  wire                                  nw1_reset;  
  wire                                  txusrclk             ;
  wire                                  txusrclk2            ;
  wire                                  txclk322             ;
  wire                                  areset_refclk_bufh   ;
  wire                                  areset_clk156        ;
  wire                                  mmcm_locked_clk156   ;
  wire                                  gttxreset_txusrclk2  ;
  wire                                  gttxreset            ;
  wire                                  gtrxreset            ;
  wire                                  txuserrdy            ;
  wire                                  qplllock             ;
  wire                                  qplloutclk           ;
  wire                                  qplloutrefclk        ;
  wire                                  qplloutclk1          ;
  wire                                  qplloutrefclk1       ;
  wire                                  qplloutclk2          ;
  wire                                  qplloutrefclk2       ;
  wire                                  reset_counter_done   ; 
  wire                                  nw0_reset_i      ;
  wire                                  nw1_reset_i      ;
  wire                                  xphy0_tx_resetdone      ;
  wire                                  xphy1_tx_resetdone      ;


  
//- Network Path signal declarations
`ifndef SIMULATION
  wire    [4:0]                                 xphy0_prtad;
  wire                                          xphy0_signal_detect;
  wire    [4:0]                                 xphy1_prtad;
  wire                                          xphy1_signal_detect;
`endif
  wire    [15:0]                                axi_str_tmac0_tlen;      
  wire                                          axi_str_tmac0_tlast;            
  wire    [AXIS_TDATA_WIDTH-1:0]                axi_str_tmac0_tdata;           
  wire    [(AXIS_TKEEP_WIDTH)-1:0]              axi_str_tmac0_tkeep;
  wire                                          axi_str_tmac0_tvalid;          
  wire                                          axi_str_tmac0_tready;          
  
  wire    [15:0]                                axi_str_rmac0_tlen;      
  wire                                          axi_str_rmac0_tlast;   
  wire    [AXIS_TDATA_WIDTH-1:0]                 axi_str_rmac0_tdata;           
  wire    [(AXIS_TKEEP_WIDTH)-1:0]              axi_str_rmac0_tkeep;
  wire                                          axi_str_rmac0_tvalid;          
  wire                                          axi_str_rmac0_tready;          
  wire                                          rmac0_rx_fifo_overflow;  
  
  wire    [15:0]                                axi_str_tmac1_tlen;      
  wire                                          axi_str_tmac1_tlast;            
  wire    [AXIS_TDATA_WIDTH-1:0]                axi_str_tmac1_tdata;           
  wire    [(AXIS_TKEEP_WIDTH)-1:0]              axi_str_tmac1_tkeep;
  wire                                          axi_str_tmac1_tvalid;          
  wire                                          axi_str_tmac1_tready;          
  
  wire    [15:0]                                axi_str_rmac1_tlen;      
  wire                                          axi_str_rmac1_tlast;   
  wire    [AXIS_TDATA_WIDTH-1:0]                axi_str_rmac1_tdata;           
  wire    [(AXIS_TKEEP_WIDTH)-1:0]              axi_str_rmac1_tkeep;
  wire                                          axi_str_rmac1_tvalid;          
  wire                                          axi_str_rmac1_tready;          
  wire                                          rmac1_rx_fifo_overflow;  
  

  wire                                          xphyrefclk_i;    
  wire                                          gt0_pma_resetout_i ;
  wire                                          gt0_pcs_resetout_i;         
  wire                                          gt0_drpen_i;                
  wire                                          gt0_drpwe_i;                
  wire   [15:0]                                 gt0_drpaddr_i;              
  wire   [15:0]                                 gt0_drpdi_i;                
  wire   [15:0]                                 gt0_drpdo_i;                
  wire                                          gt0_drprdy_i;               
  wire                                          gt0_resetdone_i;            
  wire   [31:0]                                 gt0_txd_i;                  
  wire   [7:0]                                  gt0_txc_i;                  
  wire   [31:0]                                 gt0_rxd_i;                  
  wire   [7:0]                                  gt0_rxc_i;                  
  wire                                          gt0_rxgearboxslip_i;        
  wire                                          gt0_tx_prbs31_en_i;         
  wire                                          gt0_rx_prbs31_en_i;         
  wire   [2:0]                                  gt0_loopback_i;             
  wire                                          gt0_txclk322_i;             
  wire                                          gt0_rxclk322_i;             
  wire                                          gt1_drpen_i;                
  wire                                          gt1_drpwe_i;                
  wire   [15:0]                                 gt1_drpaddr_i;              
  wire   [15:0]                                 gt1_drpdi_i;                
  wire   [15:0]                                 gt1_drpdo_i;                
  wire                                          gt1_drprdy_i;               
  wire                                          gt1_txclk322_i;             
  wire                                          gt1_rxclk322_i;             
  wire                                          dclk_i;                     
  wire                                          gt1_pma_resetout_i ;
  wire                                          gt1_pcs_resetout_i;         
  wire                                          gt1_resetdone_i;            
  wire   [31:0]                                 gt1_txd_i;                  
  wire   [7:0]                                  gt1_txc_i;                  
  wire   [31:0]                                 gt1_rxd_i;                  
  wire   [7:0]                                  gt1_rxc_i;                  
  wire                                          gt1_rxgearboxslip_i;        
  wire                                          gt1_tx_prbs31_en_i;         
  wire                                          gt1_rx_prbs31_en_i;         
  
  wire                                gt0_clear_rx_prbs_err_cnt_i;
  wire                                gt1_clear_rx_prbs_err_cnt_i;
  
  wire   [2:0]                                  gt1_loopback_i;             
  wire                                  ic_reset;
  reg [15:0]                            axi_ic_rst  = 16'd0;

  wire                                          calib_done;
  wire                                          axi_ic_mig_shim_rst_n;
  wire                                          mcb_clk;
  wire                                          mcb_rst;
  wire [NUM_PORTS-1:0]                          ddr3_fifo_empty;
  wire [NUM_PORTS-1:0]                          px_axi_str_wr_tlast;
  wire [(AXI_VFIFO_DATA_WIDTH*NUM_PORTS)-1:0]   px_axi_str_wr_tdata;
  wire [NUM_PORTS-1:0]                          px_axi_str_wr_tvalid;
  wire [(AXI_VFIFO_DATA_WIDTH/8*NUM_PORTS)-1:0] px_axi_str_wr_tkeep;
  wire [NUM_PORTS-1:0]                          px_axi_str_wr_tready;
  wire [NUM_PORTS-1:0]                          px_axi_str_rd_tlast;
  wire [(AXI_VFIFO_DATA_WIDTH*NUM_PORTS)-1:0]   px_axi_str_rd_tdata;
  wire [NUM_PORTS-1:0]                          px_axi_str_rd_tvalid;
  wire [(AXI_VFIFO_DATA_WIDTH/8*NUM_PORTS)-1:0] px_axi_str_rd_tkeep;
  wire [NUM_PORTS-1:0]                          px_axi_str_rd_tready;
  wire [(NUM_PORTS*16)-1:0]                     px_axi_str_wr_len;
  wire [(NUM_PORTS*16)-1:0]                     px_axi_str_rd_len;
  wire [(NUM_PORTS*CNTWIDTH)-1:0]               px_axi_str_rd_cnt;
  
  wire [31:0]                                   mc0_start_adrs;
  wire [31:0]                                   mc0_end_adrs;
  wire [8:0]                                    mc0_wr_burst;
  wire [8:0]                                    mc0_rd_burst;
  wire [31:0]                                   mc1_start_adrs;
  wire [31:0]                                   mc1_end_adrs;
  wire [8:0]                                    mc1_wr_burst;
  wire [8:0]                                    mc1_rd_burst;
  wire [31:0]                                   mc2_start_adrs;
  wire [31:0]                                   mc2_end_adrs;
  wire [8:0]                                    mc2_wr_burst;
  wire [8:0]                                    mc2_rd_burst;
  wire [31:0]                                   mc3_start_adrs;
  wire [31:0]                                   mc3_end_adrs;
  wire [8:0]                                    mc3_wr_burst;
  wire [8:0]                                    mc3_rd_burst;

  wire [47:0]                                   mac0_adrs;
  wire                                          mac0_pm_enable;
  wire [47:0]                                   mac1_adrs;
  wire                                          mac1_pm_enable;
  wire [1:0]                                    target_link_width;
  wire                                          valid_width_change_req;
  wire                                          width_change_done;
  wire                                          width_change_error;          
  wire                                          target_link_speed;    
  wire                                          valid_speed_change_req;
  wire                                          speed_change_done;
  wire                                          speed_change_error;

  // Wires used for external clocking connectivity
  wire                                        pipe_pclk_in;
  wire  [7:0]                                 pipe_rxusrclk_in;
  wire                                        pipe_rxoutclk_in;
  wire                                        pipe_dclk_in;
  wire                                        pipe_oobclk_in;
  wire                                        pipe_userclk1_in;
  wire                                        pipe_userclk2_in;
  wire                                        pipe_mmcm_lock_in;

  wire                                        pipe_txoutclk_out;
  wire [7:0]                                  pipe_rxoutclk_out;
  wire [7:0]                                  pipe_pclk_sel_out;
  wire                                        pipe_gen3_out;

  reg pipe_mmcm_rst_n = 1'b1;

  // Generate External Clock Module if External Clocking is selected
  generate
    if (PCIE_EXT_CLK == "TRUE") begin : ext_clk
      localparam USER_CLK_FREQ = 4;
      localparam USER_CLK2_DIV2 = "TRUE";
      localparam USERCLK2_FREQ = (USER_CLK2_DIV2 == "TRUE") ? (USER_CLK_FREQ == 4) ? 3 : (USER_CLK_FREQ == 3) ? 2 : USER_CLK_FREQ
                                                                                  : USER_CLK_FREQ;
      //---------- PIPE Clock Module -------------------------------------------------
      pcie_x8gen2_axi_st_ip_pipe_clock #
      (
           .PCIE_ASYNC_EN                  ("FALSE"),              // PCIe async enable
          .PCIE_TXBUF_EN                  ("FALSE"),              // PCIe TX buffer enable for Gen1/Gen2 only
          .PCIE_LANE                      (6'h08),     // PCIe number of lanes
          .PCIE_LINK_SPEED                (2),     // PCIe link speed
          .PCIE_REFCLK_FREQ               (0),     // PCIe reference clock frequency
          .PCIE_USERCLK1_FREQ             (USER_CLK_FREQ +1),     // PCIe user clock 1 frequency
          .PCIE_USERCLK2_FREQ             (USERCLK2_FREQ +1)      // PCIe user clock 2 frequency
      )
      pipe_clock_i
      (

          //---------- Input -------------------------------------
          .CLK_CLK                        (ref_clk),
          .CLK_TXOUTCLK                   (pipe_txoutclk_out),       // Reference clock from lane 0
          .CLK_RXOUTCLK_IN                (pipe_rxoutclk_out),
          .CLK_RST_N                      (pipe_mmcm_rst_n),
          .CLK_PCLK_SEL                   (pipe_pclk_sel_out),
          .CLK_GEN3                       (pipe_gen3_out),

          //---------- Output ------------------------------------
          .CLK_PCLK                       (pipe_pclk_in),
          .CLK_RXUSRCLK                   (pipe_rxusrclk_in),
          .CLK_RXOUTCLK_OUT               (pipe_rxoutclk_in),
          .CLK_DCLK                       (pipe_dclk_in),
          .CLK_USERCLK1                   (pipe_userclk1_in),
          .CLK_USERCLK2                   (pipe_userclk2_in),
          .CLK_OOBCLK                     (pipe_oobclk_in),
          .CLK_MMCM_LOCK                  (pipe_mmcm_lock_in)

      );
    end
  endgenerate
  
// ---------------
// Clock and Reset
// ---------------

  wire [11:0] device_temp;
  wire clk50;
  reg [1:0] clk_divide = 2'b00;
  wire clk_200;

  `ifndef USE_DDR3_FIFO
    IBUFDS diff_clk_200 (
      .I    (clk_ref_p),
      .IB   (clk_ref_n),
      .O    (clk_200)
    );
    `else
      assign clk_200 = mcb_clk;
    `endif

 assign clk50 = xgemac_clk_156   ;
//  always @(posedge clk_200)
//    clk_divide  <= clk_divide + 1'b1;

//  BUFG buffer_clk50 (
//    .I  (clk_divide[1]),
//    .O  (clk50)
//  );



// PCIe Reference Clock Input buffer
`ifdef SIMULATION
IBUFDS_GTE2 refclk_ibuf (

    .I      (pcie_clk_p     ),
    .IB     (pcie_clk_n     ),
    .O      (ref_clk        ),
    .CEB    (1'b0           ),
    .ODIV2  (               )

);
`else
IBUFDS_GTE2 refclk_ibuf (

    .I      (pcie_clk_p     ),
    .IB     (pcie_clk_n     ),
    .O      (ref_clk        ),
    .ODIV2  (               )

);
`endif
// PCIe PERST# input buffer
IBUF perst_n_ibuf (

    .I      (perst_n        ),
    .O      (perst_n_c      )

);

// Register to improve timing
FDCP #(

  .INIT     (1'b1           )

) user_lnk_up_int_i (

    .Q      (user_lnk_up    ),
    .D      (user_lnk_up_c  ),
    .C      (user_clk       ),
    .CLR    (1'b0           ),
    .PRE    (1'b0           )

);

// Register to improve timing
FDCP #(

  .INIT(1'b1)

) user_reset_i (

    .Q      (user_reset    ),
    .D      (user_reset_c | (~user_lnk_up)),
    .C      (user_clk        ),
    .CLR    (1'b0           ),
    .PRE    (1'b0           )

);

  assign tx_cfg_gnt = 1'b1;

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
    .user_reset_out                 (user_reset_c                   ),
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
    
    .pl_received_hot_rst            (pl_received_hot_rst            ),      
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
    
        .sys_rst_n                      (perst_n_c                      )  


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
    .t_wdata                          (axi4lite_s_wdata               ),
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

    .t_rdata                          (axi4lite_s_rdata               ),
    .t_rresp                          (axi4lite_s_rresp               ),
    .t_rvalid                         (axi4lite_s_rvalid              ),
    .t_rlast                          (axi4lite_s_rvalid              ),
    .t_rready                         (axi4lite_s_rready              ) 
);

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

  wire [31:0] rdata, wdata;
  reg [3:0] rd_addr_nibble = 4'd0;
  
    //- Extract out valid write data based on strobe
  assign wdata = axi4lite_s_wstrb[0] ? axi4lite_s_wdata[31:0] :
                  axi4lite_s_wstrb[4] ? axi4lite_s_wdata[63:32] :
                  axi4lite_s_wstrb[8] ? axi4lite_s_wdata[95:64] :
                  axi4lite_s_wdata[127:96];

    //- Latch onto the read address lowest nibble
  always @(posedge user_clk)
    if (axi4lite_s_arvalid & axi4lite_s_arready)
      rd_addr_nibble  <= axi4lite_s_araddr[3:0];

    //- Place the read 32-bit data into the appropriate 128-bit rdata
    //  location based on address nibble latched above
  assign axi4lite_s_rdata = (rd_addr_nibble == 4'hC) ? {rdata,96'd0} :
                            (rd_addr_nibble == 4'h8) ? {32'd0,rdata,64'd0} :
                            (rd_addr_nibble == 4'h4) ? {64'd0,rdata,32'd0} :
                            {96'd0,rdata};


`ifdef DMA_LOOPBACK
  assign axi_str_s2c0_tready = axi_str_c2s0_tready;
  assign axi_str_c2s0_tlast = axi_str_s2c0_tlast;
  assign axi_str_c2s0_tvalid = axi_str_s2c0_tvalid;
  assign axi_str_c2s0_tuser = axi_str_s2c0_tuser;
  assign axi_str_c2s0_tdata = axi_str_s2c0_tdata;
  assign axi_str_c2s0_tkeep = axi_str_s2c0_tkeep;
  
  assign axi_str_s2c1_tready = axi_str_c2s1_tready;
  assign axi_str_c2s1_tlast = axi_str_s2c1_tlast;
  assign axi_str_c2s1_tvalid = axi_str_s2c1_tvalid;
  assign axi_str_c2s1_tuser = axi_str_s2c1_tuser;
  assign axi_str_c2s1_tdata = axi_str_s2c1_tdata;
  assign axi_str_c2s1_tkeep = axi_str_s2c1_tkeep;

`else

  /*
   * This section instantiates the user applications behind the DMA
   */

                  
  /*
   *    AXI-Lite Interconnect instantiation to fan out the control path
   *    The design currently uses 1M:4S AXI-Lite Interconnect core. DMA
   *    AXI-Target interface is the master driving this, which is mapped to
   *    PCIe BAR-0.
   */
   
    //- Internal signals for user application

  wire [31:0]                     axilite_m0_awaddr;
  wire                            axilite_m0_awvalid;
  wire                            axilite_m0_awready;
  wire [31:0]                     axilite_m0_wdata;
  wire [3:0]                      axilite_m0_wstrb;
  wire                            axilite_m0_wvalid;
  wire                            axilite_m0_wready;
  wire                            axilite_m0_bvalid;
  wire                            axilite_m0_bready;
  wire [1:0]                      axilite_m0_bresp;
  wire [31:0]                     axilite_m0_araddr;
  wire                            axilite_m0_arready;
  wire                            axilite_m0_arvalid;
  wire [31:0]                     axilite_m0_rdata;
  wire [1:0]                      axilite_m0_rresp;
  wire                            axilite_m0_rready;
  wire                            axilite_m0_rvalid;

  wire [31:0]                     axilite_m1_awaddr;
  wire                            axilite_m1_awvalid;
  wire                            axilite_m1_awready;
  wire [31:0]                     axilite_m1_wdata;
  wire [3:0]                      axilite_m1_wstrb;
  wire                            axilite_m1_wvalid;
  wire                            axilite_m1_wready;
  wire                            axilite_m1_bvalid;
  wire                            axilite_m1_bready;
  wire [1:0]                      axilite_m1_bresp;
  wire [31:0]                     axilite_m1_araddr;
  wire                            axilite_m1_arready;
  wire                            axilite_m1_arvalid;
  wire [31:0]                     axilite_m1_rdata;
  wire [1:0]                      axilite_m1_rresp;
  wire                            axilite_m1_rready;
  wire                            axilite_m1_rvalid;

  wire                            axilite_m2_clk;          
  wire [31:0]                     axilite_m2_awaddr;
  wire                            axilite_m2_awvalid;
  wire                            axilite_m2_awready;
  wire [31:0]                     axilite_m2_wdata;
  wire [3:0]                      axilite_m2_wstrb;
  wire                            axilite_m2_wvalid;
  wire                            axilite_m2_wready;
  wire                            axilite_m2_bvalid;
  wire                            axilite_m2_bready;
  wire [1:0]                      axilite_m2_bresp;
  wire [31:0]                     axilite_m2_araddr;
  wire                            axilite_m2_arready;
  wire                            axilite_m2_arvalid;
  wire [31:0]                     axilite_m2_rdata;
  wire [1:0]                      axilite_m2_rresp;
  wire                            axilite_m2_rready;
  wire                            axilite_m2_rvalid;

  /*
   *  This AXILITE interconnect is 1M:3S configuration. The received 1DW
   *  register transactions from the target AXI master are connected to
   *  this for routing to appropriate slave.
   *  For address mapping, only lower 16-bits as received over the target
   *  AXI master are used. As an alternative, BAR0 could have been read
   *  through backdoor access and address received XOR'd with it to provide
   *  the right offset. 
   *  However, requesting for BAR space of 64KB ensures that the lower
   *  16-bits of address will indicate offset directly.
   */

  //- Hold AXI4LITE interconnect in reset till all clocks are stable

  reg clk_stable = 1'b0;
  reg ic_rstdone  = 1'b0;

  always @(posedge user_clk)
    if (user_reset | nw0_reset | nw1_reset | ic_reset)
      clk_stable  <= 1'b0;
    else if (~ic_rstdone)
      clk_stable  <= 1'b1;

  always @(posedge user_clk)
    if (user_reset)
      ic_rstdone  <= 1'b0;
    else if (clk_stable)
      ic_rstdone  <= 1'b1;
      
  always @(posedge user_clk)
    if (clk_stable)
      axi_ic_rst  <= 16'd1;
    else
      axi_ic_rst <= {axi_ic_rst[14:0],1'b0};
      
  assign ic_reset = |(axi_ic_rst);

  system  axilite_system (
    .axilite_interconnect_0_INTERCONNECT_ACLK_pin        (user_clk),
    .axilite_interconnect_0_INTERCONNECT_ARESETN_pin     (~ic_reset),
    
    .axi_ext_slave_conn_2_ACLK_pin                        (xgemac_clk_156),
    .axi_ext_slave_conn_1_ACLK_pin                        (xgemac_clk_156),
    .axi_ext_slave_conn_0_ACLK_pin                        (user_clk),
    .axi_ext_master_conn_0_ACLK_pin                       (user_clk),
    
    .axi_ext_slave_conn_2_M_AXI_AWADDR_pin                (axilite_m2_awaddr),
    .axi_ext_slave_conn_2_M_AXI_AWVALID_pin               (axilite_m2_awvalid),
    .axi_ext_slave_conn_2_M_AXI_AWREADY_pin               (axilite_m2_awready),
    .axi_ext_slave_conn_2_M_AXI_WDATA_pin                 (axilite_m2_wdata),
    .axi_ext_slave_conn_2_M_AXI_WSTRB_pin                 (axilite_m2_wstrb),
    .axi_ext_slave_conn_2_M_AXI_WVALID_pin                (axilite_m2_wvalid),
    .axi_ext_slave_conn_2_M_AXI_WREADY_pin                (axilite_m2_wready),
    .axi_ext_slave_conn_2_M_AXI_BRESP_pin                 (axilite_m2_bresp),
    .axi_ext_slave_conn_2_M_AXI_BVALID_pin                (axilite_m2_bvalid),
    .axi_ext_slave_conn_2_M_AXI_BREADY_pin                (axilite_m2_bready),
    .axi_ext_slave_conn_2_M_AXI_ARADDR_pin                (axilite_m2_araddr),
    .axi_ext_slave_conn_2_M_AXI_ARVALID_pin               (axilite_m2_arvalid),
    .axi_ext_slave_conn_2_M_AXI_ARREADY_pin               (axilite_m2_arready),
    .axi_ext_slave_conn_2_M_AXI_RDATA_pin                 (axilite_m2_rdata),
    .axi_ext_slave_conn_2_M_AXI_RRESP_pin                 (axilite_m2_rresp),
    .axi_ext_slave_conn_2_M_AXI_RVALID_pin                (axilite_m2_rvalid),
    .axi_ext_slave_conn_2_M_AXI_RREADY_pin                (axilite_m2_rready),

    .axi_ext_slave_conn_1_M_AXI_AWADDR_pin                (axilite_m1_awaddr),
    .axi_ext_slave_conn_1_M_AXI_AWVALID_pin               (axilite_m1_awvalid),
    .axi_ext_slave_conn_1_M_AXI_AWREADY_pin               (axilite_m1_awready),
    .axi_ext_slave_conn_1_M_AXI_WDATA_pin                 (axilite_m1_wdata),
    .axi_ext_slave_conn_1_M_AXI_WSTRB_pin                 (axilite_m1_wstrb),
    .axi_ext_slave_conn_1_M_AXI_WVALID_pin                (axilite_m1_wvalid),
    .axi_ext_slave_conn_1_M_AXI_WREADY_pin                (axilite_m1_wready),
    .axi_ext_slave_conn_1_M_AXI_BRESP_pin                 (axilite_m1_bresp),
    .axi_ext_slave_conn_1_M_AXI_BVALID_pin                (axilite_m1_bvalid),
    .axi_ext_slave_conn_1_M_AXI_BREADY_pin                (axilite_m1_bready),
    .axi_ext_slave_conn_1_M_AXI_ARADDR_pin                (axilite_m1_araddr),
    .axi_ext_slave_conn_1_M_AXI_ARVALID_pin               (axilite_m1_arvalid),
    .axi_ext_slave_conn_1_M_AXI_ARREADY_pin               (axilite_m1_arready),
    .axi_ext_slave_conn_1_M_AXI_RDATA_pin                 (axilite_m1_rdata),
    .axi_ext_slave_conn_1_M_AXI_RRESP_pin                 (axilite_m1_rresp),
    .axi_ext_slave_conn_1_M_AXI_RVALID_pin                (axilite_m1_rvalid),
    .axi_ext_slave_conn_1_M_AXI_RREADY_pin                (axilite_m1_rready),
    
    .axi_ext_slave_conn_0_M_AXI_AWADDR_pin                (axilite_m0_awaddr),
    .axi_ext_slave_conn_0_M_AXI_AWVALID_pin               (axilite_m0_awvalid),
    .axi_ext_slave_conn_0_M_AXI_AWREADY_pin               (axilite_m0_awready),
    .axi_ext_slave_conn_0_M_AXI_WDATA_pin                 (axilite_m0_wdata),
    .axi_ext_slave_conn_0_M_AXI_WSTRB_pin                 (axilite_m0_wstrb),
    .axi_ext_slave_conn_0_M_AXI_WVALID_pin                (axilite_m0_wvalid),
    .axi_ext_slave_conn_0_M_AXI_WREADY_pin                (axilite_m0_wready),
    .axi_ext_slave_conn_0_M_AXI_BRESP_pin                 (axilite_m0_bresp),
    .axi_ext_slave_conn_0_M_AXI_BVALID_pin                (axilite_m0_bvalid),
    .axi_ext_slave_conn_0_M_AXI_BREADY_pin                (axilite_m0_bready),
    .axi_ext_slave_conn_0_M_AXI_ARADDR_pin                (axilite_m0_araddr),
    .axi_ext_slave_conn_0_M_AXI_ARVALID_pin               (axilite_m0_arvalid),
    .axi_ext_slave_conn_0_M_AXI_ARREADY_pin               (axilite_m0_arready),
    .axi_ext_slave_conn_0_M_AXI_RDATA_pin                 (axilite_m0_rdata),
    .axi_ext_slave_conn_0_M_AXI_RRESP_pin                 (axilite_m0_rresp),
    .axi_ext_slave_conn_0_M_AXI_RVALID_pin                (axilite_m0_rvalid),
    .axi_ext_slave_conn_0_M_AXI_RREADY_pin                (axilite_m0_rready),

    .axi_ext_master_conn_0_S_AXI_AWADDR_pin  ({16'd0,axi4lite_s_awaddr[15:0]}),
    .axi_ext_master_conn_0_S_AXI_AWPROT_pin               ('d0),
    .axi_ext_master_conn_0_S_AXI_AWVALID_pin              (axi4lite_s_awvalid),
    .axi_ext_master_conn_0_S_AXI_AWREADY_pin              (axi4lite_s_awready),
    .axi_ext_master_conn_0_S_AXI_WDATA_pin                (wdata             ),
    .axi_ext_master_conn_0_S_AXI_WSTRB_pin                (4'b1111          ),
    .axi_ext_master_conn_0_S_AXI_WVALID_pin               (axi4lite_s_wvalid),
    .axi_ext_master_conn_0_S_AXI_WREADY_pin               (axi4lite_s_wready),
    .axi_ext_master_conn_0_S_AXI_BRESP_pin                (axi4lite_s_bresp),
    .axi_ext_master_conn_0_S_AXI_BVALID_pin               (axi4lite_s_bvalid),
    .axi_ext_master_conn_0_S_AXI_BREADY_pin               (axi4lite_s_bready),
    .axi_ext_master_conn_0_S_AXI_ARADDR_pin ({16'd0,axi4lite_s_araddr[15:0]}),
    .axi_ext_master_conn_0_S_AXI_ARPROT_pin               ('d0              ),
    .axi_ext_master_conn_0_S_AXI_ARVALID_pin              (axi4lite_s_arvalid),
    .axi_ext_master_conn_0_S_AXI_ARREADY_pin              (axi4lite_s_arready),
    .axi_ext_master_conn_0_S_AXI_RDATA_pin                (rdata            ),
    .axi_ext_master_conn_0_S_AXI_RRESP_pin                (axi4lite_s_rresp ),
    .axi_ext_master_conn_0_S_AXI_RVALID_pin               (axi4lite_s_rvalid),
    .axi_ext_master_conn_0_S_AXI_RREADY_pin               (axi4lite_s_rready)
  );

  assign xphy0_tx_fault = 1'b0;
  assign xphy1_tx_fault = 1'b0;

  wire                                  gt0_pma_resetout;
  wire                                  gt0_pcs_resetout;
  wire                                  gt0_drpen;
  wire                                  gt0_drpwe;
  wire [15:0]                           gt0_drpaddr;
  wire [15:0]                           gt0_drpdi;
  wire [15:0]                           gt0_drpdo;
  wire                                  gt0_drprdy;
  wire                                  gt0_resetdone;
  wire [63:0]                           gt0_txd;
  wire [7:0]                            gt0_txc;
  wire [63:0]                           gt0_rxd;
  wire [7:0]                            gt0_rxc;
  wire                                  gt0_rxgearboxslip;
  wire                                  gt0_tx_prbs31_en;
  wire                                  gt0_rx_prbs31_en;
  wire [2:0]                            gt0_loopback;

  wire                                  gt1_pma_resetout;
  wire                                  gt1_pcs_resetout;
  wire                                  gt1_drpen;
  wire                                  gt1_drpwe;
  wire [15:0]                           gt1_drpaddr;
  wire [15:0]                           gt1_drpdi;
  wire [15:0]                           gt1_drpdo;
  wire                                  gt1_drprdy;
  wire                                  gt1_resetdone;
  wire [63:0]                           gt1_txd;
  wire [7:0]                            gt1_txc;
  wire [63:0]                           gt1_rxd;
  wire [7:0]                            gt1_rxc;
  wire                                  gt1_rxgearboxslip;
  wire [2:0]                            gt1_loopback;

  
`ifndef SIMULATION
  assign xphy0_prtad  = 5'd0;
  assign xphy0_signal_detect = 1'b1;
`endif
//  assign dclk_i=clk50;

  network_path #(
    .FIFO_CNT_WIDTH                   (CNTWIDTH                   ),
    .AXIS_TDATA_WIDTH                 (AXIS_TDATA_WIDTH    ),
    .AXIS_TKEEP_WIDTH                 (AXIS_TKEEP_WIDTH           ), 
    .AXIS_XGEMAC_TDATA_WIDTH          (AXIS_XGEMAC_TDATA_WIDTH    ),
    .ADDRESS_FILTER_EN                (ADDRESS_FILTERING          ) 
  ) network_path_inst_0 (
    // AXI Lite register interface
    .s_axi_awready                    (axilite_m1_awready          ),
    .s_axi_wready                     (axilite_m1_wready           ),
    .s_axi_bvalid                     (axilite_m1_bvalid           ),
    .s_axi_bresp                      (axilite_m1_bresp            ),
    .s_axi_arready                    (axilite_m1_arready          ),
    .s_axi_rdata                      (axilite_m1_rdata            ),
    .s_axi_rresp                      (axilite_m1_rresp            ),
    .s_axi_rvalid                     (axilite_m1_rvalid           ),
    .s_axi_arvalid                    (axilite_m1_arvalid          ),
    .s_axi_araddr                     (axilite_m1_araddr           ),
    .s_axi_awaddr                     (axilite_m1_awaddr           ),
    .s_axi_wdata                      (axilite_m1_wdata            ),
    .s_axi_wstrb                      (axilite_m1_wstrb            ),
    .s_axi_wvalid                     (axilite_m1_wvalid           ),
    .s_axi_bready                     (axilite_m1_bready           ),
    .s_axi_awvalid                    (axilite_m1_awvalid          ),
    .s_axi_rready                     (axilite_m1_rready           ), 

     //Data interface 
    .axi_str_wr_tdata                 ({64'd0, axi_str_tmac0_tdata[63:0]}),
    .axi_str_wr_tkeep                 ({8'd0, axi_str_tmac0_tkeep[7:0]}),
    .axi_str_wr_tvalid                (axi_str_tmac0_tvalid        ),
    .axi_str_wr_tlast                 (axi_str_tmac0_tlast         ),
    .axi_str_wr_tready                (axi_str_tmac0_tready        ),
    .axi_str_rd_tdata                 (axi_str_rmac0_tdata         ),
    .axi_str_rd_tkeep                 (axi_str_rmac0_tkeep         ),
    .axi_str_rd_tvalid                (axi_str_rmac0_tvalid        ),
    .axi_str_rd_tlast                 (axi_str_rmac0_tlast         ),
    .axi_str_rd_tready                (axi_str_rmac0_tready        ),
    .rx_fifo_overflow                 (rmac0_rx_fifo_overflow      ),
    .mac_id                           (mac0_adrs                   ),
    .tx_ifg_delay                     (8'd0                        ),
    .mac_id_valid                     (1'b1                        ),
    .promiscuous_mode_en              (mac0_pm_enable              ),
    .rd_data_count_xgmac              (                            ),
    //XGEMAC PHY IO

    .txusrclk                         (txusrclk             ),
    .txusrclk2                        (txusrclk2            ),
    .txclk322                         (txclk322             ),
    .areset_refclk_bufh               (areset_refclk_bufh   ),
    .areset_clk156                    (areset_clk156        ),
    .mmcm_locked_clk156               (mmcm_locked_clk156   ),
    .gttxreset_txusrclk2              (gttxreset_txusrclk2  ),
    .gttxreset                        (gttxreset            ),
    .gtrxreset                        (gtrxreset            ),
    .txuserrdy                        (txuserrdy            ),
    .qplllock                         (qplllock             ),
`ifdef USE_DIFF_QUAD
    .qplloutclk                       (qplloutclk1          ),
    .qplloutrefclk                    (qplloutrefclk1       ),
`else
    .qplloutclk                       (qplloutclk           ),
    .qplloutrefclk                    (qplloutrefclk        ),
`endif
    .reset_counter_done               (reset_counter_done   ), 
    .txp                              (xphy0_txp                  ),
    .txn                              (xphy0_txn                  ),
    .rxp                              (xphy0_rxp                  ),
    .rxn                              (xphy0_rxn                  ),
    .tx_resetdone                     (xphy0_tx_resetdone         ),
    
    .signal_detect                    (xphy0_signal_detect      ),
    .tx_fault                         (xphy0_tx_fault             ),
    .prtad                            (xphy0_prtad                ),
    .xphy_status                      (xphy0_status               ),
    .clk156                           (xgemac_clk_156            ),
    .soft_reset                       (~axi_str_c2s0_aresetn       ),
    .sys_rst                          ((~perst_n_c & ~mmcm_locked_clk156)),
    .nw_rst_out                       (nw0_reset_i                ),   
    .dclk                             (dclk_i                     )  
  ); 

`ifndef SIMULATION
  assign xphy1_prtad  = 5'd1;
  assign xphy1_signal_detect = 1'b1;
`endif
 
  assign  nw0_reset = nw0_reset_i;
  assign  nw1_reset = nw1_reset_i;
 
  network_path #(
    .FIFO_CNT_WIDTH                   (CNTWIDTH                   ),
    .AXIS_TDATA_WIDTH                 (AXIS_TDATA_WIDTH    ),
    .AXIS_TKEEP_WIDTH                 (AXIS_TKEEP_WIDTH    ), 
    .AXIS_XGEMAC_TDATA_WIDTH          (AXIS_XGEMAC_TDATA_WIDTH    ),
    .ADDRESS_FILTER_EN                (ADDRESS_FILTERING          ) 
  ) network_path_inst_1 (
    // AXI Lite register interface
    .s_axi_awready                    (axilite_m2_awready          ),
    .s_axi_wready                     (axilite_m2_wready           ),
    .s_axi_bvalid                     (axilite_m2_bvalid           ),
    .s_axi_bresp                      (axilite_m2_bresp            ),
    .s_axi_arready                    (axilite_m2_arready          ),
    .s_axi_rdata                      (axilite_m2_rdata            ),
    .s_axi_rresp                      (axilite_m2_rresp            ),
    .s_axi_rvalid                     (axilite_m2_rvalid           ),
    .s_axi_arvalid                    (axilite_m2_arvalid          ),
    .s_axi_araddr                     (axilite_m2_araddr           ),
    .s_axi_awaddr                     (axilite_m2_awaddr           ),
    .s_axi_wdata                      (axilite_m2_wdata            ),
    .s_axi_wstrb                      (axilite_m2_wstrb            ),
    .s_axi_wvalid                     (axilite_m2_wvalid           ),
    .s_axi_bready                     (axilite_m2_bready           ),
    .s_axi_awvalid                    (axilite_m2_awvalid          ),
    .s_axi_rready                     (axilite_m2_rready           ), 

     //Data interface 
    .axi_str_wr_tdata                 ({64'd0, axi_str_tmac1_tdata[63:0]}),
    .axi_str_wr_tkeep                 ({8'd0, axi_str_tmac1_tkeep[7:0]}),
    .axi_str_wr_tvalid                (axi_str_tmac1_tvalid        ),
    .axi_str_wr_tlast                 (axi_str_tmac1_tlast         ),
    .axi_str_wr_tready                (axi_str_tmac1_tready        ),
    .axi_str_rd_tdata                 (axi_str_rmac1_tdata         ),
    .axi_str_rd_tkeep                 (axi_str_rmac1_tkeep         ),
    .axi_str_rd_tvalid                (axi_str_rmac1_tvalid        ),
    .axi_str_rd_tlast                 (axi_str_rmac1_tlast         ),
    .axi_str_rd_tready                (axi_str_rmac1_tready        ),
    .rx_fifo_overflow                 (rmac1_rx_fifo_overflow      ),
    .mac_id                           (mac1_adrs                  ),
    .tx_ifg_delay                     (8'd0                       ),
    .mac_id_valid                     (1'b1                       ),
    .promiscuous_mode_en              (mac1_pm_enable              ),
    .rd_data_count_xgmac              (                           ),
    //XGEMAC PHY IO

    .txusrclk                         (txusrclk             ),
    .txusrclk2                        (txusrclk2            ),
    .txclk322                         (                     ),
    .areset_refclk_bufh               (areset_refclk_bufh   ),
    .areset_clk156                    (areset_clk156        ),
    .mmcm_locked_clk156               (mmcm_locked_clk156   ),
    .gttxreset_txusrclk2              (gttxreset_txusrclk2  ),
    .gttxreset                        (gttxreset            ),
    .gtrxreset                        (gtrxreset            ),
    .txuserrdy                        (txuserrdy            ),
    .qplllock                         (qplllock             ),
`ifdef USE_DIFF_QUAD
    .qplloutclk                       (qplloutclk2          ),
    .qplloutrefclk                    (qplloutrefclk2       ),
`else
    .qplloutclk                       (qplloutclk           ),
    .qplloutrefclk                    (qplloutrefclk        ),
`endif
    .reset_counter_done               (reset_counter_done   ), 
    .txp                              (xphy1_txp                  ),
    .txn                              (xphy1_txn                  ),
    .rxp                              (xphy1_rxp                  ),
    .rxn                              (xphy1_rxn                  ),
    .tx_resetdone                     (xphy1_tx_resetdone         ),
    
    .signal_detect                    (xphy1_signal_detect      ),
    .tx_fault                         (xphy1_tx_fault             ),
    .prtad                            (xphy1_prtad                ),
    .xphy_status                      (xphy1_status               ),
    .clk156                           (xgemac_clk_156            ),
    .soft_reset                       (~axi_str_c2s1_aresetn       ),
    .sys_rst                          ((~perst_n_c & ~mmcm_locked_clk156)),
    .nw_rst_out                       (nw1_reset_i                ),   
    .dclk                             (dclk_i                     )  
  ); 


`ifdef USE_DIFF_QUAD
  xgbaser_gt_diff_quad_wrapper xgbaser_gt_wrapper_inst_0
  (
     .areset(~perst_n_c),
     .refclk_p(xphy0_refclk_p),
     .refclk_n(xphy0_refclk_n),
     .txclk322(txclk322),
     .gt0_tx_resetdone(xphy0_tx_resetdone),
     .gt1_tx_resetdone(xphy1_tx_resetdone),

     .areset_refclk_bufh(areset_refclk_bufh),
     .areset_clk156(areset_clk156),
     .mmcm_locked_clk156(mmcm_locked_clk156),
     .gttxreset_txusrclk2(gttxreset_txusrclk2),
     .gttxreset(gttxreset),
     .gtrxreset(gtrxreset),
     .txuserrdy(txuserrdy),
     .reset_counter_done(reset_counter_done),
     .txusrclk(txusrclk),
     .txusrclk2(txusrclk2),
     .clk156(xgemac_clk_156),
     .dclk(dclk_i),
     .qpllreset(qpllreset),
     .qplllock(qplllock),
     .qplloutclk1(qplloutclk1), 
     .qplloutrefclk1(qplloutrefclk1), 
     .qplloutclk2(qplloutclk2), 
     .qplloutrefclk2(qplloutrefclk2) 

   );

`else
  xgbaser_gt_same_quad_wrapper xgbaser_gt_wrapper_inst_0
  (
     .areset(~perst_n_c),
     .refclk_p(xphy0_refclk_p),
     .refclk_n(xphy0_refclk_n),
     .txclk322(txclk322),
     .gt0_tx_resetdone(xphy0_tx_resetdone),
     .gt1_tx_resetdone(xphy1_tx_resetdone),

     .areset_refclk_bufh(areset_refclk_bufh),
     .areset_clk156(areset_clk156),
     .mmcm_locked_clk156(mmcm_locked_clk156),
     .gttxreset_txusrclk2(gttxreset_txusrclk2),
     .gttxreset(gttxreset),
     .gtrxreset(gtrxreset),
     .txuserrdy(txuserrdy),
     .reset_counter_done(reset_counter_done),
     .txusrclk(txusrclk),
     .txusrclk2(txusrclk2),
     .clk156(xgemac_clk_156),
     .dclk(dclk_i),
     .qpllreset(qpllreset),
     .qplllock(qplllock),
     .qplloutclk(qplloutclk), 
     .qplloutrefclk(qplloutrefclk) 

    );
`endif    //USE_DIFF_QUAD


//`ifdef USE_DDR3_FIFO

  axis_ic_vfifo_ctrl_ip #(
    .NUM_PORTS                (NUM_PORTS          ),
    .AXIS_TDATA_WIDTH         (AXIS_TDATA_WIDTH   ),
    .AXI_MIG_DATA_WIDTH       (AXI_MIG_DATA_WIDTH ),
    .AWIDTH                   (AWIDTH),    
    .CNTWIDTH                 (CNTWIDTH),
    .DWIDTH                   (DWIDTH),
    .ID_WIDTH                 (ID_WIDTH)
  ) mp_pfifo_inst (
      .calib_done                           (calib_done           ),
`ifdef KC705_PVTMON
      .device_temp                          (device_temp          ),
`endif
      .axi_ic_mig_shim_rst_n                (axi_ic_mig_shim_rst_n),
      .clk_ref_p                            (clk_ref_p            ),
      .clk_ref_n                            (clk_ref_n            ),
      .mcb_clk                              (mcb_clk               ),
      .mcb_rst                              (mcb_rst               ),
      .ddr_addr                             (ddr3_addr             ),
      .ddr_ba                               (ddr3_ba               ),
      .ddr_cas_n                            (ddr3_cas_n            ),
      .ddr_ck_p                             (ddr3_ck_p             ),
      .ddr_ck_n                             (ddr3_ck_n             ),
      .ddr_cke                              (ddr3_cke              ),
      .ddr_cs_n                             (ddr3_cs_n             ),
      .ddr_dm                               (ddr3_dm               ),
      .ddr_odt                              (ddr3_odt              ),
      .ddr_ras_n                            (ddr3_ras_n            ),
      .ddr_reset_n                          (ddr3_reset_n          ),
      .ddr_we_n                             (ddr3_we_n             ),
      .ddr_dq                               (ddr3_dq               ),
      .ddr_dqs_p                            (ddr3_dqs_p            ),
      .ddr_dqs_n                            (ddr3_dqs_n            ),
   // AXI streaming Interface
     .axi_str_wr_tlast                 (px_axi_str_wr_tlast    ),
     .axi_str_wr_tdata                 (px_axi_str_wr_tdata    ),
     .axi_str_wr_tvalid                (px_axi_str_wr_tvalid   ),
     .axi_str_wr_tready                (px_axi_str_wr_tready   ),
     .axi_str_wr_tkeep                 (px_axi_str_wr_tkeep    ),
     .wr_reset_n               ({~nw1_reset, axi_str_s2c1_aresetn, ~nw0_reset, axi_str_s2c0_aresetn}),
     .axi_str_wr_aclk          ({xgemac_clk_156, user_clk, xgemac_clk_156, user_clk}),     
     .axi_str_rd_aclk          ({user_clk, xgemac_clk_156, user_clk, xgemac_clk_156}),     
     .rd_reset_n               ({axi_str_c2s1_aresetn, ~nw1_reset, axi_str_c2s0_aresetn, ~nw0_reset}),
   // AXI streaming Interface
     .axi_str_rd_tlast                 (px_axi_str_rd_tlast    ),
     .axi_str_rd_tdata                 (px_axi_str_rd_tdata    ),
     .axi_str_rd_tvalid                (px_axi_str_rd_tvalid   ),
     .axi_str_rd_tready                (px_axi_str_rd_tready   ),
     .axi_str_rd_tkeep                 (px_axi_str_rd_tkeep    ),
     .ddr3_fifo_empty                  (ddr3_fifo_empty       ),
     .user_reset                       (~perst_n_c)  
    );  


  assign px_axi_str_wr_tdata = {
                                axi_str_rmac1_tdata,
                                axi_str_s2c1_tdata,
                                axi_str_rmac0_tdata,
                                axi_str_s2c0_tdata
  };

  assign px_axi_str_wr_tkeep  = {
                                axi_str_rmac1_tkeep,
                                axi_str_s2c1_tkeep,
                                axi_str_rmac0_tkeep,
                                axi_str_s2c0_tkeep
  };

  assign px_axi_str_wr_tvalid = {
                                axi_str_rmac1_tvalid,
                                axi_str_s2c1_tvalid_app,
                                axi_str_rmac0_tvalid,
                                axi_str_s2c0_tvalid_app
  };

  assign px_axi_str_wr_tlast  = {
                                axi_str_rmac1_tlast,
                                axi_str_s2c1_tlast,
                                axi_str_rmac0_tlast,
                                axi_str_s2c0_tlast
  };
  assign axi_str_s2c0_tready_app  = px_axi_str_wr_tready[0];
  assign axi_str_rmac0_tready     = px_axi_str_wr_tready[1];
  assign axi_str_s2c1_tready_app  = px_axi_str_wr_tready[2];
  assign axi_str_rmac1_tready     = px_axi_str_wr_tready[3];
 
  assign px_axi_str_rd_tready = {
                                axi_str_c2s1_tready,  
                                axi_str_tmac1_tready,
                                axi_str_c2s0_tready,  
                                axi_str_tmac0_tready
  };
 
  assign {  axi_str_c2s1_tdata_app,
            axi_str_tmac1_tdata,
            axi_str_c2s0_tdata_app,
            axi_str_tmac0_tdata   } = px_axi_str_rd_tdata;

  assign {  axi_str_c2s1_tvalid_app,
            axi_str_tmac1_tvalid,
            axi_str_c2s0_tvalid_app,
            axi_str_tmac0_tvalid  } = px_axi_str_rd_tvalid;

  assign {  axi_str_c2s1_tkeep_app,
            axi_str_tmac1_tkeep,
            axi_str_c2s0_tkeep_app,
            axi_str_tmac0_tkeep } = px_axi_str_rd_tkeep;

  assign {  axi_str_c2s1_tlast_app,
            axi_str_tmac1_tlast,
            axi_str_c2s0_tlast_app,
            axi_str_tmac0_tlast } = px_axi_str_rd_tlast;

  assign axi_str_c2s0_tuser_app = 64'd0;
  assign axi_str_c2s1_tuser_app = 64'd0;
  
 

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

  //- Disable data validity to checker when not in GEN/CHK performance mode
  assign axi_str_s2c0_tvalid_perf = ch0_perf_mode_en ? axi_str_s2c0_tvalid :
                                          1'b0;
  assign axi_str_s2c1_tvalid_perf = ch1_perf_mode_en ? axi_str_s2c1_tvalid :
                                          1'b0;

  assign axi_str_c2s0_tuser = ch0_perf_mode_en ? 64'd0 :
                                    axi_str_c2s0_tuser_app;
  
  assign axi_str_s2c0_tready  = ch0_perf_mode_en ? axi_str_s2c0_tready_perf :
                                  axi_str_s2c0_tready_app;

  assign axi_str_c2s0_tvalid  = ch0_perf_mode_en  ? axi_str_c2s0_tvalid_perf :
                                  axi_str_c2s0_tvalid_app;
  assign axi_str_c2s0_tdata   = ch0_perf_mode_en  ? axi_str_c2s0_tdata_perf :
                                  axi_str_c2s0_tdata_app;
  assign axi_str_c2s0_tlast   = ch0_perf_mode_en  ? axi_str_c2s0_tlast_perf :
                                  axi_str_c2s0_tlast_app;
  assign axi_str_c2s0_tkeep   = ch0_perf_mode_en  ? axi_str_c2s0_tkeep_perf :
                                  axi_str_c2s0_tkeep_app;

  assign axi_str_c2s1_tuser = ch1_perf_mode_en ? 64'd0 :
                                    axi_str_c2s1_tuser_app;
  assign axi_str_s2c1_tready  = ch1_perf_mode_en ? axi_str_s2c1_tready_perf :
                                  axi_str_s2c1_tready_app;
  assign axi_str_c2s1_tvalid  = ch1_perf_mode_en  ? axi_str_c2s1_tvalid_perf :
                                  axi_str_c2s1_tvalid_app;
  assign axi_str_c2s1_tdata   = ch1_perf_mode_en  ? axi_str_c2s1_tdata_perf :
                                  axi_str_c2s1_tdata_app;
  assign axi_str_c2s1_tlast   = ch1_perf_mode_en  ? axi_str_c2s1_tlast_perf :
                                  axi_str_c2s1_tlast_app;
  assign axi_str_c2s1_tkeep   = ch1_perf_mode_en  ? axi_str_c2s1_tkeep_perf :
                                  axi_str_c2s1_tkeep_app;

  //- S2C/C2S - 0 GEN/CHK
  axi_stream_gen_check #(
    .CNT_WIDTH              (16               ),
    .AXIS_TDATA_WIDTH       (AXIS_TDATA_WIDTH ),
    .AXIS_TKEEP_WIDTH       (AXIS_TKEEP_WIDTH )
  ) gen_chk_inst0 (
    .enable_loopback        (app0_en_lpbk        ),
    .enable_gen             (app0_en_gen         ),
    .enable_check           (app0_en_chk         ),
    .gen_length             (app0_pkt_len        ),
    .seq_end_cnt            (app0_cnt_wrap       ),
    .check_length           (app0_pkt_len        ),
    .axi_stream_s2c_tdata   (axi_str_s2c0_tdata ),
    .axi_stream_s2c_tkeep   (axi_str_s2c0_tkeep ),
    .axi_stream_s2c_tvalid  (axi_str_s2c0_tvalid_perf),
    .axi_stream_s2c_tlast   (axi_str_s2c0_tlast),
    .axi_stream_s2c_tready  (axi_str_s2c0_tready_perf),
    .axi_stream_c2s_tdata   (axi_str_c2s0_tdata_perf),
    .axi_stream_c2s_tkeep   (axi_str_c2s0_tkeep_perf),
    .axi_stream_c2s_tvalid  (axi_str_c2s0_tvalid_perf  ),
    .axi_stream_c2s_tlast   (axi_str_c2s0_tlast_perf ),
    .axi_stream_c2s_tready  (axi_str_c2s0_tready),
    .error_flag             (app0_chk_status),
    .user_clk               (user_clk),
    .reset                  (user_reset)
  );

  //- S2C/C2S - 1 GEN/CHK
  axi_stream_gen_check #(
    .CNT_WIDTH              (16               ),
    .AXIS_TDATA_WIDTH       (AXIS_TDATA_WIDTH ),
    .AXIS_TKEEP_WIDTH       (AXIS_TKEEP_WIDTH )
  ) gen_chk_inst1 (
    .enable_loopback        (app1_en_lpbk        ),
    .enable_gen             (app1_en_gen         ),
    .enable_check           (app1_en_chk         ),
    .gen_length             (app1_pkt_len        ),
    .seq_end_cnt            (app1_cnt_wrap       ),
    .check_length           (app1_pkt_len        ),
    .axi_stream_s2c_tdata   (axi_str_s2c1_tdata ),
    .axi_stream_s2c_tkeep   (axi_str_s2c1_tkeep ),
    .axi_stream_s2c_tvalid  (axi_str_s2c1_tvalid_perf),
    .axi_stream_s2c_tlast   (axi_str_s2c1_tlast),
    .axi_stream_s2c_tready  (axi_str_s2c1_tready_perf),
    .axi_stream_c2s_tdata   (axi_str_c2s1_tdata_perf),
    .axi_stream_c2s_tkeep   (axi_str_c2s1_tkeep_perf),
    .axi_stream_c2s_tvalid  (axi_str_c2s1_tvalid_perf  ),
    .axi_stream_c2s_tlast   (axi_str_c2s1_tlast_perf ),
    .axi_stream_c2s_tready  (axi_str_c2s1_tready),
    .error_flag             (app1_chk_status),
    .user_clk               (user_clk),
    .reset                  (user_reset)
  );

`endif	//-DMA_LOOPBACK

  /*
   *  Instatiation of AXI-Lite Slave for User Space Registers
   */
   
    user_registers_slave #(
      .CORE_DATA_WIDTH      (CORE_DATA_WIDTH      ),
      .CORE_BE_WIDTH        (CORE_BE_WIDTH        ),
      .CORE_REMAIN_WIDTH    (CORE_REMAIN_WIDTH    ),
      .C_S_AXI_ADDR_WIDTH   (C_AXILITE_ADDR_WIDTH ),
      .C_S_AXI_DATA_WIDTH   (C_AXILITE_DATA_WIDTH ),
      .C_BASE_ADDRESS       (C_BASE_USER_REG      ),
      .C_HIGH_ADDRESS       (C_HIGH_USER_REG      ),
      .C_S_AXI_MIN_SIZE     (32'h0000_FFFF        ),
      .C_TOTAL_NUM_CE       (1                    ),
      .C_NUM_ADDRESS_RANGES (1                    ),
      .C_DPHASE_TIMEOUT     (32                   ),
      .C_FAMILY             (C_FAMILY             )
    ) user_reg_slave_inst (
      .s_axi_clk            (user_clk             ),
      .s_axi_areset_n       (~user_reset          ),
`ifdef DMA_LOOPBACK      
      .s_axi_awaddr         ({16'd0,axi4lite_s_awaddr[15:0]}    ),
      .s_axi_awready        (axi4lite_s_awready   ),
      .s_axi_awvalid        (axi4lite_s_awvalid   ),
      .s_axi_wdata          (wdata     ),
      .s_axi_wstrb          (4'b1111),
      .s_axi_wvalid         (axi4lite_s_wvalid    ),
      .s_axi_wready         (axi4lite_s_wready    ),
      .s_axi_bresp          (axi4lite_s_bresp     ),
      .s_axi_bvalid         (axi4lite_s_bvalid    ),
      .s_axi_bready         (axi4lite_s_bready    ),
      .s_axi_araddr         ({16'd0,axi4lite_s_araddr[15:0]}    ),
      .s_axi_arvalid        (axi4lite_s_arvalid   ),
      .s_axi_arready        (axi4lite_s_arready   ),
      .s_axi_rdata          (rdata     ),
      .s_axi_rresp          (axi4lite_s_rresp     ),
      .s_axi_rvalid         (axi4lite_s_rvalid    ),
      .s_axi_rready         (axi4lite_s_rready    ),
`else      
      .s_axi_awaddr         (axilite_m0_awaddr    ),
      .s_axi_awready        (axilite_m0_awready   ),
      .s_axi_awvalid        (axilite_m0_awvalid   ),
      .s_axi_wdata          (axilite_m0_wdata     ),
      .s_axi_wstrb          (axilite_m0_wstrb     ),
      .s_axi_wvalid         (axilite_m0_wvalid    ),
      .s_axi_wready         (axilite_m0_wready    ),
      .s_axi_bresp          (axilite_m0_bresp     ),
      .s_axi_bvalid         (axilite_m0_bvalid    ),
      .s_axi_bready         (axilite_m0_bready    ),
      .s_axi_araddr         (axilite_m0_araddr    ),
      .s_axi_arvalid        (axilite_m0_arvalid   ),
      .s_axi_arready        (axilite_m0_arready   ),
      .s_axi_rdata          (axilite_m0_rdata     ),
      .s_axi_rresp          (axilite_m0_rresp     ),
      .s_axi_rvalid         (axilite_m0_rvalid    ),
      .s_axi_rready         (axilite_m0_rready    ),
`endif      
      .tx_pcie_byte_cnt     (tx_pcie_byte_cnt     ),
      .rx_pcie_byte_cnt     (rx_pcie_byte_cnt     ),
      .tx_pcie_payload_cnt  (tx_pcie_payload_cnt  ),
      .rx_pcie_payload_cnt  (rx_pcie_payload_cnt  ),
      .init_fc_cpld         (init_fc_cpld         ),
      .init_fc_cplh         (init_fc_cplh         ),
      .init_fc_npd          (init_fc_npd          ),
      .init_fc_nph          (init_fc_nph          ),
      .init_fc_pd           (init_fc_pd           ),
      .init_fc_ph           (init_fc_ph           ),
      
      .pcie_link_up           (user_lnk_up        ),
      
      .pl_ltssm_state         (pl_ltssm_state     ),
      .pl_initial_link_width  (pl_initial_link_width),
      .pl_link_upcfg_capable  (pl_link_upcfg_capable),
      .pl_link_gen2_capable   (pl_link_gen2_capable),
      .pl_link_partner_gen2_supported (pl_link_partner_gen2_supported),
      .cfg_pcie_link_state    (cfg_pcie_link_state  ),
      .pl_lane_reversal_mode  (pl_lane_reversal_mode),
      .pl_sel_lnk_rate        (pl_sel_lnk_rate      ),
      .pl_sel_lnk_width       (pl_sel_lnk_width     ),
      .pl_directed_link_speed (pl_directed_link_speed ),
      .pl_directed_link_width (pl_directed_link_width ),
      .pl_directed_link_change(pl_directed_link_change),
      .pl_directed_link_auton (pl_directed_link_auton ),

      .ch0_perf_mode_en     (ch0_perf_mode_en     ),
      .ch1_perf_mode_en     (ch1_perf_mode_en     ),
      .app0_en_gen          (app0_en_gen          ),
      .app0_en_lpbk         (app0_en_lpbk         ),
      .app0_en_chk          (app0_en_chk          ),
      .app0_pkt_len         (app0_pkt_len         ),
      .app0_cnt_wrap        (app0_cnt_wrap        ),
      .app0_chk_status      (app0_chk_status      ),
      .app1_en_gen          (app1_en_gen          ),
      .app1_en_lpbk         (app1_en_lpbk         ),
      .app1_en_chk          (app1_en_chk          ),
      .app1_pkt_len         (app1_pkt_len         ),
      .app1_cnt_wrap        (app1_cnt_wrap        ),
      .app1_chk_status      (app1_chk_status      ),
`ifdef KC705_PVTMON
      .pmbus_clk            (pmbus_clk            ),
      .pmbus_data           (pmbus_data           ),
      .pmbus_control        (),
      .pmbus_alert          (pmbus_alert          ),
      .clk50                (clk50                ),
      .device_temp          (device_temp          ),
`endif
      .ddr3_fifo_empty      (ddr3_fifo_empty      ),
      .axi_ic_mig_shim_rst_n(axi_ic_mig_shim_rst_n),
      .calib_done           (calib_done           ),  
      .xphy0_status         (xphy0_status[0]      ),
      .xphy1_status         (xphy1_status[0]      ),
      .mac0_pm_enable       (mac0_pm_enable       ),
      .mac0_adrs            (mac0_adrs            ),
      .mac0_rx_fifo_overflow(rmac0_rx_fifo_overflow),
      .mac1_pm_enable       (mac1_pm_enable       ),
      .mac1_rx_fifo_overflow(rmac1_rx_fifo_overflow),
      .mac1_adrs            (mac1_adrs            )
    );


  //- Performance Monitoring

  // Monitor to track performnce on the 
// transaction interface of the PCIe block
 pcie_monitor #(
    .DWIDTH               (AXIS_TDATA_WIDTH)
 ) monitor_i (
   .clk                   (user_clk),
   .reset                 (user_reset),
   .clk_period_in_ns      (clk_period_in_ns),

   // PCIe-AXI Tx
   .s_axis_tx_tdata       (s_axis_tx_tdata),
   .s_axis_tx_tlast       (s_axis_tx_tlast),
   .s_axis_tx_tvalid      (s_axis_tx_tvalid),
   .s_axis_tx_tready      (s_axis_tx_tready),
   .s_axis_tx_tuser       (s_axis_tx_tuser),

   // PCIe-AXI Rx                    
   .m_axis_rx_tdata       (m_axis_rx_tdata),
   .m_axis_rx_tlast       (m_axis_rx_tlast),
   .m_axis_rx_tvalid      (m_axis_rx_tvalid),
   .m_axis_rx_tready      (m_axis_rx_tready),
   .m_axis_rx_tuser       (m_axis_rx_tuser),
   
   .fc_cpld               (fc_cpld),
   .fc_cplh               (fc_cplh),
   .fc_npd                (fc_npd),
   .fc_nph                (fc_nph),
   .fc_pd                 (fc_pd),
   .fc_ph                 (fc_ph),
   .fc_sel                (fc_sel),

   .init_fc_cpld          (init_fc_cpld),
   .init_fc_cplh          (init_fc_cplh),
   .init_fc_npd           (init_fc_npd),
   .init_fc_nph           (init_fc_nph),
   .init_fc_pd            (init_fc_pd),
   .init_fc_ph            (init_fc_ph),

   .tx_byte_count         (tx_pcie_byte_cnt),
   .rx_byte_count         (rx_pcie_byte_cnt),
   .tx_payload_count      (tx_pcie_payload_cnt),
   .rx_payload_count      (rx_pcie_payload_cnt)
 ); 


// LEDs - Status
// ---------------
// Heart beat LED; flashes when primary PCIe core clock is present
always @(posedge user_clk)
begin
    led_ctr <= led_ctr + {{(LED_CTR_WIDTH-1){1'b0}}, 1'b1};
end
always @(posedge xgemac_clk_156)
begin
    led156_ctr <= led156_ctr + {{(LED_CTR_WIDTH-1){1'b0}}, 1'b1};
end
`ifdef SIMULATION
// Initialize for simulation
initial
begin
    led_ctr = {LED_CTR_WIDTH{1'b0}};
    led156_ctr = {LED_CTR_WIDTH{1'b0}};
end
`endif

always @(posedge user_clk or posedge user_reset)
begin
    if (user_reset == 1'b1)
        lane_width_error <= 1'b0;
    else
        lane_width_error <= (cfg_lstatus[9:4] != NUM_LANES); // Negotiated Link Width
end

// led[1] lights up when PCIe core has trained
assign led[1] = user_lnk_up; 

// led[2] flashes to indicate PCIe clock is running
assign led[2] = led_ctr[LED_CTR_WIDTH-1];            // Flashes when core_clk_i_div2 is present

// led[3] lights up when the correct lane width is acheived
// If the link is not operating at full width, it flashes at twice the speed of the heartbeat on led[1]
assign led[3] = lane_width_error ? led_ctr[LED_CTR_WIDTH-2] : 1'b1;

// Flashing indicates 156.25 MHz clock is alive
assign led[4] = led156_ctr[LED_CTR_WIDTH-1];

assign led[5] = xphy0_status[0]; 

assign led[6] = xphy1_status[0]; 

`ifdef USE_DDR3_FIFO
// When glowing, the DDR3 initialization has completed
assign led[7] = calib_done;
`else
assign led[7] = 1'b0;
`endif

  //- Tie off related to SFP+
  assign sfp_tx_disable = 2'b00;

  //- This LED indicates FMC connected OK
  assign fmc_ok_led = 1'b1;
    //- This LED indicates FMC GBTCLK0 programmed OK
  assign fmc_clk_312_5 = (fmc_gbtclk0_fsel == 2'b11) ? 1'b1 : 1'b0;

endmodule

