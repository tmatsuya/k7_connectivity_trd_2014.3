*******************************************************************************
** © Copyright 2012-2013 Xilinx, Inc. All rights reserved.
** This file contains confidential and proprietary information of Xilinx, Inc. and 
** is protected under U.S. and international copyright and other intellectual property laws.
*******************************************************************************
**   ____  ____ 
**  /   /\/   / 
** /___/  \  /   Vendor: Xilinx 
** \   \   \/   
**  \   \        Readme Version: 1.9  
**  /   /        Date Last Modified: 15OCT2014
** /___/   /\     
** \   \  /  \   Associated Filename: Kintex-7 Connectivity Targeted Reference Design 
**  \___\/\___\ 
** 
**  Device: XC7K325T
**  Purpose: Targeted Reference Design
**  Reference: UG927
**     
*******************************************************************************
**
**  Disclaimer: 
**
**      This disclaimer is not a license and does not grant any rights to the materials 
**              distributed herewith. Except as otherwise provided in a valid license issued to you 
**              by Xilinx, and to the maximum extent permitted by applicable law: 
**              (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, 
**              AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
**              INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR 
**              FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract 
**              or tort, including negligence, or under any other theory of liability) for any loss or damage 
**              of any kind or nature related to, arising under or in connection with these materials, 
**              including for any direct, or any indirect, special, incidental, or consequential loss 
**              or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered 
**              as a result of any action brought by a third party) even if such damage or loss was 
**              reasonably foreseeable or Xilinx had been advised of the possibility of the same.


**  Critical Applications:
**
**      Xilinx products are not designed or intended to be fail-safe, or for use in any application 
**      requiring fail-safe performance, such as life-support or safety devices or systems, 
**      Class III medical devices, nuclear facilities, applications related to the deployment of airbags,
**      or any other applications that could lead to death, personal injury, or severe property or 
**      environmental damage (individually and collectively, "Critical Applications"). Customer assumes 
**      the sole risk and liability of any use of Xilinx products in Critical Applications, subject only 
**      to applicable laws and regulations governing limitations on product liability.

**  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.

*******************************************************************************

This readme file contains these sections:

1. REVISION HISTORY
2. OVERVIEW
3. SOFTWARE TOOLS AND SYSTEM REQUIREMENTS
4. DESIGN FILE HIERARCHY
5. INSTALLATION AND OPERATING INSTRUCTIONS
6. OTHER INFORMATION (OPTIONAL)
7. SUPPORT


1. REVISION HISTORY 

            Readme  
Date        Version      Revision Description
=========================================================================
17MAY2012   1.0          Initial Xilinx release.
20JUN2012   1.1          IDS 14.2 Upgrade
04NOV2012   1.2          IDS 14.3 Upgrade
08JAN2013   1.3          Vivado 2012.4 Upgrade
17APR2013   1.4          Vivado 2013.1 Upgrade
7July2013   1.5          Vivado 2013.2 Upgrade
7NOV2013    1.6          Vivado 2013.3 Upgrade
6JAN2014    1.7          Vivado 2013.4 Upgrade
15MAY2014   1.8	         Vivado 2014.1 Upgrade
15OCT2014   1.9          Vivado 2014.3 Upgrade			
=========================================================================

2. OVERVIEW

    This is a x8 GEN2 endpoint design which has scatter gather DMA from
    Northwest Logic, two DDR3 controllers each operating at 1600Mbps, two 
    ten gigabit ethernet MAC with 10GBASE-R physical layer.
    The design operates in the following modes-
    
    a. Performance Mode (GEN/CHK) : This mode highlights PCIe-DMA performance
    with traffic generator and checker connected behind C2S0 and S2C0 channels
    respectively. This mode exercises traffic only through these two DMA
    channels.
    Following options are provided in this mode-
      i. Loopback - Software generates traffic which is transferred to FPGA
      over PCIe-DMA. This data is stored in DDR3 based virtual FIFO and looped
      back to software.
      ii. Checker - Software generates traffic which is transferred to FPGA
      over PCIe-DMA. This is stored in DDR3 based virtual FIFO and verified by
      checker in hardware.
      iii. Generator - Hardware generates traffic which is stored in DDR3
      based virtual FIFO and then passed onto software over PCIe-DMA.

    b. Performance Mode (Raw Ethernet) : This mode highlights hardware network
    path performance. Raw Ethernet broadcast frames from software driver
    traverse through PCIe-DMA, DDR3 virtual FIFO and 10GMAC-10GBASE-R PHY.

    c. Application Mode : This mode showcases use in quad NIC scenario. Basic
    ping functionality is provided as an example.

    Also provided are linux (32-bit and 64-bit Fedora-16) device drivers with user space
    application for traffic generation and consumption.

3. SOFTWARE TOOLS AND SYSTEM REQUIREMENTS

    a. Hardware
      i.  KC705 Connectivity Kit (Rev-1.0 with Production Silicon and other components in kit)
      ii. PC with PCI Express slot (x8 PCIe v2.1 compliant)
      iii.Keyboard & Mouse

    b. Software
     i. QuestaSim v10.2a  
    ii. Vivado 2014.3 
        
    c. IP Versions used
        i. 7 Series PCIe (pcie_x8gen2_axi_st_ip)      : v3.0
       ii. 7 Series MIG (mig_axi_mm)                  : v2.0
      iii. AXI Stream Interconnect                    : v1.0
       iv. AXI Virtual FIFO Controller                : v2.0
        v. AXI4Lite Interconnect (XPS generated)      : v1.06a
       vi. Ten Gigabit Ethernet MAC
                  (ten_gig_eth_mac_axi_st_ip)         : v13.1
      vii. Ten Gigabit PCS-PMA
                  (ten_gig_eth_pcs_pma_ip)            : v4.1
       ix. Fifo Generator                             : v11.0            

4. DESIGN FILE HIERARCHY 

    k7_connectivity_trd : Main TRD folder
    |
    |--ready_to_test : Prebuilt bitfile & MCS file 
    |
    |--hardware : Design files and scripts for simulation & implementation
    |  |
    |  |---sources  
    |  |   |
    |  |   |-- constraints : Constraint files
    |  |   |-- hdl : Custom RTL files required for the design
    |  |   |-- ip_cores : Xilinx and Third Party IPs
    |  |   |-- ip_package : Contains the locally packaged IPs required for the IPI flow
    |  |   `-- testbench : Testbench files for Out Of Box Simulation
    |  |
    |  |---vivado  : Implementation scripts folder
    |  |   |
    |  |   |----scripts: Scripts for vivado flow 
    |    
    |--doc  : Documentation for TRD & Doxygen generated HTML for software code         
    |
    |--software/linux : Source code for linux device driver, user application and Java based GUI         
    |  |
    |  |---driver : Linux driver source files
    |  |   |   
    |  |   |---xdma : Base DMA driver source files
    |  |   |
    |  |   |---xrawdata0, xrawdata1 : Raw data driver source files
    |  |   |
    |  |   |---xxgbeth0, xxgbeth1 : Ethernet driver source files
    |  |
    |  |---gui : Application GUI source files   
    |  |
    |  |---util : Script for address translation for out-of-box ping test  
    |  
    |--software/windows : Executable file for Windows OS        
    |
    |--readme.txt : the file you are currently reading 
    |
    |--ready_to_test : Bit file and MCS for testing on HW 


5. INSTALLATION AND OPERATING INSTRUCTIONS 

   This section summarizes the operating instructions for implementation and simulation flow. 

 IMPLEMENTATION FLOW 
 -------------------
  
a. Vivado IP Integrator flow for Windows and Linux 

      Navigate to 'hardware/vivado/scripts'
      Open the Vivado Design Suite Command prompt and run the following command
        $ vivado -source k7_conn_gui_ipi.tcl
        
        Click on Run Synthesis in the Project Manager window. A window with message "Synthesis Completed Successfully" will appear
        after Vivado generates a design netlist. Close the message window.  Alternatively, you can skip this step and go straight
        to Run Implementation.  The tool will tell you that you need to run synthesis first, click OK to close dialog box to run
        synthesis immediately followed by implementation.

        Click on Run Implementation in the Project Manager window. A window with message "Implementation Completed Successfully" 
        will appear after place and route processes are done. Close the message window.

        Click on Generate Bitstream. Click on OK to generate bitstream.
        A window with message "Generate Bitstream Completed Successfully" will appear at the end of this process and a design bit file 
        will be available under hardware/vivado/runs_ipi/k7_connectivity_trd.runs/impl_1/k7_connectivity_trd_top.bit
       
      Close Vivado GUI.

      To run the Vivado IP Integrator flow in batch mode:
        vivado -mode batch -source k7_conn_impl_ipi_batch.tcl 
      The bit file will be available under hardware/vivado/runs_ipi/k7_connectivity_trd.runs/impl_1/k7_connectivity_trd_top.bit

      Note:While using the Vivado tool on a Windows platform,the path length (on hierarchial expansion of IPs)should not exceed 260 bytes else an error occurs.
      The error is due to a Windows OS limitation. Windows has a 260 character limitation on the maximum length for a path. 
      Due to this limitation, if the path length is more than 260 characters, Vivado and its subsidiary tools might fail.
      The user specified path can be shortened as shown below by using the subst command to a virtual drive letter in Vivado's TCL console or in a script, for example :
      exec subst V: C:/Users/username/workspace/vivado_projects/k7_connectivity_trd/hardware
      By doing the above, all further operations in Vivado will refer to V: instead of C:/Users/username/workspace/vivado_projects/k7_connectivity_trd/hardware
      For more details,refer to AR 52787 in the link:
      http://www.xilinx.com/support/answers/52787.htm  
     

 SIMULATION FLOW 
 ---------------

   QuestaSim
   --------
   Requires Xilinx tools and QuestaSim.

   a. Simulation using the scripts provided
        Navigate to the 'vivado/scripts' folder.
        Set MODELSIM environment variable to point to the 'modelsim.ini' file which contains paths to the compiled libraries.
        Modify the simulator setting to set Questa Simulator
        Run 'vivado -source k7_conn_trd_ipi_mti.tcl' script to simulate the design.
        After the compilation of the design is done ,give the command "run -all" in the transcript window of the QuestaSim GUI.
        Note that Vivado Simulator(XSIM) is setup by default in the k7_conn_gui_ipi.tcl file

   Vivado Simulator (XSIM)
   --------
   Requires Xilinx tools 

   a. Simulation using the scripts provided
       Run 'vivado -source k7_conn_trd_ipi_xsim.tcl' script to simulate the design.
       After the compilation of the design is done ,give the command "run -all" in the tcl console of the XSim GUI.
       

BUILDING THE MCS FILE 
 ---------------
 Follow the steps to build the MCS file after generating the bit file using Vivado Design Suite 2014.3.

  a. Browse to k7_connectivity_trd/hardware/vivado/scripts
  b. This step will generate the MCS file.
     For IP Integrator flow bit file:
      Source k7_conn_ipi_flash.tcl script (vivado -source k7_conn_ipi_flash.tcl)  
  c. The above command generate a MCS file in the k7_connectivity_trd/hardware/vivado/scripts directory. 
  d. To program the flash using Vivado follow the below steps:
           i) Open a hardware session in the Vivado GUI.
          ii) Connect to the hardware device (KC705 board).
         iii) Navigate to k7_connectivity_trd/hardware/vivado/scripts directory and source program_flash.tcl script.   
 TESTING
 -------
   To test the design in hardware, refer to either the GSG or 'Chapter-2 Getting Started' in the TRD user guide under the 'doc' folder. 
   
6. OTHER INFORMATION 
        
  a. The graphical user interface does not show power number plots. 
      This can happen when FPGA is reprogrammed leaving the earlier design accessing PMBUS controllers in an unknown state.
     Resolution: Power off the host machine and power cycle the KC705 board and this should be fixed
     
  b. On certain machines, it is seen that when changing PCIe link width, PCIe link speed (if at 2.5Gbps) automatically comes up to 5Gbps. 
  
  c. Unzipping the TRD zip file in Windows and copying over the unzipped folder to Linux leaves some files without
     having execution permission. User has to manually do 'chmod +x <file name>' on a terminal to make the files executable.

  d. On Fedora 16 64-bit version performance is observed to be less when compared with 
     Fedora latest versions(Fedora 17 and Fedora 18). 

  e. GUI is developed with JDK 1.6 version. Few APIs are depreciated in JDK 1.7. Users 
     need to modify the APIs or use JDK 1.6 to compile the GUI shipped along with the package.

  f. The GUI in TRD uses jfreechart as a library and no modifications have been done to the downloaded source/JAR. jfreechart is downloaded
    from http://www.jfree.org/jfreechart/download.html and is licensed under the terms of LGPL. A copy of the source along with license is
    included in this distribution.

  g. The TRD works on Kintex-7 production silicon

  h. The interrupt mode of operation of driver has been tested with kernel version 3.5

  i. The user can download the Fedora 16 64-bit OS from the below link:
     http://www.fedoraproject.org
     It is advised that user installs the full version of Fedora (DVD ISO image) on the machine with PCIe slot in it. Refer to UG929 for more details on PCIe host machine.
    
 
