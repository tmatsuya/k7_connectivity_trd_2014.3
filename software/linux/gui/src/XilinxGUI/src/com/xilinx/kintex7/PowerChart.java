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
 * @file PowerChart.java 
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
import java.text.NumberFormat;
import javax.swing.BorderFactory;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.CategoryAxis;
import org.jfree.chart.axis.ValueAxis;
import org.jfree.chart.labels.StandardCategorySeriesLabelGenerator;
import org.jfree.chart.labels.StandardCategoryToolTipGenerator;
import org.jfree.chart.labels.StandardXYSeriesLabelGenerator;
import org.jfree.chart.plot.CategoryPlot;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.renderer.category.BarRenderer;
import org.jfree.chart.title.TextTitle;
import org.jfree.data.category.DefaultCategoryDataset;

public class PowerChart {
    DefaultCategoryDataset dataset;
    JFreeChart chart;
    Color bg;
    String title;
    int index;
    int mark;
    int reverseMark;
    
    public PowerChart(String title, Color bg){
        this.bg = bg;
        this.title = title;
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
            "", "Time Interval", "",
            dataset, PlotOrientation.HORIZONTAL, true, true, false);

        TextTitle ttitle = new TextTitle(title, new Font(title, Font.BOLD, 15));
        ttitle.setPaint(Color.WHITE);
        chart.setTitle(ttitle);
        chart.setBackgroundPaint(bg);
        
        CategoryPlot plot = chart.getCategoryPlot();
        plot.setDomainGridlinesVisible(false);
        plot.setRangeGridlinesVisible(false);
        
        BarRenderer renderer = (BarRenderer)plot.getRenderer();
        renderer.setDrawBarOutline(false);
        
        ValueAxis axis = plot.getRangeAxis();
        axis.setUpperBound(6.0);
        axis.setLowerBound(0.0);
        axis.setTickLabelPaint(new Color(185, 185, 185));
        
        CategoryAxis caxis = plot.getDomainAxis();
        caxis.setTickLabelPaint(new Color(185, 185, 185));
        caxis.setLabelPaint(new Color(185, 185, 185));
        
        
        renderer.setItemMargin(0);
        renderer.setSeriesPaint(0, new Color(0x17, 0x7b, 0x7c));
        renderer.setSeriesPaint(1, new Color(0xa2, 0x45, 0x73));
        renderer.setSeriesPaint(2, new Color(0xff, 0x80, 0x40));
        renderer.setSeriesPaint(3, new Color(0x6f, 0x2c, 0x85));    
        renderer.setBaseToolTipGenerator(new StandardCategoryToolTipGenerator("{0}:{2}", new DecimalFormat("0.000")));
        addDummy();
    }
    
    public void updateChart(double val1, double val2, double val3, double val4){
        String name = "";
        if (mark > 0){
            name = ""+reverseMark;
            dataset.addValue(val1, "VCCint  ", name);
            dataset.addValue(val3, "GTvcc  ", name);
            dataset.addValue(val2, "VCCaux  ", name);
            dataset.addValue(val4, "VCCbram  ", name);
            mark--;
            reverseMark++;
        }else{
            if (dataset.getColumnCount() == 6){
                dataset.removeColumn(0);
            }
            name = ""+index;
            dataset.addValue(val1, "VCCint  ", name);
            dataset.addValue(val3, "GTvcc  ", name);
            dataset.addValue(val2, "VCCaux  ", name);
            dataset.addValue(val4, "VCCbram  ", name);
            index++;
        }
        
    }
    
    private void addDummy(){
        for (int i = 0; i < 6; ++i){
            String name = ""+index;
            dataset.addValue(-1, "VCCint  ", name);
            dataset.addValue(-1, "GTvcc  ", name);
            dataset.addValue(-1, "VCCaux  ", name);
            dataset.addValue(-1, "VCCbram  ", name);
            index++;
        }
        mark = 6;
        reverseMark = 1;
    }
}
