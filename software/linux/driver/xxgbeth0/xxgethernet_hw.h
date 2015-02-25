/*******************************************************************************
** © Copyright 2012 - 2013 Xilinx, Inc. All rights reserved.
** This file contains confidential and proprietary information of Xilinx, Inc. and 
** is protected under U.S. and international copyright and other intellectual property laws.
*******************************************************************************
**   ____  ____ 
**  /   /\/   / 
** /___/  \  /   Vendor: Xilinx 
** \   \   \/    
**  \   \
**  /   /          
** /___/    \
** \   \  /  \   Kintex-7 PCIe-DMA-DDR3-10GMAC-10GBASER Targeted Reference Design
**  \___\/\___\
** 
**  Device: xc7k325t
**  Version: 1.0
**  Reference: UG927
**     
*******************************************************************************
**
**  Disclaimer: 
**
**    This disclaimer is not a license and does not grant any rights to the materials 
**    distributed herewith. Except as otherwise provided in a valid license issued to you 
**    by Xilinx, and to the maximum extent permitted by applicable law: 
**    (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, 
**    AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
**    INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR 
**    FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract 
**    or tort, including negligence, or under any other theory of liability) for any loss or damage 
**    of any kind or nature related to, arising under or in connection with these materials, 
**    including for any direct, or any indirect, special, incidental, or consequential loss 
**    or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered 
**    as a result of any action brought by a third party) even if such damage or loss was 
**    reasonably foreseeable or Xilinx had been advised of the possibility of the same.


**  Critical Applications:
**
**    Xilinx products are not designed or intended to be fail-safe, or for use in any application 
**    requiring fail-safe performance, such as life-support or safety devices or systems, 
**    Class III medical devices, nuclear facilities, applications related to the deployment of airbags,
**    or any other applications that could lead to death, personal injury, or severe property or 
**    environmental damage (individually and collectively, "Critical Applications"). Customer assumes 
**    the sole risk and liability of any use of Xilinx products in Critical Applications, subject only 
**    to applicable laws and regulations governing limitations on product liability.

**  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.

*******************************************************************************/
/*****************************************************************************/
/**
 *
* @file xxgethernet_hw.h
*
* This header file contains identifiers and macros that can be used to access
* the XGEMAC Ethernet device. The driver APIs/functions are defined in
* xxgethernet.h.
*
* @note
*
* MODIFICATION HISTORY:
*
* Ver  Date     Changes
* ------------- -------------------------------------------------------
* 1.0  05/15/12 First release

******************************************************************************/
#ifndef XXGETHERNET_HW_H		/* prevent circular inclusions */
#define XXGETHERNET_HW_H		/* by using protection macros */

/******************************XPS_LL_MAC*************************************/
#ifdef	XPS__LL_MAC_H
#undef	XPS__LL_MAC_H
#endif

/***************************** Include Files *********************************/

#include "xdebug.h"

#include "xio.h"
#include "xbasic_types.h"

#ifdef __cplusplus
extern "C" {
#endif

/************************** Constant Definitions *****************************/

/*
 * Register offset definitions. Unless otherwise noted, register access is
 * 32 bit.
 */


/*
 * Statistics Counter Registers are from offset 0x200 to 0x30C
 * They are defined from offset 0x200 to 0x30C in this device.
 * The offsets from 0x350 to 0x3FF are reserved.
 * The counters are 64 bit.
 * The Least Significant Word (LSW) are stored in one 32 bit register and
 * the Most Significant Word (MSW) are stored in one 32 bit register
 */
/* Start of Statistics Counter Registers Definitions */
#define XXGE_RXBL_OFFSET		0x00000200 /**< Received Bytes, LSW */
#define XXGE_RXBU_OFFSET		0x00000204 /**< Received Bytes, MSW */
#define XXGE_TXBL_OFFSET		0x00000208 /**< Transmitted Bytes, LSW */
#define XXGE_TXBU_OFFSET		0x0000020C /**< Transmitted Bytes, MSW */
#define XXGE_RXUNDRL_OFFSET	        0x00000210 /**< Count of undersize(less than
					     *  64 bytes) frames received,
					     *  LSW
					     */
#define XXGE_RXUNDRU_OFFSET		0x00000214 /**< Count of undersize(less than
					     *  64 bytes) frames received,
					     *  MSW
					     */
#define XXGE_RXFRAGL_OFFSET		0x00000218 /**< Count of undersized(less
					     *  than 64 bytes) and bad FCS
					     *  frames received, LSW
					     */
#define XXGE_RXFRAGU_OFFSET		0x0000021C /**< Count of undersized(less
					     *  than 64 bytes) and bad FCS
					     *  frames received, MSW
					     */
#define XXGE_RX64BL_OFFSET		0x00000220 /**< Count of 64 bytes frames
					     *  received, LSW
					     */
#define XXGE_RX64BU_OFFSET		0x00000224 /**< Count of 64 bytes frames
					     *  received, MSW
					     */
#define XXGE_RX65B127L_OFFSET		0x00000228 /**< Count of 65-127 bytes
					     *  Frames received, LSW
					     */
#define XXGE_RX65B127U_OFFSET		0x0000022C /**< Count of 65-127 bytes
					     *  Frames received, MSW
					     */
#define XXGE_RX128B255L_OFFSET	0x00000230 /**< Count of 128-255 bytes
					     *  Frames received, LSW
					     */
#define XXGE_RX128B255U_OFFSET	0x00000234 /**< Count of 128-255 bytes
					     *  frames received, MSW
					     */
#define XXGE_RX256B511L_OFFSET	0x00000238 /**< Count of 256-511 bytes
					     *  Frames received, LSW
					     */
#define XXGE_RX256B511U_OFFSET	0x0000023C /**< Count of 256-511 bytes
					     *  frames received, MSW
					     */
#define XXGE_RX512B1023L_OFFSET	0x00000240 /**< Count of 512-1023 bytes
					     *  frames received, LSW
					     */
#define XXGE_RX512B1023U_OFFSET	0x00000244 /**< Count of 512-1023 bytes
					     *  frames received, MSW
					     */
#define XXGE_RX1024BL_OFFSET	0x00000248 /**< Count of 1024-MAX bytes
					     *  frames received, LSW
					     */
#define XXGE_RX1024BU_OFFSET	0x0000024C /**< Count of 1024-MAX bytes
					     *  frames received, MSW
					     */
#define XXGE_RXOVRL_OFFSET	0x00000250 /**< Count of oversize frames
					     *  received, LSW
					     */
#define XXGE_RXOVRU_OFFSET	0x00000254 /**< Count of oversize frames
					     *  received, MSW
					     */
#define XXGE_TX64BL_OFFSET	0x00000258 /**< Count of 64 bytes frames
					     *  transmitted, LSW
					     */
#define XXGE_TX64BU_OFFSET	0x0000025C /**< Count of 64 bytes frames
					     *  transmitted, MSW
					     */
#define XXGE_TX65B127L_OFFSET		0x00000260 /**< Count of 65-127 bytes
					     *  error-free frames transmitted, LSW
					     */
#define XXGE_TX65B127U_OFFSET		0x00000264 /**< Count of 65-127 bytes
					     *  error-free  frames transmitted, MSW
					     */
#define XXGE_TX128B255L_OFFSET	0x00000268 /**< Count of 128-255 bytes
					     *   error-free frames transmitted, LSW
					     */
#define XXGE_TX128B255U_OFFSET	0x0000026C /**< Count of 128-255 bytes
					     *   error-free frames transmitted, MSW
					     */
#define XXGE_TX256B511L_OFFSET	0x00000270 /**< Count of 256-511 bytes
					     *   error-free frames transmitted, LSW
					     */
#define XXGE_TX256B511U_OFFSET	0x00000274 /**< Count of 256-511 bytes
					     *   error-free frames transmitted, MSW
					     */
#define XXGE_TX512B1023L_OFFSET	0x00000278 /**< Count of 512-1023 bytes
					     *   error-free frames transmitted, LSW
					     */
#define XXGE_TX512B1023U_OFFSET	0x0000027C /**< Count of 512-1023 bytes
					     *   error-free frames transmitted, MSW
					     */
#define XXGE_TX1024L_OFFSET	0x00000280 /**< Count of 1024-MAX bytes
					     *   error-free frames transmitted, LSW
					     */
#define XXGE_TX1024U_OFFSET	0x00000284 /**< Count of 1024-MAX bytes
					     *   error-free frames transmitted, MSW
					     */
#define XXGE_TXOVRL_OFFSET	0x00000288 /**< Count of oversize frames
					     *  transmitted, LSW
					     */
#define XXGE_TXOVRU_OFFSET	0x0000028C /**< Count of oversize frames
					     *  transmitted, MSW
					     */
#define XXGE_RXFL_OFFSET		0x00000290 /**< Count of frames received OK,
					     *  LSW
					     */
#define XXGE_RXFU_OFFSET		0x00000294 /**< Count of frames received OK,
					     *  MSW
					     */
#define XXGE_RXFCSERL_OFFSET	0x00000298 /**< Count of frames received with
					     *  FCS error and at least 64 bytes, LSW
					     */
#define XXGE_RXFCSERU_OFFSET	0x0000029C /**< Count of frames received with
					     *  FCS error and at least 64 bytes,MSW
					     */
#define XXGE_RXBCSTFL_OFFSET	0x000002A0 /**< Count of broadcast frames
					     *  received, LSW
					     */
#define XXGE_RXBCSTFU_OFFSET	0x000002A4 /**< Count of broadcast frames
					     *  received, MSW
					     */
#define XXGE_RXMCSTFL_OFFSET	0x000002A8 /**< Count of multicast frames
					     *  received, LSW
					     */
#define XXGE_RXMCSTFU_OFFSET	0x000002AC /**< Count of multicast frames
					     *  received, MSW
					     */
#define XXGE_RXCTRFL_OFFSET	0x000002B0 /**< Count of control frames
					     *  received, LSW
					     */
#define XXGE_RXCTRFU_OFFSET	0x000002B4 /**< Count of control frames
					     *  received, MSW
					     */
#define XXGE_RXLTERL_OFFSET	0x000002B8 /**< Count of frames received
					     *  with length/type error, LSW
					     */
#define XXGE_RXLTERU_OFFSET	0x000002BC /**< Count of frames received
					     *  with length/type error, MSW
					     */
#define XXGE_RXVLANFL_OFFSET	0x000002C0 /**< Count of VLAN tagged
					     *  frames received, LSW
					     */
#define XXGE_RXVLANFU_OFFSET	0x000002C4 /**< Count of VLAN tagged frames
					     *  received, MSW
					     */
#define XXGE_RXPFL_OFFSET		0x000002C8 /**< Count of pause frames received,
					     *  LSW
					     */
#define XXGE_RXPFU_OFFSET		0x000002CC /**< Count of pause frames received,
					     *  MSW
					     */
#define XXGE_RXUOPFL_OFFSET		0x000002D0 /**< Count of control frames
					     *  received with unsupported
					     *  opcode, LSW
					     */
#define XXGE_RXUOPFU_OFFSET		0x000002D4 /**< Count of control frames
					     *  received with unsupported
					     *  opcode, MSW
					     */
#define XXGE_TXFL_OFFSET			0x000002D8 /**< Count of frames transmitted OK,
					     *  LSW
					     */
#define XXGE_TXFU_OFFSET			0x000002DC /**< Count of frames transmitted OK,
					     *  MSW
					     */
#define XXGE_TXBCSTFL_OFFSET		0x000002E0 /**< Count of broadcast frames
					     *  transmitted OK, LSW
					     */
#define XXGE_TXBCSTFU_OFFSET		0x000002E4 /**< Count of broadcast frames
					     *  transmitted, MSW
					     */
#define XXGE_TXMCSTFL_OFFSET		0x000002E8 /**< Count of multicast frames
					     *  transmitted, LSW
					     */
#define XXGE_TXMCSTFU_OFFSET		0x000002EC /**< Count of multicast frames
					     *  transmitted, MSW
					     */
#define XXGE_TXUNDRERL_OFFSET		0x000002F0 /**< Count of frames transmitted
					     *  underrun error, LSW
					     */
#define XXGE_TXUNDRERU_OFFSET	0x000002F4 /**< Count of frames transmitted
					     *  underrun error, MSW
					     */
#define XXGE_TXCTRFL_OFFSET	0x000002F8 /**< Count of error-free frames transmitted  
					     *  transmitted, that contained the MAC Control Frame type 
					     * identifier 88-08 in the length/type field, LSW
					     */
#define XXGE_TXCTRFU_OFFSET	0x000002FC /**< Count of error-free frames transmitted  
					     *  transmitted, that contained the MAC Control Frame type 
					     * identifier 88-08 in the length/type field, MSW
					     */
#define XXGE_TXVLANFL_OFFSET	0x00000300 /**< Count of VLAN tagged frames
					     *  transmitted, LSW
					     */
#define XXGE_TXVLANFU_OFFSET	0x00000304 /**< Count of VLAN tagged
					     *  frames transmitted, MSW
					     */
#define XXGE_TXPFL_OFFSET		0x00000308 /**< Count of pause frames
					     *  transmitted, LSW
					     */
#define XXGE_TXPFU_OFFSET		0x0000030C /**< Count of pause frames
					     *  transmitted, MSW
					     */
					     
/* End of Statistics Counter Registers Offset definitions */

/* ??? */
#define XXGE_RCW0_OFFSET	0x00000400 /**< Rx Configuration Word 0 */
#define XXGE_RCW1_OFFSET	0x00000404 /**< Rx Configuration Word 1 */
#define XXGE_TC_OFFSET		0x00000408 /**< Tx Configuration */
#define XXGE_FCC_OFFSET		0x0000040C /**< Flow Control Configuration */
//NOT using this...
#define XXGE_GERS_OFFSET	0x00000410 /**< Reconciliation Sublayer Configuration ~chng.. */
	/** GERS: gigabit Ethernet reconciliation sublayer  */
#define XXGE_RMTU_OFFSET	0x00000414 /**< Receiver MTU Configuration Word ~chng..  */
#define XXGE_TMTU_OFFSET	0x00000418 /**< Transmitter MTU Configuration Word ~chng.. */
#define XXGE_VER_OFFSET		0x000004F8 /**< Version Register (Read Only) ~chng.. */
#define XXGE_CAP_OFFSET		0x000004FC /**< Capability Register (Read Only) ~chng.. */
									 //we may not use this...b3 is only useful

#define XXGE_MDIO_REGISTER_ADDRESS  32         /* Register to read for getting phy status */
#define XXGE_MDIO_CFG0_OFFSET       0x00000500 /**< MDIO Configuration word 0 */
#define XXGE_MDIO_CFG1_OFFSET	    0x00000504 /**< MDIO Configuration word 1 */
#define XXGE_MDIO_TX_DATA_OFFSET    0x00000508 /**< MDIO TX Data */
#define XXGE_MDIO_RX_DATA_OFFSET	0x0000050C /**< MDIO RX Data (Read-only) */

#define XXGE_TC_TXCONTROLBIT            0x1C /* Set this bit to 0 to disable transmission */


/* custom registers implemented in the user space */
#if defined     XGEMAC_MAC1__
  // IN KINTEX-7, THESE OFFSETS ARE W.R.T. DMA BASE ADDRESS
  // MAC address program is done in DMA driver.
  #define XXGE_AFC_OFFSET     0x00009400  /**< Address Filtering Control Register  for MAC1 */
  #define XXGE_MACL_OFFSET    0x00009404  /**< XGEMAC1 MAC Address Lower Register  */
  #define XXGE_MACU_OFFSET    0x00009408  /**< XGEMAC1 MAC Address Upper Register */
#elif   defined         XGEMAC_MAC2__
  // IN KINTEX-7, THESE OFFSETS ARE W.R.T. DMA BASE ADDRESS
  // MAC address program is done in DMA driver.
  #define XXGE_AFC_OFFSET     0x0000940C  /**< Address Filtering Control Register  for MAC2 */
  #define XXGE_MACL_OFFSET    0x00009410  /**< XGEMAC2 MAC Address Lower Register */
  #define XXGE_MACU_OFFSET    0x00009414  /**< XGEMAC2 MAC Address Upper Register */
#else
#Warning: No MAC is attached to this Driver instance Neither MAC1 nor MAC2.
#endif





/* ******************************************************************************* */



#define XXGE_AFC_PM_MASK	     	0x00000004 /**< Enable the 
						    *   Promiscuous Mode 
						    */
						    
/** @name Transmit Pause Frame Register (TPF) bit definitions
 *  @{
 */
#define XXGE_TPF_TPFV_MASK		0x0000FFFF /**< Tx pause frame value */
/*@}*/

/** @name Receive Configuration Word 1 (RCW1) Register bit definitions
 *  @{
 */
#define XXGE_RCW1_RST_MASK		0x80000000 /**< Reset */
#define XXGE_RCW1_JUM_MASK	0x40000000 /**< Jumbo frame enable */
#define XXGE_RCW1_FCS_MASK	0x20000000 /**< In-Band FCS enable
					     *  (FCS not stripped) */
#define XXGE_RCW1_RX_MASK	0x10000000 /**< Receiver enable */
#define XXGE_RCW1_VLAN_MASK	0x08000000 /**< VLAN frame enable */
#define XXGE_RCW1_HD_MASK	0x04000000 /**< Receiver Preserve Preamble Enable !!chng... change HD<->PP */
#define XXGE_RCW1_LT_DIS_MASK	0x02000000 /**< Length/type field valid check
					     *  disable
					     */
#define XXGE_RCW1_CL_DIS_MASK	0x01000000 /**< Control frame Length check
					     *  disable
					     */
#define XXGE_RCW1_PAUSEADDR_MASK 0x0000FFFF /**< Pause frame source
					     *  address bits [47:32].Bits
					     *	[31:0] are stored in register
					     *  RCW0
					     */
/*@}*/


/** @name Transmitter Configuration (TC) Register bit definitions
 *  @{
 */
#define XXGE_TC_RST_MASK		0x80000000 /**< Reset */
#define XXGE_TC_JUM_MASK		0x40000000 /**< Jumbo frame enable */
#define XXGE_TC_FCS_MASK		0x20000000 /**< In-Band FCS enable
					     *  (FCS not generated)
					     */
#define XXGE_TC_TX_MASK		0x10000000 /**< Transmitter enable */
#define XXGE_TC_VLAN_MASK	0x08000000 /**< VLAN frame enable */
#define XXGE_TC_HD_MASK		0x04000000 /**< WAN Mode Enable !!chng...bit-26 we may NOT use*/
#define XXGE_TC_IFG_MASK		0x02000000 /**< Inter-frame gap adjustment
					      * enable
					      */
/* !!chng... */
#define XXGE_TC_TPP_MASK		0x00800000 /**< Transmitter Preserve Preamble Enable ...b23 we may NOT use*/
#define XXGE_TC_DIC_MASK		0x01000000/**< Deficit Idle Count Enable ...b24 */
/*@}*/


/** @name Flow Control Configuration (FCC) Register Bit definitions
 *  @{
 */
#define XXGE_FCC_FCRX_MASK	0x20000000   /**< Rx flow control enable */
#define XXGE_FCC_FCTX_MASK	0x40000000   /**< Tx flow control enable */
/*@}*/

/* * @name Reconciliation Sublayer Configuration  Register bit definitions
* @{
*/
#define XXGE_RSC_FI_MASK 		0x08000000 /**< Fault Inhibit ...b27 */
#define XXGE_RSC_LFR_MASK	 	0x10000000 /**< Local Fault Received ...b28 */
#define XXGE_RSC_SGMII_MASK	 	0x20000000 /**< Remote Fault Received ...b29 */
#define XXGE_RSC_GPCS_MASK	 	0x40000000 /**< Transmit DCM(Digital Clock) Locked ...b30 */
#define XXGE_RSC_HOST_MASK	 	0x80000000 /**< Receive DCM(Digital Clock) Locked ...b31 */


/* * @name Receiver MTU Configuration Register bit definitions
* @{
*/
#define XXGE_RMTU_FI_MASK 		0x00010000  /**< RX MTU Enable ...b16 */
#define XXGE_RMTU_LFR_MASK	 	0x  /**< RX MTU Size ...b14:0 default:0x05EE */


/* * @name Transmitter MTU Configuration Register bit definitions
* @{
*/
#define XXGE_TMTU_FI_MASK 		0x00010000    	/**< TX MTU Enable ...b16 */
#define XXGE_TMTU_LFR_MASK	 	0x0001FFFF		 /**< TX MTU Size ...b14:0 default:0x05EE */


/* * @name Version Register bit definitions
* @{
*/
#define XXGE_VER_MAJ 		0xFF000000  /**< Major Revision ...b31:24 default:0x0B */
#define XXGE_VER_MIN 		0x00FF0000  /**< Minor Revision ...b23:16 default:0x01 */
#define XXGE_VER_PTCH	 	0x000000FF  /**< Patch Level (0x00 - No Patch, 0x01 – Rev1 etc.) ...b7:0 default:0x00 */


/* * @name Capability Register  bit definitions
* @{
*/
#define XXGE_CAP_STAT_MASK 		0x00000100 /**<  Core has statistics counters ...b8 */
#define XXGE_CAP_LC10G_MASK	 	0x00000008  /**< Line rate capability- 10Gbit ...b3 */
#define XXGE_CAP_LC1G_MASK	 	0x00000004 /**< Line rate capability- 1Gbit ...b2 */
#define XXGE_CAP_LC100M_MASK	 	0x00000002  /**< Line rate capability- 100Mbit ...b1 */
#define XXGE_CAP_LC10M_MASK	 	0x00000001  /**< Line rate capability- 10Mbit ...b0 */


/** @name MDIO Management Configuration (MC) Register bit definitions
 * @{
 */
#define XXGE_MDIO_CFG0_MDIOEN_MASK		0x00000040  /**< MII management enable*/
#define XXGE_MDIO_CFG0_CLOCK_DIVIDE_MAX	0x3F        /**< Maximum MDIO divisor */
#define XXGE_MDIO_PHY_LINK_UP_MASK      0x1000 /* Checking for 12th bit  */


#define XXGE_MDIO_MC_MDIOPRTAD_MASK		0x1F000000  /**< PRTAD ...b28:24*/
#define XXGE_MDIO_MC_CLOCK_DEVAD_MAX	0x001F0000  /**< DEVAD ...b20:16*/
#define XXGE_MDIO_MC_MDIO_TXOP_MASK		0x0000C000  /**< TX OP ...b15:14*/
#define XXGE_MDIO_CFG1_INITIATE_MASK	0x00000800  /**< Initiate ...b11 */
#define XXGE_MDIO_CFG1_READY_MASK       0x00000080  /**< MDIO Ready ...b7*/
#define XXGE_MDIO_CFG1_OP_SETADDR_MASK	0x00000000  /**< Opcode Set Addr Mask */
#define XXGE_MDIO_CFG1_OP_READ_MASK     0x0000C000  /**< Opcode Read Mask */
#define XXGE_MDIO_CFG1_OP_WRITE_MASK	0x00004000  /**< Opcode Write Mask */
/*@}*/


/** @name MDIO TX Data (MTX) Register bit definitions
 * @{
 */
#define XXGE_MDIO_TX_DATA_MASK		0x0000FFFF /**< MDIO TX Data ...b15:0 */

/** @name MDIO TX Data (MTX) Register bit definitions
 * @{
 */
#define XXGE_MDIO_RX_DATA_MASK		0x0000FFFF /**< MDIO RX Data ...b15:0 */



/*@}*/


/** @name Other Constant definitions used in the driver
 * @{
 */

#define XXGE_SPEED_10_GBPS		10000	/**< Speed of 10 Gbps */
#define XXGE_SPEED_1_GBPS		1000		/**< Speed of 1 Gbps */
#define XXGE_SPEED_100_MBPS	100		/**< Speed of 100 Mbps */
#define XXGE_SPEED_10_MBPS		10		/**< Speed of 10 Mbps */

#define XXGE_PHY_ADDR_LIMIT		36	/**< Max limit while accessing
						  *  and searching for available
						  * PHYs.
						  */
#define XXGE_PHY_REG_NUM_LIMIT		35	/**< Max register limit in PHY
						  * as mandated by the spec.
						  */
#define XXGE_LOOPS_TO_COME_OUT_OF_RST	5000	/**< Number of loops in the driver
						 *   API to wait for before
						 *   returning a failure case.
						 */

#define XXGE_RST_DELAY_LOOPCNT_VAL	4	/**< Timeout in ticks used
						  *  while checking if the core
						  *  had come out of reset. The
						  *  exact tick time is defined
						  *  in each case/loop where it
						  *  will be used
						  */



/*@}*/

/**************************** Type Definitions *******************************/

/***************** Macros (Inline Functions) Definitions *********************/
xdbg_stmnt(extern int indent_on);

#define XXgEthernet_indent(RegOffset) \
 ((indent_on && ((RegOffset) >= XXGE_RAF_OFFSET) && ((RegOffset) <= 	\
 XXGE_RXAERU_OFFSET)) ? "\t" : "")


#define XXgEthernet_reg_name(RegOffset) \
	((RegOffset) == XXGE_RXBL_OFFSET) ? "XXGE_RXBL_OFFSET": \
	((RegOffset) == XXGE_RXBU_OFFSET) ? "XXGE_RXBU_OFFSET": \
	((RegOffset) == XXGE_TXBL_OFFSET) ? "XXGE_TXBL_OFFSET": \
	((RegOffset) == XXGE_TXBU_OFFSET) ? "XXGE_TXBU_OFFSET": \
	((RegOffset) == XXGE_RXUNDRL_OFFSET) ? "XXGE_RXUNDRL_OFFSET": \
	((RegOffset) == XXGE_RXUNDRU_OFFSET) ? "XXGE_RXUNDRU_OFFSET": \
	((RegOffset) == XXGE_RXFRAGL_OFFSET) ? "XXGE_RXFRAGL_OFFSET": \
	((RegOffset) == XXGE_RXFRAGU_OFFSET) ? "XXGE_RXFRAGU_OFFSET": \
	((RegOffset) == XXGE_RX64BL_OFFSET) ? "XXGE_RX64BL_OFFSET": \
	((RegOffset) == XXGE_RX64BU_OFFSET) ? "XXGE_RX64BU_OFFSET": \
	((RegOffset) == XXGE_RX65B127L_OFFSET) ? "XXGE_RX65B127L_OFFSET": \
	((RegOffset) == XXGE_RX65B127U_OFFSET) ? "XXGE_RX65B127U_OFFSET": \
	((RegOffset) == XXGE_RX128B255L_OFFSET) ? "XXGE_RX128B255L_OFFSET": \
	((RegOffset) == XXGE_RX128B255U_OFFSET) ? "XXGE_RX128B255U_OFFSET": \
	((RegOffset) == XXGE_RX256B511L_OFFSET) ? "XXGE_RX256B511L_OFFSET": \
	((RegOffset) == XXGE_RX256B511U_OFFSET) ? "XXGE_RX256B511U_OFFSET": \
	((RegOffset) == XXGE_RX512B1023L_OFFSET) ? "XXGE_RX512B1023L_OFFSET": \
	((RegOffset) == XXGE_RX512B1023U_OFFSET) ? "XXGE_RX512B1023U_OFFSET": \
	((RegOffset) == XXGE_RX1024BL_OFFSET) ? "XXGE_RX1024L_OFFSET": \
	((RegOffset) == XXGE_RX1024BU_OFFSET) ? "XXGE_RX1024U_OFFSET": \
	((RegOffset) == XXGE_RXOVRL_OFFSET) ? "XXGE_RXOVRL_OFFSET": \
	((RegOffset) == XXGE_RXOVRU_OFFSET) ? "XXGE_RXOVRU_OFFSET": \
	((RegOffset) == XXGE_TX64BL_OFFSET) ? "XXGE_TX64BL_OFFSET": \
	((RegOffset) == XXGE_TX64BU_OFFSET) ? "XXGE_TX64BU_OFFSET": \
	((RegOffset) == XXGE_TX65B127L_OFFSET) ? "XXGE_TX65B127L_OFFSET": \
	((RegOffset) == XXGE_TX65B127U_OFFSET) ? "XXGE_TX65B127U_OFFSET": \
	((RegOffset) == XXGE_TX128B255L_OFFSET) ? "XXGE_TX128B255L_OFFSET": \
	((RegOffset) == XXGE_TX128B255U_OFFSET) ? "XXGE_TX128B255U_OFFSET": \
	((RegOffset) == XXGE_TX256B511L_OFFSET) ? "XXGE_TX256B511L_OFFSET": \
	((RegOffset) == XXGE_TX256B511U_OFFSET) ? "XXGE_TX256B511U_OFFSET": \
	((RegOffset) == XXGE_TX512B1023L_OFFSET) ? "XXGE_TX512B1023L_OFFSET": \
	((RegOffset) == XXGE_TX512B1023U_OFFSET) ? "XXGE_TX512B1023U_OFFSET": \
	((RegOffset) == XXGE_TX1024L_OFFSET) ? "XXGE_TX1024L_OFFSET": \
	((RegOffset) == XXGE_TX1024U_OFFSET) ? "XXGE_TX1024U_OFFSET": \
	((RegOffset) == XXGE_TXOVRL_OFFSET) ? "XXGE_TXOVRL_OFFSET": \
	((RegOffset) == XXGE_TXOVRU_OFFSET) ? "XXGE_TXOVRU_OFFSET": \
	((RegOffset) == XXGE_RXFL_OFFSET) ? "XXGE_RXFL_OFFSET": \
	((RegOffset) == XXGE_RXFU_OFFSET) ? "XXGE_RXFU_OFFSET": \
	((RegOffset) == XXGE_RXFCSERL_OFFSET) ? "XXGE_RXFCSERL_OFFSET": \
	((RegOffset) == XXGE_RXFCSERU_OFFSET) ? "XXGE_RXFCSERU_OFFSET": \
	((RegOffset) == XXGE_RXBCSTFL_OFFSET) ? "XXGE_RXBCSTFL_OFFSET": \
	((RegOffset) == XXGE_RXBCSTFU_OFFSET) ? "XXGE_RXBCSTFU_OFFSET": \
	((RegOffset) == XXGE_RXMCSTFL_OFFSET) ? "XXGE_RXMCSTFL_OFFSET": \
	((RegOffset) == XXGE_RXMCSTFU_OFFSET) ? "XXGE_RXMCSTFU_OFFSET": \
	((RegOffset) == XXGE_RXCTRFL_OFFSET) ? "XXGE_RXCTRFL_OFFSET": \
	((RegOffset) == XXGE_RXCTRFU_OFFSET) ? "XXGE_RXCTRFU_OFFSET": \
	((RegOffset) == XXGE_RXLTERL_OFFSET) ? "XXGE_RXLTERL_OFFSET": \
	((RegOffset) == XXGE_RXLTERU_OFFSET) ? "XXGE_RXLTERU_OFFSET": \
	((RegOffset) == XXGE_RXVLANFL_OFFSET) ? "XXGE_RXVLANFL_OFFSET": \
	((RegOffset) == XXGE_RXVLANFU_OFFSET) ? "XXGE_RXVLANFU_OFFSET": \
	((RegOffset) == XXGE_RXPFL_OFFSET) ? "XXGE_RXFL_OFFSET": \
	((RegOffset) == XXGE_RXPFU_OFFSET) ? "XXGE_RXFU_OFFSET": \
	((RegOffset) == XXGE_RXUOPFL_OFFSET) ? "XXGE_RXUOPFL_OFFSET": \
	((RegOffset) == XXGE_RXUOPFU_OFFSET) ? "XXGE_RXUOPFU_OFFSET": \
	((RegOffset) == XXGE_TXFL_OFFSET) ? "XXGE_TXFL_OFFSET": \
	((RegOffset) == XXGE_TXFU_OFFSET) ? "XXGE_TXFU_OFFSET": \
	((RegOffset) == XXGE_TXBCSTFL_OFFSET) ? "XXGE_TXBCSTFL_OFFSET": \
	((RegOffset) == XXGE_TXBCSTFU_OFFSET) ? "XXGE_TXBCSTFU_OFFSET": \
	((RegOffset) == XXGE_TXMCSTFL_OFFSET) ? "XXGE_TXMCSTFL_OFFSET": \
	((RegOffset) == XXGE_TXMCSTFU_OFFSET) ? "XXGE_TXMCSTFU_OFFSET": \
	((RegOffset) == XXGE_TXUNDRERL_OFFSET) ? "XXGE_TXUNDRERL_OFFSET": \
	((RegOffset) == XXGE_TXUNDRERU_OFFSET) ? "XXGE_TXUNDRERU_OFFSET": \
	((RegOffset) == XXGE_TXCTRFL_OFFSET) ? "XXGE_TXCTRFL_OFFSET": \
	((RegOffset) == XXGE_TXCTRFU_OFFSET) ? "XXGE_TXCTRFU_OFFSET": \
	((RegOffset) == XXGE_TXVLANFL_OFFSET) ? "XXGE_TXVLANFL_OFFSET": \
	((RegOffset) == XXGE_TXVLANFU_OFFSET) ? "XXGE_TXVLANFU_OFFSET": \
	((RegOffset) == XXGE_TXPFL_OFFSET) ? "XXGE_TXPFL_OFFSET": \
	((RegOffset) == XXGE_TXPFU_OFFSET) ? "XXGE_TXPFU_OFFSET": \
	((RegOffset) == XXGE_RCW0_OFFSET) ? "XXGE_RCW0_OFFSET": \
	((RegOffset) == XXGE_RCW1_OFFSET) ? "XXGE_RCW1_OFFSET": \
	((RegOffset) == XXGE_TC_OFFSET) ? "XXGE_TC_OFFSET": \
	((RegOffset) == XXGE_FCC_OFFSET) ? "XXGE_FCC_OFFSET": \
	((RegOffset) == XXGE_GERS_OFFSET) ? "XXGE_GERS_OFFSET": \
	((RegOffset) == XXGE_RMTU_OFFSET) ? "XXGE_RMTU_OFFSET": \
	((RegOffset) == XXGE_TMTU_OFFSET) ? "XXGE_TMTU_OFFSET": \
	((RegOffset) == XXGE_VER_OFFSET) ? "XXGE_VER_OFFSET": \
	((RegOffset) == XXGE_CAP_OFFSET) ? "XXGE_CAP_OFFSET": \
	((RegOffset) == XXGE_MDIO_CFGL_OFFSET) ? "XXGE_MDIO_CFGL_OFFSET": \
	((RegOffset) == XXGE_MDIO_CFGL_OFFSET) ? "XXGE_MDIO_CFGL_OFFSET": \
	((RegOffset) == XXGE_MDIO_TX_OFFSET) ? "XXGE_MDIO_TX_OFFSET": \
	((RegOffset) == XXGE_MDIO_RX_OFFSET) ? "XXGE_MDIO_RX_OFFSET": \
	((RegOffset) == XXGE_MDIO_MIS_OFFSET) ? "XXGE_MDIO_MIS_OFFSET": \
	((RegOffset) == XXGE_MDIO_MIP_OFFSET) ? "XXGE_MDIO_MIP_OFFSET": \
	((RegOffset) == XXGE_MDIO_MIE_OFFSET) ? "XXGE_MDIO_MIE_OFFSET": \
	((RegOffset) == XXGE_MDIO_MIA_OFFSET) ? "XXGE_MDIO_MIA_OFFSET": \
	((RegOffset) == XXGE_AFC_OFFSET) ? "XXGE_AFC_OFFSET": \
	((RegOffset) == XXGE_MACL_OFFSET) ? "XXGE_MACL_OFFSET": \
	((RegOffset) == XXGE_MACU_OFFSET) ? "XXGE_MACU_OFFSET": \
	"unknown")

#define XXgEthernet_print_reg_o(BaseAddress, RegOffset, Value) 	\
	xdbg_printf(XDBG_DEBUG_TEMAC_REG, "%s0x%0x -> %s(0x%0x)\n", 	\
			XXgEthernet_indent(RegOffset), (Value), 	\
			XXgEthernet_reg_name(RegOffset), (RegOffset)) 	

#define XXgEthernet_print_reg_i(BaseAddress, RegOffset, Value) \
	xdbg_printf(XDBG_DEBUG_TEMAC_REG, "%s%s(0x%0x) -> 0x%0x\n", \
		XXgEthernet_indent(RegOffset),  \
		XXgEthernet_reg_name(RegOffset),(RegOffset), (Value)) 

/****************************************************************************/
/**
*
* XXgEthernet_ReadReg returns the value read from the register specified by
* <i>RegOffset</i>.
*
* @param	BaseAddress is the base address of the XGEMAC Ethernet device.
* @param	RegOffset is the offset of the register to be read.
*
* @return	Returns the 32-bit value of the register.
*
* @note		C-style signature:
*		u32 XXgEthernet_ReadReg(u32 BaseAddress, u32 RegOffset)
*
*****************************************************************************/
#ifdef DEBUG
#define XXgEthernet_ReadReg(BaseAddress, RegOffset) 			\
({									\
	u32 value; 							\
	value = Xil_In32(((BaseAddress) + (RegOffset))); 		\
	XXgEthernet_print_reg_i((BaseAddress), (RegOffset), value);	\
})
#else
#ifdef X86_64
#define XXgEthernet_ReadReg(BaseAddress, RegOffset) 			\
	(Xil_In32((((u64)(BaseAddress)) + (unsigned int)(RegOffset))))
#else
#define XXgEthernet_ReadReg(BaseAddress, RegOffset) 			\
	(Xil_In32(((BaseAddress) + (RegOffset))))
#endif	
#endif

/****************************************************************************/
/**
*
* XXgEthernet_WriteReg, writes <i>Data</i> to the register specified by
* <i>RegOffset</i>.
*
* @param	BaseAddress is the base address of the XGEMAC Ethernet device.
* @param	RegOffset is the offset of the register to be written.
* @param	Data is the 32-bit value to write to the register.
*
* @return	None.
*
* @note
* 	C-style signature:
*	void XXgEthernet_WriteReg(u32 BaseAddress, u32 RegOffset, u32 Data)
*
*****************************************************************************/
#ifdef DEBUG
#define XXgEthernet_WriteReg(BaseAddress, RegOffset, Data)		\
({ 									\
	XXgEthernet_print_reg_o((BaseAddress), (RegOffset), (Data));	\
	Xil_Out32(((BaseAddress) + (RegOffset)), (Data)); 		\
})
#else
#ifdef X86_64
#define XXgEthernet_WriteReg(BaseAddress, RegOffset, Data) \
	Xil_Out32((((u64)(BaseAddress)) + (unsigned int)(RegOffset)), (Data));
#else
#define XXgEthernet_WriteReg(BaseAddress, RegOffset, Data) \
	Xil_Out32(((BaseAddress) + (RegOffset)), (Data));
#endif	
#endif


#ifdef __cplusplus
  }
#endif

#endif /* end of protection macro */
