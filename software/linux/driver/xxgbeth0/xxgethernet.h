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
* @file xxgethernet.h
*
* The Xilinx XGEMAC Ethernet MAC driver component. This driver supports hard
* Ethernet core for Virtex-6(TM) devices and soft Ethernet core for
* Virtex-6(TM) and other supported devices. The supported speed can be
* 10/100/1000 Mbps and can reach upto 2000/2500 Mbps (1000Base-X versions).
*
* For a full description of XGEMAC Ethernet features, please see the hardware
* spec.
* This driver supports the following features:
*   - Memory mapped access to host interface registers
*   - Virtual memory support
*   - Unicast, broadcast, and multicast receive address filtering
*   - Full and half duplex operation
*   - Automatic source address insertion or overwrite (programmable)
*   - Automatic PAD & FCS insertion and stripping (programmable)
*   - Flow control
*   - VLAN frame support
*   - Pause frame support
*   - Jumbo frame support
*   - Partial and full checksum offload
*   - Extended multicast addresses to 2**23.
*   - Extended VLAN translation, tagging and stripping supports.
*
* <h2>Driver Description</h2>
*
* The device driver enables higher layer software (e.g., an application) to
* configure a XGEMAC Ethernet device. It is intended that this driver be used in
* cooperation with another driver (FIFO or DMA) for data communication. This
* device driver can support multiple devices even when those devices have
* significantly different configurations.
*
* <h2>Initialization & Configuration</h2>
*
* The XXgEthernet_Config structure can be used by the driver to configure
* itself. This configuration structure is typically created by the tool-chain
* based on hardware build properties, although, other methods are allowed and
* currently used in some systems.
*
* To support multiple runtime loading and initialization strategies employed
* by various operating systems, the driver instance can be initialized using
* the XXgEthernet_CfgInitialze() routine.
*
* <h2>Interrupts and Asynchronous Callbacks</h2>
*
* The driver has no dependencies on the interrupt controller. It provides
* no interrupt handlers. The application/OS software should set up its own
* interrupt handlers if required.
*
* <h2>Device Reset</h2>
*
* When a XGEMAC Ethernet device is connected up to a FIFO or DMA core in hardware,
* errors may be reported on one of those cores (FIFO or DMA) such that it can
* be determined that the XGEMAC Ethernet device needs to be reset. If a reset is
* performed, the calling code should also reconfigure and reapply the proper
* settings in the XGEMAC Ethernet device.
*
* When a XGEMAC Ethernet device reset is required, XXgEthernet_Reset() should
* be utilized.
*
* <h2>Virtual Memory</h2>
*
* This driver may be used in systems with virtual memory support by passing
* the appropriate value for the <i>EffectiveAddress</i> parameter to the
* XXgEthernet_CfgInitialize() routine.
*
* <h2>Transfering Data</h2>
*
* The XGEMAC Ethernet core by itself is not capable of transmitting or receiving
* data in any meaningful way. Instead the XGEMAC Ethernet device need to be
* connected to a FIFO or DMA core in hardware.
*
* This XGEMAC Ethernet driver is modeled in a similar fashion where the
* application code or O/S adapter driver needs to make use of a separate FIFO
* or DMA driver in connection with this driver to establish meaningful
* communication over Ethernet.
*
* <h2>Checksum Offloading</h2>
*
* If configured, the device can compute a 16-bit checksum from frame data. In
* most circumstances this can lead to a substantial gain in throughput.
*
* The checksum offload settings for each frame sent or received are
* transmitted through the AXI4-Stream interface in hardware. What this means
* is that the checksum offload feature is indirectly controlled in the
* XGEMAC Ethernet device through the driver for DMA core connected
* to the XGEMAC Ethernet device.
*
* Refer to the documentation for DMA driver used for data
* communication on how to set the values for the relevant AXI4-Stream control
* words.
*
* Since this hardware implementation is general purpose in nature system
* software must perform pre and post frame processing to obtain the desired
* results for the types of packets being transferred. Most of the time this
* will be TCP/IP traffic.
*
* TCP/IP and UDP/IP frames contain separate checksums for the IP header and
* UDP/TCP header+data.
* For partial checksum offloading (enabled while configuring the hardware),
* the IP header checksum cannot be offloaded. Many stacks that support
* offloading will compute the IP header if required and use hardware to compute
* the UDP/TCP header+data checksum. There are other complications concerning
* the IP pseudo header that must be taken into consideration. Readers should
* consult a TCP/IP design reference for more details.
* For full checksum offloading (enabled while configuring the hardware), the
* IPv4 checksum calculation and validation can also be offloaded at the
* harwdare. More details on this will be updated when available.
*
* There are certain device options that will affect the checksum calculation
* performed by hardware for Tx:
*
*   - FCS insertion disabled (XXGE_FCS_INSERT_OPTION): software is required to
*     calculate and insert the FCS value at the end of the frame, but the
*     checksum must be known ahead of time prior to calculating the FCS.
*     Therefore checksum offloading cannot be used in this situation.
*
* And for Rx:
*
*   - FCS/PAD stripping disabled (XXGE_FCS_STRIP_OPTION): The 4 byte FCS at the
*     end of frame will be included in the hardware calculated checksum.
*     software must subtract out this data.
*
*   - FCS/PAD stripping disabled (XXGE_FCS_STRIP_OPTION): For frames smaller
*     than 64 bytes, padding will be included in the hardware calculated
*     checksum.
*     software must subtract out this data. It may be better to allow the
*     TCP/IP stack verify checksums for this type of packet.
*
*   - VLAN enabled (XXGE_VLAN_OPTION): The 4 extra bytes in the Ethernet header
*     affect the hardware calculated checksum. software must subtract out the
*     1st two 16-bit words starting at the 15th byte.
*
* <h3>Transmit Checksum Offloading</h3>
*
* For transmit, the software can specify where in the frame the checksum
* calculation is to start, where the result should be inserted, and a seed
* value. The checksum is calculated from the start point through the end of
* frame.
*
* The checksum offloading settings are sent in the transmit AXI4 Stream control
* words. The relevant control word fields are described in brief below.
* Refer to the XGEMAC Ethernet hardware specification for more details.
*
*<h4>AXI4-Stream Control Word 0:</h4>
*<pre>
*	Bits  1-0  : Transmit Checksum Enable: 	01 - partial checsum offload,
*						10 - full checksum offload
*						00 - No checksum offloading
*						11 - Not used, reserved
*	Bits 27-2  : Reserved
*	Bits 31-28 : Used for AXI4-Stream Control Mode flag
*</pre>
*
*<h4>AXI4-Stream Control Word 1:</h4>
*<pre>
*	Bits 31-16 (MSB): Transmit Checksum Calculation Starting Point: Offset
*			  in the frame where checksum calculation should begin
*	Bits 15-0  (LSB): Transmit Checksum Insertion Point: Frame offset where
*			  the computed checksum value is stored, which should be
*			  in the TCP or UDP header
*   </pre>
*
*<h4>AXI4-Stream Control Word 2:</h4>
*<pre>
*	Bits 31-16 (MSB): Reserved
*	Bits  0-15 (LSB): Transmit Checksum Calculation Initial Value: Checksum
*			  seed value
*</pre>
*
* <h3>Receive Checksum Offloading</h3>
*
* For Receive, the 15th byte to end of frame is check summed. This range of
* bytes is the entire Ethernet payload (for non-VLAN frames).
*
* The checksum offloading information is sent in the receive AXI4-Stream
* Control words. There are 4 relevant control words available. However
* only the relevant control words are described in brief below.
* Refer to the XGEMAC Ethernet hardware specification for more details.
*
*<h4>AXI4-Stream Control Word 0:</h4>
*<pre>
*	Bits 31-28 (MSB): Always 0x5 to represent receive status frame
*	Bits 27-16	: Undefined
*	Bits 15-0  (LSB): MCAST_ADR_U. Upper 16 bits of the multicast
*			  destination address of the frame.
*
*<h4>AXI4-Stream Control Word 1:</h4>
*</pre>
*	Bits 31-0	: MCAST_ADR_L. The lower 32 bits of the multicast
*			  destination address.
*
*<h4>AXI4-Stream Control Word 2:</h4>
*Various status information on the received packet.
*
*<h4>AXI4-Stream Control Word 3:</h4>
*	Bits 31-16	: T_L_TPID. This is the value of 13th and 14th byte
*			  of the frame.
*	Bits 15-0 	: Receive Raw Checksum: Computed checksum value
*
*<h4>AXI4-Stream Control Word 3:</h4>
*	Bits 31-16	: VLAN_TAG. Value of 15th and 16th byte of the
*			 frame.
*	Bits 15-0 	: RX_BYTECNT. Received frame length.
*
*
* <h2>Extended multicast</h2>
* (XXGE_EXT_MULTICAST_OPTION): Allow and perform address filtering more than 4
* multicast addresses. Hardware requires to enable promiscuous mode
* (XXGE_PROMISCUOUS_OPTION) and disable legacy multicast mode
* (XXGE_MULTICAST_OPTION) for this feature to work.
*
* <h2>Extended VLAN</h2>
*
* <h3>TX/RX VLAN stripping</h3>
* (XXGE_EXT_[T|R]XVLAN_STRP_OPTION) handles transmit/receive one VLAN tag
* stripping in Ethernet frames. To enable this option, hardware requires to
* build with this feature and enable (XXGE_FCS_INSERT_OPTION),
* (XXGE_FCS_STRP_OPTION) and disable (XXGE_VLAN_OPTION). Supports three modes,
* -XXGE_VSTRP_NONE   : no stripping
* -XXGE_VSTRP_ALL    : strip one tag from all frames
* -XXGE_VSTRP_SELECT : strip one tag from selected frames
*
* <h3>TX/RX VLAN translation</h3>
* (XATE_EXT_[T|R]XVLAN_TRAN_OPTION) handles transmit/receive one VLAN tag
* translation in Ethernet frames. To enable this option, hardware requires to
* build with this feature and enable (XATE_FCS_INSERT_OPTION),
* (XXGE_FCS_STRP_OPTION), and disable (XXGE_VLAN_OPTION).
*
* <h3>TX/RX VLAN tagging</h3>
* (XXGE_EXT_[T|R]XVLAN_TAG_OPTION) adds transmit/receive one VLAN tag in
* Ethernet frames. To enable this option, hardware requires to build with this
* feature and enable (XXGE_FCS_INSERT_OPTION), (XXGE_FCS_STRP_OPTION),
* (XXGE_JUMBO_OPTION) and disable (XXGE_VLAN_OPTION). Support four modes,
* -XXGE_VTAG_NONE    : no tagging
* -XXGE_VTAG_ALL     : tag all frames
* -XXGE_VTAG_EXISTED : tag already tagged frames
* -XXGE_VTAG_SELECT  : tag selected already tagged frames
*
* <h2>PHY Communication</h2>
*
* Prior to PHY access, the MDIO clock must be setup. This driver will set a
* safe default that should work with AXI4-Lite bus speeds of up to 150 MHz
* and keep the MDIO clock below 2.5 MHz. If the user wishes faster access to
* the PHY then the clock divisor can be set to a different value (see
* XXgEthernet_PhySetMdioDivisor()).
*
* MII register access is performed through the functions XXgEthernet_PhyRead()
* and XXgEthernet_PhyWrite().
*
* <h2>Link Sync</h2>
*
* When the device is used in a multi speed environment, the link speed must be
* explicitly set using XXgEthernet_SetOperatingSpeed() and must match the
* speed PHY has negotiated. If the speeds are mismatched, then the MAC will not
* pass traffic.
*
* The application/OS software may use the AutoNegotiation interrupt to be
* notified when the PHY has completed auto-negotiation.
*
* <h2>Asserts</h2>
*
* Asserts are used within all Xilinx drivers to enforce constraints on argument
* values. Asserts can be turned off on a system-wide basis by defining, at
* compile time, the NDEBUG identifier. By default, asserts are turned on and it
* is recommended that users leave asserts on during development. For deployment
* use -DNDEBUG compiler switch to remove assert code.
*
* <h2>Driver Errata</h2>
*
*   - A dropped receive frame indication may be reported by the driver after
*     calling XXgEthernet_Stop() followed by XXgEthernet_Start(). This can
*     occur if a frame is arriving when stop is called.
*   - On Rx with checksum offloading enabled and FCS/PAD stripping disabled,
*     FCS and PAD data will be included in the checksum result.
*   - On Tx with checksum offloading enabled and auto FCS insertion disabled,
*     the user calculated FCS will be included in the checksum result.
*
* @note
*
* Xilinx drivers are typically composed of two components, one is the driver
* and the other is the adapter.  The driver is independent of OS and processor
* and is intended to be highly portable.  The adapter is OS-specific and
* facilitates communication between the driver and an OS.
* <br><br>
* This driver is intended to be RTOS and processor independent. Any needs for
* dynamic memory management, threads or thread mutual exclusion, or cache
* control must be satisfied by the layer above this driver.
*
* MODIFICATION HISTORY:
*
* Ver  Date     Changes
* ---- -------- -------------------------------------------------------
* 1.0  05/15/12 First release
*
*****************************************************************************/

#ifndef XXGETHERNET_H		/* prevent circular inclusions */
#define XXGETHERNET_H		/* by using protection macros */

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/

#include "xstatus.h"
#include "xxgethernet_hw.h"

/************************** Constant Definitions *****************************/

/** @name Configuration options
 *
 * The following are device configuration options. See the
 * <i>XXgEthernet_SetOptions</i>, <i>XXgEthernet_ClearOptions</i> and
 * <i>XXgEthernet_GetOptions</i> routines for information on how to use
 * options.
 *
 * The default state of the options are also noted below.
 *
 * @{
 */

/**< XXGE_PROMISC_OPTION specifies the XGEMAC Ethernet device to accept all
 *   incoming packets.
 *   This driver sets this option to disabled (cleared) by default.
 */
#define XXGE_PROMISC_OPTION		0x00000001

/**< XXGE_JUMBO_OPTION specifies the XGEMAC Ethernet device to accept jumbo
 *   frames for transmit and receive.
 *   This driver sets this option to disabled (cleared) by default.
 */
#define XXGE_JUMBO_OPTION		0x00000002


/**< XXGE_FLOW_CONTROL_OPTION specifies the XGEMAC Ethernet device to recognize
 *   received flow control frames.
 *   This driver sets this option to enabled (set) by default.
 */
#define XXGE_FLOW_CONTROL_OPTION	0x00000008

/**< XXGE_FCS_STRIP_OPTION specifies the XGEMAC Ethernet device to strip FCS and
 *   PAD from received frames. Note that PAD from VLAN frames is not stripped.
 *   This driver sets this option to enabled (set) by default.
 */
#define XXGE_FCS_STRIP_OPTION		0x00000010	 

/**< XXGE_FCS_INSERT_OPTION specifies the XGEMAC Ethernet device to generate the
 *   FCS field and add PAD automatically for outgoing frames.
 *   This driver sets this option to enabled (set) by default.
 */
#define XXGE_FCS_INSERT_OPTION		0x00000020	 

/**< XXGE_LENTYPE_ERR_OPTION specifies the XGEMAC Ethernet device to enable
 *   Length/Type error checking (mismatched type/length field) for received
 *   frames.
 *   This driver sets this option to enabled (set) by default.
 */
#define XXGE_LENTYPE_ERR_OPTION		0x00000040	 

/**< XXGE_TRANSMITTER_ENABLE_OPTION specifies the XGEMAC Ethernet device
 *   transmitter to be enabled.
 *   This driver sets this option to enabled (set) by default.
 */
#define XXGE_TRANSMITTER_ENABLE_OPTION	0x00000080

/**< XXGE_RECEIVER_ENABLE_OPTION specifies the XGEMAC Ethernet device receiver to
 *   be enabled.
 *   This driver sets this option to enabled (set) by default.
 */
#define XXGE_RECEIVER_ENABLE_OPTION	0x00000100

//
/**< XXGE_BROADCAST_OPTION specifies the XGEMAC Ethernet device to receive frames
 *   sent to the broadcast Ethernet address.
 *   This driver sets this option to enabled (set) by default.
 */
#define XXGE_BROADCAST_OPTION		0x00000200	 


#define XXGE_DEFAULT_OPTIONS			\
		(XXGE_FLOW_CONTROL_OPTION |		\
		 XXGE_FCS_INSERT_OPTION |			\
		XXGE_FCS_STRIP_OPTION |			\
		 XXGE_LENTYPE_ERR_OPTION |		\
		 XXGE_TRANSMITTER_ENABLE_OPTION |	\
		 XXGE_RECEIVER_ENABLE_OPTION)
/**< XXGE_DEFAULT_OPTIONS specify the options set in XXgEthernet_Reset() and
 *   XXgEthernet_CfgInitialize()
 */
/*@}*/


#define XXGE_MDIO_DIV_DFT       33	/**< Default MDIO clock divisor */

/*
 * The next few constants help upper layers determine the size of memory
 * pools used for Ethernet buffers and descriptor lists.
 */
#define XXGE_MAC_ADDR_SIZE		6	/* MAC addresses are 6 bytes */
#define XXGE_MTU			1500	/* Max MTU size of an Ethernet
									 * frame
									 */
#define XXGE_JUMBO_MTU			8192	/* Max MTU size of a jumbo
						 				  * Ethernet frame
						 				  */
#define XXGE_HDR_SIZE			14	/* Size of an Ethernet header*/
#define XAE_HDR_VLAN_SIZE		18	/* Size of an Ethernet header
									 * with VLAN
									 */
#define XXGE_TRL_SIZE			4	/* Size of an Ethernet trailer
									 * (FCS)
						 			*/
#define XXGE_MAX_FRAME_SIZE	 (XXGE_MTU + XXGE_HDR_SIZE + XXGE_TRL_SIZE)
#define XAE_MAX_VLAN_FRAME_SIZE  (XAE_MTU + XAE_HDR_VLAN_SIZE + XAE_TRL_SIZE)
#define XXGE_MAX_JUMBO_FRAME_SIZE (XXGE_JUMBO_MTU + XXGE_HDR_SIZE + XXGE_TRL_SIZE)

#ifdef USE_NW_PATH0 
#define XXGE_PHY_PRTAD     0   /* Port address 0 */
#else
#define XXGE_PHY_PRTAD     1   /* Port address 0 */
#endif
#define XXGE_PHY_DEVAD     3   /* Device address 3 */
#define XXGE_PHY_ADDRESS   ((XXGE_PHY_PRTAD << 24) | (XXGE_PHY_DEVAD << 16))





#define XXGE_RX				1 /* Receive direction  */
#define XXGE_TX				2 /* Transmit direction */

/**************************** Type Definitions *******************************/


/**
 * This typedef contains configuration information for a XGEMAC Ethernet device.
 */
#ifdef X86_64
typedef struct XXgEthernet_Config {
	u16 DeviceId;	/**< DeviceId is the unique ID  of the device */
	u64 BaseAddress;/**< BaseAddress is the physical base address of the
			  *  device's registers
			  */
u8 TemacType;   /**< Temac Type can have 3 possible values. They are
			  *  0 for SoftTemac at 10/100 Mbps, 1 for SoftTemac
			  *  at 10/100/1000 Mbps and 2 for Vitex6 Hard Temac
			  */
	u8 TxVlanTran;  /**< TX VLAN Translation indication */
	u8 RxVlanTran;  /**< RX VLAN Translation indication */
	u8 TxVlanTag;   /**< TX VLAN tagging indication */
	u8 RxVlanTag;   /**< RX VLAN tagging indication */
	u8 TxVlanStrp;  /**< TX VLAN stripping indication */
	u8 RxVlanStrp;  /**< RX VLAN stripping indication */
	u8 ExtMcast;    /**< Extend multicast indication */

	u8 Stats;	/**< Statistics gathering option */

} XXgEthernet_Config;
#else 
typedef struct XXgEthernet_Config {
	u16 DeviceId;	/**< DeviceId is the unique ID  of the device */
	u32 BaseAddress;/**< BaseAddress is the physical base address of the
			  *  device's registers
			  */
u8 TemacType;   /**< Temac Type can have 3 possible values. They are
			  *  0 for SoftTemac at 10/100 Mbps, 1 for SoftTemac
			  *  at 10/100/1000 Mbps and 2 for Vitex6 Hard Temac
			  */
	u8 TxVlanTran;  /**< TX VLAN Translation indication */
	u8 RxVlanTran;  /**< RX VLAN Translation indication */
	u8 TxVlanTag;   /**< TX VLAN tagging indication */
	u8 RxVlanTag;   /**< RX VLAN tagging indication */
	u8 TxVlanStrp;  /**< TX VLAN stripping indication */
	u8 RxVlanStrp;  /**< RX VLAN stripping indication */
	u8 ExtMcast;    /**< Extend multicast indication */

	u8 Stats;	/**< Statistics gathering option */

} XXgEthernet_Config;
#endif

/**
 * struct XXgEthernet is the type for XGEMAC Ethernet driver instance data.
 * The calling code is required to use a unique instance of this structure
 * for every XGEMAC Ethernet device used in the system. A reference to a structure
 * of this type is then passed to the driver API functions.
 */
typedef struct XXgEthernet {		 
	XXgEthernet_Config Config; /**< Hardware configuration */
	u32 IsStarted;		 /**< Device is currently started */
	u32 IsReady;		 /**< Device is initialized and ready */
	u32 Options;		 /**< Current options word */
	u32 Flags;		 /**< Internal driver flags */
} XXgEthernet;


/***************** Macros (Inline Functions) Definitions *********************/

/*****************************************************************************/
/**
*
* XXgEthernet_IsStarted reports if the device is in the started or stopped
* state. To be in the started state, the calling code must have made a
* successful call to <i>XXgEthernet_Start</i>. To be in the stopped state,
* <i>XXgEthernet_Stop</i> or <i>XXgEthernet_CfgInitialize</i> function must
* have been called.
*
* @param	InstancePtr is a pointer to the of XGEMAC Ethernet instance to be
*		worked on.
*
* @return
*		- TRUE if the device has been started.
*		- FALSE.if the device has not been started
*
* @note 	C-style signature:
* 		u32 XXgEthernet_IsStarted(XXgEthernet *InstancePtr)
*
 ******************************************************************************/
#define XXgEthernet_IsStarted(InstancePtr) \
	(((InstancePtr)->IsStarted == XIL_COMPONENT_IS_STARTED) ? TRUE : FALSE)


/*****************************************************************************/
/**
*
* XXgEthernet_IsStatsConfigured returns determines if Statistics gathering.
* is configured in the harwdare or not.
*
* @param	InstancePtr is a pointer to the XGEMAC Ethernet instance to be
*		worked on.
*
* @return
*	 	- TRUE if the device is configured with
*		  statistics gathering.
*		- FALSE if the device is NOT configured with
*		  statistics gathering.
*
* @note 	C-style signature:
* 		u32 XXgEthernet_IsAvbConfigured(XXgEthernet *InstancePtr)
*
 *****************************************************************************/
#define XXgEthernet_IsStatsConfigured(InstancePtr)	\
	(((InstancePtr)->Config.Stats) ? TRUE : FALSE)

/************************** Function Prototypes ******************************/

/*
 * Initialization functions in xxgeethernet.c
 */
#ifdef X86_64
int XXgEthernet_CfgInitialize(XXgEthernet *InstancePtr, XXgEthernet_Config *CfgPtr,u64 VirtualAddress);
#else 
int XXgEthernet_CfgInitialize(XXgEthernet *InstancePtr, XXgEthernet_Config *CfgPtr,u32 VirtualAddress);
#endif
void XXgEthernet_Start(XXgEthernet *InstancePtr);
void XXgEthernet_Stop(XXgEthernet *InstancePtr);
void XXgEthernet_Reset(XXgEthernet *InstancePtr);

/*
 * Initialization functions in xxgetemac_sinit.c
 */
XXgEthernet_Config *XXgEthernet_LookupConfig(u16 DeviceId);

/*
 * MAC configuration/control functions in xxgetemac_control.c
 */
int XXgEthernet_SetOptions(XXgEthernet *InstancePtr, u32 Options);
int XXgEthernet_ClearOptions(XXgEthernet *InstancePtr, u32 Options);
u32 XXgEthernet_GetOptions(XXgEthernet *InstancePtr);

int XXgEthernet_SetMacAddress(XXgEthernet *InstancePtr, void *AddressPtr);
void XXgEthernet_GetMacAddress(XXgEthernet *InstancePtr, void *AddressPtr);

int XXgEthernet_SetMacPauseAddress(XXgEthernet *InstancePtr,
							void *AddressPtr);
void XXgEthernet_GetMacPauseAddress(XXgEthernet *InstancePtr,
							void *AddressPtr);
int XXgEthernet_SendPausePacket(XXgEthernet *InstancePtr, u16 PauseValue);


void XXgEthernet_SetBadFrmRcvOption(XXgEthernet *InstancePtr);
void XXgEthernet_ClearBadFrmRcvOption(XXgEthernet *InstancePtr);

void XXgEthernet_DisableControlFrameLenCheck(XXgEthernet *InstancePtr);
void XXgEthernet_EnableControlFrameLenCheck(XXgEthernet *InstancePtr);

void XXgEthernet_PhySetMdioDivisor(XXgEthernet *InstancePtr, u8 Divisor);
void XXgEthernet_PhyRead(XXgEthernet *InstancePtr, u32 PhyAddress,
					u32 RegisterNum, u16 *PhyDataPtr);
void XXgEthernet_PhyWrite(XXgEthernet *InstancePtr, u32 PhyAddress,
			 		u32 RegisterNum, u16 PhyData);


#ifdef __cplusplus
}
#endif

#endif /* end of protection macro */
