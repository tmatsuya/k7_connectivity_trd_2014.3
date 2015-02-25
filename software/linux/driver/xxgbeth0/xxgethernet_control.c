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
* @file xxgethernet_control.c
*
* This file has driver APIs related to the controlling of the extended
* features of the AXI Ethernet device. Please note that APIs for turning on/off
* any of the driver features are present in axiethernet.c. This file takes care
* of controlling these features.
*	- Normal/extended multicast filtering
*	- Normal/extended VLAN features
*	- RGMII/SGMII features
*
* See xxgethernet.h for a detailed description of the driver.
*
* MODIFICATION HISTORY:
*
* Ver  Date     Changes
* ------------- -------------------------------------------------------
* 1.0  05/15/12 First release
*****************************************************************************/

/***************************** Include Files *********************************/

#include "xxgethernet.h"

/************************** Constant Definitions *****************************/


/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/************************** Function Prototypes ******************************/


/************************** Variable Definitions *****************************/



/*****************************************************************************/
/**
* XXgEthernet_SetMacPauseAddress sets the MAC address used for pause frames
* to <i>AddressPtr</i>. <i>AddressPtr</i> will be the address the Axi Ethernet
* device will recognize as being for pause frames. Pause frames transmitted
* with XXgEthernet_SendPausePacket() will also use this address.
*
* @param	InstancePtr is a pointer to the Axi Ethernet instance to be
*		worked on.
* @param	AddressPtr is a pointer to the 6-byte Ethernet address to set.
*
* @return
*		- XST_SUCCESS on successful completion.
*		- XST_DEVICE_IS_STARTED if the Axi Ethernet device is not
*		  stopped.
*
* @note		None.
*
******************************************************************************/
int XXgEthernet_SetMacPauseAddress(XXgEthernet *InstancePtr,
							void *AddressPtr)
{
	u32 MacAddr;
	u8 *Aptr = (u8 *) AddressPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);
	Xil_AssertNonvoid(AddressPtr != NULL);

	xdbg_printf(XDBG_DEBUG_GENERAL, "XXgEthernet_SetMacPauseAddress\n");

	/* Be sure device has been stopped */
	if (InstancePtr->IsStarted == XIL_COMPONENT_IS_STARTED) {
		xdbg_printf(XDBG_DEBUG_GENERAL,
		"XXgEthernet_SetMacPauseAddress:returning DEVICE_IS_STARTED\n");
		return (XST_DEVICE_IS_STARTED);
	}

	/* Set the MAC bits [31:0] in RCW0 register */
	MacAddr = Aptr[0];
	MacAddr |= Aptr[1] << 8;
	MacAddr |= Aptr[2] << 16;
	MacAddr |= Aptr[3] << 24;
	XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
						XXGE_RCW0_OFFSET, MacAddr);

	/* RCW1 contains other info that must be preserved */
	MacAddr = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
							XXGE_RCW1_OFFSET);
	MacAddr &= ~XXGE_RCW1_PAUSEADDR_MASK;

	/* Set MAC bits [47:32] */
	MacAddr |= Aptr[4];
	MacAddr |= Aptr[5] << 8;
	XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
						XXGE_RCW1_OFFSET, MacAddr);

	xdbg_printf(XDBG_DEBUG_GENERAL,
		   "XXgEthernet_SetMacPauseAddress: returning SUCCESS\n");

	return (XST_SUCCESS);
}


/*****************************************************************************/
/**
* XXgEthernet_GetMacPauseAddress gets the MAC address used for pause frames
* for the Axi Ethernet device specified by <i>InstancePtr</i>.
*
* @param	InstancePtr is a pointer to the Axi Ethernet instance to be
*		worked on.
* @param	AddressPtr references the memory buffer to store the retrieved
*		MAC address. This memory buffer must be at least 6 bytes in
*		length.
*
* @return 	None.
*
* @note		None.
*
******************************************************************************/
void XXgEthernet_GetMacPauseAddress(XXgEthernet *InstancePtr,
							void *AddressPtr)
{
	u32 MacAddr;
	u8 *Aptr = (u8 *) AddressPtr;

	Xil_AssertVoid(InstancePtr != NULL);
	Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);
	Xil_AssertVoid(AddressPtr != NULL);


	xdbg_printf(XDBG_DEBUG_GENERAL, "XXgEthernet_SetMacPauseAddress\n");

	/* Read MAC bits [31:0] in ERXC0 */
	MacAddr = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
							XXGE_RCW0_OFFSET);
	Aptr[0] = (u8) MacAddr;
	Aptr[1] = (u8) (MacAddr >> 8);
	Aptr[2] = (u8) (MacAddr >> 16);
	Aptr[3] = (u8) (MacAddr >> 24);

	/* Read MAC bits [47:32] in RCW1 */
	MacAddr = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
							XXGE_RCW1_OFFSET);
	Aptr[4] = (u8) MacAddr;
	Aptr[5] = (u8) (MacAddr >> 8);

	xdbg_printf(XDBG_DEBUG_GENERAL,
				"XXgEthernet_SetMacPauseAddress: done\n");
}
