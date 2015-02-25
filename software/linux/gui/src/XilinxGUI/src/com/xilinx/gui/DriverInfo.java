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
 * @file DriverInfo.java 
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

import com.xilinx.kintex7.LandingPage;
import com.xilinx.kintex7.MainScreen;

public class DriverInfo{
    public static int ENABLE_LOOPBACK = 0;
    public static int CHECKER = 1;
    public static int GENERATOR = 2;
    public static int CHECKER_GEN = 3;
       
    
    DriverInfoRaw diraw;
    DriverInfoGen digen;
    DriverInfoGenDV digendv;
    DriverInfoRawDV dirawdv;
    int mode;
    
    
    public DriverInfo(){
    }

    public void init(int mode){
        this.mode = mode;
        if (mode == LandingPage.PERFORMANCE_MODE_RAW)
        {
            if (diraw == null)
                diraw = new DriverInfoRaw();
            DriverInfoRaw.initlibs();
        }else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK){
            if (digen == null)
                digen = new DriverInfoGen();
            DriverInfoGen.initlibs();
        }else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV){
            if (digendv == null)
                digendv = new DriverInfoGenDV();
            DriverInfoGenDV.initlibs();
        }else if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV){
            if (dirawdv == null)
                dirawdv = new DriverInfoRawDV();
            DriverInfoRawDV.initlibs();
        }else if (mode == LandingPage.APPLICATION_MODE){
            if (digen == null)
                digen = new DriverInfoGen();
            DriverInfoGen.initlibs();
        }
        else if (mode == LandingPage.APPLICATION_MODE_P2P){
            if (digen == null)
                digen = new DriverInfoGen();
            DriverInfoGen.initlibs();
        }
    }
    
    protected void finalize(){
        diraw = null;
        digen = null;
        digendv = null;
        dirawdv = null;
        System.gc();
    }
    
    public int get_PCIstate(){
        if (mode == LandingPage.PERFORMANCE_MODE_RAW)
           return diraw.get_PCIstate();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK)
           return digen.get_PCIstate();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
           return digendv.get_PCIstate();
        else if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
           return dirawdv.get_PCIstate();
        else if (mode == LandingPage.APPLICATION_MODE)
           return digen.get_PCIstate();
        else if (mode == LandingPage.APPLICATION_MODE_P2P)
           return digen.get_PCIstate();
        return -1;
    }
    
    public int get_EngineState(){
        if (mode == LandingPage.PERFORMANCE_MODE_RAW)
           return diraw.get_EngineState();
        else if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
           return dirawdv.get_EngineState();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
           return digendv.get_EngineState();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK)
           return digen.get_EngineState();
        else if (mode == LandingPage.APPLICATION_MODE)
           return digen.get_EngineState();
        else if (mode == LandingPage.APPLICATION_MODE_P2P)
           return digen.get_EngineState();
        return -1;
    }
    
    public int get_DMAStats(){
        if (mode == LandingPage.PERFORMANCE_MODE_RAW)
           return diraw.get_DMAStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
           return dirawdv.get_DMAStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
           return digendv.get_DMAStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK)
           return digen.get_DMAStats();
        else if (mode == LandingPage.APPLICATION_MODE)
           return digen.get_DMAStats();
        else if (mode == LandingPage.APPLICATION_MODE_P2P)
           return digen.get_DMAStats();
        return -1;
    }
    
    public int get_TRNStats(){
        if (mode == LandingPage.PERFORMANCE_MODE_RAW)
           return diraw.get_TRNStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
           return dirawdv.get_TRNStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
           return digendv.get_TRNStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK)
           return digen.get_TRNStats();
        else if (mode == LandingPage.APPLICATION_MODE)
           return digen.get_TRNStats();
        else if (mode == LandingPage.APPLICATION_MODE_P2P)
           return digen.get_TRNStats();
        return -1;
    }
    
    public int get_SWStats(){
        if (mode == LandingPage.PERFORMANCE_MODE_RAW)
           return diraw.get_SWStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
           return dirawdv.get_SWStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
           return digendv.get_SWStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK)
           return digen.get_SWStats();
        else if (mode == LandingPage.APPLICATION_MODE)
           return digen.get_SWStats();
        else if (mode == LandingPage.APPLICATION_MODE_P2P)
           return digen.get_SWStats();
       return -1;
    }
    
    public int get_PowerStats(){
        if (mode == LandingPage.PERFORMANCE_MODE_RAW)
           return diraw.get_PowerStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
           return dirawdv.get_PowerStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
           return digendv.get_PowerStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK)
           return digen.get_PowerStats();
        else if (mode == LandingPage.APPLICATION_MODE)
           return digen.get_PowerStats();
        else if (mode == LandingPage.APPLICATION_MODE_P2P)
           return digen.get_PowerStats();
        return -1;
    }
    
    public int startTest(int engine, int testmode, int maxsize){
        if (mode == LandingPage.PERFORMANCE_MODE_RAW)
           return diraw.startTest(engine, testmode, maxsize);
        else if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
           return dirawdv.startTest(engine, testmode, maxsize);
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
           return digendv.startTest(engine, testmode, maxsize);
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK)
           return digen.startTest(engine, testmode, maxsize);
        return -1;
    }
    
    public int stopTest(int engine, int testmode, int maxsize){
        if (mode == LandingPage.PERFORMANCE_MODE_RAW)
           return diraw.stopTest(engine, testmode, maxsize);
        else if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
           return dirawdv.stopTest(engine, testmode, maxsize);
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
           return digendv.stopTest(engine, testmode, maxsize);
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK)
           return digen.stopTest(engine, testmode, maxsize);
        return -1;
    }
    
    public void flush(){
        if (mode == LandingPage.PERFORMANCE_MODE_RAW)
           diraw.flush();
        else if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
           dirawdv.flush();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
           digendv.flush();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK)
           digen.flush();
        else if (mode == LandingPage.APPLICATION_MODE)
           digen.flush();
        else if (mode == LandingPage.APPLICATION_MODE_P2P)
           digen.flush();
    }
    
    public PCIState getPCIInfo(){
       
       if (mode == LandingPage.PERFORMANCE_MODE_RAW)
           return diraw.getPCIInfo();
       else if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
           return dirawdv.getPCIInfo();
       else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
           return digendv.getPCIInfo();
       else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK)
           return digen.getPCIInfo();
       else if (mode == LandingPage.APPLICATION_MODE)
           return digen.getPCIInfo();
       else if (mode == LandingPage.APPLICATION_MODE_P2P)
           return digen.getPCIInfo();
       return null;
    }
 
    public EngState[] getEngState(){
       if (mode == LandingPage.PERFORMANCE_MODE_RAW)
           return diraw.getEngState();
       else if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
           return dirawdv.getEngState();
       else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
           return digendv.getEngState();
       else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK)
           return digen.getEngState();
       else if (mode == LandingPage.APPLICATION_MODE)
           return digen.getEngState();
       else if (mode == LandingPage.APPLICATION_MODE_P2P)
           return digen.getEngState();
       return null;
    }
    
    public DMAStats[] getDMAStats(){
        if (mode == LandingPage.PERFORMANCE_MODE_RAW)
           return diraw.getDMAStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
           return dirawdv.getDMAStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
           return digendv.getDMAStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK)
           return digen.getDMAStats();
        else if (mode == LandingPage.APPLICATION_MODE)
           return digen.getDMAStats();
        else if (mode == LandingPage.APPLICATION_MODE_P2P)
           return digen.getDMAStats();
       return null;
    }
    
    public TRNStats getTRNStats(){
        if (mode == LandingPage.PERFORMANCE_MODE_RAW)
           return diraw.getTRNStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
           return dirawdv.getTRNStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
           return digendv.getTRNStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK)
           return digen.getTRNStats();
        else if (mode == LandingPage.APPLICATION_MODE)
           return digen.getTRNStats();
        else if (mode == LandingPage.APPLICATION_MODE_P2P)
           return digen.getTRNStats();
        return null;
    }
    
    public PowerStats getPowerStats(){
        if (mode == LandingPage.PERFORMANCE_MODE_RAW)
           return diraw.getPowerStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
           return dirawdv.getPowerStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
           return digendv.getPowerStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK)
           return digen.getPowerStats();
        else if (mode == LandingPage.APPLICATION_MODE)
           return digen.getPowerStats();
         else if (mode == LandingPage.APPLICATION_MODE_P2P)
           return digen.getPowerStats();
       return null;
    }
    
    public int setLinkSpeed(int speed){
        if (mode == LandingPage.PERFORMANCE_MODE_RAW)
           return diraw.setLinkSpeed(speed);
        else if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
           return dirawdv.setLinkSpeed(speed);
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
           return digendv.setLinkSpeed(speed);
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK)
           return digen.setLinkSpeed(speed);
        else if (mode == LandingPage.APPLICATION_MODE)
           return digen.setLinkSpeed(speed);
        else if (mode == LandingPage.APPLICATION_MODE_P2P)
           return digen.setLinkSpeed(speed);
       return -1;
    }
    
    public int setLinkWidth(int width){
        if (mode == LandingPage.PERFORMANCE_MODE_RAW)
           return diraw.setLinkWidth(width);
        else if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
           return dirawdv.setLinkWidth(width);
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
           return digendv.setLinkWidth(width);
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK)
           return digen.setLinkWidth(width);
        else if (mode == LandingPage.APPLICATION_MODE)
           return digen.setLinkWidth(width);
        else if (mode == LandingPage.APPLICATION_MODE_P2P)
           return digen.setLinkWidth(width);
       return -1;
    }
    
    public int get_LedStats(){
        if (mode == LandingPage.PERFORMANCE_MODE_RAW)
           return diraw.LedStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
           return dirawdv.LedStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
           return digendv.LedStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK)
           return digen.LedStats();
        else if (mode == LandingPage.APPLICATION_MODE)
           return digen.LedStats();
        else if (mode == LandingPage.APPLICATION_MODE_P2P)
           return digen.LedStats();
       return -1;
    }
    
    public LedStats getLedStats(){
        if (mode == LandingPage.PERFORMANCE_MODE_RAW)
           return diraw.getLedStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
           return dirawdv.getLedStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
           return digendv.getLedStats();
        else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK)
           return digen.getLedStats();
        else if (mode == LandingPage.APPLICATION_MODE)
           return digen.getLedStats();
        else if (mode == LandingPage.APPLICATION_MODE_P2P)
           return digen.getLedStats();
       return null;
    }
}
