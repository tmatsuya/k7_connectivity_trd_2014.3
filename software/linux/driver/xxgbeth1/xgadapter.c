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
 * @file xgadapter.c
 *
 * This is the Linux Ethernet driver for the XPS_LL_TEMAC core. It registers 
 * with the TCP/IP stack above it and with the Xilinx base DMA driver (xdma) 
 * below it.
 *
 * Author: Xilinx, Inc.
 *
 * 2007-2010 (c) Xilinx, Inc. This file is licensed uner the terms of the GNU
 * General Public License version 2.1. This program is licensed "as is" without
 * any warranty of any kind, whether express or implied.
 *
 * @note
 *
 * With the way the hardened Temac works, the driver needs to communicate
 * with the PHY controller. Since each board will have a different
 * type of PHY, this driver supports MII and 1000BASE-X types under 
 * compile-time macros. For your specific board, you will want to replace 
 * this code with code of your own for your specific board.
 *
 * <b> Checksum Offload </b>
 *
 * TX or RX checksum offloading can be enabled or disabled via ethtool.
 *
 * <b> Transmit CSO: </b> 
 * If TX checksum offload is enabled, when the ethernet stack wants us 
 * to perform the checksum in hardware, skb->ip_summed is set to CHECKSUM_HW
 * or CHECKSUM_PARTIAL (depending on the OS version). Otherwise skb->ip_summed 
 * is CHECKSUM_NONE, meaning the checksum is already done, or 
 * CHECKSUM_UNNECESSARY, meaning checksumming is turned off (e.g. for a 
 * loopback interface)
 *
 * When the driver is requested to transmit a packet, the ethernet stack 
 * above will have already computed the pseudoheader csum value and have 
 * placed it in the TCP/UDP header.
 *
 * The IP header csum has also already been computed and inserted.
 *
 * Since the IP header with it's own csum should compute to a null
 * csum, it should be ok to include it in the hw csum. 
 *
 * <b> Receive CSO: </b>
 * This hardware only supports proper checksum calculations
 * on TCP/UDP packets. Other packets as well as packets smaller than
 * or equal to 64 bytes in length must be verified for checksum by the
 * stack as usual.
 *
 * The skb->csum field is set to the actual checksum value as returned
 * by the hardware, before it is passed up the stack.
 *
 * If we set skb->ip_summed to CHECKSUM_COMPLETE or CHECKSUM_HW 
 * (depending on the OS version), the ethernet stack above will compute 
 * only the pseudoheader csum value and add it to the partial checksum 
 * (already computed and placed in skb->csum) and verify it.
 *
 * Setting skb->ip_summed to CHECKSUM_NONE means that the hardware
 * didn't compute the checksum and the stack must check it instead.
 *
 * Setting skb->ip_summed to CHECKSUM_UNNECESSARY means
 * that the cheksum was verified/assumed to be good and the
 * stack does not need to (re)check it. This is not done by this driver.
 *
 * The ethernet stack above will (re)compute the checksum
 * under the following conditions:
 * 1) skb->ip_summed was set to CHECKSUM_NONE
 * 2) skb->len does not match the length of the ethernet
 *    packet determined by parsing the packet. In this case
 *    the ethernet stack will assume any prior checksum
 *    value was miscomputed and throw it away.
 * 3) skb->ip_summed was set to CHECKSUM_COMPLETE or CHECKSUM_HW, 
 *    skb->csum was set, but the result does not check out ok by the
 *    ethernet stack.
 *
 * The minimum transfer packet size over the wire is 64 bytes. If the 
 * packet is sent as exactly 64 bytes, then it probably contains some 
 * random padding bytes. It is somewhat difficult to determine the 
 * actual length of the real packet data, so we just let the stack recheck the
 * checksum for us.
 *
 * After the call to eth_type_trans(), the following holds true:
 *    skb->data points to the beginning of the ip header
 *
 * <b> FCS Stripping: </b>
 * If the TEMAC hardware stripping feature is off, each received
 * packet will contain an FCS field. If the feature is enabled, then
 * each received packet will not include the FCS field. This driver has
 * the FCS stripping feature enabled, and has not been tested with it
 * disabled.
 *
 * <b> Checksum Offload and FCS Stripping: </b>
 * If the FCS stripping feature is disabled, and checksum offload is
 * enabled, then the received packet will contain the FCS field, which 
 * would have been included in the hardware checksum operation. This 4-byte
 * FCS value needs to be subtracted back out of the checksum value computed 
 * by hardware as it is not included in a normal ethernet packet checksum.
 * 
 * This combination has not been adequately tested in this driver.
 *
 * MODIFICATION HISTORY:
 *
 * Ver   Date     Changes
 * ----- -------- -------------------------------------------------------
 * 1.0  05/15/12 First release 
 *
 ******************************************************************************/


/***************************** Include Files *********************************/

#include <linux/version.h>
#include <linux/pci.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/mm.h>
#include <linux/netdevice.h>
#include <linux/etherdevice.h>
#include <linux/mii.h>
#include <linux/delay.h>
#include <linux/dma-mapping.h>
#include <asm/io.h>
#include <linux/ethtool.h>
#include <linux/vmalloc.h>
#include <linux/spinlock.h>

#include "xgadapter.h"
#include "xxgethernet.h"
#include "xdma_user.h"


/************************** Constant Definitions *****************************/

/** @name PHY-related constants
 * Two possible PHY types are supported in this driver. The following
 * check ensures that one or the other, but not both, must be defined
 * else the driver will not compile.
 * @{
 */

/*@}*/

/** @name DMA-related constants
 * @{
 */

/* SJ: Added macros for K7*/
#ifdef USE_NW_PATH0
#define TX_ENGINE           0       /**< DMA Engine number of TX engine */
#define RX_ENGINE           32      /**< DMA Engine number of RX engine */
#define NW_PATH_OFFSET      0xB000
#endif

#ifdef USE_NW_PATH1
#define TX_ENGINE           1       /**< DMA Engine number of TX engine */
#define RX_ENGINE           33      /**< DMA Engine number of RX engine */
#define NW_PATH_OFFSET	    0xC000
#endif

//----------------

#define DESIGN_MODE_ADDRESS 0x9004
#define PERF_DESIGN_MODE    0x00000000

#define UNINITIALIZED       0       /**< Driver state at start */
#define INITIALIZED_TOP     1       /**< Driver state before registering */
#define INITIALIZED_FIRST   2       /**< Driver state during registering.
                                    * UserInit() will be invoked for both TX and RX engines. This is an
                                    * intermediate state after the first UserInit() is invoked. */
#define INITIALIZED_SECOND  3       /**< Driver state during registering 
                                    * UserInit() will be invoked for both TX and RX engines. This is an
                                    * intermediate state after the second UserInit() is invoked. */
#define READY               4       /**< Driver state after registering. */
#undef UNREGISTERING
#define UNREGISTERING       5       /**< Driver state while unregistering */
#ifdef PM_SUPPORT
#define PM_SUSPEND          6       /* Driver is being suspended */
#endif

#define TEMAC_BAR           0       /**< BAR with the device registers */
#define TEMAC_OFFSET        0x0     /**< Offset within the BAR */
#define TEMAC_SIZE          0x400   /**< Space for 64 4-byte regs */
#define TEMAC_PKTSIZE       1600    /**< Buffer size with MTU 1514 */
/*@}*/

#define XXGE_AUTOSTRIPPING       1     /**< Set to enable FCS auto-stripping */

/** @name Driver Information. Is used while registering the driver and
 * for driver information displayed by tools like ethtool, modprobe, etc.
 * @{
 */
/* Must be shorter than length of ethtool_drvinfo.driver field to fit */
#define DRIVER_NAME         "xxgbeth_driver"
#define DRIVER_DESCRIPTION  "Xilinx 10 Gigabit Ethernet (XGEMAC) Linux driver"
#define DRIVER_VERSION      "1.0"
/*@}*/

#define TX_TIMEOUT   (3*HZ)	/** < Transmission watchdog timeout is 3 seconds */

/** @name Buffer alignment required on receive buffers.
 * @{
 */
#define ALIGNMENT_RECV          32
#define BUFFER_ALIGNRECV(adr) ((ALIGNMENT_RECV - ((u32) adr)) % ALIGNMENT_RECV)
/*@}*/

typedef enum DUPLEX { UNKNOWN_DUPLEX, HALF_DUPLEX, FULL_DUPLEX } DUPLEX;


/************************** Variable Names ***********************************/

struct net_device *ndev = NULL;	    /* This networking device */

/** @name Buffers to handle multi-fragment packets 
 * @{
 */
PktBuf Pkt[MAX_SKB_FRAGS];
/*@}*/


/************************** Function Prototypes ******************************/

/** @name Interface with DMA driver
 * @{
 */
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 29)
static void xenet_set_netdev_ops(struct net_device *, struct net_device_ops *);
#endif
#ifdef X86_64
static int xtenet_init_bottom(u64 , u64 );
int myRxGetPkt(void *, PktBuf *, unsigned int, int, u64);
int myRxPutPkt(void *, PktBuf *, int, u64);
int myTxPutPkt(void *, PktBuf *, int, u64);
int mySetState(void *, UserState *, u64);
int myGetState(void *, UserState *, u64);
#ifdef PM_SUPPORT
int mySetSuspend_Early(void * handle, UserState * ustate, u64 privdata);
int mySetSuspend_Late(void * handle, UserState * ustate, u64 privdata);
int mySetResume(void * handle, UserState * ustate, u64  privdata);
#endif
#else
static int xtenet_init_bottom(unsigned int, unsigned int);
int myRxGetPkt(void *, PktBuf *, unsigned int, int, unsigned int);
int myRxPutPkt(void *, PktBuf *, int, unsigned int);
int myTxPutPkt(void *, PktBuf *, int, unsigned int);
int mySetState(void *, UserState *, unsigned int);
int myGetState(void *, UserState *, unsigned int);
#ifdef PM_SUPPORT
int mySetSuspend_Early(void * handle, UserState * ustate, unsigned int privdata);
int mySetSuspend_Late(void * handle, UserState * ustate, unsigned int privdata);
int mySetResume(void * handle, UserState * ustate, unsigned int privdata);
#endif
#endif
/*@}*/

/** @name Interface with upper layer
 * @{
 */
static int xenet_Send_internal(struct sk_buff *, struct net_device *);
/*@}*/
#ifdef DEBUG_VERBOSE
static void read_xgemac(unsigned int);
void disp_frag(unsigned char *, u32);
#endif

/** @name Our private per-device data. When a net_device is allocated we 
 * will ask for enough extra space for this.
 * @{
 */
 #ifdef X86_64
 struct net_local {
	struct list_head rcv;
	struct list_head xmit;

	struct net_device *ndev;	    /* This device instance */
	struct net_device_stats stats;	/* Statistics for this device */
	struct timer_list phy_timer;	/* PHY monitoring timer */

	u32 index;		                /* Which interface is this */
	u32 xgmii_addr;		            /* The XGMII address of the PHY */	
	u64 versionReg;                 /* User-specific version info */

	void * TxHandle;                /* Handle of TX DMA engine */
	void * RxHandle;                /* Handle of RX DMA engine */

	int DriverState;                /* State of driver */
#ifdef PM_SUPPORT
	int DriverState_beforeSusp;     /* State of driver before Suspend */
#endif
	/* The underlying OS independent code needs space as well.  A
	 * pointer to the following XXgEthernet structure will be passed to
	 * any XXgEthernet_ function that requires it.  However, we treat the
	 * data as an opaque object in this file (meaning that we never
	 * reference any of the fields inside this structure). */
	XXgEthernet Emac;

	unsigned int max_frame_size;
	/* buffer for one skb in case no room is available for transmission */
	struct sk_buff *deferred_skb;

	/* Stats which could not fit in net_device_stats */
    	int tx_pkts;
    	int rx_pkts;
    	int max_frags_in_a_packet;
    	unsigned long realignments;
	unsigned long local_features;
#if ! XXGE_AUTOSTRIPPING
	unsigned long stripping;
#endif
};
 #else
struct net_local {
	struct list_head rcv;
	struct list_head xmit;

	struct net_device *ndev;	    /* This device instance */
	struct net_device_stats stats;	/* Statistics for this device */
	struct timer_list phy_timer;	/* PHY monitoring timer */

	u32 index;		                /* Which interface is this */
	u32 xgmii_addr;		            /* The XGMII address of the PHY */	
	u32 versionReg;                 /* User-specific version info */

	void * TxHandle;                /* Handle of TX DMA engine */
	void * RxHandle;                /* Handle of RX DMA engine */

	int DriverState;                /* State of driver */
#ifdef PM_SUPPORT
	int DriverState_beforeSusp;     /* State of driver before Suspend */
#endif
	/* The underlying OS independent code needs space as well.  A
	 * pointer to the following XXgEthernet structure will be passed to
	 * any XXgEthernet_ function that requires it.  However, we treat the
	 * data as an opaque object in this file (meaning that we never
	 * reference any of the fields inside this structure). */
	XXgEthernet Emac;

	unsigned int max_frame_size;
	/* buffer for one skb in case no room is available for transmission */
	struct sk_buff *deferred_skb;

	/* Stats which could not fit in net_device_stats */
    	int tx_pkts;
    	int rx_pkts;
    	int max_frags_in_a_packet;
    	unsigned long realignments;
	unsigned long local_features;
#if ! XXGE_AUTOSTRIPPING
	unsigned long stripping;
#endif
};
#endif
/*@}*/

/** @name ethtool-related variables
 * ethtool has a status reporting feature where we can report any sort of
 * status information we'd like. This is the list of strings used for that
 * status reporting. ETH_GSTRING_LEN is defined in ethtool.h
 * @{
 */
/** Strings displayed in ethtool statistics */
static char xenet_ethtool_gstrings_stats[][ETH_GSTRING_LEN] = 
{
    "txpkts",       /**< Total number of TX packets */
    "txbytes",      /**< Total number of TX bytes */
    "txundrerr",    /**< Total number of TX underrun errors */
    "rxpkts",       /**< Total number of RX packets */
    "rxbytes",      /**< Total number of RX bytes */
    "rxlenerr",     /**< Total number of RX packet length errors */
    "rxcrcerr",     /**< Total number of RX packet CRC errors */
    "max_frags",    /**< Maximum number of fragments in TX packets */
    
};

#define XENET_STATS_LEN sizeof(xenet_ethtool_gstrings_stats) / ETH_GSTRING_LEN

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 29)
static struct net_device_ops xenet_netdev_ops;
#endif

/*@}*/

/** @name For protection exclusion of all program flows
 * Calls from upper layer, and calls from DMA driver, and timer handlers.
 * Wrap certain temac routines with a lock, so access to the shared hard temac
 * interface is accessed mutually exclusive for dual channel temac support.
 * @{
 */
spinlock_t XTE_spinlock;

/* Queues with locks */
LIST_HEAD(receivedQueue);
static spinlock_t receivedQueueSpin;

LIST_HEAD(sentQueue);
static spinlock_t sentQueueSpin;
/*@}*/


/***************** Macros (Inline Functions) Definitions *********************/

/** @name Inline functions for programming the TEMAC. The underscore version
 * holds the spinlock and then calls the non-underscore version.
 * @{
 */
static inline void _XXgEthernet_Start(XXgEthernet *InstancePtr)
{
	spin_lock_bh(&XTE_spinlock);
	XXgEthernet_Start(InstancePtr);
	spin_unlock_bh(&XTE_spinlock);
}

static inline void _XXgEthernet_Stop(XXgEthernet *InstancePtr)
{
	spin_lock_bh(&XTE_spinlock);
	XXgEthernet_Stop(InstancePtr);
	spin_unlock_bh(&XTE_spinlock);
}

static inline void _XXgEthernet_Reset(XXgEthernet *InstancePtr)
{
	spin_lock_bh(&XTE_spinlock);
	XXgEthernet_Reset(InstancePtr);
	spin_unlock_bh(&XTE_spinlock);
}

static inline int _XXgEthernet_SetMacAddress(XXgEthernet *InstancePtr,
                                              void *AddressPtr)
{
	int status;

	spin_lock_bh(&XTE_spinlock);
	status = XXgEthernet_SetMacAddress(InstancePtr, AddressPtr);
	spin_unlock_bh(&XTE_spinlock);

	return	status;
}

static inline void _XXgEthernet_GetMacAddress(XXgEthernet *InstancePtr,
                                              void *AddressPtr)
{
	spin_lock_bh(&XTE_spinlock);
	XXgEthernet_GetMacAddress(InstancePtr, AddressPtr);
	spin_unlock_bh(&XTE_spinlock);
}

static inline int _XXgEthernet_SetOptions(XXgEthernet *InstancePtr, u32 Options)
{
	int status;

	spin_lock_bh(&XTE_spinlock);
	status = XXgEthernet_SetOptions(InstancePtr, Options);
	spin_unlock_bh(&XTE_spinlock);

	return status;
}

static inline int _XXgEthernet_ClearOptions(XXgEthernet *InstancePtr, u32 Options)
{
	int status;

	spin_lock_bh(&XTE_spinlock);
	status = XXgEthernet_ClearOptions(InstancePtr, Options);
	spin_unlock_bh(&XTE_spinlock);

	return status;
}

static inline void _XXgEthernet_PhyRead(XXgEthernet *InstancePtr, u32 PhyAddress,
                                     u32 RegisterNum, u16 *PhyDataPtr)
{
	spin_lock_bh(&XTE_spinlock);
	XXgEthernet_PhyRead(InstancePtr, PhyAddress, RegisterNum, PhyDataPtr);
	spin_unlock_bh(&XTE_spinlock);
}

static inline void _XXgEthernet_PhyWrite(XXgEthernet *InstancePtr, u32 PhyAddress,
                                     u32 RegisterNum, u16 PhyData)
{
	spin_lock_bh(&XTE_spinlock);
	XXgEthernet_PhyWrite(InstancePtr, PhyAddress, RegisterNum, PhyData);
	spin_unlock_bh(&XTE_spinlock);
}


/*
 * Helper function to reset the underlying hardware.  This is called
 * when we get into such deep trouble that we don't know how to handle
 * otherwise.
 */
static void reset(struct net_device *dev, u32 line_num)
{

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
	struct net_local *lp = netdev_priv(dev);
#else	
	struct net_local *lp = (struct net_local *) dev->priv;	
#endif	
		
	u32 Options;
#if defined DEBUG_NORMAL || defined DEBUG_VERBOSE
	static u32 reset_cnt = 0;
#endif

	log_normal(KERN_INFO "%s: XXgEthernet: resets (#%u) from adapter code line %d\n",
	       dev->name, ++reset_cnt, line_num);

	/* Shouldn't really be necessary, but shouldn't hurt. */
	netif_stop_queue(dev);

	/* Stop device */
	_XXgEthernet_Stop(&lp->Emac);

	/*
	 * XXgEthernet_Reset puts the device back to the default state.  We need
	 * to save all the settings we don't already know, reset, restore
	 * the settings, and then restart the TEMAC.
	 */
	Options = XXgEthernet_GetOptions(&lp->Emac);

	/* now we can reset the device */
	_XXgEthernet_Reset(&lp->Emac);

	/* Reset on TEMAC also resets PHY. Give it some time to finish negotiation
	 * before we move on */
	mdelay(2000);

	/*
	 * The following four functions will return an error if the
	 * EMAC is already started.  We just stopped it by calling
	 * _XXgEthernet_Reset() so we can safely ignore the return values.
	 */
	(int) _XXgEthernet_SetMacAddress(&lp->Emac, dev->dev_addr);

	(int) _XXgEthernet_SetOptions(&lp->Emac, Options);
	(int) _XXgEthernet_ClearOptions(&lp->Emac, ~Options);
	Options = XXgEthernet_GetOptions(&lp->Emac);
	log_normal(KERN_INFO "%s: XXgEthernet: Options: 0x%x\n", dev->name, Options);


	if (lp->deferred_skb) {
		dev_kfree_skb_any(lp->deferred_skb);
		lp->deferred_skb = NULL;
		lp->stats.tx_errors++;
	}

	/*
	 * XXgEthernet_Start returns an error when: if configured for
	 * scatter-gather DMA and a descriptor list has not yet been created
	 * for the send or receive channel, or if no receive buffer descriptors
	 * have been initialized. Those are not happening. so ignore the returned
	 * result checking.
	 */
	_XXgEthernet_Start(&lp->Emac);

	/* We're all ready to go.  Start the queue in case it was stopped. */
	netif_wake_queue(dev);
}

#ifdef	MDIO_CHANGES
/*
 * The PHY registers read here should be standard registers in all PHY chips
 */
static int get_phy_status(struct net_device *dev, DUPLEX * duplex, int *linkup)
{
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
	struct net_local *lp = netdev_priv(dev);
#else	
	struct net_local *lp = (struct net_local *) dev->priv;	
#endif	

	u16 reg;

	*duplex = FULL_DUPLEX;

	_XXgEthernet_PhyRead(&lp->Emac, lp->xgmii_addr, XXGE_MDIO_REGISTER_ADDRESS, &reg);
#ifdef MDIO_CHANGES
	*linkup = reg & XXGE_MDIO_PHY_LINK_UP_MASK;
#else
//	 Forced this to 1 when there is no PHY
	*linkup = 1;
#endif

	return 0;
}
#endif

/*
 * This routine is used for two purposes.  The first is to keep the
 * EMAC's duplex setting in sync with the PHY's.  The second is to keep
 * the system appraised of the state of the link.  Note that this driver
 * does not configure the PHY.  Either the PHY should be configured for
 * auto-negotiation or it should be handled by something like mii-tool. */
static void poll_gmii(unsigned long data)
{
#ifdef	MDIO_CHANGES
	struct net_device *dev;
	struct net_local *lp;
	DUPLEX phy_duplex;
	int phy_carrier;
	int netif_carrier;

	dev = (struct net_device *) data;

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28) 
	lp = netdev_priv(dev);
#else	
	lp = (struct net_local *) dev->priv;	
#endif	

	

/* First, find out what's going on with the PHY. */
    log_verbose(KERN_ERR "poll_gmii\n");
	if (get_phy_status(dev, &phy_duplex, &phy_carrier)) {
		log_normal(KERN_ERR "%s: XXgEthernet: terminating link monitoring.\n",
		       dev->name);
		return;
	}
	netif_carrier = netif_carrier_ok(dev) != 0;
	if (phy_carrier != netif_carrier) {
		if (phy_carrier) {
			log_normal(KERN_INFO
			       "%s: XXgEthernet: PHY Link carrier restored.\n",
			       dev->name);
			netif_carrier_on(dev);
/*!!            set_mac_speed(lp);	*/
		}
		else {
			log_normal(KERN_INFO "%s: XXgEthernet: PHY Link carrier lost.\n",
			       dev->name);
			netif_carrier_off(dev);
		}
	}

	/* Set up the timer so we'll get called again in 2 seconds. */
	lp->phy_timer.expires = jiffies + 2 * HZ;
	add_timer(&lp->phy_timer);
#endif
}


#ifdef DEBUG_VERBOSE
static void read_xgemac(unsigned int IoAddrTemac)
{
    printk("RCW0 = 0x%x\t", XXgEthernet_ReadReg(IoAddrTemac,XXGE_RCW0_OFFSET));
    printk("RCW1 = 0x%x\t", XXgEthernet_ReadReg(IoAddrTemac,XXGE_RCW1_OFFSET));
    printk("TC   = 0x%x\t", XXgEthernet_ReadReg(IoAddrTemac,XXGE_TC_OFFSET));
    printk("CAP  = 0x%x\t", XXgEthernet_ReadReg(IoAddrTemac,XXGE_CAP_OFFSET));
    printk("MC0  = 0x%x\n", XXgEthernet_ReadReg(IoAddrTemac,XXGE_MDIO_CFG0_OFFSET));
    printk("MC1  = 0x%x\n", XXgEthernet_ReadReg(IoAddrTemac,XXGE_MDIO_CFG1_OFFSET));
    printk("MTX  = 0x%x\t", XXgEthernet_ReadReg(IoAddrTemac,XXGE_MDIO_TX_DATA_OFFSET));
    printk("MRX  = 0x%x\n", XXgEthernet_ReadReg(IoAddrTemac,XXGE_MDIO_RX_DATA_OFFSET));
        //-Read Stats
    printk("RcvdBytesLower = 0x%x\n", XXgEthernet_ReadReg(IoAddrTemac,XXGE_RXBL_OFFSET));
    printk("RcvdBytesUpper = 0x%x\n", XXgEthernet_ReadReg(IoAddrTemac,XXGE_RXBU_OFFSET));
    printk("SentBytesLower = 0x%x\n", XXgEthernet_ReadReg(IoAddrTemac,XXGE_TXBL_OFFSET));
    printk("SentBytesUpper = 0x%x\n", XXgEthernet_ReadReg(IoAddrTemac,XXGE_TXBU_OFFSET));
    printk("FCS ErrorLower = 0x%x\n", XXgEthernet_ReadReg(IoAddrTemac,XXGE_RXFCSERL_OFFSET));
    printk("FCS ErrorUpper = 0x%x\n", XXgEthernet_ReadReg(IoAddrTemac,XXGE_RXFCSERU_OFFSET));
    printk("L/T ErrorLower = 0x%x\n", XXgEthernet_ReadReg(IoAddrTemac,XXGE_RXLTERL_OFFSET));
    printk("L/T ErrorUpper = 0x%x\n", XXgEthernet_ReadReg(IoAddrTemac,XXGE_RXLTERU_OFFSET));
}
#endif



/* Gets called when ifconfig opens the interface */
static int xenet_open(struct net_device *dev)
{
    struct net_local *lp;
	u32 Options;

    log_normal(KERN_INFO "calling xenet_open\n");

	/*
	 * Just to be safe, stop TX queue and the device first.  If the device is
	 * already stopped, an error will be returned.  In this case, we don't
	 * really care.
	 */
	netif_stop_queue(dev);

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
    lp = netdev_priv(dev);
#else		
    lp = (struct net_local *) dev->priv;	
#endif	

	_XXgEthernet_Stop(&lp->Emac);
	/* Set the MAC address each time opened. */
	if (_XXgEthernet_SetMacAddress(&lp->Emac, dev->dev_addr) != XST_SUCCESS) {
		printk(KERN_ERR "%s: xgbeth_axi: could not set MAC address.\n",
		       dev->name);
		return -EIO;
	}

	/*
	 * If the device is not configured for polled mode, connect to the
	 * interrupt controller and enable interrupts.  Currently, there
	 * isn't any code to set polled mode, so this check is probably
	 * superfluous.
	 */
	Options = XXgEthernet_GetOptions(&lp->Emac);
	Options |= XXGE_FLOW_CONTROL_OPTION;
#ifdef ENABLE_JUMBO    
	Options |= XXGE_JUMBO_OPTION;
#endif    
	Options |= XXGE_TRANSMITTER_ENABLE_OPTION;
	Options |= XXGE_RECEIVER_ENABLE_OPTION;
#if XXGE_AUTOSTRIPPING
	Options |= XXGE_FCS_STRIP_OPTION;
#endif

	(int) _XXgEthernet_SetOptions(&lp->Emac, Options);
	Options = XXgEthernet_GetOptions(&lp->Emac);
	log_normal(KERN_INFO "%s: XXgEthernet: Options: 0x%x\n", dev->name, Options);
	/* give the system enough time to establish a link */
	mdelay(2000);

    /* Start TEMAC device */
    _XXgEthernet_Start(&lp->Emac);

	/* We're ready to go. */
	netif_start_queue(dev);
	/* Set up the PHY monitoring timer. */
	lp->phy_timer.expires = jiffies + 2 * HZ;
	lp->phy_timer.data = (unsigned long) dev;
	lp->phy_timer.function = &poll_gmii;
	init_timer(&lp->phy_timer);
	add_timer(&lp->phy_timer);

	INIT_LIST_HEAD(&sentQueue);
	INIT_LIST_HEAD(&receivedQueue);

	spin_lock_init(&sentQueueSpin);
	spin_lock_init(&receivedQueueSpin);


	return 0;
}

static int xenet_close(struct net_device *dev)
{
	struct net_local *lp;

    log_normal(KERN_INFO "xenet_close:\n");

       #if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
       	    lp = netdev_priv(dev);
       #else
       	    lp = (struct net_local *) dev->priv;	
       #endif	
				
	/* Shut down the PHY monitoring timer. */
	del_timer_sync(&lp->phy_timer);
	/* Stop Send queue */
	netif_stop_queue(dev);
	/* Now we could stop the device */
	_XXgEthernet_Stop(&lp->Emac);

    return 0;
}

static struct net_device_stats *xenet_get_stats(struct net_device *dev)
{
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
    struct net_local *lp = netdev_priv(dev);
#else    		
    struct net_local *lp = (struct net_local *) dev->priv;	
#endif	


    log_normal(KERN_INFO "xenet_get_stats: \n");

    return &(lp->stats);
}

static int xenet_change_mtu(struct net_device *dev, int new_mtu)
{
        u32 SetMtu=0; 
#ifdef CONFIG_XILINX_GIGE_VLAN
	int head_size = XXGE_HDR_VLAN_SIZE;
#else
	int head_size = XXGE_HDR_SIZE;
#endif

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
    struct net_local *lp = netdev_priv(dev);
#else			
    struct net_local *lp = (struct net_local *) dev->priv;	
#endif	


	int max_frame = new_mtu + head_size + XXGE_TRL_SIZE;
	int min_frame = 1 + head_size + XXGE_TRL_SIZE;

    log_verbose(KERN_INFO "xenet_change_mtu:\n");

	if ((max_frame < min_frame) || (max_frame > lp->max_frame_size))
		return -EINVAL;

    dev->mtu = new_mtu;	/* change mtu in net_device structure */
	//- XGEMAC provides MTU configuration registers but Jumbo bit takes precendence over them
//    SetMtu = lp->max_frame_size;
//    SetMtu = SetMtu | XXGE_RMTU_FI_MASK ;

//    XXgEthernet_WriteReg((lp->Emac.Config.BaseAddress),XXGE_TMTU_OFFSET, SetMtu);
//    XXgEthernet_WriteReg((lp->Emac.Config.BaseAddress),XXGE_RMTU_OFFSET, SetMtu);

    return 0;
}

static int xenet_set_mac_address(struct net_device *dev, void * ptr)
{

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
    struct net_local *lp = netdev_priv(dev);
#else		
    struct net_local *lp = (struct net_local *) dev->priv;	
#endif	

	struct sockaddr *addr = ptr;

	if (netif_running(dev))
    {
        log_normal(KERN_INFO "set_mac_address: Interface should be down\n");
		return -EBUSY;
    }

    if (!is_valid_ether_addr(addr->sa_data))
    {
        log_normal(KERN_INFO "set_mac_address: Invalid Ethernet address\n");
        return -EADDRNOTAVAIL;
    }

    memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);

#ifdef DEBUG_VERBOSE
    {
        int i;
        log_verbose(KERN_INFO "Setting MAC address: ");
        for(i=0; i<6; i++)
            printk("%x ", dev->dev_addr[i]);
        printk("\n");
    }
#endif

	if (_XXgEthernet_SetMacAddress(&lp->Emac, dev->dev_addr) != XST_SUCCESS) {
		printk(KERN_ERR "xgbeth_axi: could not set MAC address.\n");
		return -EIO;
	}

    return 0;
}


#ifdef DEBUG_VERBOSE
void disp_frag(unsigned char * addr, u32 len)
{
	int i;

	for(i=0; i<len; i++)
	{
		printk("%02x ", addr[i]);
		if(!((i+1)%4))
			printk(", ");
		if(!((i+1)%16))
			printk("\n");
	}
	printk("\n");
}
#endif

#ifdef DEBUG_VERBOSE
static void read_skb_info(struct sk_buff *skb)
{
    printk("Reading skb %x\n", (u32) skb);
    //printk("Transport layer header %x\n", (u32)(skb->transport_header));
    //printk("Network layer header %x\n", (u32)(skb->network_header));
    //printk("MAC layer header %x\n", (u32)(skb->mac_header));
    printk("Actual data length %d\n", (u32)(skb->len));
    printk("Data length %d\n", (u32)(skb->data_len));
    printk("Link layer header length %d\n", (u32)(skb->mac_len));
    printk("csum field %x\n", (u32)(skb->csum));
    //printk("csum_start field %x\n", (u32)(skb->csum_start));
    //printk("csum_offset field %x\n", (u32)(skb->csum_offset));
    printk("Packet type %x\n", (u32)(skb->pkt_type));
    printk("ip_summed %d\n", (u32)(skb->ip_summed));
    printk("Protocol %x\n", (u32)(skb->protocol));
    printk("Truesize %d\n", (u32)(skb->truesize));
    printk("Buffer head ptr %x\n", (u32)(skb->head));
    printk("Buffer data ptr %x\n", (u32)(skb->data));
    printk("Buffer tail ptr %x\n", (u32)(skb->tail));
    printk("Buffer end pr %x\n", (u32)(skb->end));
}
#endif

/*
 * xenet_Send_internal is an internal use, send routine.
 * Any locks that need to be acquired, should be acquired
 * prior to calling this routine.
 */
static int xenet_Send_internal(struct sk_buff *skb, struct net_device *dev)
{
	struct net_local *lp;
	int result;
	int total_frags;
	size_t len;
	skb_frag_t *frag;
    void * virt_addr;
    int i;

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
    lp = netdev_priv(dev);
#else	    	
    lp = (struct net_local *) dev->priv;	
#endif    

    if(lp->DriverState != READY) return XST_FAILURE;
    log_verbose(KERN_INFO "Came in with skb %x skb->data %x\n", (u32) skb, (u32) skb->data);
#ifdef DEBUG_VERBOSE
    read_xgemac(lp->Emac.Config.BaseAddress);
#endif

	/* get skb_shinfo(skb)->nr_frags + 1 buffer descriptors */
	total_frags = skb_shinfo(skb)->nr_frags + 1;
    log_verbose(KERN_INFO "Sending %d fragments\n", total_frags);

    /* Update stats */
    if (lp->max_frags_in_a_packet < total_frags) {
        lp->max_frags_in_a_packet = total_frags;
    }
    lp->stats.tx_packets++;

    /* First, send the first fragment */
    len = skb_headlen(skb);
    lp->stats.tx_bytes += skb->len;

    Pkt[0].pktBuf = skb->data;
    Pkt[0].bufInfo = (unsigned char *)skb;
    Pkt[0].size = len;
    Pkt[0].flags = PKT_SOP;
    Pkt[0].userInfo = skb->len;     // Required for packet FIFO 

#ifdef DEBUG_VERBOSE
    read_skb_info(skb);
#endif
    log_normal("TX pkt csum field contains %02x %02x\n", 
                (u8)(skb->data[0x32]), (u8)(skb->data[0x33]));

    
#ifdef DEBUG_VERBOSE
    log_verbose("TX frag 0 pkt len is %d, flags %x\n", Pkt[0].size, Pkt[0].flags);
    log_verbose(KERN_INFO "Fragment 0: len is %d, buf is %x\n", 
                                            len, (u32) (skb->data));
    disp_frag(skb->data, len);
#endif

    if(total_frags == 1) 
    {
        Pkt[0].flags |= PKT_EOP;
        result = DmaSendPkt(lp->TxHandle, Pkt, 1);
        if(result)
            lp->tx_pkts += 1;
        if(!result)
        {
            /* Should stop the queue and defer skb sending. */
            if(!netif_queue_stopped(dev))
                netif_stop_queue(dev);
            //lp->deferred_skb = skb;
            return XST_FAILURE;
        }
    }
    else
    {
        Pkt[0].flags |= PKT_ALL;
        frag = &skb_shinfo(skb)->frags[0];
        i = 1;                      // First iteration, skip the first fragment.
        while(total_frags)
        {
            int max;

            max = (total_frags >= MAX_SKB_FRAGS) ? MAX_SKB_FRAGS : total_frags;
            for(; i<max; i++, frag++)
            {
#if LINUX_VERSION_CODE <= KERNEL_VERSION(3, 1, 0)
                virt_addr =
                    (void *) page_address(frag->page) + frag->page_offset;
#else
                virt_addr =
                    (void *) page_address(skb_frag_page(frag)) + frag->page_offset;
#endif


		log_verbose("packet length is %d\n", skb->len);
		Pkt[i].pktBuf = virt_addr;
		Pkt[i].bufInfo = NULL;
		Pkt[i].size = frag->size;
		Pkt[i].userInfo = skb->len;     // Required for packet FIFO
		log_verbose("userInfo is %llx\n", Pkt[i].userInfo);
		Pkt[i].flags = PKT_ALL;
	    }

            if(total_frags == max)
                Pkt[i - 1].flags = PKT_EOP; 

            result = DmaSendPkt(lp->TxHandle, Pkt, i);
            if(result)
                lp->tx_pkts += result;

            if(result != i)
            {
                /* Should stop the queue and defer skb sending. */
                if(!netif_queue_stopped(dev))
                    netif_stop_queue(dev);
                //lp->deferred_skb = skb;
                return XST_FAILURE;
            }
            i = 0;              // Prepare for next iteration.
            total_frags -= max;
        }
    }

	dev->trans_start = jiffies;

	return XST_SUCCESS;
}

/* The send function for frames sent in DMA mode */
static int xenet_Send(struct sk_buff *skb, struct net_device *dev)
{
    int retval;
	/* The following spin_lock protects against contention during PutPkt() */
	spin_lock_bh(&XTE_spinlock);

	retval = xenet_Send_internal(skb, dev);

	spin_unlock_bh(&XTE_spinlock);

    if(retval == XST_SUCCESS)
        return NETDEV_TX_OK;
    else
        return NETDEV_TX_BUSY;
}

static void xenet_tx_timeout(struct net_device *dev)
{
	struct net_local *lp;
	unsigned long flags;

    log_normal(KERN_INFO "xenet_tx_timeout:\n");

	/*
	 * Make sure that no interrupts come in that could cause reentrancy
	 * problems in reset.
	 */
	spin_lock_irqsave(&XTE_spinlock, flags);

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
    lp = netdev_priv(dev);
#else		
    lp = (struct net_local *) dev->priv;	
#endif	

	
	printk(KERN_ERR
	       "%s: XXgEthernet: exceeded transmit timeout of %lu ms.  Resetting emac.\n",
	       dev->name, TX_TIMEOUT * 1000UL / HZ);
	lp->stats.tx_errors++;

	reset(dev, __LINE__);

	spin_unlock_irqrestore(&XTE_spinlock, flags);
}

static int
xenet_ethtool_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
{

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
    struct net_local *lp = netdev_priv(dev);
#else			
    struct net_local *lp = (struct net_local *) dev->priv;	
#endif	


	u32 mac_options;
        u16 gmii_cmd, gmii_status;


	memset(ecmd, 0, sizeof(struct ethtool_cmd));

	mac_options = XXgEthernet_GetOptions(&(lp->Emac));

	_XXgEthernet_PhyRead(&lp->Emac, lp->xgmii_addr, MII_BMCR, &gmii_cmd);
	_XXgEthernet_PhyRead(&lp->Emac, lp->xgmii_addr, MII_BMSR, &gmii_status);


	ecmd->duplex = DUPLEX_FULL;
	ecmd->supported |= (SUPPORTED_FIBRE);
	ecmd->port = PORT_FIBRE; 
	ecmd->speed = SPEED_10000;
	ecmd->autoneg = AUTONEG_DISABLE;
	ecmd->advertising |= ADVERTISED_FIBRE; 


	ecmd->phy_address = lp->xgmii_addr;
	ecmd->transceiver = XCVR_INTERNAL;
	return 0;
}

static int
xenet_ethtool_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
{
    return -EOPNOTSUPP;
}

#define EMAC_REGS_N 8

static void xenet_ethtool_get_ringparam(struct net_device *dev,
                                         struct ethtool_ringparam *ering)
{
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
    struct net_local *lp = netdev_priv(dev);
#else			
    struct net_local *lp = (struct net_local *) dev->priv;	
#endif	
         
        Dma_get_ringparam(lp->TxHandle,ering);
        Dma_get_ringparam(lp->RxHandle,ering);

        return ;
}

static int
xenet_ethtool_get_regs_len(struct net_device *dev)
{
    log_normal(KERN_INFO "ethtool_get_regs_len\n");
    return EMAC_REGS_N * sizeof(u16);
}

static void
xenet_ethtool_get_regs(struct net_device *dev, struct ethtool_regs *regs,
		       void *ret)
{
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
	struct net_local *lp = netdev_priv(dev);
#else	
	struct net_local *lp = (struct net_local *) dev->priv;	
#endif	

	u16 * data = (u16 *) ret;
	int i;

    log_normal(KERN_INFO "ethtool_get_regs\n");
	regs->version = 0;
	regs->len = EMAC_REGS_N * sizeof(u16);
	memset(ret, 0, EMAC_REGS_N * sizeof(u16));

	for (i = 0; i < EMAC_REGS_N; i++) {
		_XXgEthernet_PhyRead(&lp->Emac, lp->xgmii_addr, i, &(data[i]));
	}
}

    static void
xenet_ethtool_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *ed)
{
    log_normal(KERN_INFO "ethtool_get_drvinfo\n");
	memset(ed, 0, sizeof(struct ethtool_drvinfo));
	strncpy(ed->driver, DRIVER_NAME, sizeof(ed->driver) - 1);
	strncpy(ed->version, DRIVER_VERSION, sizeof(ed->version) - 1);
	/* Also tell how much memory is needed for dumping register values */
	ed->regdump_len = sizeof(u16) * EMAC_REGS_N;
}

static void
xenet_ethtool_get_pauseparam(struct net_device *dev, 
                             struct ethtool_pauseparam *epp)
{
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
    struct net_local *lp = netdev_priv(dev);
#else		
    struct net_local *lp = (struct net_local *) dev->priv;	
#endif	

	struct ethtool_cmd ecmd;
	int ret = -EOPNOTSUPP;
	u32 Options;

    log_normal(KERN_INFO "ethtool_get_pauseparam\n");

    ret = xenet_ethtool_get_settings(dev, &ecmd);
    if (ret < 0)
        return;

    epp->autoneg = ecmd.autoneg;
    Options = XXgEthernet_GetOptions(&lp->Emac);
    if (Options & XXGE_FCS_INSERT_OPTION) {
        epp->rx_pause = 1;
        epp->tx_pause = 1;
    }
    else {
        epp->rx_pause = 0;
        epp->tx_pause = 0;
    }
}


#if LINUX_VERSION_CODE <= KERNEL_VERSION(3, 1, 0)
static u32 xenet_ethtool_get_sg(struct net_device *dev)
{
    log_normal(KERN_INFO "ethtool_get_sg\n");

/* Always support scatter-gather */
    return 1;
}
#endif


#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 33)
static int xenet_ethtool_get_sset_count(struct net_device *dev, int sset)
{    
	log_normal(KERN_INFO "ethtool_get_sset_count %d\n", XENET_STATS_LEN);    

	switch (sset) {    
		case ETH_SS_STATS:        
			return XENET_STATS_LEN;    

		default:        
			return -EOPNOTSUPP;    
			}
}
#else
static int xenet_ethtool_get_stats_count(struct net_device *dev)
{
    log_normal(KERN_INFO "ethtool_get_stats_count %d\n", XENET_STATS_LEN);
    return XENET_STATS_LEN;
}
#endif

static void xenet_ethtool_get_strings(struct net_device *dev, u32 sset, u8 * data)
{
    log_normal(KERN_INFO "ethtool_get_strings\n");

    switch (sset) {
    case ETH_SS_STATS:
        log_normal(KERN_INFO "ethtool_get_strings: ETH_SS_STATS\n");
        memcpy(data, *xenet_ethtool_gstrings_stats, sizeof(xenet_ethtool_gstrings_stats));
        break;
    }
}

static void xenet_ethtool_get_stats(struct net_device *dev, struct ethtool_stats *est, u64 *data)
{
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
	struct net_local *lp = netdev_priv(dev);
#else			
	struct net_local *lp = (struct net_local *) dev->priv;	
#endif	

		
    log_normal(KERN_ERR "ethtool_get_stats\n");


    est->n_stats = ARRAY_SIZE(xenet_ethtool_gstrings_stats);

    lp->stats.tx_fifo_errors = XXgEthernet_ReadReg(lp->Emac.Config.BaseAddress,XXGE_TXUNDRERL_OFFSET);
    lp->stats.rx_length_errors = XXgEthernet_ReadReg(lp->Emac.Config.BaseAddress,XXGE_RXLTERL_OFFSET);
    lp->stats.rx_crc_errors = XXgEthernet_ReadReg(lp->Emac.Config.BaseAddress,XXGE_RXFCSERL_OFFSET);

    data[0] = lp->stats.tx_packets;
    data[1] = lp->stats.tx_bytes;
    data[2] = lp->stats.tx_fifo_errors;
    data[3] = lp->stats.rx_packets;
    data[4] = lp->stats.rx_bytes;
    data[5] = lp->stats.rx_length_errors;
    data[6] = lp->stats.rx_crc_errors;
    data[7] = lp->max_frags_in_a_packet;
}

static int xenet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
{
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
    struct net_local *lp = netdev_priv(dev);
#else			
    struct net_local *lp = (struct net_local *) dev->priv;	
#endif	


	/* gmii_ioctl_data has 4 u16 fields: phy_id, reg_num, val_in & val_out */
	struct mii_ioctl_data *data = (struct mii_ioctl_data *) &rq->ifr_data;

    log_normal(KERN_INFO "In xenet_ioctl:\n");

	switch (cmd) {

	case SIOCGMIIPHY:	/* Get address of GMII PHY in use. */
        log_normal(KERN_INFO "xenet_ioctl: SIOCGMIIPHY\n");
	case SIOCDEVPRIVATE:	/* for binary compat, remove in 2.5 */
        if(cmd == SIOCDEVPRIVATE) 
            log_normal(KERN_INFO "xenet_ioctl: SIOCDEVPRIVATE\n");

		data->phy_id = lp->xgmii_addr;
		/* Fall Through */

	case SIOCGMIIREG:	/* Read GMII PHY register. */
        if(cmd == SIOCGMIIREG) 
            log_normal(KERN_INFO "xenet_ioctl: SIOCGMIIREG\n");
	case SIOCDEVPRIVATE + 1:	/* for binary compat, remove in 2.5 */
        if(cmd == (SIOCDEVPRIVATE+1)) 
            log_normal(KERN_INFO "xenet_ioctl: SIOCDEVPRIVATE+1\n");
		if (data->phy_id > 31 || data->reg_num > 31)
			return -ENXIO;

		/* Stop the PHY timer to prevent reentrancy. */
		del_timer_sync(&lp->phy_timer);

		_XXgEthernet_PhyRead(&lp->Emac, data->phy_id, data->reg_num,
			       &data->val_out);

		/* Start the PHY timer up again. */
		lp->phy_timer.expires = jiffies + 2 * HZ;
		add_timer(&lp->phy_timer);
		return 0;

	case SIOCSMIIREG:	/* Write GMII PHY register. */
        log_normal(KERN_INFO "xenet_ioctl: SIOCSMIIREG\n");
	case SIOCDEVPRIVATE + 2:	/* for binary compat, remove in 2.5 */
        if(cmd == (SIOCDEVPRIVATE+2)) 
            log_normal(KERN_INFO "xenet_ioctl: SIOCDEVPRIVATE+2\n");

		if (!capable(CAP_NET_ADMIN))
			return -EPERM;

		if (data->phy_id > 31 || data->reg_num > 31)
			return -ENXIO;

		/* Stop the PHY timer to prevent reentrancy. */
		del_timer_sync(&lp->phy_timer);

		_XXgEthernet_PhyWrite(&lp->Emac, data->phy_id, data->reg_num,
				data->val_in);

		/* Start the PHY timer up again. */
		lp->phy_timer.expires = jiffies + 2 * HZ;
		add_timer(&lp->phy_timer);
		return 0;
	default:
        log_normal(KERN_INFO "xenet_ioctl: unsupported value %d\n", cmd);
		return -EOPNOTSUPP;
	}
}



static int xtenet_init_top(void)
{
    struct net_local *lp = NULL;
    UserPtrs ufuncs;
    int rc;
    void * handle;

    log_verbose(KERN_ERR "Came to xtenet_init_top\n");

    /* Create an ethernet device instance */
    ndev = alloc_etherdev(sizeof(struct net_local));
    if (!ndev) {
        printk(KERN_ERR "xgbeth_axi: Could not allocate net device.\n");
        rc = -ENOMEM;
        return rc;
    }

    /* Initialize the private data used by XEmac_LookupConfig().
     * The private data are zeroed out by alloc_etherdev() already.
     */
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
    lp = netdev_priv(ndev);
#else			
    lp = (struct net_local *) ndev->priv;	
#endif	
    lp->ndev = ndev;
    lp->deferred_skb = NULL;

    log_verbose("Going to do DmaRegister\n");

    /* Set it before DmaRegister because bottom half of init may get called
     * within the register function.
     */
    lp->DriverState = INITIALIZED_TOP;

    ufuncs.UserInit = xtenet_init_bottom;
    ufuncs.UserPutPkt = myTxPutPkt;
    ufuncs.UserSetState = mySetState;
    ufuncs.UserGetState = myGetState;
#ifdef PM_SUPPORT
    ufuncs.UserSuspend_Early = mySetSuspend_Early;  // suspend from XDMA driver
    ufuncs.UserSuspend_Late = mySetSuspend_Late;    // suspend from XDMA driver
    ufuncs.UserResume = mySetResume;    // resume  from XDMA driver
#endif
#ifdef X86_64
	ufuncs.privData = ndev;
#else
    ufuncs.privData = (u32) ndev;
#endif	
    ufuncs.mode = ETHERNET_APPMODE;
    handle = DmaRegister(TX_ENGINE, TEMAC_BAR, &ufuncs, TEMAC_PKTSIZE);
    if(handle == NULL) {
        printk(KERN_ERR "Unable to register engine %d\n", TX_ENGINE);
        free_netdev(ndev);
        ndev = NULL;
        return -ENOMEM;
    }
    lp->TxHandle = handle;

    /* Note the user-specific version register address. This is valid only
     * for the transmit engine. Use this later to read version information.
     */
    lp->versionReg = ufuncs.versionReg;

    ufuncs.UserPutPkt = myRxPutPkt;
    ufuncs.UserGetPkt = myRxGetPkt;
    ufuncs.UserSetState = mySetState;
    ufuncs.UserGetState = myGetState;
#ifdef PM_SUPPORT
    ufuncs.UserSuspend_Early = mySetSuspend_Early;  // suspend from XDMA driver
    ufuncs.UserSuspend_Late = mySetSuspend_Late;    // suspend from XDMA driver
    ufuncs.UserResume = mySetResume;    // resume  from XDMA driver
#endif
#ifdef X86_64
	ufuncs.privData = ndev;
#else
    ufuncs.privData = (u32) ndev;
#endif	
    ufuncs.mode = ETHERNET_APPMODE;
    handle = DmaRegister(RX_ENGINE, TEMAC_BAR, &ufuncs, TEMAC_PKTSIZE);
    if(handle == NULL) {
        printk(KERN_ERR "Unable to register engine %d\n", RX_ENGINE);
        free_netdev(ndev);
        ndev = NULL;
        return -ENOMEM;
    }
    lp->RxHandle = handle;

    return 0;
}

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 29)
static void xenet_set_netdev_ops(struct net_device *ndev, struct net_device_ops *ndops)
{
    ndops->ndo_open = xenet_open;
    ndops->ndo_stop = xenet_close;
    ndops->ndo_start_xmit = xenet_Send;
    ndops->ndo_set_mac_address = xenet_set_mac_address;
    ndops->ndo_do_ioctl = xenet_ioctl;
    ndops->ndo_change_mtu = xenet_change_mtu;
    ndops->ndo_tx_timeout = xenet_tx_timeout;
    ndops->ndo_get_stats = xenet_get_stats;
    ndev->netdev_ops = ndops;
}
#endif

/* ethtool callback functions */
static struct ethtool_ops xenet_ethtool_ops = {
    .get_settings       = xenet_ethtool_get_settings,
    .set_settings       = xenet_ethtool_set_settings,
    .get_pauseparam     = xenet_ethtool_get_pauseparam,
#if LINUX_VERSION_CODE <= KERNEL_VERSION(3, 1, 0)
    .get_sg             = xenet_ethtool_get_sg,
#endif
    .get_drvinfo        = xenet_ethtool_get_drvinfo,
    .get_regs_len       = xenet_ethtool_get_regs_len,
    .get_regs           = xenet_ethtool_get_regs,
    .get_ringparam      = xenet_ethtool_get_ringparam,
    .get_link           = ethtool_op_get_link,
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 33)
    .get_sset_count     = xenet_ethtool_get_sset_count,
#else
    .get_stats_count    = xenet_ethtool_get_stats_count,
#endif    
    .get_strings        = xenet_ethtool_get_strings,
    .get_ethtool_stats  = xenet_ethtool_get_stats
};

#ifdef DEBUG_VERBOSE
static void read_allreg(u32 RegBase)
{
    /* Read all MAC registers */

    printk("Reading all MAC registers\n");
    printk("Reg %x = %x\n", (RegBase+XXGE_RCW0_OFFSET), XXgEthernet_ReadReg(RegBase,XXGE_RCW0_OFFSET));
    printk("Reg %x = %x\n", (RegBase+XXGE_RCW1_OFFSET), XXgEthernet_ReadReg(RegBase,XXGE_RCW1_OFFSET ));
    printk("Reg %x = %x\n", (RegBase+XXGE_TC_OFFSET), XXgEthernet_ReadReg(RegBase,XXGE_TC_OFFSET ));
    printk("Reg %x = %x\n", (RegBase+XXGE_FCC_OFFSET), XXgEthernet_ReadReg(RegBase,XXGE_FCC_OFFSET ));
    printk("Reg %x = %x\n", (RegBase+XXGE_GERS_OFFSET), XXgEthernet_ReadReg(RegBase,XXGE_GERS_OFFSET ));
    printk("Reg %x = %x\n", (RegBase+XXGE_RMTU_OFFSET), XXgEthernet_ReadReg(RegBase,XXGE_RMTU_OFFSET ));
    printk("Reg %x = %x\n", (RegBase+XXGE_TMTU_OFFSET), XXgEthernet_ReadReg(RegBase,XXGE_TMTU_OFFSET ));
    printk("Reg %x = %x\n", (RegBase+XXGE_VER_OFFSET), XXgEthernet_ReadReg(RegBase,XXGE_VER_OFFSET ));
    printk("Reg %x = %x\n", (RegBase+XXGE_CAP_OFFSET), XXgEthernet_ReadReg(RegBase,XXGE_CAP_OFFSET ));

    /* Read all MDIO registers */
    printk("Reg %x = %x\n", (RegBase+XXGE_MDIO_CFG0_OFFSET), XXgEthernet_ReadReg(RegBase, XXGE_MDIO_CFG0_OFFSET));
    printk("Reg %x = %x\n", (RegBase+XXGE_MDIO_CFG1_OFFSET), XXgEthernet_ReadReg(RegBase,XXGE_MDIO_CFG1_OFFSET ));
    printk("Reg %x = %x\n", (RegBase+XXGE_MDIO_TX_DATA_OFFSET), XXgEthernet_ReadReg(RegBase,XXGE_MDIO_TX_DATA_OFFSET ));
    printk("Reg %x = %x\n", (RegBase+XXGE_MDIO_RX_DATA_OFFSET), XXgEthernet_ReadReg(RegBase,XXGE_MDIO_RX_DATA_OFFSET ));
    /* Read all PHY registers */
}
#endif
#ifdef X86_64
static int xtenet_init_bottom(u64 BarBase, u64 privdata)
{
#else
static int xtenet_init_bottom(unsigned int BarBase, unsigned int privdata)
{
#endif
    u8 mac_addr[6];
    struct net_device *ndev = NULL;
    struct net_local *lp = NULL;
    XXgEthernet_Config Temac_Config;
    int rc = 0;
#ifdef X86_64
	u64 RegBase;
#else
    unsigned int RegBase;
#endif
    // XGEMAC + 10GPHY offset from BAR0
    RegBase = BarBase + NW_PATH_OFFSET;
	
    //Disable GEN/CHK performance mode
    XIo_Out32 (BarBase + DESIGN_MODE_ADDRESS, PERF_DESIGN_MODE); 

    /* Get instance context information */
    ndev = (struct net_device *)privdata;
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
    lp = netdev_priv(ndev);
#else      	
    lp = (struct net_local *) ndev->priv;
#endif    



    /* The device initialization given below should be done only after
     * both RX and TX engines have been registered. Therefore, check
     * for the double callback before continuing.
     */
    if(lp->DriverState == INITIALIZED_TOP) {
        lp->DriverState = INITIALIZED_FIRST;
        return XST_SUCCESS;
    } 
    else if(lp->DriverState == INITIALIZED_FIRST) {
        lp->DriverState = INITIALIZED_SECOND;
    }
    else {
        printk("DriverState unrecognized %d\n", lp->DriverState);
        return XST_FAILURE;
    }

    /* Check whether working with a compatible version of hardware */

    log_normal(KERN_INFO "TEMAC Base %x\n", RegBase);

    /* Initialize the private data used by XEmac_LookupConfig().
     * The private data are zeroed out by alloc_etherdev() already.
     */

    /* Setup the Config structure for the XXgEthernet_CfgInitialize() call. */
    Temac_Config.BaseAddress = RegBase;


    log_verbose("Going to do CfgInitialize\n");
#ifdef X86_64
	if (XXgEthernet_CfgInitialize(&lp->Emac, &Temac_Config, RegBase) != XST_SUCCESS) 
    {
#else
    if (XXgEthernet_CfgInitialize(&lp->Emac, &Temac_Config, (u32) RegBase) != XST_SUCCESS) 
    {
#endif	
        printk(KERN_ERR "xgbeth_axi: Could not initialize device.\n");
        rc = -ENODEV;
        goto error;
    }

    /* Default MAC address assignment */
     mac_addr[0]=0xAA;
#ifdef USE_NW_PATH0
     mac_addr[1]=0xBB;
#else
	 mac_addr[1]=0x00;
#endif
     mac_addr[2]=0xCC;
     mac_addr[3]=0xDD;
     mac_addr[4]=0xEE;
     mac_addr[5]=0xFF;

    if (_XXgEthernet_SetMacAddress(&lp->Emac, mac_addr) != XST_SUCCESS) {
        printk(KERN_ERR "Could not set MAC address.\n");
        rc = -EIO;
        goto error;
    }

#ifdef DEBUG_NORMAL
    printk("**Set the MAC adress in init_bottom**\n");
#endif

    _XXgEthernet_GetMacAddress(&lp->Emac,ndev->dev_addr);

log_verbose("addr_len is %d, perm_addr[0] is %x, [1] = %x, [2] = %x, [3] = %x, perm_addr[4] is %x, [5] = %x\n", 
	ndev->addr_len, ndev->dev_addr[0], ndev->dev_addr[1], ndev->dev_addr[2],
		ndev->dev_addr[3], ndev->dev_addr[4], ndev->dev_addr[5]);
    

#ifdef ENABLE_JUMBO    
    lp->max_frame_size = XXGE_MAX_JUMBO_FRAME_SIZE;
#else
    lp->max_frame_size = 1600;
#endif
    log_verbose(KERN_INFO "MTU size is %d\n", ndev->mtu);
    if (ndev->mtu > XXGE_JUMBO_MTU)
	ndev->mtu = XXGE_JUMBO_MTU;
    log_verbose(KERN_INFO "MTU size is %d\n", ndev->mtu);


    /** Scan to find the PHY */
    lp->xgmii_addr = XXGE_PHY_ADDRESS;
    log_verbose("xgmii_addr is %x\n", lp->xgmii_addr);

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 29)
    xenet_set_netdev_ops(ndev, &xenet_netdev_ops);
#else
    /* initialize the netdev structure */
    ndev->open = xenet_open;
    ndev->stop = xenet_close;
    ndev->hard_start_xmit = xenet_Send;
    ndev->set_mac_address = xenet_set_mac_address;
    ndev->do_ioctl = xenet_ioctl;
    ndev->change_mtu = xenet_change_mtu;
    ndev->tx_timeout = xenet_tx_timeout;
    ndev->get_stats = xenet_get_stats;
#endif

    ndev->flags &= ~IFF_MULTICAST;
    ndev->features = NETIF_F_SG | NETIF_F_FRAGLIST;

    ndev->watchdog_timeo = TX_TIMEOUT;
    SET_ETHTOOL_OPS(ndev, &xenet_ethtool_ops);

    /* init the stats */
    lp->max_frags_in_a_packet = 0;
    lp->rx_pkts = 0;

#if ! XXGE_AUTOSTRIPPING
    lp->stripping =
        (XXgEthernet_GetOptions(&(lp->Emac)) & XXGE_FCS_STRIP_OPTION) != 0;
#endif

    log_verbose(KERN_ERR "Registering net device\n");
    
    rc = register_netdev(ndev);
    if (rc) {
        printk(KERN_ERR
               "%s: Cannot register net device, aborting.\n", ndev->name);
        goto error; /* rc is already set here... */
    }

    lp->DriverState = READY;

    return 0;
error:
    if (ndev) {
        free_netdev(ndev);
    }
#ifdef XGEMAC_DEBUG__
    printk("**Completed the xtenet_init_bottom functionality**\n");
#endif

    return rc;
}
#ifdef X86_64
int myRxGetPkt(void * handle, PktBuf * vaddr, unsigned int size, int numpkts, u64 privdata)
{
#else
int myRxGetPkt(void * handle, PktBuf * vaddr, unsigned int size, int numpkts, unsigned int privdata)
{
#endif
    struct net_device *ndev = NULL;
    struct net_local *lp = NULL;
	struct sk_buff *new_skb;
    PktBuf * pbuf;
    int i;
    u32 align;

#if defined DEBUG_NORMAL || defined DEBUG_VERBOSE
    static int recv_count=1;
    log_normal(KERN_INFO "myRxGetPkt: %d\n",recv_count);
    recv_count += numpkts;
#endif

    /* Get instance context information */
    ndev = (struct net_device *)privdata;

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
    lp = netdev_priv(ndev);
#else    	
    lp = (struct net_local *) ndev->priv;
#endif    


    /* Check if driver is ready */
    if(lp->DriverState != READY) {
        printk("xenet driver is not ready\n");
        return 0;
    }

    /* Get free buffers from upper layers */
    for(i=0; i<numpkts; i++)
    {
        pbuf = &(vaddr[i]);
        new_skb = alloc_skb(lp->max_frame_size, GFP_ATOMIC);
        if (new_skb == NULL) {
            log_normal("Alloc SKB failed for %d\n",i);    
            break;
        }
        /* Make sure we are long-word aligned */
        align = BUFFER_ALIGNRECV(new_skb->data);
        if (align)
        {
            skb_reserve(new_skb, align);
        }

        pbuf->pktBuf = new_skb->data;
        pbuf->bufInfo = (unsigned char *)new_skb;
        pbuf->size = lp->max_frame_size;

        /* Update stats of currently allocated skbs */
        lp->rx_pkts += 1;
    }

    return i;
}
#ifdef X86_64
int myRxPutPkt(void * handle, PktBuf * vaddr, int numpkts, u64  privdata)
{
#else
int myRxPutPkt(void * handle, PktBuf * vaddr, int numpkts, unsigned int privdata)
{
#endif
    struct net_device *ndev = NULL;
    struct net_local *lp = NULL;
	struct sk_buff *skb;
    PktBuf * pbuf;
    int len, i;


        /* Get instance context information */
    ndev = (struct net_device *)privdata;
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
    lp = netdev_priv(ndev);
#else    	
    lp = (struct net_local *) ndev->priv;
#endif    

    if((lp->DriverState != READY) && (lp->DriverState != UNREGISTERING))
    {
#ifdef PM_SUPPORT
	if( lp->DriverState != PM_SUSPEND)
#endif
        {
        printk("xenet driver is not ready\n");
        return -1;
        }
    }

    for(i=0; i<numpkts; i++)
    {
        pbuf = &(vaddr[i]);
        /* get ptr to skb */
        skb = (struct sk_buff *) pbuf->bufInfo;

	/* Incase this is unused, then return it upstream as such. */
	if(pbuf->flags & PKT_UNUSED)
	{
	    log_verbose("myRxPutPkt: skb %p returned unused\n", skb);
	    if(skb)
		dev_kfree_skb(skb);
	    continue;
	}
	len = pbuf->size;

#ifdef DEBUG_VERBOSE
        printk(KERN_INFO "Recv data: len %d data %x\n", 
                        len, (unsigned int)(skb->data));
        {
            unsigned char * dptr;
            int i;
            dptr = skb->data;
            if(i<6) 
                disp_frag(skb->data, len);
        }
#endif

        /* setup received skb and send it upstream */
        skb_put(skb, len);	/* Tell the skb how much data we got. */
        skb->dev = ndev;

        /* this routine adjusts skb->data to skip the header */
        skb->protocol = eth_type_trans(skb, ndev);

#ifdef DEBUG_VERBOSE
        read_skb_info(skb);
#endif

            /* default the ip_summed value */
            skb->ip_summed = CHECKSUM_NONE;

        lp->stats.rx_packets++;
        lp->stats.rx_bytes += len;
        if(lp->rx_pkts)
            lp->rx_pkts -= 1;
        netif_rx(skb);	/* Send the packet upstream. */
    }

    return 0;
}
#ifdef X86_64
int myTxPutPkt(void * handle, PktBuf * vaddr, int numpkts, u64 privdata)
{
#else
int myTxPutPkt(void * handle, PktBuf * vaddr, int numpkts, unsigned int privdata)
{
#endif
    struct net_device *ndev = NULL;
    struct net_local *lp = NULL;
	struct sk_buff *skb;
    PktBuf * pbuf;
    int i;

   /* Get instance context information */
    ndev = (struct net_device *)privdata;

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
    lp = netdev_priv(ndev);
#else    	
    lp = (struct net_local *) ndev->priv;
#endif    


    if((lp->DriverState != READY) && (lp->DriverState != UNREGISTERING))
    {
#ifdef PM_SUPPORT
	if( lp->DriverState != PM_SUSPEND)
#endif
        {
        printk("xenet driver is not ready\n");
        return -1;
        }
    }

	//spin_lock_bh(&XTE_tx_spinlock);
    for(i=0; i<numpkts; i++)
    {
        pbuf = &(vaddr[i]);

        /* get ptr to skb */
        skb = (struct sk_buff *) pbuf->bufInfo;

	if (skb)
	    dev_kfree_skb(skb);

        if(lp->tx_pkts)
            lp->tx_pkts -= 1;
    }
	//spin_unlock_bh(&XTE_tx_spinlock);

#ifdef USE_LATER /* Commented out for now - has not been tested */
    if(lp->deferred_skb)
    {
        int retval;
        spin_lock_bh(&XTE_spinlock);
        skb = lp->deferred_skb;
        lp->deferred_skb = NULL;
        retval = xenet_DSI(skb, ndev);
        printk("Calling DSI for deferred skb %p returns %d\n", skb, retval);
        spin_unlock_bh(&XTE_spinlock);
    }
#endif

#ifdef PM_SUPPORT
    if( lp->DriverState != PM_SUSPEND ) 
#endif
{       
    if(netif_queue_stopped(ndev))
        netif_wake_queue(ndev);    
}


    return 0; 
}
#ifdef X86_64
int mySetState(void * handle, UserState * ustate, u64 privdata)
{
#else
int mySetState(void * handle, UserState * ustate, unsigned int privdata)
{
#endif
    return 0;
}


#ifdef X86_64
int myGetState(void * handle, UserState * ustate, u64 privdata)
{
#else
int myGetState(void * handle, UserState * ustate, unsigned int privdata)
{
#endif   
    struct net_device *ndev = NULL;
    struct net_local *lp = NULL;

    log_verbose("Reached myGetState with privdata %x\n", privdata);

  /* Get instance context information */
    ndev = (struct net_device *)privdata;
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
    lp = netdev_priv(ndev);
#else    	
    lp = (struct net_local *) ndev->priv;
#endif    



    if(lp->DriverState != READY) 
    {
        printk("xenet driver is not ready\n");
        return -1;
    }
    
    /* Same state is being returned for both engines */

    //spin_lock(&RawLock);

    ustate->LinkState = (netif_carrier_ok(ndev) ? LINK_UP : LINK_DOWN);
    ustate->DataMismatch = 0;
    ustate->MinPktSize = 64;
    ustate->MaxPktSize = lp->max_frame_size;
    ustate->TestMode = 0;
    if(handle == lp->TxHandle)
        ustate->Buffers = lp->tx_pkts;
    else
        ustate->Buffers = lp->rx_pkts;

    //spin_unlock(&RawLock);
    return 0;
}

#ifdef PM_SUPPORT
//////////////////////////////////
// Suspend_Early : 
//    a. stop TX on netif
//    b. stop RX on PHY/MAC
// 
#ifdef X86_64
int mySetSuspend_Early(void * handle, UserState * ustate, u64 privdata)
{
#else
int mySetSuspend_Early(void * handle, UserState * ustate, unsigned int privdata)
{
#endif
    struct net_device *ndev = NULL;
    struct net_local *lp = NULL;

    log_verbose(KERN_ERR "begin: xgbeth mySetSuspend_Early\n");
    //// 1. Get instance context information
    ndev = (struct net_device *)privdata;
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
    lp = netdev_priv(ndev);
#else
    lp = (struct net_local *) ndev->priv;
#endif

    if(lp->DriverState != PM_SUSPEND){   // called for multiple Dma Engines.
        lp->DriverState_beforeSusp = lp->DriverState;
        lp->DriverState = PM_SUSPEND;
    }

    log_verbose(KERN_ERR "...SuspendEarly: privdata=0x%x, ndev=0x%x, lp=0x%x, Emac=0x%x, baseaddr=0x%x, xgmii_addr=%d\n",
	    (unsigned int)privdata,
	    (unsigned int)ndev,
	    (unsigned int)lp,
	    (unsigned int)&lp->Emac,
	    (unsigned int)&lp->Emac.Config.BaseAddress,
	    (unsigned int)lp->xgmii_addr );

    // 2. Stop TX queue on upper layer side
    if( !(netif_queue_stopped(ndev)) ) {
	log_verbose(KERN_ERR ".... stopping netif tx\n");
	netif_stop_queue(ndev);
    }

    // 3. Stop RX on PHY side
    // ==>> Disable MAC
    log_verbose(KERN_ERR ".... disabling rx on hw\n");
    _XXgEthernet_Stop(&lp->Emac);
    msleep(3);
    log_verbose(KERN_ERR "PM.... end: xgbeth mySetSuspend_Early.\n");
    return 0;
}

//////////////////////////////////
// Suspend_Late:
//    a. stop TX on PHY/MAC
//    b. set PHY in Power Down mode
//    c. stop RX on netif
//    d. detach the driver with upper layers (tcpip stack)
//
#ifdef X86_64
int mySetSuspend_Late(void * handle, UserState * ustate, u64 privdata)
{
#else
int mySetSuspend_Late(void * handle, UserState * ustate, unsigned int privdata)
{
#endif
    struct net_device *ndev = NULL;
    struct net_local *lp = NULL;

    log_verbose(KERN_ERR "begin: xgbeth mySetSuspend_Late\n");
    /* Get instance context information */
    ndev = (struct net_device *)privdata;
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
    lp = netdev_priv(ndev);
#else
    lp = (struct net_local *) ndev->priv;
#endif

    // 1. set PHY in Power Down mode
    // 2. Stop Queues in network interface
    if( !(netif_queue_stopped(ndev)) ) {
	netif_stop_queue(ndev);
	log_verbose(KERN_ERR "PM.... xgbeth: netif queue is stopped.\n");
    }
    msleep(3);

    // 3. detach the network interface
    netif_device_detach(ndev);
    log_verbose(KERN_ERR "PM.... xgbeth: netif device detached.\n");
    msleep(3);
    log_verbose(KERN_ERR "PM.... end: xgbeth mySetSuspend_Late.\n");
    return 0;
}
#ifdef X86_64
int mySetResume(void * handle, UserState * ustate, u64 privdata)
{
#else
int mySetResume(void * handle, UserState * ustate, unsigned int privdata)
{
#endif
    struct net_device *ndev = NULL;
    struct net_local *lp = NULL;

    log_verbose(KERN_ERR "begin: xgbeth mySetResume\n");
    /* Get instance context information */
    ndev = (struct net_device *)privdata;
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
    lp = netdev_priv(ndev);
#else
    lp = (struct net_local *) ndev->priv;
#endif

    log_verbose(KERN_ERR "...resume: privdata=0x%x, ndev=0x%x, lp=0x%x, Emac=0x%x, baseaddr=0x%x, xgmii_addr=%d\n",
	    (unsigned int)privdata,
	    (unsigned int)ndev,
	    (unsigned int)lp,
	    (unsigned int)&lp->Emac,
	    (unsigned int)&lp->Emac.Config.BaseAddress,
	    (unsigned int)lp->xgmii_addr );


    if( lp->DriverState == PM_SUSPEND ) {
    
	/*
	 * The following four functions will return an error if the
	 * EMAC is already started.	 */
	(int) _XXgEthernet_SetMacAddress(&lp->Emac, ndev->dev_addr);
	(int) _XXgEthernet_SetOptions(&lp->Emac, (lp->Emac).Options);

        msleep(3);
        _XXgEthernet_Start(&lp->Emac);

	netif_wake_queue(ndev);
	log_verbose("PM.... xgbeth: netif queue is started.\n");
	msleep(3);

	netif_device_attach(ndev);
	log_verbose("PM.... xgbeth: netif device attached.\n");
	msleep(3);

    }
    else 
	log_verbose("PM.... xxgbeth ethernet PHY, MAC already up\n");
    msleep(3);

    lp->DriverState = lp->DriverState_beforeSusp;
    log_verbose(".... driver state restored to %d\n", lp->DriverState);
    log_verbose("PM.... end: xgbeth mySetResume.\n");
    return 0;
}
#endif


static int /*__init*/ xtenet_init(void)
{
    int ret;
	/*
	 * Make sure the locks are initialized
	 */
	spin_lock_init(&XTE_spinlock);


	/*
	 * No kernel boot options used,
	 * so we just need to register the driver
	 */
	printk(KERN_INFO "Inserting Xilinx GigE driver in kernel.\n");

    if((ret=xtenet_init_top())!=0){
	log_verbose("error in xtenet_init_top\n");
	return -1;
    }
return 0;
}


static void /*__exit*/ xtenet_cleanup(void)
{
    struct net_local *lp = NULL;
    int state;

    printk(KERN_INFO "Unregistering Xilinx GigE driver from kernel.\n");
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
    lp = netdev_priv(ndev);
#else    	
    lp = (struct net_local *) ndev->priv;
#endif    

    /* Save state for checking later the state of the driver */
    state = lp->DriverState;
    lp->DriverState = UNREGISTERING;
    DmaUnregister(lp->TxHandle);
    DmaUnregister(lp->RxHandle);
    mdelay(2000);

    /* Driver could have failed at different points of the initialization
     * process. Check for the state conditions first before freeing up
     * resources, to avoid kernel oops.
     */
    if(state == READY)
        unregister_netdev(ndev);
    if(ndev != NULL)
        free_netdev(ndev);
}

module_init(xtenet_init);
module_exit(xtenet_cleanup);

MODULE_AUTHOR("Xilinx, Inc.");
MODULE_DESCRIPTION(DRIVER_DESCRIPTION);
MODULE_LICENSE("GPL");
MODULE_VERSION(DRIVER_VERSION);

