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
 * @file MainScreen.java
 *
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

import java.awt.*;
import java.util.TimerTask;
import javax.swing.*;
import org.jfree.chart.ChartPanel;
import com.xilinx.gui.*;
import java.awt.event.*;
import java.text.DecimalFormat;
import javax.swing.table.JTableHeader;
import javax.swing.table.TableCellRenderer;
import javax.swing.text.SimpleAttributeSet;
import javax.swing.text.StyleConstants;
import javax.swing.text.StyledDocument;


public class MainScreen {
    private boolean RIGHT_TO_LEFT = false;
    private int LED_OFF = 0;
    private int LED_ON = 1;
    private JPanel testPanel;
    private ImageBackgroundPanel imagePanel;
    private JPanel messagePanel;
    private JTabbedPane tabs;
    private JButton tabButton1;
    private CustomTextPane textArea;
    MyTableModel table1;
    MyTableModel table2;
    PowerChart pchart;
    PowerDial dial2;
    ThermoPlot tplot;
    DriverInfo di;
    int height;
    int width;
    public boolean testStarted = false;
    public boolean testStarted1 = false;
    String[] dmaColumnNames0 ={"Parameters", "Transmit(S2C0)", "Receive(C2S0)"};
    String[] dmaColumnNames1 ={"Parameters", "Transmit(S2C1)", "Receive(C2S1)"};
    String[] pcieColumnNames = {"Type", "Value"};
    
    Object[][] dummy_data = {
            {"Throughput (GBPS)",0,0},
            {"DMA Active Time(ns)", 0, 0},
            {"DMA Wait Time(ns)", 0, 0},
            {"BD Errors", 0,0},
            {"BD Short Errors", 0, 0},
            {"# SW BDs",0, 0}
        };
    Object[][] trnDummy = {
        {"LTX",22.3},
        {"LRX", 22.3}
    };    
    String[] themenames = { "Default", "Windows", "Motif", "Nimbus"};
    JFrame frame;
    JTable dmaStats1;
    JTable dmaStats2;
    JTextField trnLTX, trnLRX;
    JCheckBox t1_o1;
    JCheckBox t1_o2;
    JCheckBox t1_o3;
    JCheckBox t2_o1;
    JCheckBox t2_o2;
    JCheckBox t2_o3;
    JTextField t1_psize;
    JTextField t2_psize;
    int test1_option;
    int test2_option;
    LandingPage lp;
    Image blockDiagram;
    java.util.Timer timer;
    DMABarChart dma0chart;
    DMABarChart dma1chart;
    int mode;
    JTable pcieTable;
    JTable hostTable;
    MyTableModel ptable;
    MyTableModel htable;
    int maxpkt0, maxpkt1, minpkt0, minpkt1;
    private static MainScreen ms;
    static StringBuffer messages= new StringBuffer();
    boolean dataMismatch0, dataMismatch2, errcnt0, errcnt1;
    SimpleAttributeSet keyWord;
    SimpleAttributeSet logStatus;
    JSplitPane splitPane;
    private boolean selectionVisible;
    JPanel mainPanel;
    int reqHeight, reqWidth;
    int minWidth, minHeight;
    int minFrameWidth, minFrameHeight;
    ChartPanel tplotPanel;
    ChartPanel dialPanel;
    String modeText;
    TableCellRenderer renderer = new CustomTableCellRenderer();
    Image led1, led2, led3;
    JLabel led_ddr3, led_phy0, led_phy1;
    LedStats lstats;
    JButton startTest;
    JButton stest;
    JDialog modalDialog;
    
    private MainScreen(){
        
    }
    public static MainScreen getInstance(){
        if (ms == null)
            ms = new MainScreen();
        return ms;
    }
       
    public void initialize(LandingPage l, String imgName, int mode){
        lp = l;
        blockDiagram = Toolkit.getDefaultToolkit().getImage(getClass().getResource("/com/xilinx/kintex7/"+imgName));
        led1 = Toolkit.getDefaultToolkit().getImage(getClass().getResource(
                      "/com/xilinx/gui/green.png"));
        led2 = Toolkit.getDefaultToolkit().getImage(getClass().getResource(
                      "/com/xilinx/gui/ledoff.png"));
        led3 = Toolkit.getDefaultToolkit().getImage(getClass().getResource(
                      "/com/xilinx/gui/red.png"));
        this.mode = mode;
        setModeText(mode);
        dataMismatch0 = dataMismatch2 = errcnt0 = errcnt1 = false;
        di = null;
        di = new DriverInfo();
        di.init(mode);
        int ret = di.get_PCIstate();
        
        //ret = di.get_PowerStats();
        test1_option = DriverInfo.ENABLE_LOOPBACK;
        test2_option = DriverInfo.ENABLE_LOOPBACK;
        // create a new jframe, and pack it
        frame = new JFrame("Kintex-7 Connectivity TRD Control & Monitoring Interface");
        frame.pack();
        frame.setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
        final int m = mode;
        frame.addWindowListener(new WindowAdapter() {
            @Override
            public void windowClosing(WindowEvent e){
                // check if tests are running or not
                if ((testStarted || testStarted1) && ((m != LandingPage.APPLICATION_MODE) || (m != LandingPage.APPLICATION_MODE_P2P))  ){
                    int confirmed = JOptionPane.showConfirmDialog(null, 
                            "This will stop the tests and uninstall the drivers. Do you want to continue?",
                            "Exit", JOptionPane.YES_NO_OPTION);
                    if (confirmed == JOptionPane.YES_OPTION)
                    {
                        if (testStarted){
                            di.stopTest(0, test1_option, Integer.parseInt(t1_psize.getText()));
                            testStarted = false;
                        }
                        if (testStarted1){
                            di.stopTest(1, test2_option, Integer.parseInt(t2_psize.getText()));
                            testStarted1 = false;
                        }
                        
                        timer.cancel();
                        textArea.removeAll();
                        di.flush();
                        di = null;
                        System.gc();
                        lp.uninstallDrivers();
                        showDialog("Removing Device Drivers...Please wait...");
                    }
                }else{
                    int confirmed = JOptionPane.showConfirmDialog(null, 
                            "This will Uninstall the drivers. Do you want to continue?",
                            "Exit", JOptionPane.YES_NO_OPTION);
                    if (confirmed == JOptionPane.YES_OPTION)
                    {
                        timer.cancel();
                        textArea.removeAll();
                        di.flush();
                        di = null;
                        System.gc();
                        lp.uninstallDrivers();
                        showDialog("Removing Device Drivers...Please wait...");      
                    }
                }                
            }
        });
        
        
        // make the frame half the height and width
        Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
        height = screenSize.height;
        width = screenSize.width;
      
        minWidth = 1000;
        minHeight = 700;
        minFrameWidth = 1024;
        minFrameHeight = 745;
        
        reqHeight = 745;
        if (width < 1280)
            reqWidth = 1024;
        else if (width == 1280)
            reqWidth = 1280;
        else if (width < 1600){
            reqWidth = width - (width*4)/100;
            reqHeight = height - (height*3)/100;
        }
        else{
            reqWidth = 
            reqHeight = height = height - (height*10)/100;
        }
                      
        frame.setSize(new Dimension(minFrameWidth, minFrameHeight));
        frame.setResizable(true);
        frame.addComponentListener(new ComponentListener() {

            @Override
            public void componentResized(ComponentEvent ce) {
                frame.setSize(new Dimension(
                Math.max(minFrameWidth, frame.getWidth()),
                Math.max(minFrameHeight, frame.getHeight())
                 ));
            }

            @Override
            public void componentMoved(ComponentEvent ce) {
                //throw new UnsupportedOperationException("Not supported yet.");
            }

            @Override
            public void componentShown(ComponentEvent ce) {
                //throw new UnsupportedOperationException("Not supported yet.");
            }

            @Override
            public void componentHidden(ComponentEvent ce) {
                //throw new UnsupportedOperationException("Not supported yet.");
            }
        });
        frame.setVisible(true);
        
        frame.setIconImage(Toolkit.getDefaultToolkit().getImage(getClass().getResource("/com/xilinx/kintex7/icon.png")));
        // center the jframe on screen
        frame.setLocationRelativeTo(null);
      
        frame.setContentPane(createContentPane());
        
        keyWord = new SimpleAttributeSet();
        StyleConstants.setForeground(keyWord, Color.RED);
     
        StyleConstants.setBold(keyWord, true);
        
        logStatus = new SimpleAttributeSet();
        StyleConstants.setForeground(logStatus, Color.BLACK);
        StyleConstants.setBold(logStatus, true);

        if ((mode == LandingPage.APPLICATION_MODE)|| (mode == LandingPage.APPLICATION_MODE_P2P)){
            testStarted = testStarted1 = true;
        }
        
        if (mode == LandingPage.PERFORMANCE_MODE_RAW){
            t1_o1.setSelected(true);
            t1_o2.setEnabled(false);
            t1_o3.setEnabled(false);
            t2_o2.setEnabled(false);
            t2_o3.setEnabled(false);
        }
        if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV){
            t1_o2.setEnabled(false);
            t1_o3.setEnabled(false);
            t2_o2.setEnabled(false);
            t2_o3.setEnabled(false);
            t1_o1.setSelected(true);
        }
        
        
        // initialize max packet size
        ret = di.get_EngineState();
        EngState[] engData = di.getEngState();
        maxpkt0 = engData[0].MaxPktSize;
        minpkt0 = engData[0].MinPktSize;
        
        minpkt1 = engData[2].MinPktSize;
        maxpkt1 = engData[2].MaxPktSize;
        
        t1_psize.setText(String.valueOf(maxpkt0));
        t2_psize.setText(String.valueOf(maxpkt1));
        
        t1_psize.setToolTipText(minpkt0+"-"+maxpkt0);
        t2_psize.setToolTipText(minpkt1+"-"+maxpkt1);
       
        updateLog(di.getPCIInfo().getVersionInfo(), logStatus);
        updateLog("Configuration: "+modeText, logStatus);
                
        // LED status
        di.get_LedStats();
        lstats = di.getLedStats();
        setLedStats(lstats);
        
        startTimer();
    }
    
    public void unInstallDone(){
        modalDialog.setVisible(false);
        lp.showLP();
        frame.dispose();
    }
    
    private void updateLog(String message, SimpleAttributeSet aset){
        StyledDocument doc = textArea.getStyledDocument();
        String[] lines = Utils.wrapText(message, 60);
        try{
            for (int i = 0; i < lines.length; ++i)
               doc.insertString(doc.getLength(),"\n"+lines[i], aset);
        }catch(Exception e){

        }
    }
    
    private void showDialog(String message){
        modalDialog = new JDialog(frame, "Busy", Dialog.ModalityType.DOCUMENT_MODAL);
        JLabel lmessage = new JLabel(message, JLabel.CENTER);
       
        //modalDialog.add(limg, BorderLayout.LINE_START);
        modalDialog.add(lmessage, BorderLayout.CENTER);
        modalDialog.setSize(400, 150);
        modalDialog.setLocationRelativeTo(frame);
        modalDialog.setVisible(true);
    }
    
    private void setLedStats(LedStats ls){
        if (ls.ddrCalib == LED_ON)
            led_ddr3.setIcon(new ImageIcon(led1));
        else{
            led_ddr3.setIcon(new ImageIcon(led2));
            //if tests are running stop them
            if (mode == LandingPage.PERFORMANCE_MODE_RAW||
                mode == LandingPage.PERFORMANCE_MODE_RAW_DV){
                if (testStarted)
                    stopTest1();
                if (testStarted1)
                    stopTest2();
                JOptionPane.showMessageDialog(null, 
                                "DDR3 is not calibrated. Test(s) stopped", "Error", 
                                JOptionPane.ERROR_MESSAGE);
            }
        }
        
        
        if (ls.phy0 == LED_ON)
            led_phy0.setIcon(new ImageIcon(led1));
        else
        {
            led_phy0.setIcon(new ImageIcon(led2));
            //if tests are running stop them
            if (mode == LandingPage.PERFORMANCE_MODE_RAW||
                mode == LandingPage.PERFORMANCE_MODE_RAW_DV){
                if (testStarted){
                    stopTest1();
                     JOptionPane.showMessageDialog(null, 
                                "10G-PHY0 Link down. Test stopped", "Error", 
                                JOptionPane.ERROR_MESSAGE); 
                }                
            }
        }
        
        if (ls.phy1 == LED_ON)
            led_phy1.setIcon(new ImageIcon(led1));
        else{
            led_phy1.setIcon(new ImageIcon(led2));
            //if tests are running stop them
            if (mode == LandingPage.PERFORMANCE_MODE_RAW||
                mode == LandingPage.PERFORMANCE_MODE_RAW_DV){
               
                if (testStarted1){
                    stopTest2();
                    JOptionPane.showMessageDialog(null, 
                                "10G-PHY1 Link down. Test stopped", "Error", 
                                JOptionPane.ERROR_MESSAGE);
                }
            }
        }
    }
    
    private void setModeText(int m){
        modeText = "";
        if (m == LandingPage.APPLICATION_MODE)
            modeText = modeText+"Application Mode (Dual 10G NIC)";
        else if (m == LandingPage.APPLICATION_MODE_P2P)
            modeText = modeText+"Application Mode (Dual 10G NIC) peer2peer"; 
       else if (m == LandingPage.PERFORMANCE_MODE_GENCHK)
            modeText = modeText + "Performance Mode (GEN/CHK)";
        else if (m == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
            modeText = modeText + "Performance Mode (GEN/CHK) with Data Verify";
        else if (m == LandingPage.PERFORMANCE_MODE_RAW)
            modeText = modeText + "Performance Mode (Raw Ethernet)";
        else if (m == LandingPage.PERFORMANCE_MODE_RAW_DV)
            modeText = modeText + "Performance Mode (Raw Ethernet) with Data Verify";
    }
    
    public void startTimer(){
        timer = new java.util.Timer();
        timer.schedule(new TimerTask(){
            @Override
            public void run(){
                    makeDMAData();
                    updatePowerAndTemp();
            }
        }, 0, 3000);
    }
    
    public void updatePowerAndTemp(){
        int ret = di.get_PowerStats();
        PowerStats ps = di.getPowerStats();
       
        if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV ||
            mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
        {
           
            if (ps.errCnt0 != 0 && errcnt0 == false){
                 errcnt0 = true;
                 updateLog("Data Mismatch occured on RAWDATA-0", keyWord);
            }
            if (ps.errCnt1 != 0 && errcnt1 == false){
                errcnt1 = true;
                updateLog("Data Mismatch occured on RAWDATA-1", keyWord);
            }
        }
        pchart.updateChart((double)ps.vccint/1000.0, (double)ps.vccaux/1000.0, 
                (double)ps.mgtvcc/1000.0, (double)ps.vccbram/1000.0);
        tplot.update(ps.die_temp);
        
    }
        
    public void makeDMAData(){
        
        int ret = di.get_DMAStats();
        ret = di.get_EngineState();
        
        DMAStats[] dmaData = di.getDMAStats();
        EngState[] engData = di.getEngState();
        if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV ||
            mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
        {  
            if (engData[0].DataMismatch != 0 && dataMismatch0 == false){
                dataMismatch0 = true;
                updateLog("Data Mismatch occured on Engine S2C"+engData[0].Engine, keyWord);
            }
            if (engData[2].DataMismatch != 0 && dataMismatch2 == false){
                dataMismatch2 = true;
                updateLog("Data Mismatch occured on Engine S2C"+engData[2].Engine, keyWord);
            }
        }
        ret = di.get_TRNStats();
        TRNStats trnStats = di.getTRNStats();
        
        trnLTX.setText(String.format("%2.3f", trnStats.LTX));
        trnLRX.setText(String.format("%2.3f",trnStats.LRX));
        
        //if (testStarted){
        Object[][] data = {
            {"Throughput (Gbps)",String.format("%2.3f", dmaData[0].LBR),String.format("%2.3f", dmaData[1].LBR)},
            {"DMA Active Time(ns)", dmaData[0].LAT, dmaData[1].LAT},
            {"DMA Wait Time(ns)", dmaData[0].LWT, dmaData[1].LWT},
            {"BD Errors", engData[0].BDerrs,engData[1].BDerrs},
            {"BD Short Errors", engData[0].BDSerrs, engData[1].BDSerrs},
            {"SW BDs",engData[0].BDs, engData[1].BDs}
        };
        table1.setData(data, dmaColumnNames0);
        table1.fireTableDataChanged();
        
       
        Object[][] data1 = {
            {"Throughput (Gbps)",String.format("%2.3f", dmaData[2].LBR),String.format("%2.3f", dmaData[3].LBR)},
            {"DMA Active Time(ns)", dmaData[2].LAT, dmaData[3].LAT},
            {"DMA Wait Time(ns)", dmaData[2].LWT, dmaData[3].LWT},
            {"BD Errors", engData[2].BDerrs,engData[3].BDerrs},
            {"BD Short Errors", engData[2].BDSerrs, engData[3].BDSerrs},
            {"SW BDs",engData[2].BDs, engData[3].BDs}
        };
        table2.setData(data1, dmaColumnNames1);
        table2.fireTableDataChanged();
        
        // update plots
        DecimalFormat df = new DecimalFormat("##.###");
        if (testStarted || testStarted1){
        dma0chart.updateChart(Double.valueOf(df.format(dmaData[0].LBR)), 
                              Double.valueOf(df.format(dmaData[2].LBR)), 
                              Double.valueOf(df.format(trnStats.LRX))
                              );        
        dma1chart.updateChart(Double.valueOf(df.format(dmaData[1].LBR)), 
                              Double.valueOf(df.format(dmaData[3].LBR)),
                              Double.valueOf(df.format(trnStats.LTX)) 
                             );
        }
        // LED status
        di.get_LedStats();
        lstats = di.getLedStats();
        setLedStats(lstats);
    }
    
  
    
    private Container createContentPane(){
        JPanel contentPane = new JPanel();
        contentPane.setLayout(new BorderLayout());
        contentPane.setOpaque(true);

        mainPanel = new JPanel(new BorderLayout());
       
        mainPanel.setBounds(0, 0, minWidth, minHeight);
        testPanel  = new JPanel(new BorderLayout());
        
        testPanel.add(testAndStats(), BorderLayout.CENTER);
       
        mainPanel.add(testPanel, BorderLayout.LINE_START);
         
        //Make the center component big, since that's the
        //typical usage of BorderLayout.
        tabs = new JTabbedPane();
       
        mainPanel.add(tabs, BorderLayout.CENTER);
       
        tabs.add("System Monitor", pciInfo());
        tabs.add("Performance Plots", plotPanel());
       
        mainPanel.setOpaque(true);
         
       try{
        imagePanel = new ImageBackgroundPanel(blockDiagram, false);
        }catch(Exception e)
        {
        }
        /*imagePanel.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createTitledBorder("Design Block Diagram"),
                        BorderFactory.createEmptyBorder(5,5,5,5)));*/
        imagePanel.setBackground(Color.WHITE);
        imagePanel.setSize(minWidth, minHeight);
      
        imagePanel.setLocation(0, 0);
        imagePanel.setOpaque(true);
        
        final JLayeredPane layeredPane = new JLayeredPane();
        layeredPane.setPreferredSize(new Dimension(minWidth, minHeight));
        layeredPane.add(mainPanel, JLayeredPane.DEFAULT_LAYER, 0);
        layeredPane.add(imagePanel, JLayeredPane.DEFAULT_LAYER, 0);
        layeredPane.addComponentListener(new ComponentListener() {

            @Override
            public void componentResized(ComponentEvent ce) {
                mainPanel.setBounds(0, 0, 
                        Math.max(minWidth, layeredPane.getWidth()), 
                        Math.max(minHeight, layeredPane.getHeight()));
                if (layeredPane.getWidth() > 1024){
                    tplotPanel.setPreferredSize(new Dimension(300, 100));
                }else{
                    tplotPanel.setPreferredSize(new Dimension(200, 100));
                }
                imagePanel.setSize(mainPanel.getWidth(), mainPanel.getHeight());
                imagePanel.setLocation(0, 0);
                mainPanel.repaint();
            }

            @Override
            public void componentMoved(ComponentEvent ce) {
                //throw new UnsupportedOperationException("Not supported yet.");
            }

            @Override
            public void componentShown(ComponentEvent ce) {
                //throw new UnsupportedOperationException("Not supported yet.");
            }

            @Override
            public void componentHidden(ComponentEvent ce) {
                //throw new UnsupportedOperationException("Not supported yet.");
            }
        });
        // on top, but invisible initially
        imagePanel.setVisible(false);
        
        JPanel bpanel = new JPanel(new BorderLayout());
                
        final JButton button = new JButton("<html><b>B<br>L<br>O<br>C<br>K<br> <br>D<br>I<br>A<br>G<br>R<br>A<br>M<br></b></html>");    
        button.setToolTipText("Click here to see the block diagram");
        button.addActionListener(new ActionListener(){
        @Override
        public void actionPerformed(ActionEvent event)
        {
           adjustSelectionPanel();
        }
        });
       
        bpanel.add(button, BorderLayout.CENTER);
        
        contentPane.add(layeredPane, BorderLayout.CENTER);
        contentPane.add(button, BorderLayout.EAST);
        JLabel mLabel = new JLabel(modeText, JLabel.CENTER);
        mLabel.setFont(new Font(modeText, Font.BOLD, 15));
        contentPane.add(mLabel, BorderLayout.PAGE_START);
        return contentPane;
    }
    
    private void adjustSelectionPanel()
    {
        imagePanel.setVisible(!selectionVisible);
        selectionVisible = !selectionVisible;
        
        if (imagePanel.isVisible()){
               mainPanel.setVisible(false);
        }else{ 
               mainPanel.setVisible(true);
        }
    }
      
    private JPanel testAndStats(){
        JPanel tstats = new JPanel();
        tstats.setLayout(new BoxLayout(tstats, BoxLayout.Y_AXIS));
        
        JPanel ledPanel = new JPanel(new BorderLayout());
        
        JPanel iledPanel = new JPanel();
        iledPanel.setLayout(new BoxLayout(iledPanel, BoxLayout.X_AXIS));
               
        led_ddr3 = new JLabel("DDR3", new ImageIcon(led1), JLabel.CENTER);
        led_phy0 = new JLabel("10G PHY-0", new ImageIcon(led1), JLabel.CENTER);
        led_phy1 = new JLabel("10G PHY-1", new ImageIcon(led1), JLabel.CENTER);
        
        JPanel le1 = new JPanel(new BorderLayout());
        le1.add(led_ddr3, BorderLayout.CENTER);
        
        JPanel le2 = new JPanel(new BorderLayout());
        le2.add(led_phy0, BorderLayout.CENTER);
        
        JPanel le3 = new JPanel(new BorderLayout());
        le3.add(led_phy1, BorderLayout.CENTER);
             
        
        iledPanel.add(le1);
        iledPanel.add(le2);
        iledPanel.add(le3);
        
        ledPanel.add(iledPanel, BorderLayout.CENTER);
        tstats.add(ledPanel);
        
        JPanel tstats1 = new JPanel();
        tstats1.setLayout(new BoxLayout(tstats1, BoxLayout.Y_AXIS));
        
        
        
        tstats1.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createTitledBorder(""),
                        BorderFactory.createRaisedBevelBorder()));
                        
        tstats1.add(testPanelItems());
       
        JPanel dmaInner = new JPanel(new BorderLayout());
        
        
        JPanel dmaPanel = new JPanel(new BorderLayout());
       
        dmaPanel.setBackground(new Color(130, 170, 180));
        table1 = new MyTableModel(dummy_data, dmaColumnNames0);
        dmaStats1 = new JTable(table1);
        try{
            dmaStats1.setDefaultRenderer(Object.class, new CustomTableCellRenderer());
        }catch(Exception e){
        }
        JTableHeader dmaHeader = dmaStats1.getTableHeader();
        dmaHeader.setForeground(new Color(92, 25, 25));
        
        dmaPanel.add(dmaHeader, BorderLayout.PAGE_START);
        dmaPanel.add(dmaStats1, BorderLayout.CENTER);
        dmaInner.add(dmaPanel, BorderLayout.CENTER);
        tstats1.add(dmaInner);
        tstats.add(tstats1);
        
        JPanel trnPanel = new JPanel(new GridLayout(1,1));
        trnPanel.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createTitledBorder("PCIe Statistics"),
                        BorderFactory.createRaisedBevelBorder()));
        JPanel trn1 = new JPanel(new FlowLayout());
        trn1.add(new JLabel("Transmit (writes in Gbps): "));
        trnLTX = new JTextField("0.0", 5);
        trnLTX.setEditable(false);
        trn1.add(trnLTX);
        trn1.add(new JLabel("Receive (reads in Gbps): "));
        trnLRX = new JTextField("0.0", 5);
        trnLRX.setEditable(false);
        trn1.add(trnLRX);
        trnPanel.add(trn1);
        tstats.add(trnPanel);
        
        JPanel tstats2 = new JPanel();
        tstats2.setLayout(new BoxLayout(tstats2, BoxLayout.Y_AXIS));
        tstats2.add(testPanelItems1());
        
        tstats2.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createTitledBorder(""),
                        BorderFactory.createRaisedBevelBorder()));
        
        JPanel dmaPanel1 = new JPanel(new BorderLayout());
        
        table2 = new MyTableModel(dummy_data, dmaColumnNames1);
        dmaStats2 = new JTable(table2);
        try{
            dmaStats2.setDefaultRenderer(Object.class, new CustomTableCellRenderer());
        }catch(Exception e){
        }
        JTableHeader dmaHeader1 = dmaStats2.getTableHeader();
        dmaHeader1.setForeground(new Color(92, 25, 25));
        
        dmaPanel1.add(dmaHeader1, BorderLayout.PAGE_START);
        dmaPanel1.add(dmaStats2, BorderLayout.CENTER);
        tstats2.add(dmaPanel1);
        tstats.add(tstats2);   
        
        JPanel tstats3 = new JPanel(new BorderLayout());
        tstats3.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createTitledBorder("Message Log"),
                        BorderFactory.createRaisedBevelBorder()));
        textArea = new CustomTextPane();
            
        final JScrollPane scrollPane = new JScrollPane(textArea, JScrollPane.VERTICAL_SCROLLBAR_ALWAYS, 
                JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
                       
        // keep scrollbar at end showing latest messages
        scrollPane.getVerticalScrollBar().addAdjustmentListener(new AdjustmentListener() {
            BoundedRangeModel brm = scrollPane.getVerticalScrollBar().getModel();
            boolean wasAtBottom = true;
            @Override
            public void adjustmentValueChanged(AdjustmentEvent ae) {
                if (!brm.getValueIsAdjusting()) {
                    if (wasAtBottom)
                        brm.setValue(brm.getMaximum());
                    } else
                        wasAtBottom = ((brm.getValue() + brm.getExtent()) == brm.getMaximum());
                }
        });
       
        textArea.setEditable(false);
        tstats3.add(scrollPane, BorderLayout.CENTER);
        tstats.add(tstats3);
        return tstats;
    }
      
    private JPanel dialChart(int w){
        JPanel panel = new JPanel();
        JPanel panel1 = new JPanel(new BorderLayout());
        
        panel.setLayout(new BorderLayout());
        
        pchart = new PowerChart("Power (in Watt)", panel.getBackground());
        dialPanel = pchart.getChart("");
        dialPanel.setPreferredSize(new Dimension(300, 100));
        
        
        tplot = new ThermoPlot();
        tplotPanel = tplot.getChart();
        tplotPanel.setPreferredSize(new Dimension(200, 100));
        
        panel1.add(dialPanel, BorderLayout.CENTER);
        panel1.add(tplotPanel, BorderLayout.LINE_END);
        
        panel.add(panel1, BorderLayout.CENTER);
       
        return panel;
    }
    
    private JPanel plotPanel(){
        JPanel panel = new JPanel();
        panel.setLayout(new BoxLayout(panel, BoxLayout.Y_AXIS));
        JPanel panel1 = new JPanel();
        JPanel panel2 = new JPanel();
        String[] labels0 = {"S2C0  ","S2C1  ", "PCIe Reads  "};
        String[] labels1 = {"C2S0  ", "C2S1  ", "PCIe Writes  "};
       
        dma0chart = new DMABarChart("Transmit (S2C) Performance", panel1.getBackground(),
                labels0);
        dma1chart = new DMABarChart("Receive (C2S) Performance", panel1.getBackground(),
                labels1);
        panel1.setLayout(new BoxLayout(panel1, BoxLayout.Y_AXIS));
        panel1.setSize(new Dimension(panel1.getWidth()-100, panel1.getHeight()-100));
        
        panel1.add(dma0chart.getChart(""));
        panel2.setLayout(new BoxLayout(panel2, BoxLayout.Y_AXIS));
        panel2.setSize(new Dimension(panel2.getWidth()-100, panel2.getHeight()-100));
       
        panel2.add(dma1chart.getChart(""));
        panel.add(panel1);
        panel.add(panel2);
        return panel;
    }
    private JPanel pciInfo(){
        JPanel pciSystemPanel = new JPanel();
        pciSystemPanel.setLayout(new BoxLayout(pciSystemPanel, BoxLayout.Y_AXIS));
        
               
        JPanel topPanel = new JPanel(new GridLayout(1,2));
        topPanel.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createTitledBorder("PCIe Settings"),
                        BorderFactory.createRaisedBevelBorder()));
        JPanel sPanel = new JPanel(new FlowLayout());
        sPanel.add(new JLabel("Link Speed: "));
        Object[] speeds = {"2.5 Gbps","5.0 Gbps"};
        final PartialDisableComboBox lspeed = new PartialDisableComboBox();
        lspeed.addItems(speeds);
        
        lspeed.setSelectedIndex(di.getPCIInfo().LinkSpeed-1);
        lspeed.setItemEnabled(di.getPCIInfo().LinkSpeed-1, false);
        
        sPanel.add(lspeed);
        JButton setSpeed = new JButton("Go");
        setSpeed.setToolTipText("This enables directed PCIe link speed change");
        setSpeed.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent ae) {
                if (lspeed.isItemEnabled(lspeed.getSelectedIndex()))
                {
                    int ret = di.setLinkSpeed(lspeed.getSelectedIndex()+1);
                    if (ret == 0){
                        //update pcie information
                        di.get_PCIstate();
                        lspeed.setItemEnabled(0, true);
                        lspeed.setItemEnabled(1, true);
                        lspeed.setSelectedIndex(di.getPCIInfo().LinkSpeed-1);
                        lspeed.setItemEnabled(di.getPCIInfo().LinkSpeed-1, false);
                        ptable.setData(di.getPCIInfo().getPCIData(), pcieColumnNames);
                        ptable.fireTableDataChanged();
                    }
                    else{
                        updateLog("Unable to set Link Speed "+lspeed.getSelectedItem(), keyWord);
                    }
                }
            }
        });
        
        sPanel.add(setSpeed);
        topPanel.add(sPanel);
        
        JPanel sPanel1 = new JPanel(new FlowLayout());
        sPanel1.add(new JLabel("Link Width: "));
        Object[] widths = {"x1","x2","x4","x8"};
        final PartialDisableComboBox lwidths = new PartialDisableComboBox();
        lwidths.addItems(widths);
        lwidths.setSelectedItem("x"+di.getPCIInfo().LinkWidth);
        lwidths.setItemEnabled(lwidths.getSelectedIndex(), false);
        sPanel1.add(lwidths);
        JButton setWidth = new JButton("Go");
        setWidth.setToolTipText("This enables directed PCIe link width change");
        setWidth.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent ae) {
                if (lwidths.isItemEnabled(lwidths.getSelectedIndex()))
                {
                    int ret = di.setLinkWidth(lwidths.getSelectedIndex()+1);
                    if (ret == 0){
                        //update pcie information
                        // some times width change affect link speed so
                        // enable the same in lspeedd also
                        di.get_PCIstate();
                        lwidths.setItemEnabled(0, true);
                        lwidths.setItemEnabled(1, true);
                        lwidths.setItemEnabled(2, true);
                        lwidths.setItemEnabled(3, true);
                        lwidths.setSelectedItem("x"+di.getPCIInfo().LinkWidth);
                        lwidths.setItemEnabled(lwidths.getSelectedIndex(), false);

                        // some times width change affect link speed so
                        // enable the same in lspeed also
                        lspeed.setItemEnabled(0, true);
                        lspeed.setItemEnabled(1, true);
                        lspeed.setSelectedIndex(di.getPCIInfo().LinkSpeed-1);
                        lspeed.setItemEnabled(di.getPCIInfo().LinkSpeed-1, false);

                        ptable.setData(di.getPCIInfo().getPCIData(), pcieColumnNames);
                        ptable.fireTableDataChanged();

                    }else
                    {
                        di.get_PCIstate();
                        int upCap = di.getPCIInfo().LinkUpCap;
                                             
                        if (upCap == 0)
                            updateLog("Unable to set Link Width "+lwidths.getSelectedItem()+". PCIe link not upconfigurable", keyWord);

                        else
                            updateLog("Unable to set Link Width "+lwidths.getSelectedItem(), keyWord);

                    }
                }
            }
        });
        sPanel1.add(setWidth);
        topPanel.add(sPanel1);
        
       
        pciSystemPanel.add(topPanel);
        JPanel panel =  new JPanel(new GridLayout(1,2));
        
        JPanel pciPanel = new JPanel(new BorderLayout());
        pciPanel.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createTitledBorder("PCIe Endpoint Status"),
                        BorderFactory.createRaisedBevelBorder()));
        ptable = new MyTableModel(di.getPCIInfo().getPCIData(), pcieColumnNames);
        pcieTable = new JTable(ptable);
        try{
            pcieTable.setDefaultRenderer(Object.class, new CustomTableCellRenderer());
        }catch(Exception e){
        }
        
        JTableHeader pcieHeader = pcieTable.getTableHeader();
        pcieHeader.setForeground(new Color(92, 25, 25));
        
        pciPanel.add(pcieHeader, BorderLayout.PAGE_START);
        pciPanel.add(pcieTable, BorderLayout.CENTER);
        
        panel.add(pciPanel);
        
        JPanel hostPanel = new JPanel(new BorderLayout());
        hostPanel.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createTitledBorder("Host System's Initial Credits"),
                        BorderFactory.createRaisedBevelBorder()));
        htable = new MyTableModel(di.getPCIInfo().getHostedData(), pcieColumnNames);
        hostTable = new JTable(htable);
        try{
            hostTable.setDefaultRenderer(Object.class, new CustomTableCellRenderer());
        }catch(Exception e){
        }
        
        JTableHeader hostHeader = hostTable.getTableHeader();
        hostHeader.setForeground(new Color(92, 25, 25));
        
        hostPanel.add(hostHeader, BorderLayout.PAGE_START);
        hostPanel.add(hostTable, BorderLayout.CENTER);
        
        panel.add(hostPanel);
       
        pciSystemPanel.add(panel);
        
        
        pciSystemPanel.add(dialChart(pciSystemPanel.getWidth()));
       
        return pciSystemPanel;
    }
       
    private JPanel testPanelItems(){
        JPanel panel1 = new JPanel();
        
        JPanel panel = new JPanel();
        
       
        panel.setComponentOrientation(
                ComponentOrientation.LEFT_TO_RIGHT);
       
               
        panel.add(new JLabel("Data Path-0:"));
        t1_o1 =  new JCheckBox("Loopback");
        if (mode == LandingPage.PERFORMANCE_MODE_GENCHK ||
            mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
            t1_o1.setToolTipText("This loops back software generated traffic at DMA user interface");
       else if (mode == LandingPage.PERFORMANCE_MODE_RAW ||
            mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
           t1_o1.setToolTipText("This loops back software generated raw Ethernet frames at 10G PHY");   
             
        t1_o1.setSelected(true);
        t1_o1.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent ae) {
                if (mode == LandingPage.PERFORMANCE_MODE_RAW||
                        mode == LandingPage.PERFORMANCE_MODE_RAW_DV){
                        t1_o1.setSelected(true);
                        return;
                }
                if (t1_o1.isSelected())
                {
                    // disable others
                    test1_option = DriverInfo.ENABLE_LOOPBACK;
                    t1_o2.setSelected(false);
                    t1_o3.setSelected(false);
                }else{
                     if (!t1_o2.isSelected() && !t1_o3.isSelected()){
                       test1_option = DriverInfo.CHECKER;  
                       t1_o2.setSelected(true);
                     }
                }
            }
        });
        //b1.setSelected(true);
        t1_o2 =  new JCheckBox("HW Checker");
        if (mode == LandingPage.PERFORMANCE_MODE_GENCHK ||
            mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
            t1_o2.setToolTipText("This enables Checker in hardware at DMA user interface verifying traffic generated by software");
        t1_o2.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent ae) {
                if (t1_o2.isSelected())
                {
                    // disable others
                    test1_option = DriverInfo.CHECKER;
                    t1_o1.setSelected(false);
                    if (t1_o3.isSelected())
                        test1_option = DriverInfo.CHECKER_GEN;
                }
                else{
                    if (t1_o3.isSelected())
                        test1_option = DriverInfo.GENERATOR;
                    else{
                        test1_option = DriverInfo.ENABLE_LOOPBACK;
                        t1_o1.setSelected(true);
                    }
                        
                }
            }
        });
        t1_o3 =  new JCheckBox("HW Generator");
        if (mode == LandingPage.PERFORMANCE_MODE_GENCHK ||
            mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
            t1_o3.setToolTipText("This enables traffic generator in hardware at the DMA user interface");
        t1_o3.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent ae) {
                if (t1_o3.isSelected())
                {
                    // disable others
                    test1_option = DriverInfo.GENERATOR;
                    t1_o1.setSelected(false);
                    //t1_o2.setSelected(false);
                    if (t1_o2.isSelected())
                        test1_option = DriverInfo.CHECKER_GEN;
                }else{
                    if (t1_o2.isSelected())
                        test1_option = DriverInfo.CHECKER;
                    else{
                        test1_option = DriverInfo.ENABLE_LOOPBACK;
                        t1_o1.setSelected(true);
                    }
                }
            }
        });
        //b3.setEnabled(false);
        JPanel ip = new JPanel();
        ip.setLayout(new BoxLayout(ip, BoxLayout.PAGE_AXIS));
        ip.add(t1_o1); ip.add(t1_o2); ip.add(t1_o3);
        panel.add(ip);
        panel.add(new JLabel("Packet Size (bytes):"));
        t1_psize = new JTextField("32768", 5); 
        
        panel.add(t1_psize);
        startTest = new JButton("Start");
        startTest.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent ae) {
                               
                //Check for led status and start the test
                if (mode == LandingPage.PERFORMANCE_MODE_RAW ||
                    mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
                {
                    if (lstats.ddrCalib == LED_OFF &&
                        (lstats.phy0 == LED_ON &&
                        lstats.phy1 == LED_ON)){
                    JOptionPane.showMessageDialog(null, 
                                "DDR3 is not calibrated. Test cannot be started", "Error", 
                                JOptionPane.ERROR_MESSAGE);
                        return;
                    }else if (lstats.ddrCalib == LED_OFF &&
                        (lstats.phy0 == LED_OFF ||
                        lstats.phy1 == LED_OFF)){
                    JOptionPane.showMessageDialog(null, 
                                "DDR3 is not calibrated and 10G-PHY link is down. Test cannot be started", "Error", 
                                JOptionPane.ERROR_MESSAGE);
                        return;
                    }else if(lstats.ddrCalib == LED_ON &&
                        (lstats.phy0 == LED_OFF ||
                        lstats.phy1 == LED_OFF)){
                        JOptionPane.showMessageDialog(null, 
                                "10G-PHY link is down. Test cannot be started", "Error", 
                                JOptionPane.ERROR_MESSAGE);
                        return;
                    }
                }
                
                if (startTest.getText().equals("Start")){
                    int psize = 0;
                    dataMismatch0 = errcnt0 = false;
                    try{
                         psize = Integer.parseInt(t1_psize.getText());
                    }catch(Exception e){
                        JOptionPane.showMessageDialog(null, 
                                "Only Natural numbers are allowed", "Error", 
                                JOptionPane.ERROR_MESSAGE);
                        return;
                    }
                    if (psize < minpkt0 || psize > maxpkt0)
                    {
                        JOptionPane.showMessageDialog(null, 
                                "Packet size must be within "+minpkt0+" to "+maxpkt0 +" bytes", "Error", 
                                JOptionPane.ERROR_MESSAGE);
                        return;
                    }
                    di.startTest(0, test1_option, psize);
                    // disable components
                    t1_o1.setEnabled(false);
                    t1_o2.setEnabled(false);
                    t1_o3.setEnabled(false);
                    t1_psize.setEnabled(false);
                    startTest.setText("Stop"); 
                    testStarted = true;
                    updateLog("[Test Started for Data Path-0]", logStatus);
                }else if(startTest.getText().equals("Stop")){
                    startTest.setEnabled(false);
                    SwingWorker worker = new SwingWorker<Void, Void>(){

                        @Override
                        protected Void doInBackground() throws Exception {
                            try{
                                stopTest1();
                            }catch(Exception e){
                                e.printStackTrace();
                            }
                            return null;
                        }
                        
                    };
                    worker.execute();
                } 
            }
        });  
        panel.add(startTest);
        if ((mode == LandingPage.APPLICATION_MODE)||(mode == LandingPage.APPLICATION_MODE_P2P)){
            t1_o1.setSelected(false);
            t1_o2.setSelected(false);
            t1_o3.setSelected(false);
            t1_o1.setEnabled(false);
            t1_o2.setEnabled(false);
            t1_o3.setEnabled(false);
            t1_psize.setEnabled(false);
            t1_psize.setText("");
            startTest.setEnabled(false);
        }
        panel1.add(panel);
        return panel1;
    }
    
    private void stopTest1(){
         int ret = di.stopTest(0, test1_option, Integer.parseInt(t1_psize.getText()));
         
         if (ret == -1){
             updateLog("Unable to stop test Data Path - 0", keyWord);
         }else{
                    t1_o1.setEnabled(true);
                    if (mode == LandingPage.PERFORMANCE_MODE_RAW ||
                        mode == LandingPage.PERFORMANCE_MODE_RAW_DV){   
                        t1_o2.setEnabled(false);
                        t1_o3.setEnabled(false);
                    }else
                    {
                        t1_o2.setEnabled(true);
                        t1_o3.setEnabled(true);
                    }
                    t1_psize.setEnabled(true);
                    testStarted = false;
                    startTest.setEnabled(true);
                    startTest.setText("Start");
                    updateLog("[Test Stopped for Data Path-0]", logStatus);
                    
         }     
    }
    private JPanel testPanelItems1(){
        JPanel panel = new JPanel();
        panel.setComponentOrientation(
                ComponentOrientation.LEFT_TO_RIGHT);
        /*panel.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createTitledBorder("Test Parameters-1"),
                        BorderFactory.createEmptyBorder()));*/
        float w = (float)((float)width*0.4);
        //panel.setPreferredSize(new Dimension((int)w, 100));
        panel.add(new JLabel("Data Path-1:"));
        t2_o1 =  new JCheckBox("Loopback");
        if (mode == LandingPage.PERFORMANCE_MODE_GENCHK ||
            mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
            t2_o1.setToolTipText("This loops back software generated traffic at DMA user interface");
       else if (mode == LandingPage.PERFORMANCE_MODE_RAW ||
            mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
           t2_o1.setToolTipText("This loops back software generated raw Ethernet frames at 10G PHY");   
             
        t2_o1.setSelected(true);
        t2_o1.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent ae) {
                if (mode == LandingPage.PERFORMANCE_MODE_RAW||
                        mode == LandingPage.PERFORMANCE_MODE_RAW_DV){
                        t2_o1.setSelected(true);
                        return;
                }
                if (t2_o1.isSelected())
                {
                    // disable others
                    test2_option = DriverInfo.ENABLE_LOOPBACK;
                    t2_o2.setSelected(false);
                    t2_o3.setSelected(false);
                }
                else{
                    if (!t2_o2.isSelected() && !t2_o3.isSelected()){
                       test2_option = DriverInfo.CHECKER; 
                       t2_o2.setSelected(true);
                    }
                }
            }
        });
        //b1.setSelected(true);
        t2_o2 =  new JCheckBox("HW Checker");
        if (mode == LandingPage.PERFORMANCE_MODE_GENCHK ||
            mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
            t2_o2.setToolTipText("This enables Checker in hardware at DMA user interface verifying traffic generated by software");
        t2_o2.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent ae) {
                if (t2_o2.isSelected())
                {
                    // disable others
                    test2_option = DriverInfo.CHECKER;
                    t2_o1.setSelected(false);
                    //t2_o3.setSelected(false);
                    if (t2_o3.isSelected())
                        test2_option = DriverInfo.CHECKER_GEN;
                }else{
                    if (t2_o3.isSelected())
                        test2_option = DriverInfo.GENERATOR;
                    else{
                        test2_option = DriverInfo.ENABLE_LOOPBACK;
                        t2_o1.setSelected(true);
                    }
                }
            }
        });
        //b2.setEnabled(false);
        t2_o3 =  new JCheckBox("HW Generator");
        if (mode == LandingPage.PERFORMANCE_MODE_GENCHK ||
            mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV)
            t2_o3.setToolTipText("This enables traffic generator in hardware at the DMA user interface");
        t2_o3.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent ae) {
                if (t2_o3.isSelected())
                {
                    // disable others
                    test2_option = DriverInfo.GENERATOR;
                    t2_o1.setSelected(false);
                    //t2_o2.setSelected(false);
                    if (t2_o2.isSelected())
                        test2_option = DriverInfo.CHECKER_GEN;
                }else{
                    if (t2_o2.isSelected())
                        test2_option = DriverInfo.CHECKER;
                    else{
                        test2_option = DriverInfo.ENABLE_LOOPBACK;
                        t2_o1.setSelected(true);
                    }
                }
            }
        });
        //b3.setEnabled(false);
        JPanel ip = new JPanel();
        ip.setLayout(new BoxLayout(ip, BoxLayout.PAGE_AXIS));
        ip.add(t2_o1); ip.add(t2_o2); ip.add(t2_o3);
        panel.add(ip);
        panel.add(new JLabel("Packet Size (bytes):"));
        t2_psize = new JTextField("32768", 5); 
        panel.add(t2_psize);
        stest =  new JButton("Start");
        stest.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent ae) {
                
                //Check for led status and start the test
                if (mode == LandingPage.PERFORMANCE_MODE_RAW ||
                    mode == LandingPage.PERFORMANCE_MODE_RAW_DV)
                {
                    if (lstats.ddrCalib == LED_OFF &&
                        (lstats.phy0 == LED_ON &&
                        lstats.phy1 == LED_ON)){
                    JOptionPane.showMessageDialog(null, 
                                "DDR3 is not calibrated. Test cannot be started", "Error", 
                                JOptionPane.ERROR_MESSAGE);
                        return;
                    }else if (lstats.ddrCalib == LED_OFF &&
                        (lstats.phy0 == LED_OFF ||
                        lstats.phy1 == LED_OFF)){
                    JOptionPane.showMessageDialog(null, 
                                "DDR3 is not calibrated and 10G-PHY link is down. Test cannot be started", "Error", 
                                JOptionPane.ERROR_MESSAGE);
                        return;
                    }else if(lstats.ddrCalib == LED_ON &&
                        (lstats.phy0 == LED_OFF ||
                        lstats.phy1 == LED_OFF)){
                        JOptionPane.showMessageDialog(null, 
                                "10G-PHY link is down. Test cannot be started", "Error", 
                                JOptionPane.ERROR_MESSAGE);
                        return;
                    }
                }
                if (stest.getText().equals("Start")){
                    int psize = 0;
                    dataMismatch2 = errcnt1 = false; 
                    try{
                         psize = Integer.parseInt(t2_psize.getText());
                    }catch(Exception e){
                        JOptionPane.showMessageDialog(null, 
                                "Only Natural numbers are allowed", "Error", 
                                JOptionPane.ERROR_MESSAGE);
                        return;
                    }
                    if (psize < minpkt1 || psize > maxpkt1)
                    {
                        JOptionPane.showMessageDialog(null, 
                                "Packet size must be within "+minpkt1+" to "+maxpkt1+" bytes", "Error", 
                                JOptionPane.ERROR_MESSAGE);
                        return;
                    }
                    di.startTest(1, test2_option, psize);
                    t2_o1.setEnabled(false);
                    t2_o2.setEnabled(false);
                    t2_o3.setEnabled(false);
                    t2_psize.setEnabled(false);
                    stest.setText("Stop"); 
                    testStarted1 = true;
                    updateLog("[Test Started for Data Path-1]", logStatus);
                    
                }else if(stest.getText().equals("Stop")){
                    // Disable button to avoid multiple clicks
                    stest.setEnabled(false);
                    SwingWorker worker = new SwingWorker<Void, Void>(){

                        @Override
                        protected Void doInBackground() throws Exception {
                            try{
                                stopTest2();
                            }catch(Exception e){
                                e.printStackTrace();
                            }
                            return null;
                        }
                        
                    };
                    worker.execute();
                } 
            }
        });
        panel.add(stest);
        if ((mode == LandingPage.APPLICATION_MODE)|| (mode == LandingPage.APPLICATION_MODE_P2P)){
            t2_o1.setSelected(false);
            t2_o2.setSelected(false);
            t2_o3.setSelected(false);
            t2_o1.setEnabled(false);
            t2_o2.setEnabled(false);
            t2_o3.setEnabled(false);
            t2_psize.setEnabled(false);
            t2_psize.setText("");
            stest.setEnabled(false);
        }
        return panel;
    }
    
    
    private void stopTest2(){
         
         int ret = di.stopTest(1, test2_option, Integer.parseInt(t2_psize.getText()));
           if (ret == -1){
               updateLog("Unable to stop test on Data Path - 1", keyWord);
           }else{
                    t2_o1.setEnabled(true);
                    if (mode == LandingPage.PERFORMANCE_MODE_RAW ||
                        mode == LandingPage.PERFORMANCE_MODE_RAW_DV){
                        t2_o2.setEnabled(false);
                        t2_o3.setEnabled(false);
                    }else
                    {
                        t2_o2.setEnabled(true);
                        t2_o3.setEnabled(true);
                    }
                    
                    t2_psize.setEnabled(true);
                    testStarted1 = false;   
                    stest.setEnabled(true);
                    stest.setText("Start");
                    updateLog("[Test Stopped for Data Path-1]", logStatus);
                    
           }
    }
    
    public boolean isVisible(){
        return frame.isVisible();
    }
    
    
    class ImagePanel extends JPanel{
        Image image;
        String txt;
        ImagePanel(Image image){
            this.image = image;
        }
        protected void paintComponent(Graphics g) {
            super.paintComponent(g);
                   
            int x = (this.getWidth() - image.getWidth(null))/2;
            int y = (this.getHeight() - image.getHeight(null))/2;
            g.drawImage(image, x, y, null);
            System.out.println("w, h, x, y: "+this.getWidth()+","+this.getHeight()+","+x+","+y);
        }
    }
    class ImageBackgroundPanel extends JPanel {
        Image image;
        boolean start;
        
        ImageBackgroundPanel(Image image, boolean st) {
            this.image = image;
            this.start = st;
        }
 
        protected void paintComponent(Graphics g) {
            super.paintComponent(g);
            if (start)
            {
                int x = (this.getWidth() - image.getWidth(null)) / 2;
                int y = 15;
                g.drawImage(image, x, y, this);
            }
            else{
                int x = (this.getWidth() - image.getWidth(null)) / 2;
                int y = (this.getHeight() - image.getHeight(null)) / 2;
                g.drawImage(image, x, y, this); 
            }
        }
    }
}
