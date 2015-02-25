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
* @file xxgethernet.c
*
* The APIs in this file takes care of the primary functionalities of the driver.
* The APIs in this driver take care of the following:
*	- Starting or stopping the XGEMAC Ethernet device
*	- Initializing and resetting the XGEMAC Ethernet device
*	- Setting MAC address  
*	- Provide means for controlling the PHY and communicating with it.
*	- Turn on/off various features/options provided by the XGEMAC Ethernet
*	  device.
* See xxgethernet.h for a detailed description of the driver.
* 
* MODIFICATION HISTORY:
*
* Ver  Date     Changes
* ---- --------- -------------------------------------------------------
* 1.0  05/15/12 First release 
*
*
******************************************************************************/

/***************************** Include Files *********************************/
#include "xxgethernet.h"
#include "xdma_user.h"


/************************** Constant Definitions *****************************/


/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/************************** Function Prototypes ******************************/

static void InitHw(XXgEthernet *InstancePtr);	/* HW reset */

/************************** Variable Definitions *****************************/

xdbg_stmnt(int indent_on = 0;)
xdbg_stmnt(u32 _XXgethernet_rir_value;)

/*****************************************************************************/
/**
*
* XXgEthernet_CfgInitialize initializes an XGEMAC Ethernet device along with the
* <i>InstancePtr</i> that references it.
*
* The PHY is setup independently from the Ethernet core. Use the MII or	~chng...
* whatever other interface may be present for setup.
*
* @param	InstancePtr references the memory instance to be associated
*		with the XGEMAC Ethernet core instance upon initialization.
* @param	CfgPtr references the structure holding the hardware
*		configuration for the XGEMAC Ethernet core to initialize.
* @param	EffectiveAddress is the processor address used to access the
*		base address of the XGEMAC Ethernet instance. In systems with an
*		MMU and virtual memory, <i>EffectiveAddress</i> is the
*		virtual address mapped to the physical in
*		<code>ConfigPtr->Config.BaseAddress</code>. In systems without
*		an active MMU, <i>EffectiveAddress</i> should be set to the
*		same value as <code>ConfigPtr->Config.BaseAddress</code>.
*
* @return	XST_SUCCESS.
*
* @note		None.
*
******************************************************************************/
#ifdef X86_64
int XXgEthernet_CfgInitialize(XXgEthernet *InstancePtr,
				XXgEthernet_Config *CfgPtr,
				u64 EffectiveAddress)
{
#else
int XXgEthernet_CfgInitialize(XXgEthernet *InstancePtr,
				XXgEthernet_Config *CfgPtr,
				u32 EffectiveAddress)
{
#endif
	/* Verify arguments */
	Xil_AssertNonvoid(InstancePtr != NULL);

	/* Clear instance memory and make copy of configuration */
	memset(InstancePtr, 0, sizeof(XXgEthernet));
	memcpy(&InstancePtr->Config, CfgPtr, sizeof(XXgEthernet_Config));

	xdbg_printf(XDBG_DEBUG_GENERAL, "XXgEthernet_CfgInitialize\n");

	/* Set device base address */
	InstancePtr->Config.BaseAddress = EffectiveAddress;

	/* Reset the hardware and set default options */
	InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

	XXgEthernet_Reset(InstancePtr);

	xdbg_printf(XDBG_DEBUG_GENERAL,
			"XXgEthernet_CfgInitialize: returning SUCCESS\n");
	return XST_SUCCESS;
}


/*****************************************************************************/
/**
* XXgEthernet_Start starts the XGEMAC Ethernet device as follows:
*	- Enable transmitter if XXGE_TRANSMIT_ENABLE_OPTION is set
*	- Enable receiver if XXGE_RECEIVER_ENABLE_OPTION is set
*
* @param	InstancePtr is a pointer to the XGEMAC Ethernet instance to be
*		worked on.
* @return	None.
*
* @note		None.
*
*
******************************************************************************/
void XXgEthernet_Start(XXgEthernet *InstancePtr)
{
	u32 Reg;

#ifdef XGEMAC_DEBUG__
    u32 Reg_tmp;
#endif
    /* Assert bad arguments and conditions */
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

#ifdef XGEMAC_DEBUG__
    printk("**Completed the xtenet_init_top functionality**\n");
    
    Reg_tmp = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
							XXGE_VER_OFFSET);
    printk("**Version Register = %x \n",Reg_tmp);

    Reg_tmp = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
							XXGE_CAP_OFFSET);
    printk("the Value of Capability Register = %x \n",Reg_tmp);

#endif


	/* If already started, then there is nothing to do */
	if (InstancePtr->IsStarted == XIL_COMPONENT_IS_STARTED) {
		return;
	}

	xdbg_printf(XDBG_DEBUG_GENERAL, "XXgEthernet_Start\n");

	/* Enable transmitter if not already enabled */
	if (InstancePtr->Options & XXGE_TRANSMITTER_ENABLE_OPTION) {
		xdbg_printf(XDBG_DEBUG_GENERAL, "enabling transmitter\n");
		Reg = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
							XXGE_TC_OFFSET);
		if (!(Reg & XXGE_TC_TX_MASK)) {
			xdbg_printf(XDBG_DEBUG_GENERAL,
				"transmitter not enabled, enabling now\n");
			XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
							XXGE_TC_OFFSET,
							Reg | XXGE_TC_TX_MASK);
		}
		xdbg_printf(XDBG_DEBUG_GENERAL, "transmitter enabled\n");
	}

	/* Enable receiver */
	if (InstancePtr->Options & XXGE_RECEIVER_ENABLE_OPTION) {
		xdbg_printf(XDBG_DEBUG_GENERAL, "enabling receiver\n");
		Reg = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
							XXGE_RCW1_OFFSET);
		if (!(Reg & XXGE_RCW1_RX_MASK)) {
			xdbg_printf(XDBG_DEBUG_GENERAL,
				"receiver not enabled, enabling now\n");

			XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
							XXGE_RCW1_OFFSET,
							Reg | XXGE_RCW1_RX_MASK);
		}
		xdbg_printf(XDBG_DEBUG_GENERAL, "receiver enabled\n");
	}

	/* Mark as started */
	InstancePtr->IsStarted = XIL_COMPONENT_IS_STARTED;
	xdbg_printf(XDBG_DEBUG_GENERAL, "XXgEthernet_Start: done\n");
}

/*****************************************************************************/
/**
* XXgEthernet_Stop gracefully stops the XGEMAC Ethernet device as follows:
*	- Disable all interrupts from this device
*	- Disable the receiver
*
* XXgEthernet_Stop does not modify any of the current device options.
*
* Since the transmitter is not disabled, frames currently in internal buffers
* or in process by a DMA engine are allowed to be transmitted.
*
* @param	InstancePtr is a pointer to the XGEMAC Ethernet instance to be
*		worked on.
* @return	None
*
* @note		None.
*
*
******************************************************************************/
void XXgEthernet_Stop(XXgEthernet *InstancePtr)
{
	u32 Reg;

	Xil_AssertVoid(InstancePtr != NULL);
	Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);


	/* If already stopped, then there is nothing to do */
	if (InstancePtr->IsStarted == 0) {
		return;
	}

	xdbg_printf(XDBG_DEBUG_GENERAL, "XXgEthernet_Stop\n");
	xdbg_printf(XDBG_DEBUG_GENERAL,
		"XXgEthernet_Stop: disabling interrupts\n");


    /* Disable the receiver */
    Reg = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
	    XXGE_RCW1_OFFSET);
    Reg &= ~XXGE_RCW1_RX_MASK;
    XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
	    XXGE_RCW1_OFFSET, Reg);

    /*
     * Stopping the receiver in mid-packet causes a dropped packet
     * indication from HW. Clear it.
     */

	/* Mark as stopped */
	InstancePtr->IsStarted = 0;
	xdbg_printf(XDBG_DEBUG_GENERAL, "XXgEthernet_Stop: done\n");
}


/*****************************************************************************/
/**
* XXgEthernet_Reset performs a reset of the XGEMAC Ethernet device, specified by
* <i>InstancePtr</i>.
*
* XXgEthernet_Reset also resets the XGEMAC Ethernet's options to their
* default values.
*
* The calling software is responsible for re-configuring the XGEMAC Ethernet
* (if necessary) and restarting the MAC after the reset.
*
* @param	InstancePtr is a pointer to the XGEMAC Ethernet instance to be
*		worked on.
*
* @note		None.
*
*
******************************************************************************/
void XXgEthernet_Reset(XXgEthernet *InstancePtr)
{
	u32 Reg;
	u32 TimeoutLoops;

	Xil_AssertVoid(InstancePtr != NULL);
	Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

	xdbg_printf(XDBG_DEBUG_GENERAL, "XXgEthernet_Reset\n");

	/* Stop the device and reset HW */
	XXgEthernet_Stop(InstancePtr);
	InstancePtr->Options = XXGE_DEFAULT_OPTIONS;

	/* Reset the receiver */
	xdbg_printf(XDBG_DEBUG_GENERAL, "resetting the receiver\n");
	Reg = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
							XXGE_RCW1_OFFSET);
	Reg |= XXGE_RCW1_RST_MASK;
	XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
							XXGE_RCW1_OFFSET, Reg);

	/* Reset the transmitter */
	xdbg_printf(XDBG_DEBUG_GENERAL, "resetting the transmitter\n");
	Reg = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
							XXGE_TC_OFFSET);
	Reg |= XXGE_TC_RST_MASK;
	XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
							XXGE_TC_OFFSET, Reg);

	xdbg_printf(XDBG_DEBUG_GENERAL, "waiting until reset is done\n");

	TimeoutLoops  = XXGE_RST_DELAY_LOOPCNT_VAL;
	/* Poll until the reset is done */
	while (TimeoutLoops  && (Reg & (XXGE_RCW1_RST_MASK | XXGE_TC_RST_MASK))) {
		Reg = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
							XXGE_RCW1_OFFSET);
		Reg |= XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
							XXGE_TC_OFFSET);
		TimeoutLoops --;
	}
	if(0 == TimeoutLoops ) {
		Xil_AssertVoidAlways();
	}

	/* Setup HW */
	InitHw(InstancePtr);
}


/******************************************************************************
*
* InitHw (internal use only) performs a one-time setup of a XGEMAC Ethernet device.
* The setup performed here only need to occur once after any reset.
*
* @param	InstancePtr is a pointer to the XGEMAC Ethernet instance to be
*		worked on.
* @note		None.
*
*
******************************************************************************/
static void InitHw(XXgEthernet *InstancePtr)
{
	u32 Reg;

	xdbg_printf(XDBG_DEBUG_GENERAL, "XXgEthernet InitHw\n");


	/* Disable the receiver */
	Reg = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
							XXGE_RCW1_OFFSET);
	Reg &= ~XXGE_RCW1_RX_MASK;
	XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
							XXGE_RCW1_OFFSET, Reg);


    /*
     * Sync default options with HW but leave receiver and transmitter
     * disabled. They get enabled with XXgEthernet_Start() if
     * XXGE_TRANSMITTER_ENABLE_OPTION and XXGE_RECEIVER_ENABLE_OPTION
     * are set
     */
    XXgEthernet_SetOptions(InstancePtr, InstancePtr->Options &
	    ~(XXGE_TRANSMITTER_ENABLE_OPTION |
		XXGE_RECEIVER_ENABLE_OPTION));

	XXgEthernet_ClearOptions(InstancePtr, ~InstancePtr->Options);

/* Just print values of RCW1 and TC registers now */
log_verbose(KERN_ERR "RCW1 now contains %x\n", 
            XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress, XXGE_RCW1_OFFSET));		
log_verbose(KERN_ERR "TC now contains %x\n", 
            XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress, XXGE_TC_OFFSET));		

	/* Set default MDIO divisor */	/* !!sunitaj */
	XXgEthernet_PhySetMdioDivisor(InstancePtr, XXGE_MDIO_DIV_DFT);

	xdbg_printf(XDBG_DEBUG_GENERAL, "XXgEthernet InitHw: done\n");
}

/*****************************************************************************/
/**
 * XXgEthernet_SetMacAddress sets the MAC address for the XGEMAC Ethernet device,
 * specified by <i>InstancePtr</i> to the MAC address specified by
 * <i>AddressPtr</i>.
 * The XGEMAC Ethernet device must be stopped before calling this function.
 *
 * @param	InstancePtr is a pointer to the XGEMAC Ethernet instance to be
 *		worked on.
 * @param	AddressPtr is a reference to the 6-byte MAC address to set.
 *
 * @return
 *		- XST_SUCCESS on successful completion.
 *		- XST_DEVICE_IS_STARTED if the XGEMAC Ethernet device has not
 *		  stopped,
 *
 * @note
 * This routine also supports the extended/new VLAN and multicast mode. The
 * XXGE_RAF_NEWFNCENBL_MASK bit dictates which offset will be configured.
 *
 ******************************************************************************/
int XXgEthernet_SetMacAddress(XXgEthernet *InstancePtr, void *AddressPtr)
{
	u32 MacAddr;
	u8 *Aptr = (u8 *) AddressPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);
	Xil_AssertNonvoid(AddressPtr != NULL);

	/* Be sure device has been stopped */
	if (InstancePtr->IsStarted == XIL_COMPONENT_IS_STARTED) {
		return (XST_DEVICE_IS_STARTED);
	}

        // REFERENCE
        // MAC address: 00:0a:35:01:fa:3a
        // XIo_Out32( (dmaData->barInfo[0].baseVAddr) + 0x9404, 0x01350a00 );
        // XIo_Out32( (dmaData->barInfo[0].baseVAddr) + 0x9408, 0x00003afa );

        //DmaBase = DmaBaseAddress(0);
        MacAddr = Aptr[0];
        MacAddr |= Aptr[1] << 8;
        MacAddr |= Aptr[2] << 16;
        MacAddr |= Aptr[3] << 24;
        log_verbose(KERN_ERR "AddressPtr = %x %x %x %x;  MacAddrH = 0x%x, MACL=%x \n",
                (unsigned char)Aptr[0],
                (unsigned char)Aptr[1],
                (unsigned char)Aptr[2],
                (unsigned char)Aptr[3],
                MacAddr, XXGE_MACL_OFFSET);
        //XXgEthernet_WriteReg(DmaBase, XXGE_MACL_OFFSET, MacAddr);
        DmaMac_WriteReg(XXGE_MACL_OFFSET, MacAddr);

        MacAddr  = 0;
        MacAddr |= Aptr[4];
        MacAddr |= Aptr[5] << 8;
        log_verbose(KERN_ERR "AddressPtr = %x %x;  MacAddrH = 0x%x, MACU=%x \n",
                (unsigned char)Aptr[4],
                (unsigned char)Aptr[5],
                MacAddr, XXGE_MACU_OFFSET);
        //XXgEthernet_WriteReg(DmaBase, XXGE_MACU_OFFSET, MacAddr);
        DmaMac_WriteReg(XXGE_MACU_OFFSET, MacAddr);

        log_verbose("0x9400 is : 0x%x \n", DmaMac_ReadReg(0x9400) );
        log_verbose("0x9404 is : 0x%x \n", DmaMac_ReadReg(0x9404) );
        log_verbose("0x9408 is : 0x%x \n", DmaMac_ReadReg(0x9408) );
        log_verbose("0x940C is : 0x%x \n", DmaMac_ReadReg(0x940C) );
        log_verbose("0x9410 is : 0x%x \n", DmaMac_ReadReg(0x9410) );
        log_verbose("0x9414 is : 0x%x \n", DmaMac_ReadReg(0x9414) );
        

    return XST_SUCCESS;


#ifdef XGEMAC_DEBUG__
    printk("**Setting the MAC adress in XXgEthernet_SetMacAddress**\n");
#endif
    xdbg_printf(XDBG_DEBUG_GENERAL,
	    "XXgEthernet_SetMacAddress: setting mac address to:0x%08x%8x%8x%8x%8x%8x\n",
	    Aptr[0],  Aptr[1], Aptr[2], Aptr[3], Aptr[4], Aptr[5]);

	/* Prepare MAC bits in either UAW0/UAWL */
	MacAddr = Aptr[0];
	MacAddr |= Aptr[1] << 8;
	MacAddr |= Aptr[2] << 16;
	MacAddr |= Aptr[3] << 24;


		return (XST_SUCCESS);

}


/*****************************************************************************/
/**
 * XXgEthernet_GetMacAddress gets the MAC address for the XGEMAC Ethernet,
 * specified by <i>InstancePtr</i> into the memory buffer specified by
 * <i>AddressPtr</i>.
 *
 * @param	InstancePtr is a pointer to the XGEMAC Ethernet instance to be
 *		worked on.
 * @param	AddressPtr references the memory buffer to store the retrieved
 *		MAC address. This memory buffer must be at least 6 bytes in
 *		length.
 *
 * @return	None.
 *
 * @note
 *
 * This routine also supports the extended/new VLAN and multicast mode. The
 * XXGE_RAF_NEWFNCENBL_MASK bit dictates which offset will be configured.
 *
 ******************************************************************************/
void XXgEthernet_GetMacAddress(XXgEthernet *InstancePtr, void *AddressPtr)
{
	u32 MacAddr;
	u8 *Aptr = (u8 *) AddressPtr;

	Xil_AssertVoid(InstancePtr != NULL);
	Xil_AssertVoid(AddressPtr != NULL);
	Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    /* Read MAC bits [31:0] in UAW0 */
    MacAddr = DmaMac_ReadReg(XXGE_MACL_OFFSET);
    Aptr[0] = (u8) MacAddr;
    Aptr[1] = (u8) (MacAddr >> 8);
    Aptr[2] = (u8) (MacAddr >> 16);
    Aptr[3] = (u8) (MacAddr >> 24);

    /* Read MAC bits [47:32] in UAW1 */
    MacAddr = DmaMac_ReadReg(XXGE_MACU_OFFSET);
    Aptr[4] = (u8) MacAddr;
    Aptr[5] = (u8) (MacAddr >> 8);

    /* Read XGEMAC MAC bits [31:0] in XXGE_MACL_OFFSET */
    MacAddr = DmaMac_ReadReg(XXGE_MACL_OFFSET);
    Aptr[0] = (u8) MacAddr;
    Aptr[1] = (u8) (MacAddr >> 8);
    Aptr[2] = (u8) (MacAddr >> 16);
    Aptr[3] = (u8) (MacAddr >> 24);

    /* Read XGEMAC MAC bits [47:32] in XXGE_MACU_OFFSET */
    MacAddr = DmaMac_ReadReg(XXGE_MACU_OFFSET);
    Aptr[4] = (u8) MacAddr;
    Aptr[5] = (u8) (MacAddr >> 8);

}



/*****************************************************************************/
/**
 * XXgEthernet_UpdateDepOption check and update dependent options for
 * new/extended features. This is a helper function that is meant to be called
 * by XXgEthernet_SetOptions() and XXgEthernet_ClearOptions().
 *
 * @param	InstancePtr is a pointer to the XGEMAC Ethernet instance to be
 *		worked on.
 *
 * @return	Dependent options that are required to set/clear per
 *		hardware requirement.
 *
 * @note
 *
 * This helper function collects the dependent OPTION(s) per hardware design.
 * When conflicts arises, extended features have precedence over legacy ones.
 * Two operations to be considered,
 * 1. Adding extended options. If XATE_VLAN_OPTION is enabled and enable one of
 *	extended VLAN options, XATE_VLAN_OPTION should be off and configure to
 *	hardware.
 *	However, XGEMAC-ethernet instance Options variable still holds
 *	XATE_VLAN_OPTION so when all of the extended feature are removed,
 *	XATE_VLAN_OPTION can be effective and configured to hardware.
 * 2. Removing extended options. Remove extended option can not just remove
 *	the selected extended option and dependent options. All extended
 *	options need to be verified and remained when one or more extended
 *	options are enabled.
 *
 * Dependent options are :
 *	- XXGE_VLAN_OPTION,
 *	- XXGE_JUMBO_OPTION
 *	- XXGE_FCS_INSERT_OPTION,
 *	- XXGE_FCS_STRIP_OPTION
 *	- XXGE_PROMISC_OPTION.
 *
 ******************************************************************************/
static u32 XXgEthernet_UpdateDepOptions(XXgEthernet *InstancePtr)
{
	/*
	 * This is a helper function for XXgEthernet_[Set|Clear]Options()
	 */
	u32 DepOptions = InstancePtr->Options;

	/*
	 * The extended/new features require some OPTIONS to be on/off per
	 * hardware design. We determine these extended/new functions here
	 * first and also on/off other OPTIONS later. So that dependent
	 * OPTIONS are in sync and _[Set|Clear]Options() can be performed
	 * seamlessly.
	 */

    /*
     * enable Promiscuous option
     * XXGE_PROMISC_OPTION is required to be enabled.
     */
    {
	DepOptions |= XXGE_PROMISC_OPTION;
	xdbg_printf(XDBG_DEBUG_GENERAL,
			"CheckDepOptions: enabling ext promiscous\n");
	}

    return(DepOptions);
}


/*****************************************************************************/
/**
* XXgEthernet_SetOptions enables the options, <i>Options</i> for the
* XGEMAC Ethernet, specified by <i>InstancePtr</i>. XGEMAC Ethernet should be
* stopped with XXgEthernet_Stop() before changing options.
*
* @param	InstancePtr is a pointer to the XGEMAC Ethernet instance to be
*		worked on.
* @param	Options is a bitmask of OR'd XXGE_*_OPTION values for options to
*		set. Options not specified are not affected.
*
* @return
*		- XST_SUCCESS on successful completion.
*		- XST_DEVICE_IS_STARTED if the device has not been stopped.
*
*
* @note
* See xxgethernet.h for a description of the available options.
*
*
******************************************************************************/
int XXgEthernet_SetOptions(XXgEthernet *InstancePtr, u32 Options)
{
	u32 Reg;	/* Generic register contents */
	u32 RegRcw1;	/* Reflects original contents of RCW1 */
	u32 RegTc;	/* Reflects original contents of TC  */
	u32 RegNewRcw1;	/* Reflects new contents of RCW1 */
	u32 RegNewTc;	/* Reflects new contents of TC  */
	u32 DepOptions;	/* Required dependent options for new features */


        u32 TempRegRcw1;    /* Reflects original contents of RCW1 */
        u32 TempRegTc;      /* Reflects original contents of TC  */


	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

	/* Be sure device has been stopped */
	if (InstancePtr->IsStarted == XIL_COMPONENT_IS_STARTED) {
		return (XST_DEVICE_IS_STARTED);
	}

	xdbg_printf(XDBG_DEBUG_GENERAL, "XXgEthernet_SetOptions\n");

	/*
	 * Set options word to its new value.
	 * The step is required before calling _UpdateDepOptions() since
	 * we are operating on updated options.
	 */
	InstancePtr->Options |= Options;

	/*
	 * There are options required to be on/off per hardware requirement.
	 * Invoke _UpdateDepOptions to check hardware availability and update
	 * options accordingly.
	 */
	DepOptions = XXgEthernet_UpdateDepOptions(InstancePtr);

    /*
     * New/extended function bit should be on if any new/extended features
     * are on and hardware is built with them.
     */

    /*
     * Many of these options will change the RCW1 or TC registers.
     * To reduce the amount of IO to the device, group these options here
     * and change them all at once.
     */
    /* Get current register contents */
    RegRcw1 = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
	    XXGE_RCW1_OFFSET);
    RegTc = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
	    XXGE_TC_OFFSET);
    RegNewRcw1 = RegRcw1;
    RegNewTc = RegTc;

	xdbg_printf(XDBG_DEBUG_GENERAL,
			"current control regs: RCW1: 0x%0x; TC: 0x%0x\n",
			RegRcw1, RegTc);
	xdbg_printf(XDBG_DEBUG_GENERAL,
			"Options: 0x%0x; default options: 0x%0x\n",Options,
							XXGE_DEFAULT_OPTIONS);

	/* Turn on jumbo packet support for both Rx and Tx */
	if (DepOptions & XXGE_JUMBO_OPTION) {
		RegNewTc |= XXGE_TC_JUM_MASK;
		RegNewRcw1 |= XXGE_RCW1_JUM_MASK;
	}
        
        /* Turn on FCS Stripping support */
        if (DepOptions & XXGE_FCS_STRIP_OPTION) {
                RegNewTc &= ~XXGE_TC_FCS_MASK;
                RegNewRcw1 &= ~XXGE_RCW1_FCS_MASK;
                                       
        }    

    /* Turn on length/type field checking on receive packets */
    if (DepOptions & XXGE_LENTYPE_ERR_OPTION) {
	RegNewRcw1 &= ~XXGE_RCW1_LT_DIS_MASK;
    }

	/* Enable transmitter */
	if (DepOptions & XXGE_TRANSMITTER_ENABLE_OPTION) {
		RegNewTc |= XXGE_TC_TX_MASK;
	}

	/* Enable receiver */
	if (DepOptions & XXGE_RECEIVER_ENABLE_OPTION) {
		RegNewRcw1 |= XXGE_RCW1_RX_MASK;
	}

	/* Change the TC or RCW1 registers if they need to be modified */
	if (RegTc != RegNewTc) {
		xdbg_printf(XDBG_DEBUG_GENERAL,
				"setOptions: writing tc: 0x%0x\n", RegNewTc);
		XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
						XXGE_TC_OFFSET, RegNewTc);
	}

	if (RegRcw1 != RegNewRcw1) {
		xdbg_printf(XDBG_DEBUG_GENERAL,
			"setOptions: writing rcw1: 0x%0x\n", RegNewRcw1);
		XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
						XXGE_RCW1_OFFSET, RegNewRcw1);
	}


    TempRegRcw1 = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
	    XXGE_RCW1_OFFSET);
    TempRegTc = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
	    XXGE_TC_OFFSET);

    /*
     * Rest of options twiddle bits of other registers. Handle them one at
     * a time
     */

	/* Turn on flow control */
	if (DepOptions & XXGE_FLOW_CONTROL_OPTION) {
		xdbg_printf(XDBG_DEBUG_GENERAL,
				"setOptions: enabling flow control\n");
		Reg = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
							XXGE_FCC_OFFSET);
		Reg |= XXGE_FCC_FCRX_MASK;
		XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
							XXGE_FCC_OFFSET, Reg);
	}
	xdbg_printf(XDBG_DEBUG_GENERAL,
	"setOptions: rcw1 is now (fcc):0x%0x\n",
	XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
							XXGE_RCW1_OFFSET));

    /* Turn on promiscuous frame filtering (all frames are received ) */
    if (DepOptions & XXGE_PROMISC_OPTION) {
	xdbg_printf(XDBG_DEBUG_GENERAL,
		"setOptions: enabling promiscuous mode\n");
	//Reg = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
	//					XXGE_AFC_OFFSET);
	Reg = DmaMac_ReadReg(XXGE_AFC_OFFSET);
	Reg |= XXGE_AFC_PM_MASK;
	//XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
	//					XXGE_AFC_OFFSET, Reg);
	DmaMac_WriteReg(XXGE_AFC_OFFSET, Reg);
    }
    xdbg_printf(XDBG_DEBUG_GENERAL,
	    "setOptions: rcw1 is now (afm):0x%0x\n",
	    XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
		XXGE_RCW1_OFFSET));		/* !!sur... */

    /*
     * The remaining options not handled here are managed elsewhere in the
     * driver. No register modifications are needed at this time.
     * Reflecting the option in InstancePtr->Options is good enough for
     * now.
     */
    xdbg_printf(XDBG_DEBUG_GENERAL, "setOptions: returning SUCCESS\n");
    return (XST_SUCCESS);
}

/*****************************************************************************/
/**
* XXgEthernet_ClearOptions clears the options, <i>Options</i> for the
* XGEMAC Ethernet, specified by <i>InstancePtr</i>. XGEMAC Ethernet should be stopped
* with XXgEthernet_Stop() before changing options.
*
* @param	InstancePtr is a pointer to the XGEMAC Ethernet instance to be
*		worked on.
* @param	Options is a bitmask of OR'd XXGE_*_OPTION values for options to
*		clear. Options not specified are not affected.
*
* @return
*		- XST_SUCCESS on successful completion.
*		- XST_DEVICE_IS_STARTED if the device has not been stopped.
*
* @note
* See xxgethernet.h for a description of the available options.
*
******************************************************************************/
int XXgEthernet_ClearOptions(XXgEthernet *InstancePtr, u32 Options)
{
	u32 Reg;	/* Generic */
	u32 RegRcw1;	/* Reflects original contents of RCW1 */
	u32 RegTc;	/* Reflects original contents of TC  */
	u32 RegNewRcw1;	/* Reflects new contents of RCW1 */
	u32 RegNewTc;	/* Reflects new contents of TC  */
	u32 DepOptions;	/* Required dependent options for new features */

	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);


	xdbg_printf(XDBG_DEBUG_GENERAL, "XXgEthernet_ClearOptions: 0x%08x\n",
								Options);
	/* Be sure device has been stopped */
	if (InstancePtr->IsStarted == XIL_COMPONENT_IS_STARTED) {
		return (XST_DEVICE_IS_STARTED);
	}

	/*
	 * Set options word to its new value.
	 * The step is required before calling _UpdateDepOptions() since
	 * we are operating on updated options.
	 */
	InstancePtr->Options &= ~Options;

    DepOptions = 0xFFFFFFFF;

    /*
     * Many of these options will change the RCW1 or TC registers.
     * Group these options here and change them all at once. What we are
     * trying to accomplish is to reduce the amount of IO to the device
     */

	/* Grab current register contents */
	RegRcw1 = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
							XXGE_RCW1_OFFSET);
	RegTc = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
							XXGE_TC_OFFSET);
	RegNewRcw1 = RegRcw1;
	RegNewTc = RegTc;

	/* Turn off jumbo packet support for both Rx and Tx */
	if (DepOptions & XXGE_JUMBO_OPTION) {
		xdbg_printf(XDBG_DEBUG_GENERAL,
		"XXgEthernet_ClearOptions: disabling jumbo\n");
		RegNewTc &= ~XXGE_TC_JUM_MASK;
		RegNewRcw1 &= ~XXGE_RCW1_JUM_MASK;
	}


    /* Turn off FCS stripping on receive packets */
    if (DepOptions & XXGE_FCS_STRIP_OPTION) {
	xdbg_printf(XDBG_DEBUG_GENERAL,
		"XXgEthernet_ClearOptions: disabling fcs strip\n");
		RegNewRcw1 |= XXGE_RCW1_FCS_MASK;
	}

	/* Turn off FCS insertion on transmit packets */
	if (DepOptions & XXGE_FCS_INSERT_OPTION) {
		xdbg_printf(XDBG_DEBUG_GENERAL,
		"XXgEthernet_ClearOptions: disabling fcs insert\n");
		RegNewTc |= XXGE_TC_FCS_MASK;
	}

	/* Turn off length/type field checking on receive packets */
	if (DepOptions & XXGE_LENTYPE_ERR_OPTION) {
		xdbg_printf(XDBG_DEBUG_GENERAL,
		"XXgEthernet_ClearOptions: disabling lentype err\n");
		RegNewRcw1 |= XXGE_RCW1_LT_DIS_MASK;
	}

	/* Disable transmitter */
	if (DepOptions & XXGE_TRANSMITTER_ENABLE_OPTION) {
		xdbg_printf(XDBG_DEBUG_GENERAL,
		"XXgEthernet_ClearOptions: disabling transmitter\n");
		RegNewTc &= ~XXGE_TC_TX_MASK;
	}

	/* Disable receiver */
	if (DepOptions & XXGE_RECEIVER_ENABLE_OPTION) {
		xdbg_printf(XDBG_DEBUG_GENERAL,
		"XXgEthernet_ClearOptions: disabling receiver\n");
		RegNewRcw1 &= ~XXGE_RCW1_RX_MASK;
	}

	/* Change the TC and RCW1 registers if they need to be
	 * modified
	 */
	if (RegTc != RegNewTc) {
		xdbg_printf(XDBG_DEBUG_GENERAL,
		"XXgEthernet_ClearOptions: setting TC: 0x%0x\n", RegNewTc);
		XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
						XXGE_TC_OFFSET, RegNewTc);
	}

	if (RegRcw1 != RegNewRcw1) {
		xdbg_printf(XDBG_DEBUG_GENERAL,
		"XXgEthernet_ClearOptions: setting RCW1: 0x%0x\n",RegNewRcw1);
		XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
						XXGE_RCW1_OFFSET, RegNewRcw1);
	}

	/*
	 * Rest of options twiddle bits of other registers. Handle them one at
	 * a time
	 */

	/* Turn off flow control */
	if (DepOptions & XXGE_FLOW_CONTROL_OPTION) {
		xdbg_printf(XDBG_DEBUG_GENERAL,
		"XXgEthernet_ClearOptions: disabling flow control\n");
		Reg = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
							XXGE_FCC_OFFSET);
		Reg &= ~XXGE_FCC_FCRX_MASK;
		XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
							XXGE_FCC_OFFSET, Reg);
	}

	/* Turn off promiscuous frame filtering */
	if (DepOptions & XXGE_PROMISC_OPTION) {
		xdbg_printf(XDBG_DEBUG_GENERAL,
		"XXgEthernet_ClearOptions: disabling promiscuous mode\n");
		//Reg = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
		//					XXGE_AFC_OFFSET);
		Reg = DmaMac_ReadReg(XXGE_AFC_OFFSET);
		Reg &= ~XXGE_AFC_PM_MASK;
		//XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
		//					XXGE_AFC_OFFSET, Reg);
		DmaMac_WriteReg(XXGE_AFC_OFFSET, Reg);
	}


    /*
     * The remaining options not handled here are managed elsewhere in the
     * driver. No register modifications are needed at this time.
     * Reflecting the option in InstancePtr->Options is good enough for
     * now.
     */
    xdbg_printf(XDBG_DEBUG_GENERAL, "ClearOptions: returning SUCCESS\n");
    return (XST_SUCCESS);
}

/*****************************************************************************/
/**
* XXgEthernet_GetOptions returns the current option settings.
*
* @param	InstancePtr is a pointer to the XGEMAC Ethernet instance to be
*		worked on.
*
* @return	Returns a bitmask of XXGE_*_OPTION constants,
*		each bit specifying an option that is currently active.
*
* @note
* See xxgethernet.h for a description of the available options.
*
******************************************************************************/
u32 XXgEthernet_GetOptions(XXgEthernet *InstancePtr)
{
	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

	return (InstancePtr->Options);
}


/*****************************************************************************/
/**
 * XAxiEthernet_GetOperatingSpeed gets the current operating link speed. This
 * may be the value set by XAxiEthernet_SetOperatingSpeed() or a hardware
 * default.
 *
 * @param	InstancePtr is a pointer to the Axi Ethernet instance to be
 *		worked on.
 *
 * @return	Returns the link speed in units of megabits per second (10 /
 *		100 / 1000).
 *		Can return a value of 0, in case it does not get a valid
 *		speed from EMMC.
 *
 * @note	None.
 *
 * @note
 *
 *
 ******************************************************************************/
void XXgEthernet_DisableControlFrameLenCheck(XXgEthernet *InstancePtr)
{
	u32 RegRcw1;

	/* Grab current register contents */
	RegRcw1 = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
							XXGE_RCW1_OFFSET);
	RegRcw1 |= XXGE_RCW1_CL_DIS_MASK;
	XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
						XXGE_RCW1_OFFSET, RegRcw1);
}

/*****************************************************************************/
/**
* XXgEthernet_EnableControlFrameLenCheck is used to enable the length check
* for control frames (pause frames). After calling the API, all control frames
* received will be checked for proper length (less than minimum frame length).
* By default, upon normal start up, control frame length check is enabled.
* Hence this API needs to be called only if previously the control frame length
* check has been disabled by calling the API
* XXgEthernet_DisableControlFrameLenCheck.
*
* @param	InstancePtr is a pointer to the XGEMAC Ethernet instance to be
*		worked on.
*
* @return	None.
*
* @note
*
******************************************************************************/
void XXgEthernet_EnableControlFrameLenCheck(XXgEthernet *InstancePtr)
{
	u32 RegRcw1;

	/* Grab current register contents */
	RegRcw1 = XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
							XXGE_RCW1_OFFSET);
	RegRcw1 &= ~XXGE_RCW1_CL_DIS_MASK;
	XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
						XXGE_RCW1_OFFSET, RegRcw1);
}

/*****************************************************************************/
/**
* XXgEthernet_PhySetMdioDivisor sets the MDIO clock divisor in the
* XGEMAC Ethernet,specified by <i>InstancePtr</i> to the value, <i>Divisor</i>.
* This function must be called once after each reset prior to accessing
* MII PHY registers.
*
* From the XGEMAC User Guide, the following equation governs the MDIO clock to the PHY:
*
* <pre>
* 			f[HOSTCLK]
*	f[MDC] = -----------------------
*			(1 + Divisor) * 2
* </pre>
*
* where f[HOSTCLK] is the bus clock frequency in MHz, and f[MDC] is the
* MDIO clock frequency in MHz to the PHY. Typically, f[MDC] should not
* exceed 2.5 MHz. Some PHYs can tolerate faster speeds which means faster
* access.
*
* @param	InstancePtr references the XGEMAC Ethernet instance on which to
*		operate.
* @param	Divisor is the divisor value to set within the range of 0 to
*		XXGE_MDIO_CFG0_CLOCK_DIVIDE_MAX.
*
* @note	None.
*
******************************************************************************/
void XXgEthernet_PhySetMdioDivisor(XXgEthernet *InstancePtr, u8 Divisor)		/* !!sunitaj */
{
	Xil_AssertVoid(InstancePtr != NULL);
	Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY)
	Xil_AssertVoid(Divisor <= XXGE_MDIO_CFG0_CLOCK_DIVIDE_MAX);


	xdbg_printf(XDBG_DEBUG_GENERAL, "XXgEthernet_PhySetMdioDivisor\n");

	XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
				XXGE_MDIO_CFG0_OFFSET,
				(u32) Divisor | XXGE_MDIO_CFG0_MDIOEN_MASK);
}



/*****************************************************************************/
/*
* XXgEthernet_PhyRead reads the specified PHY register, <i>RegisterNum</i> on 
* the PHY specified by <i>PhyAddress</i> into <i>PhyDataPtr</i>. This Ethernet 
* driver does not require the device to be stopped before reading from the PHY.
* It is the responsibility of the calling code to stop the device if it is 
* deemed necessary.
*
* Note that the XGEMAC Ethernet hardware provides the ability to talk to a PHY
* that adheres to the Management Data Input/Output (MDIO) Interface. 
*
* <b>It is important that calling code set up the MDIO clock with
* XXgEthernet_PhySetMdioDivisor() prior to accessing the PHY with this
* function.
* </b>
*
* @param	InstancePtr is a pointer to the XGEMAC Ethernet instance to be
*		worked on.
* @param	PhyAddress is the address of the PHY to be written. This is a 
*       bitmask comprising a Port Address and a Device Address.
* @param	RegisterNum is the register number, 0-31, of the specific PHY
*		register to write.
* @param	PhyDataPtr is a reference to the location where the 16-bit
*		result value is stored.
*
* @return	None.
*
*
* @note
*
* There is the possibility that this function will not return if the hardware
* is broken (i.e., it never sets the status bit indicating that the write is
* done). If this is of concern, the calling code should provide a mechanism
* suitable for recovery.
*
******************************************************************************/
void XXgEthernet_PhyRead(XXgEthernet *InstancePtr, u32 PhyAddress,
			   u32 RegisterNum, u16 *PhyDataPtr)
{

#ifdef	MDIO_CHANGES
	u32 MdioCtrlReg = 0;

	/*
	 * Verify that each of the inputs are valid.
	 */
	Xil_AssertVoid(InstancePtr != NULL);
	Xil_AssertVoid(RegisterNum <= XXGE_PHY_REG_NUM_LIMIT);

        xdbg_printf(XDBG_DEBUG_GENERAL,"PhyRead: BaseAddress %x Offset %x PhyAddress %x RegisterNum %d\n", 
            InstancePtr->Config.BaseAddress, XXGE_MDIO_CFG1_OFFSET, 
               PhyAddress, RegisterNum);

	xdbg_printf(XDBG_DEBUG_GENERAL,
		"XXgEthernet_PhyRead: BaseAddress: 0x%08x\n",
		InstancePtr->Config.BaseAddress);

    /* Sequence of steps is:
     * - Set Address opcode (CFG1) and actual address (TX Data)
     * - RX Data opcode (CFG1) and actual data read (RX Data)
     * - Check for MDIO ready at every step
     */

	/*
	 * Wait till MDIO interface is ready to accept a new transaction.
	 */
	while (!(XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
		XXGE_MDIO_CFG1_OFFSET) & XXGE_MDIO_CFG1_READY_MASK)) {
		;
	}
        xdbg_printf(XDBG_DEBUG_GENERAL,"MDIO CFG1 %x = %x\n", XXGE_MDIO_CFG1_OFFSET, 
            XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
            XXGE_MDIO_CFG1_OFFSET));

    /* Now initiate the set PHY register address operation */
	MdioCtrlReg = PhyAddress | XXGE_MDIO_CFG1_INITIATE_MASK |
                XXGE_MDIO_CFG1_OP_SETADDR_MASK;
        xdbg_printf(XDBG_DEBUG_GENERAL,"Writing Base %x Offset %x = %x\n", 
        	InstancePtr->Config.BaseAddress, XXGE_MDIO_CFG1_OFFSET, MdioCtrlReg);
        xdbg_printf(XDBG_DEBUG_GENERAL,"Writing Base %x Offset %x = %x\n", 
		InstancePtr->Config.BaseAddress, XXGE_MDIO_TX_DATA_OFFSET, 
    		      (RegisterNum & XXGE_MDIO_TX_DATA_MASK));
	
       XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
			XXGE_MDIO_TX_DATA_OFFSET, (RegisterNum & XXGE_MDIO_TX_DATA_MASK));

	XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
			XXGE_MDIO_CFG1_OFFSET, MdioCtrlReg);

	/*
	 * Wait till MDIO transaction is completed.
	 */
	while (!(XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
		XXGE_MDIO_CFG1_OFFSET) & XXGE_MDIO_CFG1_READY_MASK)) {
		;
	}
        xdbg_printf(XDBG_DEBUG_GENERAL,"MDIO CFG1 %x = %x\n", XXGE_MDIO_CFG1_OFFSET, 
            XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
                XXGE_MDIO_CFG1_OFFSET));

	/* Now initiate the read PHY register operation */
	MdioCtrlReg = PhyAddress | XXGE_MDIO_CFG1_INITIATE_MASK |
                XXGE_MDIO_CFG1_OP_READ_MASK;
	XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
			XXGE_MDIO_CFG1_OFFSET, MdioCtrlReg);
	/*
	 * Wait till MDIO transaction is completed.
	 */
	while (!(XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
		XXGE_MDIO_CFG1_OFFSET) & XXGE_MDIO_CFG1_READY_MASK)) {
		;
	}
	*PhyDataPtr = (u16) XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress, 
            XXGE_MDIO_RX_DATA_OFFSET);
	xdbg_printf(XDBG_DEBUG_GENERAL,"XXgEthernet_PhyRead: Value retrieved: 0x%0x\n", *PhyDataPtr);
#else
     *PhyDataPtr = 0x55AA;
#endif
}

/*****************************************************************************/
/*
* XXgEthernet_PhyWrite writes <i>PhyData</i> to the specified PHY register,
* <i>RegiseterNum</i> on the PHY specified by <i>PhyAddress</i>. This Ethernet
* driver does not require the device to be stopped before writing to the PHY.
* It is the responsibility of the calling code to stop the device if it is
* deemed necessary.
*
* <b>It is important that calling code set up the MDIO clock with
* XXgEthernet_PhySetMdioDivisor() prior to accessing the PHY with this
* function.</b>
*
* @param	InstancePtr is a pointer to the XGEMAC Ethernet instance to be
*		worked on.
* @param	PhyAddress is the address of the PHY to be written (multiple
*		PHYs supported).
* @param	RegisterNum is the register number, 0-31, of the specific PHY
*		register to write.
* @param	PhyData is the 16-bit value that will be written to the
*		register.
*
* @return	None.
*
* @note
*
* There is the possibility that this function will not return if the hardware
* is broken (i.e., it never sets the status bit indicating that the write is
* done). If this is of concern, the calling code should provide a mechanism
* suitable for recovery.
*
******************************************************************************/
void XXgEthernet_PhyWrite(XXgEthernet *InstancePtr, u32 PhyAddress,
			u32 RegisterNum, u16 PhyData)
{
#ifdef  MDIO_CHANGES
	u32 MdioCtrlReg = 0;

	/*
	 * Verify that each of the inputs are valid.
	 */
	Xil_AssertVoid(InstancePtr != NULL);
	Xil_AssertVoid(PhyAddress <= XXGE_PHY_ADDR_LIMIT);
	Xil_AssertVoid(RegisterNum <= XXGE_PHY_REG_NUM_LIMIT);

	xdbg_printf(XDBG_DEBUG_GENERAL,
		"XXgEthernet_PhyWrite: BaseAddress: 0x%08x\n",
		InstancePtr->Config.BaseAddress);

    /* Sequence of steps is:
     * - Set Address opcode (CFG1) and actual address (TX Data)
     * - TX Data opcode (CFG1) and actual data to be written (TX Data)
     * - Check for MDIO ready at every step
     */

#if 1
	/*
	 * Wait till the MDIO interface is ready to accept a new transaction.
	 */
	while (!(XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
		XXGE_MDIO_CFG1_OFFSET) & XXGE_MDIO_CFG1_READY_MASK)) {
		;
	}
#endif
    printk("MDIO CFG1 %x = %x\n", XXGE_MDIO_CFG1_OFFSET, 
            XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
            XXGE_MDIO_CFG1_OFFSET));

    /* Now initiate the set PHY register address operation */
	MdioCtrlReg = PhyAddress | XXGE_MDIO_CFG1_INITIATE_MASK |
                XXGE_MDIO_CFG1_OP_SETADDR_MASK;
	XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
			XXGE_MDIO_CFG1_OFFSET, MdioCtrlReg);
	XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
			XXGE_MDIO_TX_DATA_OFFSET, (RegisterNum & XXGE_MDIO_TX_DATA_MASK));

#if 1
	/*
	 * Wait till MDIO transaction is completed.
	 */
	while (!(XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
		XXGE_MDIO_CFG1_OFFSET) & XXGE_MDIO_CFG1_READY_MASK)) {
		;
	}
#endif
    printk("MDIO CFG1 %x = %x\n", XXGE_MDIO_CFG1_OFFSET, 
            XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
            XXGE_MDIO_CFG1_OFFSET));

	/* Now initiate the write PHY register operation */
	MdioCtrlReg = PhyAddress | XXGE_MDIO_CFG1_INITIATE_MASK |
                XXGE_MDIO_CFG1_OP_WRITE_MASK;
	XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress,
			XXGE_MDIO_CFG1_OFFSET, MdioCtrlReg);
	XXgEthernet_WriteReg(InstancePtr->Config.BaseAddress, 
            XXGE_MDIO_TX_DATA_OFFSET, (PhyData & XXGE_MDIO_TX_DATA_MASK));

#if 1
	/*
	 * Wait till the MDIO interface is ready to accept a new transaction.
	 */
	while (!(XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
		XXGE_MDIO_CFG1_OFFSET) & XXGE_MDIO_CFG1_READY_MASK)) {
		;
	}
#endif
    printk("MDIO CFG1 %x = %x\n", XXGE_MDIO_CFG1_OFFSET, 
            XXgEthernet_ReadReg(InstancePtr->Config.BaseAddress,
            XXGE_MDIO_CFG1_OFFSET));
#endif
}

