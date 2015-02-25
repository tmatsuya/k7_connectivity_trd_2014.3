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
 * @file PartialDisableComboBox.java 
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

import java.awt.Component;
import java.util.ArrayList;

import javax.swing.JComboBox;
import javax.swing.JList;
import javax.swing.plaf.basic.BasicComboBoxRenderer;

public class PartialDisableComboBox extends JComboBox {
 private static final long serialVersionUID = -1690671707274328126L;
 
 private ArrayList<Boolean> itemsState = new ArrayList<Boolean>();
 
 public PartialDisableComboBox() {
  super();
  this.setRenderer(new BasicComboBoxRenderer() {
   private static final long serialVersionUID = -2774241371293899669L;
   @Override
   public Component getListCellRendererComponent(JList list, Object value, 
     int index, boolean isSelected, boolean cellHasFocus) {
    Component c = super.getListCellRendererComponent(list, value, index, isSelected, cellHasFocus);
    boolean disabled = index >= 0 && index < itemsState.size() && !itemsState.get(index);
    c.setEnabled(!disabled);
    c.setFocusable(!disabled);
    return c;
   }
  });
 }
 
 public void addItems(Object[] items){
     for (int i = 0; i < items.length; ++i)
         addItem(items[i]);
 }
 
 @Override
 public void addItem(Object item) {
  this.addItem(item, true);
 }
 
 public void addItem(Object item, boolean enabled) {
  super.addItem(item);
  itemsState.add(enabled);
 }
 
 @Override
 public void insertItemAt(Object item, int index) {
  this.insertItemAt(item, index, true);
 }

 public void insertItemAt(Object item, int index, boolean enabled) {
  super.insertItemAt(item, index);
  itemsState.add(index, enabled);
 }
 
 @Override
 public void removeAllItems() {
  super.removeAllItems();
  itemsState.clear();
 }
 
 @Override
 public void removeItemAt(int index) {
  if (index < 0 || index >= itemsState.size()) throw new IllegalArgumentException("Item Index out of Bounds!");
  super.removeItemAt(index);
  itemsState.remove(index);
 }
 
 @Override
 public void removeItem(Object item) {
  for (int q = 0; q < this.getItemCount(); q++) {
   if (this.getItemAt(q) == item) itemsState.remove(q);
  }
  super.removeItem(item);
 }
 
 @Override
 public void setSelectedIndex(int index) {
  if (index < 0 || index >= itemsState.size()) throw new IllegalArgumentException("Item Index out of Bounds!");
  if (itemsState.get(index)) super.setSelectedIndex(index);
 }
 
 public void setItemEnabled(int index, boolean enabled) {
  if (index < 0 || index >= itemsState.size()) throw new IllegalArgumentException("Item Index out of Bounds!");
  itemsState.set(index, enabled);
 }
 
 public boolean isItemEnabled(int index) {
  if (index < 0 || index >= itemsState.size()) throw new IllegalArgumentException("Item Index out of Bounds!");
  return itemsState.get(index);
 }
}
