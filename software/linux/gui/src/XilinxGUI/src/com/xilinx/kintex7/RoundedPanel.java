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
 * @file RoundedPanel.java
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
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import javax.swing.JPanel;

/**
 * This class represents a Rounded Border JPanel.
 */
public class RoundedPanel extends JPanel {

    /** Stroke size. it is recommended to set it to 1 for better view */
    protected int strokeSize = 10;
    /** Color of shadow */
    protected Color shadowColor = Color.black;
    /** Sets if it drops shadow */
    protected boolean shady = true;
    /** Sets if it has an High Quality view */
    protected boolean highQuality = true;
    /** Double values for Horizontal and Vertical radius of corner arcs */
    protected Dimension arcs = new Dimension(10, 10);
    /** Distance between border of shadow and border of opaque panel */
    protected int shadowGap = 5;
    /** The offset of shadow.  */
    protected int shadowOffset = 4;
    /** The transparency value of shadow. ( 0 - 255) */
    protected int shadowAlpha = 150;

    public RoundedPanel() {
        super();
        setOpaque(false);
    }

    @Override
    protected void paintComponent(Graphics g) {
        super.paintComponent(g);
        int width = getWidth();
        int height = getHeight();
        int shadowGap = this.shadowGap;
        Color shadowColorA = new Color(shadowColor.getRed(), shadowColor.getGreen(), shadowColor.getBlue(), shadowAlpha);
        Graphics2D graphics = (Graphics2D) g;

        //Sets antialiasing if HQ.
        if (highQuality) {
            graphics.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        }

        //Draws shadow borders if any.
        if (shady) {
            graphics.setColor(shadowColorA);
            graphics.fillRoundRect(
                    shadowOffset,// X position
                    shadowOffset,// Y position
                    width - strokeSize - shadowOffset, // width
                    height - strokeSize - shadowOffset, // height
                    arcs.width, arcs.height);// arc Dimension
        } else {
            shadowGap = 1;
        }

        //Draws the rounded opaque panel with borders.
        graphics.setColor(getBackground());
        graphics.fillRoundRect(0, 0, width - shadowGap, height - shadowGap, arcs.width, arcs.height);
        graphics.setColor(getForeground());
        graphics.setStroke(new BasicStroke(strokeSize));
        graphics.drawRoundRect(0, 0, width - shadowGap, height - shadowGap, arcs.width, arcs.height);

        //Sets strokes to default, is better.
        graphics.setStroke(new BasicStroke());
    }

    /**
     * Check if component has High Quality enabled.
     * 
     * @return <b>TRUE</b> if it is HQ ; <b>FALSE</b> Otherwise
     */
    public boolean isHighQuality() {
        return highQuality;
    }

    /**
     * Sets whether this component has High Quality or not
     *
     * @param highQuality if <b>TRUE</b>, set this component to HQ
     */
    public void setHighQuality(boolean highQuality) {
        this.highQuality = highQuality;
    }

    /**
     * Returns the Color of shadow.
     *
     * @return a Color object.
     */
    public Color getShadowColor() {
        return shadowColor;
    }

    /**
     * Sets the Color of shadow
     *
     * @param shadowColor Color of shadow
     */
    public void setShadowColor(Color shadowColor) {
        this.shadowColor = shadowColor;
    }

    /**
     * Check if component drops shadow.
     *
     * @return <b>TRUE</b> if it drops shadow ; <b>FALSE</b> Otherwise
     */
    public boolean isShady() {
        return shady;
    }

    /**
     * Sets whether this component drops shadow
     *
     * @param shady if <b>TRUE</b>, it draws shadow
     */
    public void setShady(boolean shady) {
        this.shady = shady;
    }

    /**
     * Returns the size of strokes.
     *
     * @return the value of size.
     */
    public float getStrokeSize() {
        return strokeSize;
    }

    /**
     * Sets the stroke size value.
     *
     * @param strokeSize stroke size value
     */
    public void setStrokeSize(int strokeSize) {
        this.strokeSize = strokeSize;
    }

    /**
     * Get the value of arcs
     *
     * @return the value of arcs
     */
    public Dimension getArcs() {
        return arcs;
    }

    /**
     * Set the value of arcs
     *
     * @param arcs new value of arcs
     */
    public void setArcs(Dimension arcs) {
        this.arcs = arcs;
    }

    /**
     * Get the value of shadowOffset
     *
     * @return the value of shadowOffset
     */
    public int getShadowOffset() {
        return shadowOffset;
    }

    /**
     * Set the value of shadowOffset
     *
     * @param shadowOffset new value of shadowOffset
     */
    public void setShadowOffset(int shadowOffset) {
        if (shadowOffset >= 1) {
            this.shadowOffset = shadowOffset;
        } else {
            this.shadowOffset = 1;
        }
    }

    /**
     * Get the value of shadowGap
     *
     * @return the value of shadowGap
     */
    public int getShadowGap() {
        return shadowGap;
    }

    /**
     * Set the value of shadowGap
     *
     * @param shadowGap new value of shadowGap
     */
    public void setShadowGap(int shadowGap) {
        if (shadowGap >= 1) {
            this.shadowGap = shadowGap;
        } else {
            this.shadowGap = 1;
        }
    }

    /**
     * Get the value of shadowAlpha
     *
     * @return the value of shadowAlpha
     */
    public int getShadowAlpha() {
        return shadowAlpha;
    }

    /**
     * Set the value of shadowAlpha
     *
     * @param shadowAlpha new value of shadowAlpha
     */
    public void setShadowAlpha(int shadowAlpha) {
        if (shadowAlpha >= 0 && shadowAlpha <= 255) {
            this.shadowAlpha = shadowAlpha;
        } else {
            this.shadowAlpha = 255;
        }
    }
}
