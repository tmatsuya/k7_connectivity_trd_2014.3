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
 * @file com_xilinx_gui_DriverInfoGen.cpp  
 *
 * Author: Xilinx, Inc.
 *
 * 2007-2010 (c) Xilinx, Inc. This file is licensed uner the terms of the GNU
 * General Public License version 2.1. This program is licensed "as is" without
 * any warranty of any kind, whether express or implied.
 *
 * MODIFICATION HISTORY:
 *
 * Ver   Date     Changes
 * ----- -------- -------------------------------------------------------
 * 1.0  5/15/12  First release
 *
 *****************************************************************************/

#include <com_xilinx_gui_DriverInfoGen.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <xpmon_be.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

#define FILENAME "/dev/xdma_stat"

#define MAX_STATS 350
#define MULTIPLIER  8
#define DIVISOR     (1024*1024*1024)    /* Graph is in Gbits/s */

struct
{
    int Engine;         /* Engine number - for communicating with driver */
    //char *name;         /* Name to be used in Setup screen */
    //int mode;           /* TX/RX - incase of specific screens */
} DMAConfig[MAX_ENGS] =
{
    {0/*, LABEL1, TX_MODE*/ },
    {32/*, LABEL1, RX_MODE*/ },
    {1/*, LABEL2, TX_MODE*/ },
    {33/*, LABEL2, RX_MODE*/ }
};


jmethodID pci_callback;
jmethodID eng_callback;
jmethodID trn_callback;
jmethodID dma_callback;
jmethodID sws_callback;
jmethodID power_callback;
jmethodID log_callback;
jmethodID led_callback;

int statsfd=-1; 
int StartTest(int statsfd, int engine, int testmode, int maxSize);
int StopTest(int statsfd, int engine, int testmode, int maxSize);
int getErrorCount0();
int getErrorCount1();

JNIEXPORT void JNICALL Java_com_xilinx_gui_DriverInfoGen_init(JNIEnv *env, jclass cls)
{
    // Read the driver file
    if((statsfd = open(FILENAME, O_RDONLY)) < 0)
    {
        //printf("Failed to open statistics file %s\n", FILENAME);
        return;
    }
    pci_callback = env->GetMethodID(cls, "pciStateCallback", "([I)V");
    eng_callback = env->GetMethodID(cls, "engStateCallback", "([[I)V");
    trn_callback = env->GetMethodID(cls, "trnStatsCallback", "([F)V");
    dma_callback = env->GetMethodID(cls, "dmaStatsCallback", "([[F)V");
    sws_callback = env->GetMethodID(cls, "swsStatsCallback", "([[I)V");
    power_callback = env->GetMethodID(cls, "powerStatsCallback", "([I)V");
    log_callback = env->GetMethodID(cls, "showLogCallback", "(I)V");
    led_callback = env->GetMethodID(cls, "ledStatsCallback", "([I)V");
}

JNIEXPORT jint JNICALL Java_com_xilinx_gui_DriverInfoGen_flush(JNIEnv *env, jobject obj){
    close(statsfd);
}

JNIEXPORT jint JNICALL Java_com_xilinx_gui_DriverInfoGen_startTest(JNIEnv *env, jobject obj, jint engine, jint testmode, jint maxsize){  
        int tmode = ENABLE_LOOPBACK;
        if (testmode == 0) // loopback
           tmode = ENABLE_LOOPBACK;
        else if (testmode == 1) // checker
           tmode = ENABLE_PKTCHK;
        else if (testmode == 2) // generator
           tmode = ENABLE_PKTGEN; 
        else if (testmode == 3)
           tmode =  ENABLE_PKTCHK|ENABLE_PKTGEN;
	return StartTest(statsfd, engine, tmode, maxsize);
}

JNIEXPORT jint JNICALL Java_com_xilinx_gui_DriverInfoGen_stopTest(JNIEnv *env, jobject obj, jint engine, jint testmode, jint maxsize){
        int tmode = ENABLE_LOOPBACK;
        if (testmode == 0) // loopback
           tmode = ENABLE_LOOPBACK;
        else if (testmode == 1) // checker
           tmode = ENABLE_PKTCHK;
        else if (testmode == 2) // generator
           tmode = ENABLE_PKTGEN;
        else if (testmode == 3)
           tmode =  ENABLE_PKTCHK|ENABLE_PKTGEN;
        return StopTest(statsfd, engine, tmode, maxsize);
}

JNIEXPORT jint JNICALL Java_com_xilinx_gui_DriverInfoGen_get_1DMAStats(JNIEnv *env, jobject obj){
    int j,i;
    
    EngStatsArray es;
    DMAStatistics ds[MAX_STATS]; 	
    es.Count = MAX_STATS;
    es.engptr = ds;

    jfloat tmp[MAX_ENGS][4];

    if(ioctl(statsfd, IGET_DMA_STATISTICS, &es) != 0)
    {
       // printf("IGET_DMA_STATISTICS on engines failed\n");
        return -1;
    }
    for(j=0; j<es.Count; j++)
    {
        int k, eng;

        /* Driver engine number does not directly map to that of GUI */
        for(k=0; k<MAX_ENGS; k++)
        {
            if(DMAConfig[k].Engine == ds[j].Engine)
                break;
        }

        if(k >= MAX_ENGS) continue;
        eng = k;
	
        tmp[k][0] = ds[j].Engine;
        //printf("j: %d OLBR: %f LWT: %f\n", j, ds[j].LBR, ds[j].LWT);
        //printf("LBR: %f\n", ((double)(ds[j].LBR) * MULTIPLIER )/DIVISOR);
        tmp[k][1] = ((double)(ds[j].LBR) * MULTIPLIER )/DIVISOR;
        tmp[k][2] = ds[j].LAT;
        tmp[k][3] = ds[j].LWT; 
     }
     
     jfloatArray row= (jfloatArray)env->NewFloatArray(4);
     jobjectArray ret=env->NewObjectArray(MAX_ENGS, env->GetObjectClass(row), 0);

     for(i=0;i<MAX_ENGS;i++) {
    	row= (jfloatArray)env->NewFloatArray(4);
        //printf("-------------------\n");
        //printf("E: %f LBR: %f LAT: %f LWT: %f\n", tmp[i][0],tmp[i][1],tmp[i][2],tmp[i][3]);
 	//printf("-------------------\n");
    	env->SetFloatArrayRegion(row,0,4,tmp[i]);
    	env->SetObjectArrayElement(ret,i,row);
     }
     env->CallVoidMethod(obj, dma_callback, ret);
     return 0;	
}

JNIEXPORT jint JNICALL Java_com_xilinx_gui_DriverInfoGen_get_1TRNStats(JNIEnv *env, jobject obj){

    int j, i;
    TRNStatsArray tsa;
    TRNStatistics ts[8];

    tsa.Count = 8;
    tsa.trnptr = ts;

    jfloatArray jf;
    jf = env->NewFloatArray(2);
    jfloat tmp[2];

    if(ioctl(statsfd, IGET_TRN_STATISTICS, &tsa) != 0)
    {
        //printf("IGET_TRN_STATISTICS failed\n");
        return -1;
    }

    for(j=0; j<tsa.Count; j++)
    {
        //printf("Count after call %d", tsa.Count);
        tmp[0] = ((double)(ts[j].LTX) * MULTIPLIER)/DIVISOR;
        tmp[1] = ((double)(ts[j].LRX) * MULTIPLIER)/DIVISOR;
    }

    env->SetFloatArrayRegion(jf, 0, 2, tmp); 
    env->CallVoidMethod(obj, trn_callback, jf);
}

JNIEXPORT jint JNICALL Java_com_xilinx_gui_DriverInfoGen_get_1PowerStats(JNIEnv *env, jobject obj){
   PowerMonitorVal powerMonitor;
   if(ioctl(statsfd, IGET_PMVAL, &powerMonitor) != 0)
   {
        //printf("IGET_PMVAL failed\n");
        return -1;
   }
   jintArray ji;
   ji = env->NewIntArray(7);
   jint tmp[7];

   tmp[0] = powerMonitor.vcc;
   tmp[1] = powerMonitor.vccaux;
   tmp[2] = powerMonitor.mgt_avcc;
   tmp[3] = powerMonitor.vccbram;
   tmp[4] = powerMonitor.die_temp;
   tmp[5] = getErrorCount0();
   tmp[6] = getErrorCount1(); 
   //printf("vcc: %d vccaux: %d temp: %d\n", tmp[0], tmp[1], tmp[4]);
   env->SetIntArrayRegion(ji, 0, 7, tmp); 
   env->CallVoidMethod(obj, power_callback, ji);
   return 0;
}


JNIEXPORT jint JNICALL Java_com_xilinx_gui_DriverInfoGen_get_1SWStats (JNIEnv *env, jobject obj){

    int j, i;
    SWStatsArray ssa;
    SWStatistics ss[32];	

    ssa.Count = 32;
    ssa.swptr = ss;

    jint tmp[32][2];

    if(ioctl(statsfd, IGET_SW_STATISTICS, &ssa) != 0)
    {
        //printf("IGET_SW_STATISTICS failed\n");
        return -1;
    }	
    for(j=0; j<ssa.Count; j++)
    {
        int k, eng;

        /* Driver engine number does not directly map to that of GUI */
        for(k=0; k<MAX_ENGS; k++)
        {
            if(DMAConfig[k].Engine == ss[j].Engine)
                break;
        }

        if(k >= MAX_ENGS) continue;
        eng = k;
        tmp[j][0] = ss[j].Engine;
        tmp[j][1] = ss[j].LBR;
    }
}


JNIEXPORT jint JNICALL Java_com_xilinx_gui_DriverInfoGen_get_1EngineState(JNIEnv *env, jobject obj)
{
    if (statsfd == -1)
        return -2;

    int i;
    EngState EngInfo;
    int state;
  	
    jint tmp[MAX_ENGS][14]; 		
    /* Get the state of all the engines */
    for(i=0; i<MAX_ENGS; i++)
    {
        EngInfo.Engine = DMAConfig[i].Engine;
        if(ioctl(statsfd, IGET_ENG_STATE, &EngInfo) != 0)
        {
            //printf("IGET_ENG_STATE on Engine %d failed\n", EngInfo.Engine);
            for (int k = 0; k < 14; ++k)
               tmp[i][k] = 0;
        }
        else{
	    unsigned int testmode;
            tmp[i][0] = EngInfo.Engine;
            tmp[i][1] = EngInfo.BDs;
            tmp[i][2] = EngInfo.Buffers;
            tmp[i][3] = EngInfo.MinPktSize;
            tmp[i][4] = EngInfo.MaxPktSize;
            tmp[i][5] = EngInfo.BDerrs;
            tmp[i][6] = EngInfo.BDSerrs;
            tmp[i][7] = EngInfo.DataMismatch;
            tmp[i][8] = EngInfo.IntEnab;
            tmp[i][9] = EngInfo.TestMode;    
            // These additional ones are for EngStats structure
            testmode = EngInfo.TestMode;
            state = (testmode & (TEST_START|TEST_IN_PROGRESS)) ? 1 : -1;
            tmp[i][10] = state; // EngStats[i].TXEnab
            state = (testmode & ENABLE_LOOPBACK)? 1 : -1;
            tmp[i][11] = state; // EngStats[i].LBEnab
            state = (testmode & ENABLE_PKTGEN)? 1 : -1;
            tmp[i][12] = state; // EngStats[i].PktGenEnab
            state = (testmode & ENABLE_PKTCHK)? 1 : -1;
            tmp[i][13] = state; //EngStats[i].PktChkEnab
        }
    }
   	
    jintArray row= (jintArray)env->NewIntArray(14);
    jobjectArray ret=env->NewObjectArray(MAX_ENGS, env->GetObjectClass(row), 0);

    for(i=0;i<MAX_ENGS;i++) {
    	row= (jintArray)env->NewIntArray(14);
    	env->SetIntArrayRegion(row,0,14,tmp[i]);
    	env->SetObjectArrayElement(ret,i,row);
    }
    env->CallVoidMethod(obj, eng_callback, ret);
    return 0; 
}

JNIEXPORT jint JNICALL Java_com_xilinx_gui_DriverInfoGen_get_1PCIstate(JNIEnv *env, jobject obj)
{
     if (statsfd == -1)
        return -2;

     PCIState PCIInfo; 	
     // make ioctl call
     if(ioctl(statsfd, IGET_PCI_STATE, &PCIInfo) != 0)
     {
        //printf("IGET_PCI_STATE failed\n");
        return -1;
     }
     jintArray ji;
     ji = env->NewIntArray(16);
     jint tmp[16];

     tmp[0] = PCIInfo.Version;
     tmp[1] = PCIInfo.LinkState;
     tmp[2] = PCIInfo.LinkSpeed;
     tmp[3] = PCIInfo.LinkWidth;
     tmp[4] = PCIInfo.VendorId;
     tmp[5] = PCIInfo.DeviceId;
     tmp[6] = PCIInfo.IntMode;
     tmp[7] = PCIInfo.MPS;
     tmp[8] = PCIInfo.MRRS;
     tmp[9] = PCIInfo.InitFCCplD;
     tmp[10] = PCIInfo.InitFCCplH;
     tmp[11] = PCIInfo.InitFCNPD;
     tmp[12] = PCIInfo.InitFCNPH;
     tmp[13] = PCIInfo.InitFCPD;
     tmp[14] = PCIInfo.InitFCPH; 	
     tmp[15] = PCIInfo.LinkUpCap;

	
     env->SetIntArrayRegion(ji, 0, 16, tmp); 
     env->CallVoidMethod(obj, pci_callback, ji);
     return 0;
}

JNIEXPORT jint JNICALL Java_com_xilinx_gui_DriverInfoGen_setLinkSpeed(JNIEnv *env, jobject jobj, jint speed){
    DirectLinkChg dLink;

    dLink.LinkSpeed = 1;   // default
    dLink.LinkWidth = 1;   // default

    dLink.LinkSpeed = speed;

    if(ioctl(statsfd, ISET_PCI_LINKSPEED, &dLink) < 0)
    {
        //printf("ISET_PCI_LINKSPEED failed\n");
        return -1;
    }
    return 0;
}

JNIEXPORT jint JNICALL Java_com_xilinx_gui_DriverInfoGen_setLinkWidth(JNIEnv *env, jobject jobj, jint width){

    DirectLinkChg dLink;

    dLink.LinkSpeed = 1;   // default
    dLink.LinkWidth = 1;   // default

    dLink.LinkWidth = width;

    if(ioctl(statsfd, ISET_PCI_LINKWIDTH, &dLink) < 0)
    {
        //printf("ISET_PCI_LINKWIDTH failed\n");
        return -1;
    }
}

JNIEXPORT jint JNICALL Java_com_xilinx_gui_DriverInfoGen_LedStats(JNIEnv *env, jobject obj){
     LedStats ledStats;
     if(ioctl(statsfd, IGET_LED_STATISTICS, &ledStats) < 0)
     {
        //printf("ISET_PCI_LINKWIDTH failed\n");
        return -1;
     }	

     jintArray ji;
     ji = env->NewIntArray(3);
     jint tmp[3];
     
     tmp[0] = ledStats.DdrCalib;
     tmp[1] = ledStats.Phy0;
     tmp[2] = ledStats.Phy1; 
 
     env->SetIntArrayRegion(ji, 0, 3, tmp); 
     env->CallVoidMethod(obj, led_callback, ji);
     return 0;
}
