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
 * @file DriverInfoRawDV.java 
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

package com.xilinx.gui;

import com.xilinx.kintex7.MainScreen;

public class DriverInfoRawDV {
    public static int ENABLE_LOOPBACK = 0;
    public static int CHECKER = 1;
    public static int GENERATOR = 2;
    public static int CHECKER_GEN = 3;
    
    // Native method declaration
    static native void init();
    public native int flush();
    public native int get_PCIstate();
    public native int get_EngineState();
    public native int get_DMAStats();
    public native int get_TRNStats();
    public native int get_SWStats();
    public native int get_PowerStats();
    public native int startTest(int engine, int testmode, int maxsize);
    public native int stopTest(int engine, int testmode, int maxsize);
    public native int setLinkSpeed(int speed);
    public native int setLinkWidth(int width);
    public native int LedStats();
            
    private void pciStateCallback(int[] response){
        pciState.setPCIState(response);
    } 

    private void engStateCallback(int[][] eng){
        engState[0] = new EngState();
        engState[0].setEngState(eng[0]);
        engState[1] = new EngState();
        engState[1].setEngState(eng[1]);
        engState[2] = new EngState();
        engState[2].setEngState(eng[2]);
        engState[3] = new EngState();
        engState[3].setEngState(eng[3]);
    }

    private void dmaStatsCallback(float [][] stats){
        dmaStats[0] = new DMAStats();
        dmaStats[0].setDMAStats(stats[0]);
        dmaStats[1] = new DMAStats();
        dmaStats[1].setDMAStats(stats[1]);
        dmaStats[2] = new DMAStats();
        dmaStats[2].setDMAStats(stats[2]);
        dmaStats[3] = new DMAStats();
        dmaStats[3].setDMAStats(stats[3]);
    }

    private void trnStatsCallback(float[] stats){
        trnStats.setTRNStats(stats);
    }

    private void swsStatsCallback(int[][] stats){
    }
    
    private void powerStatsCallback(int[] stats){
        powerStats.setStats(stats);
    }
       
    private void showLogCallback(int log){
        System.out.println("Got back into Java: "+log);
    }
    
    private void ledStatsCallback(int[] res){
        ledStats.ddrCalib = res[0];
        ledStats.phy0 = res[1];
        ledStats.phy1 = res[2];
    }
    
    public DriverInfoRawDV(){
        pciState = new PCIState();
        engState = new EngState[4];
        dmaStats = new DMAStats[4];
        trnStats = new TRNStats();
        powerStats = new PowerStats();
        ledStats = new LedStats();
    }

    public static void initlibs(){
        System.loadLibrary("xilinxlibrawdv");
        init();
    }
    
    public PCIState getPCIInfo(){
       return pciState;
    }
 
    public EngState[] getEngState(){
       return engState;
    }
    
    public DMAStats[] getDMAStats(){
        return dmaStats;
    }
    
    public TRNStats getTRNStats(){
        return trnStats;
    }
    
    public PowerStats getPowerStats(){
        return powerStats;
    }
    
    public LedStats getLedStats(){
        return ledStats;
    }
    
    private PCIState pciState;
    private EngState[] engState;
    private DMAStats[] dmaStats;
    private TRNStats trnStats;
    private PowerStats powerStats;
    private LedStats ledStats;
}
