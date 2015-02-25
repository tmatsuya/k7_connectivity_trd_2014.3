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
 * @file PCIState.java 
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
/*
 * PCIState Class defines the structure similar to the PCIState in the driver.
 */

public class PCIState{
    int Version;       /**< Hardware design version info */
    int LinkState;     /**< Link State - up or down */
    public int LinkSpeed;     /**< Link Speed */
    public int LinkWidth;     /**< Link Width */
    int VendorId;      /**< Vendor ID */
    int DeviceId;      /**< Device ID */
    int IntMode;       /**< Legacy or MSI interrupts */
    int MPS;           /**< Max Payload Size */
    int MRRS;          /**< Max Read Request Size */
    // #if defined(V6_TRD) || defined(K7_TRD)
    int InitFCCplD;    /**< Initial FC Credits for Completion Data */
    int InitFCCplH;    /**< Initial FC Credits for Completion Header */
    int InitFCNPD;     /**< Initial FC Credits for Non-Posted Data */
    int InitFCNPH;     /**< Initial FC Credits for Non-Posted Data */
    int InitFCPD;      /**< Initial FC Credits for Posted Data */
    int InitFCPH;      /**< Initial FC Credits for Posted Data */
    public int LinkUpCap;

    public PCIState(){

    }

    public String getVersionInfo(){
         String ver = ""; 
         int major = (Version & 0x000000F0) >> 4;
         int minor = (Version & 0x0000000F);
         ver = "Kintex-7 Connectivity TRD v"+major+"."+minor;
        
         return ver;
    }
    
    public void setPCIState(int[] data)
    {
       	Version = data[0];
        LinkState = data[1];
        LinkSpeed = data[2];
        LinkWidth = data[3];
        VendorId = data[4];
        DeviceId = data[5];
        IntMode = data[6];
        MPS = data[7];
        MRRS = data[8];
        InitFCCplD =  data[9];
        InitFCCplH = data[10];
        InitFCNPD = data[11];
        InitFCNPH = data[12];
        InitFCPD = data[13];
	InitFCPH = data[14]; 
        LinkUpCap = data[15];
    }
   
    public Object[][] getPCIData(){
        String lst = "Up";
        String lsp = "2.5 Gbps";
        String vid = "";
        String did = "";
        String intp = "";
        
        if (LinkState == 1)
            lst = "Up";
        else
            lst = "Down";
        if (LinkSpeed == 1)
            lsp = "2.5 Gbps";
        else
            lsp = "5 Gbps";
        if (IntMode == 0)
            intp = "None";
        else if (IntMode == 1)
            intp = "Legacy";
        else if (IntMode == 2)
            intp = "MSI";
        else if (IntMode == 3)
            intp = "MSI-X";
        vid = "0x"+Integer.toHexString(VendorId);
        did = "0x"+Integer.toHexString(DeviceId);
        String lw = "x"+LinkWidth;
        Object [][] pcie = {
            {"Link State", lst},
            {"Link Speed", lsp},
            {"Link Width", lw},
            {"Interrupts", intp},
            {"Vendor ID", vid},
            {"Device ID", did},
            {"MPS (bytes)", MPS},
            {"MRRS (bytes)", MRRS}    
        };
        return pcie;
    }
    
    public Object[][] getHostedData(){
        Object[][] hostData = {
            {"Posted Header", InitFCPH},
            {"Non-Posted Header", InitFCNPH},
            {"Completion Header", InitFCCplH},
            {"",""},
            {"",""},
            {"Posted Data", InitFCPD},
            {"Non-Posted Data", InitFCNPD},
            {"Completion Data", InitFCCplD}           
        };
        return hostData;
    }
}
