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
 * @file DMABarChart.java 
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

import java.awt.Color;
import java.awt.Font;
import java.awt.GradientPaint;
import java.text.DecimalFormat;
import javax.swing.BorderFactory;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.CategoryAxis;
import org.jfree.chart.axis.ValueAxis;
import org.jfree.chart.labels.StandardCategoryToolTipGenerator;
import org.jfree.chart.plot.CategoryPlot;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.renderer.category.BarRenderer;
import org.jfree.chart.title.TextTitle;
import org.jfree.data.category.CategoryDataset;
import org.jfree.data.category.DefaultCategoryDataset;

public class DMABarChart {
    JFreeChart chart;
    Color bg;
    String title;
    String[] seriesLabels;
    DefaultCategoryDataset dataset;
    int index;
    int mark;
    int reverseMark;
    
    public DMABarChart(String title, Color bg, String[] labels){
        
        this.bg = bg;
        this.title = title;
        seriesLabels = labels;
        index = 1;
        makeChart();
    }
    
    public ChartPanel getChart(String title){
        ChartPanel chartpanel = new ChartPanel(chart);
        chartpanel.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createTitledBorder(title),
                        BorderFactory.createRaisedBevelBorder()));
        return chartpanel;
    }
    
    private void makeChart(){
        dataset = new DefaultCategoryDataset();
        chart = ChartFactory.createBarChart(
            "",
            "Time Interval",
            "Throughput (Gbps)",
            dataset,
            PlotOrientation.VERTICAL,
            true,
            true,
            false
        );
        chart.setBackgroundPaint(bg);
        TextTitle ttitle = new TextTitle(title, new Font(title, Font.BOLD, 15));
        ttitle.setPaint(Color.WHITE);
        chart.setTitle(ttitle);
                
        CategoryPlot plot = chart.getCategoryPlot();
        BarRenderer renderer = (BarRenderer)plot.getRenderer();
        renderer.setDrawBarOutline(false);
        ValueAxis axis = plot.getRangeAxis();
        axis.setUpperBound(30.0);
        axis.setLowerBound(0.0);
        axis.setTickLabelPaint(new Color(185, 185, 185));
        axis.setLabelPaint(new Color(185, 185, 185));
        
        CategoryAxis caxis = plot.getDomainAxis();
        caxis.setTickLabelPaint(new Color(185, 185, 185));
        caxis.setLabelPaint(new Color(185, 185, 185));
        
        renderer.setItemMargin(0);
        renderer.setSeriesPaint(0, new Color(0, 0, 0x80));
        renderer.setSeriesPaint(1, new Color(0, 0x80, 0xff));
        renderer.setSeriesPaint(2, new Color(0xa2, 0x45, 0x73));
        renderer.setBaseToolTipGenerator(new StandardCategoryToolTipGenerator("{0}:{2}", new DecimalFormat("0.000")));
        //renderer.setMaximumBarWidth(0.05);
        addDummy();
    }
    
    public void updateChart(double val1, double val2, double val3){
        String name = "";
        if (mark > 0){
            name = ""+reverseMark;
            dataset.addValue(val1, seriesLabels[0], name);
            dataset.addValue(val2, seriesLabels[1], name);
            dataset.addValue(val3, seriesLabels[2], name);
            mark--;
            reverseMark++;
        }else{
            if (dataset.getColumnCount() == 9){
                dataset.removeColumn(0);
            }
            name = ""+index;
            dataset.addValue(val1, seriesLabels[0], name);
            dataset.addValue(val2, seriesLabels[1], name);
            dataset.addValue(val3, seriesLabels[2], name); // PCI reads/write
            index++;
        }
    }
    
    private void addDummy(){
        for (int i = 0; i < 9; ++i){
            String name = ""+index;
            dataset.addValue(-1, seriesLabels[0], name);
            dataset.addValue(-1, seriesLabels[1], name);
            dataset.addValue(-1, seriesLabels[2], name); // PCI reads/write
            index++;
        }
        mark = 9;
        reverseMark = 1;
    }
    
    public void reset(){
        dataset.clear();
        index = 1;
        addDummy();
    }
}
