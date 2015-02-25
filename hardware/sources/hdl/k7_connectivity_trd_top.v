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
module k7_connectivity_trd_top #
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
    
    //clock_control ports
    inout                           i2c_clk,
    inout                           i2c_data,
        
//`ifdef USE_DDR3_FIFO
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
//`endif    
//`ifdef KC705_PVTMON
        //- Power monitoring for KC705
    inout                          pmbus_clk,
    inout                          pmbus_data,
    input                          pmbus_alert,
//`endif    
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
  wire                                  ref_clk; // clock input to pcie block , single ended output of IBUFDS: pcie_clk_p,pcie_clk_n as inputs
  wire                                  perst_n_c; // output of reset buffer
  
 
            
  wire                                  axi_str_s2c0_areset_n ;
    
  wire                                  axi_str_c2s0_areset_n ;
          
  wire                                  axi_str_s2c1_areset_n ;
  
  wire                                  axi_str_c2s1_areset_n ;

        
  reg     [LED_CTR_WIDTH-1:0]           led_ctr;
  reg                                   lane_width_error;
  reg     [LED_CTR_WIDTH-1:0]           led156_ctr;
  reg     [LED_CTR_WIDTH-1:0]           test_clk_ctr;

// -------------------
// -- Local Signals --
// -------------------

// Xilinx Hard Core Instantiation
  wire                                  calib_done;
  wire                                  user_clk;
  wire                                  user_reset;
  wire                                  user_lnk_up;
  wire                                  user_reset_c;
  wire                                  user_lnk_up_c;


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
  //wire                                  mmcm_locked_clk156   ;

//  wire                                  nw0_reset_i      ;
//  wire                                  nw1_reset_i      ;
 // wire                                  xphy0_tx_resetdone      ;
 // wire                                  xphy1_tx_resetdone      ;


  
//- Network Path signal declarations
`ifndef SIMULATION
  wire    [4:0]                                 xphy0_prtad;
  wire                                          xphy0_signal_detect;
  wire    [4:0]                                 xphy1_prtad;
  wire                                          xphy1_signal_detect;
`endif
 
  

              
  wire                                  ic_reset;
  reg [15:0]                            axi_ic_rst  = 16'd0;

  
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
  wire                                        core_clk156_out,clk156 ;
  wire                                        nw_0_reset,nw_1_reset;
  wire                                        [15:0] cfg_lstatus ;
  reg pipe_mmcm_rst_n = 1'b1;


// ---------------
// Clock and Reset
// ---------------

  wire [11:0] device_temp;
  wire clk50;
  reg [1:0] clk_divide = 2'b00;
  wire clk_200;
  wire mcb_clk; 


  assign clk_200 = mcb_clk;
  assign clk50 = clk156;


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
    .C      (user_clk       ),
    .CLR    (1'b0           ),
    .PRE    (1'b0           )

);

wire tx_cfg_gnt ;
  assign tx_cfg_gnt = 1'b1;


// ---------------------------------
// Physical Layer Control and Status
//assign pl_upstream_prefer_deemph    = 1'b1;

// -------------------------------
// Device Serial Number Capability

//assign cfg_dsn                      = DEVICE_SN;

//+++++++++++++++++++++++++++++++++++++++++++++++++++

// -------------------------
// Packet DMA Instance
// -------------------------

    // always use 250 MHz for GEN2
wire [7:0] clk_period_in_ns ;
    assign clk_period_in_ns = 8'h4; 

 // assign rx_np_req = 1'b1;

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

 
  assign xphy0_tx_fault = 1'b0;
  assign xphy1_tx_fault = 1'b0;

`ifndef SIMULATION
  assign xphy0_prtad  = 5'd0;
  assign xphy0_signal_detect = 1'b1;
`endif
//  assign dclk_i=clk50;

`ifndef SIMULATION
  assign xphy1_prtad  = 5'd1;
  assign xphy1_signal_detect = 1'b1;
`endif
 
  assign  nw0_reset = nw_0_reset;
  assign  nw1_reset = nw_1_reset;
 
// LEDs - Status
// ---------------
// Heart beat LED; flashes when primary PCIe core clock is present
always @(posedge user_clk)
begin
    led_ctr <= led_ctr + {{(LED_CTR_WIDTH-1){1'b0}}, 1'b1};
end
always @(posedge clk156)
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

// When glowing, the DDR3 initialization has completed
assign led[7] = calib_done;

  //- Tie off related to SFP+
  assign sfp_tx_disable = 2'b00;

  //- This LED indicates FMC connected OK
  assign fmc_ok_led = 1'b1;
    //- This LED indicates FMC GBTCLK0 programmed OK
  assign fmc_clk_312_5 = (fmc_gbtclk0_fsel == 2'b11) ? 1'b1 : 1'b0;

  
  // wires used in mmcme2_base  below:
  
  wire clkfbout,refclk_bufh,qplllock,clk156_buf,dclk_buf,mmcm_locked;
    
  wire mmcm_locked_clk156;

    
  
  wire sys_rst; //input to the network path (top level) 
 assign sys_rst = ~perst_n_c & ~mmcm_locked_clk156;
 
 // pcs/pma resetdone signals
 wire pcs_pma_0_resetdone,pcs_pma_1_resetdone; 
 
 wire pcs_pma_0_tx_resetdone,pcs_pma_0_rx_resetdone;
 wire pcs_pma_1_tx_resetdone,pcs_pma_1_rx_resetdone;
 
 assign pcs_pma_0_resetdone = pcs_pma_0_tx_resetdone && pcs_pma_0_rx_resetdone;
 assign pcs_pma_1_resetdone = pcs_pma_1_tx_resetdone && pcs_pma_1_rx_resetdone; //tx_resetdone,rx_resetdone is output of pcs/pma in the block design
 
 //tx_fault is separately defined (i/p of pcs/pma) xphy0_tx_fault and xphy1_tx_fault are declared and defined separetely above 
 
 // signal detect is declared and defined separetely for pcs/pma0 and pcs/pma1 as xphy0_signal_detect and xphy1_signal_detect.
 
reg core_reset_0;
reg core_reset_1;
reg core_reset_tmp_0;
reg core_reset_tmp_1;

`ifndef SIMULATION
wire core_clk156_out,clk156 ;
`endif


  always @(posedge clk156)
  begin
    if(~perst_n_c)
    begin
      core_reset_tmp_0 <= 1'b1;
      core_reset_tmp_1 <= 1'b1;
      core_reset_0 <= 1'b1;
      core_reset_1 <= 1'b1;
    end
    else
    begin
      // Hold core in reset until everything else is ready...
      core_reset_tmp_0 <= (!(pcs_pma_0_resetdone) || (sys_rst) || xphy0_tx_fault || !xphy0_signal_detect);
      core_reset_tmp_1 <= (!(pcs_pma_1_resetdone) || (sys_rst) || xphy1_tx_fault || !xphy1_signal_detect);
    
      core_reset_0 <= core_reset_tmp_0;
      core_reset_1 <= core_reset_tmp_1;  
     end
  end     
 
  assign clk156 = core_clk156_out ;
  
  
  wire rx_interface_0_reset,rx_interface_1_reset;
  wire ten_gig_mac_0_reset, ten_gig_mac_1_reset	;
  wire pcs_pma_0_reset, pcs_pma_1_reset ;
   
  assign rx_interface_0_reset = core_reset_0 ;
  assign rx_interface_1_reset = core_reset_1 ;
  
  assign ten_gig_mac_0_reset = core_reset_0 ;
  assign ten_gig_mac_1_reset = core_reset_1 ; 
  
  assign pcs_pma_0_reset = sys_rst ;
  assign pcs_pma_1_reset = sys_rst ;
  
 
  // core_reset_0 goes for rx_interface_0 and mac_0 and core_reset_1 for rx_interface_1 and mac_1.  
  
  //pcs/pma_0 and pcs/pma_1 both have same reset (sys_rst)  
  
  // resets for axis_interconnects
  
 // wire nw_0_reset,nw_1_reset;
  
  assign nw_0_reset = core_reset_0 ;
  assign nw_1_reset = core_reset_1 ;
  
  //axis_interconnect_0 (slave, write)
  wire s00_axis_aresetn,s01_axis_aresetn,s02_axis_aresetn,s03_axis_aresetn;
  //axis_interconnect_1 (master,read)
  wire m00_axis_aresetn,m01_axis_aresetn,m02_axis_aresetn,m03_axis_aresetn;
  
   assign s00_axis_aresetn = axi_str_s2c0_areset_n ;
   assign s01_axis_aresetn = ~nw_0_reset ; 
   assign s02_axis_aresetn = axi_str_s2c1_areset_n ;
   assign s03_axis_aresetn = ~nw_1_reset ;
  
   // axis_interconnect_1 (master, read)
   assign m00_axis_aresetn = ~nw_0_reset ;
   assign m01_axis_aresetn = axi_str_c2s0_areset_n ;
   assign m02_axis_aresetn = ~nw_1_reset ; 
   assign m03_axis_aresetn = axi_str_c2s1_areset_n ;
   
  // reset for axi4 lite interconnect
  wire user_reset_out;
  `ifdef SIMULATION
   reg sim_speed_control =1'b0;
   always @(posedge core_clk156_out)
      sim_speed_control = 1'b1;
    
   `else
     wire sim_speed_control =1'b0;
   `endif
  //wire mcb_clk;
  //wire [15:0] cfg_lstatus ;
  
  // other top level declarations
  
 // wire xphy0_rxp,xphy0_rxn,xphy1_rxp,xphy1_rxn;
// wire xphy0_txp,xphy0_txn,xphy1_txp,xphy1_txn ;
  //wire xphy0_refclk_n,xphy0_refclk_p ;
  
        k7_connectivity_trd_wrapper k7_connectivity_trd_wrapper_i
         (.DDR3_addr(ddr3_addr),
          .DDR3_ba(ddr3_ba),
          .DDR3_cas_n(ddr3_cas_n),
          .DDR3_ck_n(ddr3_ck_n),
          .DDR3_ck_p(ddr3_ck_p),
          .DDR3_cke(ddr3_cke),
          .DDR3_cs_n(ddr3_cs_n),
          .DDR3_dm(ddr3_dm),
          .DDR3_dq(ddr3_dq),
          .DDR3_dqs_n(ddr3_dqs_n),
          .DDR3_dqs_p(ddr3_dqs_p),
          .DDR3_odt(ddr3_odt),
          .DDR3_ras_n(ddr3_ras_n),
          .DDR3_reset_n(ddr3_reset_n),
          .DDR3_we_n(ddr3_we_n),
          //axi ic slave signals
          .axi_lite_aresetn(~ic_reset ),
          .axi_str_c2s0_areset_n(axi_str_c2s0_areset_n),
          .axi_str_c2s1_areset_n(axi_str_c2s1_areset_n),
          .axi_str_s2c0_areset_n(axi_str_s2c0_areset_n),
          .axi_str_s2c1_areset_n(axi_str_s2c1_areset_n),
          
          .cfg_lstatus(cfg_lstatus),
          .calib_done(calib_done),
          .clk50(clk50),
          .clk_ref_n(clk_ref_n),
          .clk_ref_p(clk_ref_p),
          .clk_period_in_ns(clk_period_in_ns),
          .core_clk156_out(core_clk156_out),
           
          .m00_axis_aresetn(m00_axis_aresetn),
          .m01_axis_aresetn(m01_axis_aresetn),
//          .m02_axis_aresetn(m02_axs_aresetn),
          .m03_axis_aresetn(m03_axis_aresetn),
          .mcb_clk(mcb_clk),
          .mmcm_locked_clk156(mmcm_locked_clk156),
          .pci_exp_rxn(rx_n),
          .pci_exp_rxp(rx_p),
          .pci_exp_txn(tx_n),
          .pci_exp_txp(tx_p),
          .pcie_link_up(user_lnk_up),
          .pcs_pma_0_reset(pcs_pma_0_reset),
          .pcs_pma_1_reset(pcs_pma_1_reset),
         // .pcs_pma_0_resetdone(pcs_pma_0_resetdone),
          .pcs_pma_0_rx_resetdone(pcs_pma_0_rx_resetdone),
          .pcs_pma_0_tx_resetdone(pcs_pma_0_tx_resetdone),
          .pcs_pma_1_rx_resetdone(pcs_pma_1_rx_resetdone),
          .pcs_pma_1_tx_resetdone(pcs_pma_1_tx_resetdone),
          .perst_n(perst_n_c),
          .pma_pmd_type(3'b101),
          .pmbus_alert(pmbus_alert),
          .pmbus_clk(pmbus_clk),
          .pmbus_control(),
          .pmbus_data(pmbus_data),
          .rx_interface_0_reset(rx_interface_0_reset),
          .rx_interface_0_soft_reset(~axi_str_c2s0_areset_n),
          .rx_interface_1_reset(rx_interface_1_reset),
          .rx_interface_1_soft_reset(~axi_str_c2s1_areset_n),
          .s00_axis_aresetn(s00_axis_aresetn),
          .s01_axis_aresetn(s01_axis_aresetn),
          .s02_axis_aresetn(s02_axis_aresetn),
          .s03_axis_aresetn(s03_axis_aresetn),
          .s_axis_pause_1_tdata(16'd0),
          .s_axis_pause_1_tvalid(8'b0),
          .s_axis_pause_tdata(16'd0),
          .s_axis_pause_tvalid(8'b0),
          `ifdef SIMULATION        
          .sim_speedup_control(sim_speed_control),
          .sim_speedup_control_1(sim_speed_control),
          `endif
          .sys_clk(ref_clk),
          .ten_gig_mac_0_reset(ten_gig_mac_0_reset),
          .ten_gig_mac_1_reset(ten_gig_mac_1_reset),
          .tx_disable(),
          .tx_disable_1(),
          .tx_ifg_delay(8'd0),
          .tx_ifg_delay_1(8'd0),
          .tx_cfg_gnt(tx_cfg_gnt),
          .user_clk_out(user_clk),
          .user_lnk_up(user_lnk_up_c),
          .user_reset(user_reset),
          .user_reset_out(user_reset_c),
          .xphy0_prtad(xphy0_prtad),
          .xphy0_refclk_n(xphy0_refclk_n),
          .xphy0_refclk_p(xphy0_refclk_p),
          .xphy0_rxn(xphy0_rxn),
          .xphy0_rxp(xphy0_rxp),
          .xphy0_signal_detect(xphy0_signal_detect),
          .xphy0_status(xphy0_status),
          .xphy0_tx_fault(xphy0_tx_fault),
          .xphy0_txn(xphy0_txn),
          .xphy0_txp(xphy0_txp),
          .xphy1_prtad(xphy1_prtad),
          .xphy1_rxn(xphy1_rxn),
          .xphy1_rxp(xphy1_rxp),
          .xphy1_signal_detect(xphy1_signal_detect),
          .xphy1_status(xphy1_status),
          .xphy1_tx_fault(xphy1_tx_fault),
          .xphy1_txn(xphy1_txn),
          .xphy1_txp(xphy1_txp));
          

             
         endmodule  
        
                  
                  
                 
                  
                  
                  
                                    
                  
                  
                  
     
      
                   
                 
                  
                  
                 
                  
                 
                  
                                                                                                                   
                  
                  
                 
                  
                  
                
                  
       

