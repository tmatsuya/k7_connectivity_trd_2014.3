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
 * @file ThermoPlot.java 
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

package com.xilinx.kintex7;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Font;
import java.awt.Paint;
import javax.swing.BorderFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.ThermometerPlot;
import org.jfree.chart.title.TextTitle;
import org.jfree.data.general.DefaultValueDataset;

public class ThermoPlot {
    
    JFreeChart chart;
    ThermometerPlot plot;
    DefaultValueDataset dset;
    
    public ThermoPlot(){
        createPlot();
    }
    
    public void update(int val){
        dset.setValue(val);
    }
    
    public ChartPanel getChart(){
        ChartPanel chartpanel = new ChartPanel(chart);
        chartpanel.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createTitledBorder(""),
                        BorderFactory.createRaisedBevelBorder()));
        return chartpanel;
    }
    
    public void createPlot(){
        dset = new DefaultValueDataset(50);
        plot = new ThermometerPlot(dset);
        plot.setRange(0, 125);
        //plot.setFollowDataInSubranges(true);
        //plot.setUseSubrangePaint(false);
        plot.setThermometerStroke(new BasicStroke(2.0f));
        plot.setSubrange(ThermometerPlot.NORMAL, 0, 60);
        plot.setSubrange(ThermometerPlot.WARNING, 60, 85);
        plot.setSubrange(ThermometerPlot.CRITICAL, 86, 125);
        
        plot.setThermometerPaint(Color.BLACK);
        plot.setOutlineVisible(false);
        plot.setBackgroundAlpha(0);
        plot.setMercuryPaint(Color.ORANGE);
        plot.setUnits(ThermometerPlot.UNITS_NONE);
        chart = new JFreeChart("", plot);
        TextTitle ttitle = new TextTitle("Temperature (\u2103)", new Font("Temperature (\u2103)", Font.BOLD, 15));
        ttitle.setPaint(Color.WHITE);
        chart.setTitle(ttitle);
        chart.setBackgroundPaint(new Color(133, 133, 133));
        //chart.setTitle("");
    }
}
