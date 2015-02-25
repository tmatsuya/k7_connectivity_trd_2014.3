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
 * @file DMATrendChart.java
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
import java.awt.Stroke;
import java.text.NumberFormat;
import javax.swing.BorderFactory;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.ValueAxis;
import org.jfree.chart.labels.StandardXYItemLabelGenerator;
import org.jfree.chart.labels.XYItemLabelGenerator;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.xy.XYLineAndShapeRenderer;
import org.jfree.data.time.Millisecond;
import org.jfree.data.time.Second;
import org.jfree.data.time.TimeSeries;
import org.jfree.data.time.TimeSeriesCollection;

public class DMATrendChart {
    /** The time series data. */
    private TimeSeries series1, series2, series3;
    JFreeChart chart;
    int width, height;
    Color bg;
    TimeSeriesCollection dataset;
    
    String title;
    String[] seriesLabels;
    
    public DMATrendChart(String title, int w, int h, Color bg, String[] labels){
        width = w;
        height = h;
        this.bg = bg;
        this.title = title;
        seriesLabels = labels;
        makeChart();
    }
    
    public ChartPanel getChart(String title){
        ChartPanel chartpanel = new ChartPanel(chart);
        chartpanel.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createTitledBorder(title),
                        BorderFactory.createRaisedBevelBorder()));
        return chartpanel;
    }
    
    public void makeChart(){
        series1 = new TimeSeries(seriesLabels[0]);
        series2 = new TimeSeries(seriesLabels[1]);
        series3 = new TimeSeries(seriesLabels[2]);
        dataset = new TimeSeriesCollection();
        dataset.addSeries(series1);
        dataset.addSeries(series2);
        dataset.addSeries(series3);
        chart = ChartFactory.createTimeSeriesChart(
            title, 
            "Time", 
            "Throughput(Gbps)",
            dataset, 
            true, 
            true, 
            false
        );
        chart.setBackgroundPaint(bg);
        final XYPlot plot = chart.getXYPlot();
        ValueAxis axis = plot.getDomainAxis();
        axis.setAutoRange(true);
        axis.setFixedAutoRange(30000.0);  // 60 seconds
        axis = plot.getRangeAxis();
        axis.setRange(0.0, 30.0); 
        
        XYLineAndShapeRenderer renderer =
            new XYLineAndShapeRenderer(true, true);
        
        renderer.setBaseShapesVisible(true);
        renderer.setBaseShapesFilled(true);
        
        // set the renderer's stroke
        Stroke stroke = new BasicStroke(
            3f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_BEVEL);
        renderer.setBaseOutlineStroke(stroke);
        
        //StandardXYToolTipGenerator tt = new StandardXYToolTipGenerator("{1}", null, null);
        //renderer.setSeriesToolTipGenerator(0, tt);
         // label the points
        NumberFormat format = NumberFormat.getNumberInstance();
        format.setMaximumFractionDigits(2);
        XYItemLabelGenerator generator =
            new StandardXYItemLabelGenerator(
                StandardXYItemLabelGenerator.DEFAULT_ITEM_LABEL_FORMAT,
                format, format);
        renderer.setBaseItemLabelGenerator(generator);
        renderer.setBaseItemLabelsVisible(true);
        
        plot.setRenderer(renderer);
        
        final XYPlot plot1 = chart.getXYPlot();
        ValueAxis axis1 = plot1.getDomainAxis();
        axis1.setAutoRange(true);
        axis1.setFixedAutoRange(30000.0);  // 60 seconds
        axis1 = plot.getRangeAxis();
        axis1.setRange(0.0, 30.0);
        plot1.setRenderer(renderer);
        
        final XYPlot plot2 = chart.getXYPlot();
        ValueAxis axis2 = plot1.getDomainAxis();
        axis2.setAutoRange(true);
        axis2.setFixedAutoRange(30000.0);  // 60 seconds
        axis2 = plot.getRangeAxis();
        axis2.setRange(0.0, 30.0);
        plot2.setRenderer(renderer);
    }
    
    public void updateChart(double val1, double val2, double val3){
        series1.add(new Second(), val1);
        series2.add(new Second(), val2);
        series3.add(new Second(), val3);
    }
}
