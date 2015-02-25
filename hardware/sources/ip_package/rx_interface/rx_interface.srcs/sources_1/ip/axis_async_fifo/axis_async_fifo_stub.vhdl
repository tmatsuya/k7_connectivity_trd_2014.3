-- Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2014.3.0 (lin64) Build 980735 Sun Aug 10 20:51:28 MDT 2014
-- Date        : Mon Aug 11 14:33:58 2014
-- Host        : xhd-lin64re92 running 64-bit Red Hat Enterprise Linux Client release 5.9 (Tikanga)
-- Command     : write_vhdl -force -mode synth_stub
--               /wrk/paeg/users/bokkaab/trd_2014.3/k7_connectivity_trd_2014.3/hardware/sources/ip_package/rx_interface/rx_interface.srcs/sources_1/ip/axis_async_fifo/axis_async_fifo_stub.vhdl
-- Design      : axis_async_fifo
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k325tffg900-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity axis_async_fifo is
  Port ( 
    m_aclk : in STD_LOGIC;
    s_aclk : in STD_LOGIC;
    s_aresetn : in STD_LOGIC;
    s_axis_tvalid : in STD_LOGIC;
    s_axis_tready : out STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    s_axis_tkeep : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axis_tlast : in STD_LOGIC;
    m_axis_tvalid : out STD_LOGIC;
    m_axis_tready : in STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axis_tkeep : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_tlast : out STD_LOGIC;
    axis_wr_data_count : out STD_LOGIC_VECTOR ( 12 downto 0 );
    axis_rd_data_count : out STD_LOGIC_VECTOR ( 12 downto 0 )
  );

end axis_async_fifo;

architecture stub of axis_async_fifo is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "m_aclk,s_aclk,s_aresetn,s_axis_tvalid,s_axis_tready,s_axis_tdata[63:0],s_axis_tkeep[7:0],s_axis_tlast,m_axis_tvalid,m_axis_tready,m_axis_tdata[63:0],m_axis_tkeep[7:0],m_axis_tlast,axis_wr_data_count[12:0],axis_rd_data_count[12:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "fifo_generator_v12_0,Vivado 2014.3.0";
begin
end;
