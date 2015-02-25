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
// File       : board.v
// Description:  Top level testbench
//
//------------------------------------------------------------------------------

`timescale 1ps/1ps

`include "board_common.h"
`include "dut_defines.h"
`include "user_defines.h"

module board;

parameter          REF_CLK_FREQ                 = 0;      // 0 - 100 MHz, 1 - 125 MHz,  2 - 250 MHz
parameter          CAPABILITY_LINK_WIDTH        = 6'h08;  // 1 - x1, 2 - x2, 4 - x4, 8 - x8  
parameter          CAPABILITY_LINK_SPEED        = 4'h1;   // 1 - Gen1 only, 2 - Gen2  

parameter          USER_CLK_FREQ                = 4;      // 0 - 31.25 MHz, 1 - 62.5 MHz,  2 - 125 MHz, 3 - 250 MHz

parameter          CAPABILITY_MAX_PAYLOAD_SIZE  = 3'h1;   // 0 - 128B, 1 - 256B, 3 - 512B, 4 - 1024B
parameter          UPCONFIG_CAPABLE             = "TRUE"; 
parameter          LINK_CAP_MAX_LINK_SPEED = 4'h2;
parameter          LINK_CTRL2_TARGET_LINK_SPEED = 4'h2;

parameter          LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP = "TRUE" ; 
                                    
localparam         REF_CLK_HALF_CYCLE = (REF_CLK_FREQ == 0) ? 5000 :
                                        (REF_CLK_FREQ == 1) ? 4000 :
                                        (REF_CLK_FREQ == 2) ? 2000 : 0;
integer            i_;

`ifdef USE_DDR3_FIFO
localparam MEMORY_WIDTH = 8;
localparam CS_WIDTH = 1;
localparam CKE_WIDTH = 1;
localparam CK_WIDTH =1;
localparam nCS_PER_RANK = 1;

wire [13:0]                ddr_addr;               
wire [CK_WIDTH-1:0]        ddr_ck;                 
wire [CK_WIDTH-1:0]        ddr_ck_n;               
wire [CKE_WIDTH-1:0]       ddr_cke;                
wire [(CS_WIDTH*nCS_PER_RANK)-1:0]       ddr_cs_n;               
wire [(CS_WIDTH*nCS_PER_RANK)-1:0]       ddr_odt;               
//localparam MEMORY_WIDTH = 16;
//localparam NUM_COMP = DQ_WIDTH/MEMORY_WIDTH;
localparam DQ_WIDTH = 64;
localparam NUM_COMP = DQ_WIDTH/MEMORY_WIDTH;
wire [2:0]  ddr_ba;                 
wire        ddr_cas_n;              
wire [7:0]  ddr_dm;                 
wire [63:0] ddr_dq;                 
wire [7:0]  ddr_dqs;                
wire [7:0]  ddr_dqs_n;              
wire        ddr_ras_n;              
wire        ddr_reset_n;            
wire        ddr_we_n;               
`endif
//
// System reset
//

reg                sys_reset_n;

//
// System clocks
//

reg                                   rp_sys_clk;
reg clk_156; 
reg sys_clk;
reg mcb_clk;
wire mcb_clk_p;
wire mcb_clk_n;
wire clk_ref_p;
wire clk_ref_n;

`ifdef USE_PIPE_SIM
   parameter PIPE_SIM = "TRUE";
   `ifdef IPI_FLOW
     defparam board.dut.k7_connectivity_trd_wrapper_i.k7_connectivity_trd_i.PCIe_Path.pcie_7x_0.inst.inst.PIPE_SIM_MODE = "TRUE";
    `else
     defparam board.dut.pcie_inst.inst.inst.PIPE_SIM_MODE = "TRUE";
    `endif 
  defparam board.RP.rport.PIPE_SIM_MODE = "TRUE";
`else
  parameter PIPE_SIM = "FALSE";
   `ifdef IPI_FLOW
     defparam board.dut.k7_connectivity_trd_wrapper_i.k7_connectivity_trd_i.PCIe_Path.pcie_7x_0.inst.inst.PIPE_SIM_MODE = "TRUE";
   `else
     defparam board.dut.pcie_inst.inst.inst.PIPE_SIM_MODE = "TRUE";
   `endif 
   defparam board.RP.rport.PIPE_SIM_MODE = "FALSE";
`endif

//
// PCI-Express Serial Interconnect
//

wire  [(CAPABILITY_LINK_WIDTH - 1):0]  ep_pci_exp_txn;
wire  [(CAPABILITY_LINK_WIDTH - 1):0]  ep_pci_exp_txp;
wire  [(CAPABILITY_LINK_WIDTH - 1):0]  rp_pci_exp_txn;
wire  [(CAPABILITY_LINK_WIDTH - 1):0]  rp_pci_exp_txp;

//- 5000 * 1ps = 5ns, 200 MHz clock - used for DDR3 MCB
`define MCB_REF_CLK 5000

  //- Closest even number to 96.9696
`define BITPERIOD 98  

//`define PERIOD_156 (66*98)
`define PERIOD_156 3200

  wire xphy0_txp;
  wire xphy0_txn;
  wire xphy1_txp;
  wire xphy1_txn;

  reg clk156 = 1'b0;

  initial
  begin
    clk156  <= 1'b0;
    forever #(`PERIOD_156/2) clk156 = ~clk156;
  end  
  
k7_connectivity_trd_top #(
 // .PL_FAST_TRAIN  ("TRUE"),
 // .NUM_LANES      (8)
)
dut (

    .perst_n(sys_reset_n),        // PCI Express slot PERST# reset signal
        
    .pcie_clk_p(rp_sys_clk),     // PCIe differential reference clock input
    .pcie_clk_n(~rp_sys_clk),     // PCIe differential reference clock input

    .tx_p(ep_pci_exp_txp),           // PCIe differential transmit output
    .tx_n(ep_pci_exp_txn),           // PCIe differential transmit output

    .rx_p(rp_pci_exp_txp),           // PCIe differential receive output
    .rx_n(rp_pci_exp_txn),           // PCIe differential receive output

    .xphy0_refclk_p(clk156), 
    .xphy0_refclk_n(~clk156), 
`ifdef USE_DIFF_QUAD    
    .xphy0_txp(xphy0_txp),
    .xphy0_txn(xphy0_txn),
    .xphy0_rxp(xphy0_txn),
    .xphy0_rxn(xphy0_txp),
`else
    .xphy0_txp(xphy0_txp),
    .xphy0_txn(xphy0_txn),
    .xphy0_rxp(xphy0_txp),
    .xphy0_rxn(xphy0_txn),
`endif
`ifdef SIMULATION    
    .xphy0_signal_detect(1'b1),
    .xphy0_prtad(5'd0),
    .xphy1_signal_detect(1'b1),
    .xphy1_prtad(5'd1),
`endif
    
`ifdef USE_DIFF_QUAD    
    .xphy1_txp(xphy1_txp),
    .xphy1_txn(xphy1_txn),
    .xphy1_rxp(xphy1_txn),
    .xphy1_rxn(xphy1_txp),
`else
    .xphy1_txp(xphy1_txp),
    .xphy1_txn(xphy1_txn),
    .xphy1_rxp(xphy1_txp),
    .xphy1_rxn(xphy1_txn),
`endif

`ifdef USE_DDR3_FIFO
     .clk_ref_p         (clk_ref_p),
     .clk_ref_n         (clk_ref_n),
     
     .ddr3_addr          (ddr_addr),
     .ddr3_ba            (ddr_ba),
     .ddr3_cas_n         (ddr_cas_n),
     .ddr3_ck_p          (ddr_ck),
     .ddr3_ck_n          (ddr_ck_n),
     .ddr3_cke           (ddr_cke),
     .ddr3_cs_n          (ddr_cs_n),
     .ddr3_dm            (ddr_dm),
     .ddr3_dq            (ddr_dq),
     .ddr3_dqs_p         (ddr_dqs),
     .ddr3_dqs_n         (ddr_dqs_n),
     .ddr3_odt           (ddr_odt),
     .ddr3_ras_n         (ddr_ras_n),
     .ddr3_reset_n       (ddr_reset_n),
     .ddr3_we_n          (ddr_we_n),
`endif     
    .led ()            // Diagnostic LEDs
 
    );
   
//
// PCI-Express Model Root Port Instance
//
xilinx_pcie_2_1_rport_7x # (

  .REF_CLK_FREQ(REF_CLK_FREQ),
  .ALLOW_X8_GEN2("TRUE"),
  .C_DATA_WIDTH(128),
  .UPCONFIG_CAPABLE(UPCONFIG_CAPABLE),
  .LINK_CAP_MAX_LINK_SPEED(LINK_CAP_MAX_LINK_SPEED),
  .LINK_CTRL2_TARGET_LINK_SPEED(LINK_CTRL2_TARGET_LINK_SPEED),
  .LINK_CAP_MAX_LINK_WIDTH(CAPABILITY_LINK_WIDTH),
  .USER_CLK_FREQ(USER_CLK_FREQ),
  .USER_CLK2_DIV2 ("TRUE"),
  .PL_FAST_TRAIN("TRUE"),
  .DEVICE_ID(16'h7100),
  .DEV_CAP_MAX_PAYLOAD_SUPPORTED(1),
  .VC0_TX_LASTPACKET(28),
  .VC0_RX_RAM_LIMIT(13'h3FF),
  .VC0_CPL_INFINITE("TRUE"),
  .VC0_TOTAL_CREDITS_PD(32),
  .VC0_TOTAL_CREDITS_CD(370),
  .TRN_DW ("TRUE"),
  .LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP(LINK_CAP_DLL_LINK_ACTIVE_REPORTING_CAP)
) RP (

  // SYS Inteface
  .sys_clk(rp_sys_clk),
  .sys_rst_n(sys_reset_n),

  // PCI-Express Interface
  .pci_exp_txn(rp_pci_exp_txn),
  .pci_exp_txp(rp_pci_exp_txp),
  .pci_exp_rxn(ep_pci_exp_txn),
  .pci_exp_rxp(ep_pci_exp_txp)

);


//`ifdef USE_DDR3_FIFO

genvar i,r;
  for (r = 0; r < CS_WIDTH; r = r + 1) begin: mem_rnk
    for (i = 0; i < NUM_COMP; i = i + 1) begin: gen_mem
      
          ddr3_model #(
            .DEBUG (0)
          ) u_comp_ddr3
            (
             .rst_n   (ddr_reset_n),
             .ck      (ddr_ck[(i*MEMORY_WIDTH)/72]),
             .ck_n    (ddr_ck_n[(i*MEMORY_WIDTH)/72]),
             .cke     (ddr_cke[((i*MEMORY_WIDTH)/72)+(nCS_PER_RANK*r)]),
             .cs_n    (ddr_cs_n[((i*MEMORY_WIDTH)/72)+(nCS_PER_RANK*r)]),
             .ras_n   (ddr_ras_n),
             .cas_n   (ddr_cas_n),
             .we_n    (ddr_we_n),
             .dm_tdqs (ddr_dm[i]),
             .ba      (ddr_ba),
             .addr    (ddr_addr),
             .dq      (ddr_dq[MEMORY_WIDTH*(i+1)-1:MEMORY_WIDTH*(i)]),
             .dqs     (ddr_dqs[i]),
             .dqs_n   (ddr_dqs_n[i]),
             .tdqs_n  (),
             .odt     (ddr_odt[((i*MEMORY_WIDTH)/72)+(nCS_PER_RANK*r)])
             );
      end
    end  

//`endif

// 100 MHz clock for PCIe
//- 2 * 5000 * 1ps = 10ns, 100 MHz Clock - used for PCIe interface
 initial 
 begin
   rp_sys_clk = 1'b0;
   forever #(REF_CLK_HALF_CYCLE) rp_sys_clk = ~rp_sys_clk;
 end

// 156.25 Mhz clock for 10GBASE-R interface
 initial 
 begin
   clk_156 = 1'b0;
   forever #(`PERIOD_156/2) clk_156 = ~clk_156;
 end

 // MCB clock generation
 initial 
 begin 
  sys_clk = 1'b0;
  forever #(`MCB_REF_CLK/2) sys_clk = ~sys_clk;
 end
assign clk_ref_p = sys_clk;
assign clk_ref_n = ~sys_clk;

  `include "pipe_interconnect.h"

initial begin

  $display("[%t] : System Reset Asserted...", $realtime);

  sys_reset_n = 1'b0;

  for (i_ = 0; i_ < 100; i_ = i_ + 1) begin

    @(posedge rp_sys_clk);

  end

  $display("[%t] : System Reset De-asserted...", $realtime);

  sys_reset_n = 1'b1;

end

endmodule // BOARD
