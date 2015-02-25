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
 * @file PowerDial.java 
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
import java.awt.GradientPaint;
import javax.swing.BorderFactory;
import org.jfree.chart.*;
import org.jfree.chart.plot.DialShape;
import org.jfree.chart.plot.MeterInterval;
import org.jfree.chart.plot.MeterPlot;
import org.jfree.chart.title.LegendTitle;
import org.jfree.data.Range;
import org.jfree.data.general.DefaultValueDataset;

public class PowerDial {
    JFreeChart chart;
    MeterPlot plot;
    DefaultValueDataset dset;
    int width, height;
    Color bg;
    
    public PowerDial(int w, int h, Color bg){
        width = w;
        height = h;
        this.bg = bg;
        createDial();
    }
    
    public ChartPanel getChart(String title){
        ChartPanel chartpanel = new ChartPanel(chart);
        chartpanel.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createTitledBorder(title),
                        BorderFactory.createRaisedBevelBorder()));
        return chartpanel;
    }
    
    public void update(int val){
        dset.setValue(val);
    }
    
    public void createDial(){
        plot = new MeterPlot();
        dset = new DefaultValueDataset(0);
        plot.setUnits("Watts");
        plot.setRange(new Range(1, 10));
        plot.addInterval(new MeterInterval("Acceptable", new Range(1.0, 6.0),
                          Color.lightGray, new BasicStroke(2.0f),
                          Color.GREEN));
        plot.addInterval(new MeterInterval("Warning", new Range(6.0, 8.0),
                          Color.lightGray, new BasicStroke(2.0f),
                          Color.YELLOW));
        plot.addInterval(new MeterInterval("Dangerous", new Range(8.0, 10.0),
                          Color.lightGray, new BasicStroke(2.0f),
                          Color.RED));
        
        //sets different marks
        for (int i = 0; i < 10; i+=1) {
            if (i == 0)
               plot.addInterval(new MeterInterval("", new Range(1, 1), Color.lightGray, new BasicStroke(2.0f), null));
            else
                plot.addInterval(new MeterInterval("", new Range(i, i), Color.lightGray, new BasicStroke(2.0f), null));
        }
        plot.setNeedlePaint(Color.darkGray);
        plot.setDialBackgroundPaint(Color.white);
        plot.setDialOutlinePaint(Color.gray);
        plot.setDialShape(DialShape.PIE);
        plot.setMeterAngle(180);
        plot.setTickLabelsVisible(true);
        plot.setTickLabelFont(new Font("Dialog", Font.BOLD, 10));
        plot.setTickLabelPaint(Color.DARK_GRAY);
        plot.setTickSize(10.0);
        plot.setTickPaint(Color.lightGray);
        plot.setValuePaint(Color.BLACK);
        plot.setDataset(dset);
        
        LegendItemCollection legendItemsOld = plot.getLegendItems();
        final LegendItemCollection legendItemsNew = new LegendItemCollection();

        for(int i = 0; i < 3; i++){
            LegendItem item = legendItemsOld.get(i);
            item.setLabelPaint(Color.WHITE);
            legendItemsNew.add(item);
        }
        
        LegendItemSource source = new LegendItemSource() {        
            LegendItemCollection lic = new LegendItemCollection();
            {lic.addAll(legendItemsNew);}
            @Override
            public LegendItemCollection getLegendItems() {
                return lic;
            }
        };

        chart = new JFreeChart(plot);
        chart.addLegend(new LegendTitle(source));
        chart.removeLegend();
        chart.setTitle("");
        //chart.setBackgroundPaint(new GradientPaint(0,0,new Color(139,137,137),0,height,Color.BLUE ));
        //
        chart.getTitle().setPaint(Color.white);
        plot.setValueFont(new Font("Dialog", Font.BOLD, 14));
        //chartpanel = new ChartPanel(chart);
    }
}
