
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
 * @file sguser.c
 *
 * This is the Application driver which registers with XDMA driver with private interface.
 * This Application driver creates an charracter driver interface with user Application.
 *
 * Author: Xilinx, Inc.
 *
 * 2011-2011 (c) Xilinx, Inc. This file is licensed uner the terms of the GNU
 * General Public License version 2.1. This program is licensed "as is" without
 * any warranty of any kind, whether express or implied.
 *
 * MODIFICATION HISTORY:
 *
 * Ver   Date     Changes
 * ----- -------- -------------------------------------------------------
 * 1.0   05/15/12 First release 
 *
 *****************************************************************************/

#include <linux/version.h>
#include <linux/module.h>
#include <linux/delay.h>
#include <linux/spinlock.h>
#include <linux/fs.h>
#include <linux/kdev_t.h>
#include <linux/cdev.h>
#include <linux/mm.h>		
#include <linux/spinlock.h>	
#include <linux/pagemap.h>	
#include <linux/slab.h>
#include <asm/uaccess.h>

#include <xpmon_be.h>
#include <xdma_user.h>
#include "xdebug.h"
#include "xio.h"

/* Driver states */
#define UNINITIALIZED   0	/* Not yet come up */
#define INITIALIZED     1	/* But not yet set up for polling */
#define UNREGISTERED    2       /* Unregistering with DMA */
#define POLLING         3	/* But not yet registered with DMA */
#define REGISTERED      4	/* Registered with DMA */
#define CLOSED          5	/* Driver is being brought down */

/* DMA characteristics */
#define MYBAR           0

#ifdef XRAWDATA0
#define MYHANDLE  HANDLE_0
#else
#define MYHANDLE  HANDLE_1
#endif

#ifdef XRAWDATA0
#define MYNAME   "Raw Data 0"
#define DEV_NAME  "xraw_data0"
#else
#define MYNAME   "Raw Data 1"
#define DEV_NAME  "xraw_data1"
#endif

#define DESIGN_MODE_ADDRESS 0x9004		/* Used to configure HW for different modes */        
#ifdef RAW_ETH
#define PERF_DESIGN_MODE   0x00000000
#else
#define PERF_DESIGN_MODE   0x00000003
#endif

#ifdef RAW_ETH
#define WRBURST_0       0x9308
#define WRBURST_1       0x9318
#define WRBURST_2       0x9328
#define WRBURST_3       0x9338

#define RDBURST_0       0x930C
#define RDBURST_1       0x931C
#define RDBURST_2       0x932C
#define RDBURST_3       0x933C

#define BURST_SIZE      256 

#define MDIO_ConfigWord_0        0x500  /* MDIO Config Word 0 */
#define MDIO_ConfigWord_1        0x504  /* MDIO Config Word 1 */ 
#define MDIO_TX_DATA             0x508  /* MDIO TX Data */
#define MDIO_RX_DATA             0x50C  /* MDIO RX Data */
#define YES                      1

#define MDIO_READY(X) ((XIo_In32(X + MDIO_ConfigWord_1 ) >> 7 ) & 0x00000001)
#define MDIO_LINK_STATUS_UP(X) ((XIo_In32(X + MDIO_RX_DATA ) >> 12) & 0x00000001)

#define XXGE_RCW0_OFFSET        0x00000400 /**< Rx Configuration Word 0 */
#define XXGE_RCW1_OFFSET        0x00000404 /**< Rx Configuration Word 1 */
#define XXGE_TC_OFFSET          0x00000408 /**< Tx Configuration */

#endif


#ifdef XRAWDATA0

#define TX_CONFIG_ADDRESS       0x9108
#define RX_CONFIG_ADDRESS       0x9100
#define PKT_SIZE_ADDRESS        0x9104
#define STATUS_ADDRESS          0x910C
#ifndef RAW_ETH
#define SEQNO_WRAP_REG          0x9110
#endif
/* Test start / stop conditions */
#define LOOPBACK            0x00000002	/* Enable TX data loopback onto RX */

#else

#define TX_CONFIG_ADDRESS   0x9208	/* Reg for controlling TX data */
#define RX_CONFIG_ADDRESS   0x9200	/* Reg for controlling RX pkt generator */
#define PKT_SIZE_ADDRESS    0x9204	/* Reg for programming packet size */
#define STATUS_ADDRESS      0x920C	/* Reg for checking TX pkt checker status */
#ifndef RAW_ETH
#define SEQNO_WRAP_REG      0x9210  /* Reg for sequence number wrap around */
#endif
/* Test start / stop conditions */
#define LOOPBACK            0x00000002	/* Enable TX data loopback onto RX */
#endif

/* Test start / stop conditions */
#define PKTCHKR             0x00000001	/* Enable TX packet checker */
#define PKTGENR             0x00000001	/* Enable RX packet generator */
#define CHKR_MISMATCH       0x00000001	/* TX checker reported data mismatch */

#ifdef XRAWDATA0
#define ENGINE_TX       0
#define ENGINE_RX       32
#ifdef RAW_ETH 
#define NW_PATH_OFFSET         0xB000
#define NW_PATH_OFFSET_OTHER   0xC000
#endif
#else
#define ENGINE_TX       1
#define ENGINE_RX       33
#ifdef RAW_ETH 
#define NW_PATH_OFFSET         0xC000
#define NW_PATH_OFFSET_OTHER   0xB000
#endif
#endif

/* Packet characteristics */
#define BUFSIZE         (PAGE_SIZE)
#ifdef RAW_ETH
#define MAXPKTSIZE      (4*PAGE_SIZE - 1)
#else
#define MAXPKTSIZE      (8*PAGE_SIZE)
#endif



#define MINPKTSIZE      (64)
#define NUM_BUFS        2000
#define BUFALIGN        8
#define BYTEMULTIPLE    8   /**< Lowest sub-multiple of memory path */

struct cdev *xrawCdev = NULL;
int xraw_DriverState = UNINITIALIZED;
int xraw_UserOpen = 0;

void *handle[4] = { NULL, NULL, NULL, NULL };
#ifdef X86_64
u64 TXbarbase, RXbarbase;
#else
u32 TXbarbase, RXbarbase;
#endif
u32 RawTestMode = TEST_STOP;
u32 RawMinPktSize = MINPKTSIZE, RawMaxPktSize = MAXPKTSIZE;

#ifdef BACK_PRESSURE
#define NO_BP  1
#define YES_BP 2
#define MAX_QUEUE_THRESHOLD 12288
#define MIN_QUEUE_THRESHOLD 8192 
u8 impl_bp = NO_BP;/*back pressure implementation flag */
#endif

typedef struct
{
  int TotalNum;
  int AllocNum;
  int FirstBuf;
  int LastBuf;
  int FreePtr;
  int AllocPtr;
  unsigned char *origVA[NUM_BUFS];
} Buffer;

Buffer TxBufs;
Buffer RxBufs;
char xrawTrans[4096];

/* For exclusion */
spinlock_t RawLock;

#ifdef XRAWDATA0
#define DRIVER_NAME         "xrawdata0_driver"
#define DRIVER_DESCRIPTION  "Xilinx Raw Data0 Driver "
#else
#define DRIVER_NAME         "xrawdata1_driver"
#define DRIVER_DESCRIPTION  "Xilinx Raw Data1 Driver"
#endif


/* bufferInfo queue implementation.
*
* the variables declared here are only used by either putBufferInfo or getBufferInfo.
* These should always be guarded by QUpdateLock.
*
*/


#define MAX_BUFF_INFO 16384
 
static int TestStop=0;

typedef struct BufferInfoQ
{
  spinlock_t iLock;		           /** < will be init to unlock by default  */
  BufferInfo iList[MAX_BUFF_INFO]; /** < Buffer Queue implimented in driver for storing incoming Pkts */
  unsigned int iPutIndex;          /** < Index to put the packets in Queue */
  unsigned int iGetIndex;          /** < Index to get the packets in Queue */ 
  unsigned int iPendingDone;       /** < Indicates number of packets to read */  
} BufferInfoQue;

BufferInfoQue TxDoneQ;		// assuming everything to be initialized to 0 as these are global
BufferInfoQue RxDoneQ;		// assuming everything to be initialized to 0 as these are global

// routines use for queue manipulation.
/* 
putBuffInfo is used for adding an buffer element to the queue.
it updates the queue parameters (by holding QUpdateLock).

Returns: 0 for success / -1 for failure 

*/

int putBuffInfo (BufferInfoQue * bQue, BufferInfo buff);

/* 
getBuffInfo is used for fetching the oldest buffer info from the queue.
it updates the queue parameters (by holding QUpdateLock).

Returns: 0 for success / -1 for failure 

*/
int getBuffInfo (BufferInfoQue * bQue, BufferInfo * buff);
#ifdef X86_64
int myInit (u64 barbase, unsigned int );
#else
int myInit (unsigned int barbase, unsigned int );
#endif

int myFreePkt (void *, unsigned int *, int, unsigned int);
static int DmaSetupTransmit (void *, int, const char __user *, size_t);
static int DmaSetupReceive(void * , int ,const char __user * , size_t );   
int myGetRxPkt (void *, PktBuf *, unsigned int, int, unsigned int);
int myPutTxPkt (void *, PktBuf *, int, unsigned int);
int myPutRxPkt (void *, PktBuf *, int, unsigned int);
int mySetState (void *hndl, UserState * ustate, unsigned int privdata);
int myGetState (void *hndl, UserState * ustate, unsigned int privdata);

/* For checking data integrity */
unsigned int TxBufCnt = 0;
unsigned int RxBufCnt = 0;
unsigned int ErrCnt = 0;



static inline void
PrintSummary (void)
{

#if 0

  u32 val;

  printk ("---------------------------------------------------\n");
  printk ("%s Driver results Summary:-\n", MYNAME);
  printk ("Current Run Min Packet Size = %d, Max Packet Size = %d\n",
	  RawMinPktSize, RawMaxPktSize);
  printk
    ("Buffers Transmitted = %u, Buffers Received = %u, Error Count = %u\n",
     TxBufCnt, RxBufCnt, ErrCnt);
 

  val = XIo_In32 (TXbarbase + STATUS_ADDRESS);
  printk ("Data Mismatch Status = %x\n", val);
#ifdef RAW_ETH
   printk("XGEMAC TX Bytes 0 = %x\t", XIo_In32(TXbarbase+NW_PATH_OFFSET+0x208));	
    printk("XGEMAC TX Bytes 1 = %x\n", XIo_In32(TXbarbase+NW_PATH_OFFSET+0x20C));	
    printk("XGEMAC RX Bytes 0 = %x\t", XIo_In32(TXbarbase+NW_PATH_OFFSET+0x200));	
    printk("XGEMAC RX Bytes 1 = %x\n", XIo_In32(TXbarbase+NW_PATH_OFFSET+0x204));	
#endif
  printk ("---------------------------------------------------\n");
#endif
}

#ifdef X86_64
int
myInit (u64 barbase, unsigned int privdata)
{
#else
	int
myInit (unsigned int barbase, unsigned int privdata)
{
#endif
	log_normal ("Reached myInit with barbase %x and privdata %x\n",
			barbase, privdata);

  spin_lock_bh (&RawLock);
  if (privdata == 0x54545454)	// So that this is done only once
    {
      TXbarbase = barbase;
    }
  else if (privdata == 0x54545456)	// So that this is done only once
    {
      RXbarbase = barbase;
    }
  TxBufCnt = 0;
  RxBufCnt = 0;
  ErrCnt = 0;


  /* Stop any running tests. The driver could have been unloaded without
   * stopping running tests the last time. Hence, good to reset everything.
   */
  XIo_Out32 (TXbarbase + TX_CONFIG_ADDRESS, 0);
  XIo_Out32 (TXbarbase + RX_CONFIG_ADDRESS, 0);

  spin_unlock_bh (&RawLock);

  return 0;
}

int
myPutRxPkt (void *hndl, PktBuf * vaddr, int numpkts, unsigned int privdata)
{
  int i;
  unsigned int flags;
  PktBuf *pbuf = vaddr;
  static int pktSize;
  unsigned char *usrAddr = NULL;
  BufferInfo tempBuffInfo;
  static int noPages;

  /* Check driver state */
  if (xraw_DriverState != REGISTERED)
    {
      printk ("Driver does not seem to be ready\n");
      return -1;
    }

  /* Check handle value */
  if (hndl != handle[2])
    {
      log_normal ("Came with wrong handle %x\n", (u32) hndl);
      return -1;
    }


  for (i = 0; i < numpkts; i++)
    {
      flags = vaddr->flags;
     
      pbuf = vaddr;
	  /*release the page lock*/
      page_cache_release( (struct page *)pbuf->pageAddr);
      pktSize = pktSize + pbuf->size;
      if (flags & PKT_SOP)
	    {
	      usrAddr = pbuf->bufInfo;
          pktSize = pbuf->size;
	    }
       noPages++;
       if (flags & PKT_EOP)
	{
	  tempBuffInfo.bufferAddress = usrAddr;
	  tempBuffInfo.buffSize = pktSize;
          tempBuffInfo.noPages= noPages ;  
          tempBuffInfo.endAddress= pbuf->bufInfo;
          tempBuffInfo.endSize=pbuf->size;
	  /* put the packet in driver queue*/
	  putBuffInfo (&RxDoneQ, tempBuffInfo);
	  pktSize = 0;
          noPages=0;
	  usrAddr = NULL;
	}
      vaddr++;
    }

  /* Return packet buffers to free pool */

  return 0;
}

int
myGetRxPkt (void *hndl, PktBuf * vaddr, unsigned int size, int numpkts,
	    unsigned int privdata)
{
#ifdef USE_LATER
  unsigned char *bufVA;
  PktBuf *pbuf;
  int i;

  log_verbose(KERN_INFO "myGetRxPkt: Came with handle %p size %d privdata %x\n",
                          hndl, size, privdata);

  /* Check driver state */
  if (xraw_DriverState != REGISTERED)
    {
      printk ("Driver does not seem to be ready\n");
      return 0;
    }

  /* Check handle value */
  if (hndl != handle[2])
    {
      printk ("Came with wrong handle\n");
      return 0;
    }

  /* Check size value */
  if (size != BUFSIZE)
    printk ("myGetRxPkt: Requested size %d does not match expected %d\n",
	    size, (u32) BUFSIZE);

  spin_lock_bh (&RawLock);

  for (i = 0; i < numpkts; i++)
    {
      pbuf = &(vaddr[i]);
      /* Allocate a buffer. DMA driver will map to PCI space. */
      bufVA = AllocBuf (&RxBufs);
      log_verbose (KERN_INFO
		   "myGetRxPkt: The buffer after alloc is at address %x size %d\n",
		   (u32) bufVA, (u32) BUFSIZE);
      if (bufVA == NULL)
	{
	  log_normal (KERN_ERR "RX: AllocBuf failed\n");
	  break;
	}

      pbuf->pktBuf = bufVA;
      pbuf->bufInfo = bufVA;
      pbuf->size = BUFSIZE;
    }
  spin_unlock_bh (&RawLock);

  log_verbose (KERN_INFO "Requested %d, allocated %d buffers\n", numpkts, i);
  return i;
#endif  
return 0; 
}

int
myPutTxPkt (void *hndl, PktBuf * vaddr, int numpkts, unsigned int privdata)
{
  int i;
  unsigned int flags;
  PktBuf *pbuf = vaddr;
  static int pktSize;
  unsigned char *usrAddr = NULL;
  BufferInfo tempBuffInfo;

  log_verbose (KERN_INFO
	       "Reached myPutTxPkt with handle %p, numpkts %d, privdata %x\n",
	       hndl, numpkts, privdata);
 
  /* Check driver state */
  if (xraw_DriverState != REGISTERED)
    {
      printk ("Driver does not seem to be ready\n");
      return -1;
    }

  /* Check handle value */
  if (hndl != handle[0])
    {
      printk ("Came with wrong handle\n");
      return -1;
    }

  /* Just check if we are on the way out */
  // spin_lock_bh(&RawLock);
  for (i = 0; i < numpkts; i++)
    {
      flags = vaddr->flags;
   
      pbuf = vaddr;

     if(pbuf->pageAddr)
      page_cache_release( (struct page *)pbuf->pageAddr);

	  pktSize = pktSize + pbuf->size;

      if (flags & PKT_SOP)
	{
	  usrAddr = pbuf->bufInfo;
      pktSize = pbuf->size;
	}

      if (flags & PKT_EOP)
	{
	  tempBuffInfo.bufferAddress = usrAddr;
	  tempBuffInfo.buffSize = pktSize;
	  putBuffInfo (&TxDoneQ, tempBuffInfo);
	  pktSize = 0;
	  usrAddr = NULL;
	}

      vaddr++;

    }
  

  return 0;
}

int
mySetState (void *hndl, UserState * ustate, unsigned int privdata)
{
  int val;
 #ifndef RAW_ETH
  int seqno;
 #endif

  static unsigned int testmode;

  log_verbose (KERN_INFO "Reached mySetState with privdata %x\n", privdata);

  /* Check driver state */
  if (xraw_DriverState != REGISTERED)
    {
      printk ("Driver does not seem to be ready\n");
      return EFAULT;
    }

  /* Check handle value */
  if ((hndl != handle[0]) && (hndl != handle[2]))
    {
      printk ("Came with wrong handle\n");
      return EBADF;
    }

  /* Valid only for TX engine */
  if (privdata == 0x54545454)
    {
      spin_lock_bh (&RawLock);

      /* Set up the value to be written into the register */
      RawTestMode = ustate->TestMode;

      if (RawTestMode & TEST_START)
	{
	  testmode = 0;
          TestStop=0;
	  if (RawTestMode & ENABLE_LOOPBACK)
	    testmode |= LOOPBACK;
	  if (RawTestMode & ENABLE_PKTCHK)
	    testmode |= PKTCHKR;
	  if (RawTestMode & ENABLE_PKTGEN)
	    testmode |= PKTGENR;
	}
      else
	{
	  /* Deliberately not clearing the loopback bit, incase a
	   * loopback test was going on - allows the loopback path
	   * to drain off packets. Just stopping the source of packets.
	   */
	  if (RawTestMode & ENABLE_PKTCHK)
	    testmode &= ~PKTCHKR;
	  if (RawTestMode & ENABLE_PKTGEN)
	    testmode &= ~PKTGENR;
          
          TestStop=1;
	 /* enable this if we need to Disable loop back also */ 
#ifdef USE_LATER
	  if (RawTestMode & ENABLE_LOOPBACK)
	    testmode &= ~LOOPBACK;
#endif		
	}

      log_verbose("SetState TX with RawTestMode %x, reg value %x\n",
	      RawTestMode, testmode);

      /* Now write the registers */
      if (RawTestMode & TEST_START)
	{
	  if (!
	      (RawTestMode &
	       (ENABLE_PKTCHK | ENABLE_PKTGEN | ENABLE_LOOPBACK)))
	    {
	      printk ("%s Driver: TX Test Start called with wrong mode %x\n",
		      MYNAME, testmode);
	      RawTestMode = 0;
	      spin_unlock_bh (&RawLock);
	      return EBADRQC;
	    }

	   printk(KERN_ERR "%s Driver: Starting the test - mode %x, reg %x\n",
		  MYNAME, RawTestMode, testmode);

	  /* Next, set packet sizes. Ensure they don't exceed PKTSIZEs */
	  RawMinPktSize = ustate->MinPktSize;
	  RawMaxPktSize = ustate->MaxPktSize;

	  /* Set RX packet size for memory path */
	  val = RawMaxPktSize;
	  log_verbose("Reg %x = %x\n", PKT_SIZE_ADDRESS, val);
	  RawMinPktSize = RawMaxPktSize = val;
	  /* Now ensure the sizes remain within bounds */
	  if (RawMaxPktSize > MAXPKTSIZE)
	    RawMinPktSize = RawMaxPktSize = MAXPKTSIZE;
	  if (RawMinPktSize < MINPKTSIZE)
	    RawMinPktSize = RawMaxPktSize = MINPKTSIZE;
	  if (RawMinPktSize > RawMaxPktSize)
	    RawMinPktSize = RawMaxPktSize;
	  val = RawMaxPktSize;
#ifndef RAW_ETH
	  log_verbose("========Reg %x = %d\n",DESIGN_MODE_ADDRESS, PERF_DESIGN_MODE);
          XIo_Out32 (TXbarbase + DESIGN_MODE_ADDRESS,PERF_DESIGN_MODE);
          log_verbose("DESIGN MODE %d\n",PERF_DESIGN_MODE );
#endif
	  log_verbose("========Reg %x = %d\n", PKT_SIZE_ADDRESS, val);
	  XIo_Out32 (TXbarbase + PKT_SIZE_ADDRESS, val);
	  printk(KERN_ERR "PktSize retrieved from register is %d and the value programmed is %d\n", XIo_In32(TXbarbase+PKT_SIZE_ADDRESS),val);
#ifndef RAW_ETH	  
          seqno= TX_CONFIG_SEQNO;
         log_verbose("========Reg %x = %d\n",SEQNO_WRAP_REG, seqno);
          XIo_Out32 (TXbarbase + SEQNO_WRAP_REG , seqno);
          log_verbose("SeqNo Wrap around %d\n", seqno);
#endif

#ifdef RAW_ETH
#ifdef XRAWDATA0
                        XIo_Out32(TXbarbase+WRBURST_0, BURST_SIZE );
                        XIo_Out32(TXbarbase+RDBURST_0, BURST_SIZE );
                        XIo_Out32(TXbarbase+WRBURST_1, BURST_SIZE );
                        XIo_Out32(TXbarbase+RDBURST_1, BURST_SIZE );
#else
                        XIo_Out32(TXbarbase+WRBURST_2, BURST_SIZE );
                        XIo_Out32(TXbarbase+RDBURST_2, BURST_SIZE );
                        XIo_Out32(TXbarbase+WRBURST_3, BURST_SIZE );
                        XIo_Out32(TXbarbase+RDBURST_3, BURST_SIZE );
#endif
#endif

          mdelay(1); 

          
/* Incase the last test was a loopback test, that bit may not be cleared. */
	  XIo_Out32 (TXbarbase + TX_CONFIG_ADDRESS, 0);
	  if (RawTestMode & (ENABLE_PKTCHK | ENABLE_LOOPBACK))
	    {
	     
	      log_verbose("========Reg %x = %x\n", TX_CONFIG_ADDRESS, testmode);
	      XIo_Out32 (TXbarbase + TX_CONFIG_ADDRESS, testmode);
#ifdef RAW_ETH
 		log_verbose("Reg[DESIGN_MODE] = %x\n", XIo_In32(TXbarbase+DESIGN_MODE_ADDRESS));
        XIo_Out32(TXbarbase+DESIGN_MODE_ADDRESS,PERF_DESIGN_MODE);
        log_verbose("Disable performance mode....\nReg[DESIGN_MODE] = %x\n", XIo_In32(TXbarbase+DESIGN_MODE_ADDRESS));

                if(RawTestMode & ENABLE_CRISCROSS)
                {
                printk("XGEMAC-RCW1 = %x\n", XIo_In32(TXbarbase + NW_PATH_OFFSET_OTHER + XXGE_RCW1_OFFSET));
                XIo_Out32(TXbarbase+NW_PATH_OFFSET_OTHER+XXGE_RCW1_OFFSET, 0x50000000);
                printk("XGEMAC-RCW1 = %x\n", XIo_In32(TXbarbase + NW_PATH_OFFSET_OTHER + XXGE_RCW1_OFFSET));
                }
                else
                {
                printk("XGEMAC-RCW1 = %x\n", XIo_In32(TXbarbase + NW_PATH_OFFSET + XXGE_RCW1_OFFSET));//mrinals
                XIo_Out32(TXbarbase+NW_PATH_OFFSET+XXGE_RCW1_OFFSET, 0x50000000);
                printk("XGEMAC-RCW1 = %x\n", XIo_In32(TXbarbase + NW_PATH_OFFSET + XXGE_RCW1_OFFSET));//mrinals
                }
                    printk("XGEMAC-TC = %x\n", XIo_In32(TXbarbase + NW_PATH_OFFSET + XXGE_TC_OFFSET));//mrinals
                    XIo_Out32(TXbarbase+NW_PATH_OFFSET+XXGE_TC_OFFSET, 0x50000000);
                    printk("XGEMAC-TC = %x\n", XIo_In32(TXbarbase + NW_PATH_OFFSET + XXGE_TC_OFFSET));//mrinals
   printk("XGEMAC 0 TX Bytes 0 = %x\t", XIo_In32(TXbarbase+NW_PATH_OFFSET+0x208));	
    printk("XGEMAC 0 TX Bytes 1 = %x\n", XIo_In32(TXbarbase+NW_PATH_OFFSET+0x20C));	
    printk("XGEMAC 0 RX Bytes 0 = %x\t", XIo_In32(TXbarbase+NW_PATH_OFFSET+0x200));	
    printk("XGEMAC 0 RX Bytes 1 = %x\n", XIo_In32(TXbarbase+NW_PATH_OFFSET+0x204));
    printk("XGEMAC 0 Frames Transmitted OK 0 = %x\n", XIo_In32(TXbarbase+NW_PATH_OFFSET+0x2D8));
    printk("XGEMAC 0 Frames Transmitted OK 1 = %x\n", XIo_In32(TXbarbase+NW_PATH_OFFSET+0x2DC));
    printk("XGEMAC 0 Frames Received OK 0 = %x\n", XIo_In32(TXbarbase+NW_PATH_OFFSET+0x290));
    printk("XGEMAC 0 Frames Received OK 1 = %x\n", XIo_In32(TXbarbase+NW_PATH_OFFSET+0x294));
   printk("XGEMAC 1 TX Bytes 0 = %x\t", XIo_In32(TXbarbase+NW_PATH_OFFSET_OTHER+0x208));
    printk("XGEMAC 1 TX Bytes 1 = %x\n", XIo_In32(TXbarbase+NW_PATH_OFFSET_OTHER+0x20C)); 
    printk("XGEMAC 1 RX Bytes 0 = %x\t", XIo_In32(TXbarbase+NW_PATH_OFFSET_OTHER+0x200));
    printk("XGEMAC 1 RX Bytes 1 = %x\n", XIo_In32(TXbarbase+NW_PATH_OFFSET_OTHER+0x204));	
    printk("XGEMAC 1 Frames Transmitted OK 0 = %x\n", XIo_In32(TXbarbase+NW_PATH_OFFSET_OTHER+0x2D8));
    printk("XGEMAC 1 Frames Transmitted OK 1 = %x\n", XIo_In32(TXbarbase+NW_PATH_OFFSET_OTHER+0x2DC));
    printk("XGEMAC 1 Frames Received OK 0 = %x\n", XIo_In32(TXbarbase+NW_PATH_OFFSET_OTHER+0x290));
    printk("XGEMAC 1 Frames Received OK 1 = %x\n", XIo_In32(TXbarbase+NW_PATH_OFFSET_OTHER+0x294));
#endif
	    }
	  if (RawTestMode & ENABLE_PKTGEN)
	    {
	      log_verbose("========Reg %x = %x\n", RX_CONFIG_ADDRESS, testmode);
	      XIo_Out32 (TXbarbase + RX_CONFIG_ADDRESS, testmode);
	    }

	}
      /* Else, stop the test. Do not remove any loopback here because
       * the DMA queues and hardware FIFOs must drain first.
       */
      else
	{
	  log_verbose("%s Driver: Stopping the test, mode %x\n", MYNAME,
		  testmode);
	  log_verbose("========Reg %x = %x\n", TX_CONFIG_ADDRESS, testmode);
	  XIo_Out32 (TXbarbase + TX_CONFIG_ADDRESS, testmode);
	  log_verbose ("========Reg %x = %x\n", RX_CONFIG_ADDRESS, testmode);
	  XIo_Out32 (TXbarbase + RX_CONFIG_ADDRESS, testmode);
          mdelay(200);   
          
           
	  
	}

      PrintSummary ();
      spin_unlock_bh (&RawLock);
    }
  return 0;
}

int
myGetState (void *hndl, UserState * ustate, unsigned int privdata)
{
  static int iter = 0;

  /* Same state is being returned for both engines */

  ustate->LinkState = LINK_UP;
  ustate->DataMismatch= XIo_In32 (TXbarbase + STATUS_ADDRESS);
  ustate->MinPktSize = RawMinPktSize;
  ustate->MaxPktSize = RawMaxPktSize;
  ustate->TestMode = RawTestMode;
  if (privdata == 0x54545454)
    ustate->Buffers = TxBufs.TotalNum;
  else
    ustate->Buffers = RxBufs.TotalNum;

  if (iter++ >= 4)
    {
      PrintSummary ();

      iter = 0;
    }

  return 0;
}


#define QSUCCESS 0
#define QFAILURE -1

/* 
putBuffInfo is used for adding an buffer element to the queue.
it updates the queue parameters (by holding QUpdateLock).

Returns: 0 for success / -1 for failure 

*/

int
putBuffInfo (BufferInfoQue * bQue, BufferInfo buff)
{

  // assert (bQue != NULL)

  int currentIndex = 0;
  spin_lock_bh (&(bQue->iLock));

  currentIndex = (bQue->iPutIndex + 1) % MAX_BUFF_INFO;

  if (currentIndex == bQue->iGetIndex)
    {
      spin_unlock_bh (&(bQue->iLock));
      printk (KERN_ERR "%s: BufferInfo Q is FULL in %s , drop the incoming buffers",
	      __func__,__FILE__);
      return QFAILURE;		// array full
    }

  bQue->iPutIndex = currentIndex;

	bQue->iList[bQue->iPutIndex] = buff;
	bQue->iPendingDone++;
#ifdef BACK_PRESSURE
	if(bQue == &RxDoneQ)
	{
		if((impl_bp == NO_BP)&& ( bQue->iPendingDone > MAX_QUEUE_THRESHOLD))
		{
			impl_bp = YES_BP;
			printk(KERN_ERR "XXXXXX Maximum Queue Threshold reached.Turning on BACK PRESSURE XRAW0 %d  \n",bQue->iPendingDone);
		} 
	}
#endif  
	spin_unlock_bh (&(bQue->iLock));
	return QSUCCESS;
}

/* 
getBuffInfo is used for fetching the oldest buffer info from the queue.
it updates the queue parameters (by holding QUpdateLock).

Returns: 0 for success / -1 for failure 

*/
int
getBuffInfo (BufferInfoQue * bQue, BufferInfo * buff)
{
  // assert if bQue is NULL
  if (!buff || !bQue)
    {
      printk (KERN_ERR "%s: BAD BufferInfo pointer", __func__);
      return QFAILURE;
    }

  spin_lock_bh (&(bQue->iLock));

  // assuming we get the right buffer
  if (!bQue->iPendingDone)
    {
      spin_unlock_bh (&(bQue->iLock));
      log_verbose(KERN_ERR "%s: BufferInfo Q is Empty",__func__);
      return QFAILURE;
    }

	bQue->iGetIndex++;
	bQue->iGetIndex %= MAX_BUFF_INFO;
	*buff = bQue->iList[bQue->iGetIndex];
	bQue->iPendingDone--;
#ifdef BACK_PRESSURE
	if(bQue == &RxDoneQ) 
	{
		if((impl_bp == YES_BP) && (bQue->iPendingDone < MIN_QUEUE_THRESHOLD))
		{
			impl_bp = NO_BP;
			printk(KERN_ERR "XXXXXXX Minimum Queue Threshold reached.Turning off Back Pressure at %d %s\n",__LINE__,__FILE__);
		}
	}
#endif
	spin_unlock_bh (&(bQue->iLock));

  return QSUCCESS;

}


#define WRITE_TO_CARD   0	
#define READ_FROM_CARD  1	


static int DmaSetupReceive(void * hndl, int num ,const char __user * buffer, size_t length)   
{
    int j;
    int total, result;
    PktBuf * pbuf;
    int status;               
    int offset;                
    unsigned int allocPages;   
    unsigned long first, last; 
    struct page** cachePages; 
    PktBuf **pkts;

    /* Check driver state */
    if(xraw_DriverState != REGISTERED)
    {
        printk("Driver does not seem to be ready\n");
        return 0;
    }

    /* Check handle value */
    if(hndl != handle[2])
    {
        printk("Came with wrong handle\n");
        return 0;
    }

    /* Check number of packets */
    if(!num)
    {
        printk("Came with 0 packets for sending\n");
        return 0;
    }
   
     total = 0;
      
        /****************************************************************/
        // SECTION 1: generate CACHE PAGES for USER BUFFER
        //
        offset = offset_in_page(buffer);
        first = ((unsigned long)buffer & PAGE_MASK) >> PAGE_SHIFT;
        last  = (((unsigned long)buffer + length-1) & PAGE_MASK) >> PAGE_SHIFT;
        allocPages = (last-first)+1;
        

	pkts = kmalloc( allocPages * (sizeof(PktBuf*)), GFP_KERNEL);
	if(pkts == NULL)
	{
		printk(KERN_ERR "Error: unable to allocate memory for pkts\n");
		return -1;
	}

	cachePages = kmalloc( (allocPages * (sizeof(struct page*))), GFP_KERNEL );
	if( cachePages == NULL )
	{
		printk(KERN_ERR "Error: unable to allocate memory for cachePages\n");
		kfree(pkts);
		return -1;
	}

	memset(cachePages, 0, sizeof(allocPages * sizeof(struct page*)) );
	down_read(&(current->mm->mmap_sem));
	status = get_user_pages(current,        // current process id
			current->mm,                // mm of current process
			(unsigned long)buffer,      // user buffer
			allocPages,
			READ_FROM_CARD,
			0,                          /* don't force */
			cachePages,
			NULL);
	up_read(&current->mm->mmap_sem);
	if( status < allocPages) {
		printk(KERN_ERR ".... Error: requested pages=%d, granted pages=%d ....\n", allocPages, status);

		for(j=0; j<status; j++)
			page_cache_release(cachePages[j]);

		kfree(pkts);
		kfree(cachePages);
		return -1;
	}


	allocPages = status;	// actual number of pages system gave

	for(j=0; j< allocPages; j++)		/* Packet fragments loop */
	{
		pbuf = kmalloc( (sizeof(PktBuf)), GFP_KERNEL);

            if(pbuf == NULL) {
                printk(KERN_ERR "Insufficient Memory !!\n");
                for(j--; j>=0; j--)
                    kfree(pkts[j]);
                for(j=0; j<allocPages; j++)
                    page_cache_release(cachePages[j]);
                kfree(pkts);
                kfree(cachePages);
                return -1;
            }

            //spin_lock_bh(&RawLock);
            pkts[j] = pbuf;

            // first buffer would start at some offset, need not be on page boundary
            if(j==0) {
                pbuf->size = ((PAGE_SIZE)-offset);
            } 
            else {
                if(j == (allocPages-1)) { 
                    pbuf->size = length-total;
                }
                else pbuf->size = (PAGE_SIZE);
            }
            pbuf->pktBuf = (unsigned char*)cachePages[j];		
                       
			pbuf->bufInfo = (unsigned char *) buffer + total;

			pbuf->pageAddr= (unsigned char*)cachePages[j];
           
            pbuf->flags = PKT_ALL;
                  
            total += pbuf->size;
            //spin_unlock_bh(&RawLock);
        }
        /****************************************************************/

    allocPages = j;           // actually used pages

	result = DmaSendPages(hndl, pkts, allocPages);
    if(result == -1)
    {
        for(j=0; j<allocPages; j++) {
            page_cache_release(cachePages[j]);
        }
  
      total = 0;
    }
    kfree(cachePages);

    for(j=0; j<allocPages; j++) {
        kfree(pkts[j]);
    }
    kfree(pkts);

    return total;
}
static int DmaSetupTransmit(void * hndl, int num ,const char __user * buffer, size_t length)   
{
    int j;
    int total, result;
    PktBuf * pbuf;
    int status;                
    int offset;                
    unsigned int allocPages;   
    unsigned long first, last; 
    struct page** cachePages;  
    PktBuf **pkts;

    /* Check driver state */
    if(xraw_DriverState != REGISTERED)
    {
        printk("Driver does not seem to be ready\n");
        return 0;
    }

    /* Check handle value */
    if(hndl != handle[0])
    {
        printk("Came with wrong handle\n");
        return 0;
    }

	/* Check number of packets */
	if(!num)
	{
		printk("Came with 0 packets for sending\n");
		return 0;
	}

	total = 0;
	/****************************************************************/
	// SECTION 1: generate CACHE PAGES for USER BUFFER
	//
	offset = offset_in_page(buffer);
	first = ((unsigned long)buffer & PAGE_MASK) >> PAGE_SHIFT;
	last  = (((unsigned long)buffer + length-1) & PAGE_MASK) >> PAGE_SHIFT;
	allocPages = (last-first)+1;

	pkts = kmalloc( allocPages * (sizeof(PktBuf*)), GFP_KERNEL);
	if(pkts == NULL)
	{
		printk(KERN_ERR "Error: unable to allocate memory for packets\n");
		return -1;
	}

	cachePages = kmalloc( (allocPages * (sizeof(struct page*))), GFP_KERNEL );
	if( cachePages == NULL )
	{
		printk(KERN_ERR "Error: unable to allocate memory for cachePages\n");
		kfree(pkts);
		return -1;
	}

	memset(cachePages, 0, sizeof(allocPages * sizeof(struct page*)) );
	down_read(&(current->mm->mmap_sem));
	status = get_user_pages(current,        // current process id
			current->mm,                // mm of current process
			(unsigned long)buffer,      // user buffer
			allocPages,
			WRITE_TO_CARD,
			0,                          /* don't force */
			cachePages,
			NULL);
	up_read(&current->mm->mmap_sem);
	if( status < allocPages) {
		printk(KERN_ERR ".... Error: requested pages=%d, granted pages=%d ....\n", allocPages, status);

		for(j=0; j<status; j++)
			page_cache_release(cachePages[j]);
		kfree(pkts);
		kfree(cachePages);
		return -1;
	}


	allocPages = status;	// actual number of pages system gave

	for(j=0; j< allocPages; j++)		/* Packet fragments loop */
	{
		pbuf = kmalloc( (sizeof(PktBuf)), GFP_KERNEL);

		if(pbuf == NULL) {
			printk(KERN_ERR "Insufficient Memory !!\n");
			for(j--; j>=0; j--)
				kfree(pkts[j]);
			for(j=0; j<allocPages; j++)
				page_cache_release(cachePages[j]);
			kfree(pkts);
			kfree(cachePages);
			return -1;
		}

            //spin_lock_bh(&RawLock);
            pkts[j] = pbuf;

            // first buffer would start at some offset, need not be on page boundary
            if(j==0) {
                if(j == (allocPages-1)) { 
                    pbuf->size = length;
                }
                else
                pbuf->size = ((PAGE_SIZE)-offset);
            } 
            else {
                if(j == (allocPages-1)) { 
                    pbuf->size = length-total;
                }
                else pbuf->size = (PAGE_SIZE);
            }
            pbuf->pktBuf = (unsigned char*)cachePages[j];		
                       
	        pbuf->pageOffset = (j == 0) ? offset : 0;	// try pci_page_map

			pbuf->bufInfo = (unsigned char *) buffer + total;
			pbuf->pageAddr= (unsigned char*)cachePages[j];
			pbuf->userInfo = length;
          
            pbuf->flags = PKT_ALL;
             if(j == 0)
             {
		        pbuf->flags |= PKT_SOP;
                }
             if(j == (allocPages - 1) )
             {
                pbuf->flags |= PKT_EOP;
             }
            total += pbuf->size;
            //spin_unlock_bh(&RawLock);
        }
        /****************************************************************/

    allocPages = j;           // actually used pages
    
    result = DmaSendPages_Tx (hndl, pkts,allocPages);
    if(result == -1)
    {
        for(j=0; j<allocPages; j++) {
            page_cache_release(cachePages[j]);
        }
    total = 0;
       }
    kfree(cachePages);

    for(j=0; j<allocPages; j++) {
        kfree(pkts[j]);
    }
    kfree(pkts);

   return total;
}

static int CPU_LOADED[16] =
  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

static int
xraw_dev_open (struct inode *in, struct file *filp)
{
  int cpu_id = 0;

  if (xraw_DriverState < INITIALIZED)
    {
      printk ("Driver not yet ready!\n");
      return -1;
    }

  cpu_id = get_cpu ();
  if (CPU_LOADED[cpu_id] == 0)
    {
      CPU_LOADED[cpu_id] = 1;
    }
  else
    {
      log_verbose(KERN_ERR "CPU %d is already loaded, exit this process\n",
	      cpu_id);
      //return -1;
    }
      log_verbose(KERN_ERR "$$$$$$ CPU ID %d $$$$$$\n", cpu_id);

    /* Allowing more than one Application accesing the driver */
#if 0
  if (xraw_UserOpen)
    {                                          /* To prevent more than one GUI */
      printk ("Device already in use\n");
      return -EBUSY;
    }
#endif
  //spin_lock_bh(&DmaStatsLock);
  xraw_UserOpen++;		  
  //spin_unlock_bh(&DmaStatsLock);
//  printk ("========>>>>> XDMA driver instance %d \n", xraw_UserOpen);

  return 0;
}

static int
xraw_dev_release (struct inode *in, struct file *filp)
{
  int cpu_id = 0;

  if (!xraw_UserOpen)
    {
      /* Should not come here */
      printk ("Device not in use\n");
      return -EFAULT;
    }

  //  spin_lock_bh(&DmaStatsLock);
  xraw_UserOpen--;
  //  spin_unlock_bh(&DmaStatsLock);

  cpu_id = get_cpu ();
  CPU_LOADED[cpu_id] = 0;
  log_verbose(KERN_ERR "CPU %d is released\n", cpu_id);

  return 0;
}

static long
xraw_dev_ioctl (struct file *filp,
		unsigned int cmd, unsigned long arg)
{
  int retval = 0;
 
  if (xraw_DriverState < INITIALIZED)
    {
      /* Should not come here */
      printk ("Driver not yet ready!\n");
      return -1;
    }

  /* Check cmd type and value */
  if (_IOC_TYPE (cmd) != XPMON_MAGIC)
    return -ENOTTY;
  if (_IOC_NR (cmd) > XPMON_MAX_CMD)
    return -ENOTTY;

  /* Check read/write and corresponding argument */
  if (_IOC_DIR (cmd) & _IOC_READ)
    if (!access_ok (VERIFY_WRITE, (void *) arg, _IOC_SIZE (cmd)))
      return -EFAULT;
  if (_IOC_DIR (cmd) & _IOC_WRITE)
    if (!access_ok (VERIFY_READ, (void *) arg, _IOC_SIZE (cmd)))
      return -EFAULT;

  switch (cmd)
    {
    
    case IGET_TRN_TXUSRINFO:
      {
	int count = 0;
	
	int expect_count;
        if(copy_from_user(&expect_count,&(((FreeInfo *)arg)->expected),sizeof(int)) != 0)
        {
		printk ("##### ERROR in copy from usr #####");
                break;
        }
	while (count < expect_count)
	  {
	    BufferInfo buff;
	    if (0 != getBuffInfo (&TxDoneQ, &buff))
	      {
		break;
	      }
	    if (copy_to_user
		(((BufferInfo *) (((FreeInfo *)arg)->buffList) + count), &buff,
		 sizeof (BufferInfo)))
	      {
		printk ("##### ERROR in copy to usr #####");

	      }
	   // log_verbose(" %s:bufferAddr %x   PktSize %d", __func__, usrArgument->buffList[count].bufferAddress, usrArgument->buffList[count].buffSize);
	    count++;
	  }
        if(copy_to_user(&(((FreeInfo *)arg)->expected),&count,(sizeof(int))) != 0)
        {
		printk ("##### ERROR in copy to usr #####");
        }

	break;
      }
    case IGET_TRN_RXUSRINFO:
      {
	int count = 0;
	int expect_count;
	
        if(copy_from_user(&expect_count,&(((FreeInfo *)arg)->expected),sizeof(int)) != 0)
        {
		printk ("##### ERROR in copy from usr #####");
                break;
        }

	while (count < expect_count)
	  {
	    BufferInfo buff;
	    if (0 != getBuffInfo (&RxDoneQ, &buff))
	      {
		break;
	      }
	    if (copy_to_user
		(((BufferInfo *) (((FreeInfo *)arg)->buffList) + count), &buff,
		 sizeof (BufferInfo)))
	      {
		printk ("##### ERROR in copy to usr #####");

	      }
	 	 //log_verbose(" %s:bufferAddr %x   PktSize %d", __func__, usrArgument->buffList[count].bufferAddress, usrArgument->buffList[count].buffSize);
	    count++;
	  }
        if(copy_to_user(&(((FreeInfo *)arg)->expected),&count,(sizeof(int))) != 0)
        {
		printk ("##### ERROR in copy to usr #####");
        }

	break;
      }
    default:
      printk ("Invalid command %d\n", cmd);
      retval = -1;
      break;
    }

  return retval;
}

/* 
 * This function is called when somebody tries to
 * write into our device file. 
 */
static ssize_t
xraw_dev_write (struct file *file,
		const char __user * buffer, size_t length, loff_t * offset)
{
  int ret_pack=0;


      if ((RawTestMode & TEST_START) &&
	  (RawTestMode & (ENABLE_PKTCHK | ENABLE_LOOPBACK)))
  	ret_pack = DmaSetupTransmit(handle[0], 1, buffer, length);

    /* 
	 *  return the number of bytes sent , currently one or none
	 */
  return ret_pack;
}

static ssize_t
xraw_dev_read (struct file *file,
	       char __user * buffer, size_t length, loff_t * offset)
{
  int ret_pack=0;

#ifdef BACK_PRESSURE
  if(impl_bp == NO_BP)
#endif
     ret_pack = DmaSetupReceive(handle[2],1,buffer,length);
                

    /* 
	 *  return the number of bytes sent , currently one or none
	 */

  return ret_pack;
}

static int __init
rawdata_init (void)
{
  int chrRet;
  dev_t xrawDev;
  UserPtrs ufuncs;
  static struct file_operations xrawDevFileOps;

  /* Just register the driver. No kernel boot options used. */
  printk (KERN_INFO "%s Init: Inserting Xilinx driver in kernel.\n", MYNAME);

  xraw_DriverState = INITIALIZED;
  spin_lock_init (&RawLock);
  spin_lock_init (&(TxDoneQ.iLock));
  spin_lock_init (&(RxDoneQ.iLock));


  msleep (5);

  /* First allocate a major/minor number. */
  chrRet = alloc_chrdev_region (&xrawDev, 0, 1, DEV_NAME);
  if (IS_ERR ((int *) chrRet))
  {
    log_normal (KERN_ERR "Error allocating char device region\n");
    return -1;
  }
  else
    {
      /* Register our character device */
      xrawCdev = cdev_alloc ();
      if (IS_ERR (xrawCdev))
	{
	  log_normal (KERN_ERR "Alloc error registering device driver\n");
	  unregister_chrdev_region (xrawDev, 1);
	  return -1;
	}
      else
	{
	  xrawDevFileOps.owner = THIS_MODULE;
	  xrawDevFileOps.open = xraw_dev_open;
	  xrawDevFileOps.release = xraw_dev_release;
	  xrawDevFileOps.unlocked_ioctl = xraw_dev_ioctl;
	  xrawDevFileOps.write = xraw_dev_write;
	  xrawDevFileOps.read = xraw_dev_read;
	  xrawCdev->owner = THIS_MODULE;
	  xrawCdev->ops = &xrawDevFileOps;
	  xrawCdev->dev = xrawDev;
	  chrRet = cdev_add (xrawCdev, xrawDev, 1);
	  if (chrRet < 0)
	    {
	      log_normal (KERN_ERR "Add error registering device driver\n");
	      cdev_del(xrawCdev);
	      unregister_chrdev_region (xrawDev, 1);
              return -1;
	    }
	}
    }

  if (!IS_ERR ((int *) chrRet))
    {
      printk (KERN_INFO "Device registered with major number %d\n",
	      MAJOR (xrawDev));

    }

  xraw_DriverState = INITIALIZED;
  /* Register with DMA incase not already done so */
  if (xraw_DriverState < POLLING)
    {
      spin_lock_bh (&RawLock);
      printk ("Calling DmaRegister on engine %d and %d\n",
	      ENGINE_TX, ENGINE_RX);
      xraw_DriverState = REGISTERED;

      ufuncs.UserInit = myInit;
      ufuncs.UserPutPkt = myPutTxPkt;
      ufuncs.UserSetState = mySetState;
      ufuncs.UserGetState = myGetState;
#ifdef PM_SUPPORT
      ufuncs.UserSuspend_Early = NULL;
      ufuncs.UserSuspend_Late = NULL;
      ufuncs.UserResume = NULL;
#endif
      ufuncs.privData = 0x54545454;
#ifdef RAW_ETH
      ufuncs.mode = RAWETHERNET_MODE;
#else
      ufuncs.mode = PERFORMANCE_MODE;
#endif
      spin_unlock_bh (&RawLock);

      if ((handle[0] =
	   DmaRegister (ENGINE_TX, MYBAR, &ufuncs, BUFSIZE)) == NULL)
	{
	  printk ("Register for engine %d failed. Stopping.\n", ENGINE_TX);
	  spin_lock_bh (&RawLock);
	  xraw_DriverState = UNREGISTERED;
	  spin_unlock_bh (&RawLock);
	  cdev_del(xrawCdev);
	  unregister_chrdev_region (xrawDev, 1);
	  return -1;		
	}
      printk ("Handle for engine %d is %p\n", ENGINE_TX, handle[0]);

      spin_lock_bh (&RawLock);
      ufuncs.UserInit = myInit;
      ufuncs.UserPutPkt = myPutRxPkt;
      ufuncs.UserGetPkt = myGetRxPkt;
      ufuncs.UserSetState = mySetState;
      ufuncs.UserGetState = myGetState;
#ifdef PM_SUPPORT
      ufuncs.UserSuspend_Early = NULL;
      ufuncs.UserSuspend_Late = NULL;
      ufuncs.UserResume = NULL;
#endif
      ufuncs.privData = 0x54545456;
#ifdef RAW_ETH
      ufuncs.mode = RAWETHERNET_MODE;
#else
      ufuncs.mode = PERFORMANCE_MODE;
#endif
      spin_unlock_bh (&RawLock);

      if ((handle[2] =
	   DmaRegister (ENGINE_RX, MYBAR, &ufuncs, BUFSIZE)) == NULL)
	{
	  printk ("Register for engine %d failed. Stopping.\n", ENGINE_RX);
	  spin_lock_bh (&RawLock);
	  xraw_DriverState = UNREGISTERED;
	  spin_unlock_bh (&RawLock);
	  cdev_del(xrawCdev);
	  unregister_chrdev_region (xrawDev, 1);
	  return -1;		
	}
      printk ("Handle for engine %d is %p\n", ENGINE_RX, handle[2]);


    }


  return 0;
}

static void __exit
rawdata_cleanup (void)
{
  int i;
  
  /* Stop any running tests, else the hardware's packet checker &
   * generator will continue to run.
   */
  XIo_Out32 (TXbarbase + TX_CONFIG_ADDRESS, 0);

  XIo_Out32 (TXbarbase + RX_CONFIG_ADDRESS, 0);
#ifdef RAW_ETH
  mdelay(1);

  XIo_Out32(TXbarbase+(u32)(NW_PATH_OFFSET+XXGE_TC_OFFSET), 0x80000000);
  mdelay(1);

  XIo_Out32(TXbarbase+(u32)(NW_PATH_OFFSET+XXGE_RCW1_OFFSET), 0x80000000);
  mdelay(1);
#endif

  printk (KERN_INFO "%s: Unregistering Xilinx driver from kernel.\n", MYNAME);
  if (TxBufCnt != RxBufCnt)
    {
      printk ("%s: Buffers Transmitted %u Received %u\n", MYNAME, TxBufCnt,
	      RxBufCnt);
      
      mdelay (1);
    }
#ifdef FIFO_EMPTY_CHECK
    DmaFifoEmptyWait(MYHANDLE,DIR_TYPE_S2C);
    // wait for appropriate time to stabalize
    mdelay(STABILITY_WAIT_TIME);
#endif
  DmaUnregister (handle[0]);
#ifdef FIFO_EMPTY_CHECK
    DmaFifoEmptyWait(MYHANDLE,DIR_TYPE_C2S);
    // wait for appropriate time to stabalize
    mdelay(STABILITY_WAIT_TIME);
#endif
  DmaUnregister (handle[2]);

  PrintSummary ();
  /*Unregistering the char driver  */
  if (xrawCdev != NULL)
    {
      printk ("Unregistering char device driver\n");
      cdev_del (xrawCdev);
      unregister_chrdev_region (xrawCdev->dev, 1);
    }

  mdelay (1000);

  /* Not sure if free_page() sleeps or not. */
  spin_lock_bh (&RawLock);
  printk ("Freeing user buffers\n");
  for (i = 0; i < TxBufs.TotalNum; i++)
    //kfree(TxBufs.origVA[i]);
    free_page ((unsigned long) (TxBufs.origVA[i]));
  for (i = 0; i < RxBufs.TotalNum; i++)
    //kfree(RxBufs.origVA[i]);
    free_page ((unsigned long) (RxBufs.origVA[i]));
  spin_unlock_bh (&RawLock);
}

module_init (rawdata_init);
module_exit (rawdata_cleanup);

MODULE_AUTHOR ("Xilinx, Inc.");
MODULE_DESCRIPTION (DRIVER_DESCRIPTION);
MODULE_LICENSE ("GPL");
