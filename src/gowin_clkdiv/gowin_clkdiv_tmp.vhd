--Copyright (C)2014-2023 Gowin Semiconductor Corporation.
--All rights reserved.
--File Title: Template file for instantiation
--GOWIN Version: V1.9.8.11 Education
--Part Number: GW2AR-LV18QN88C8/I7
--Device: GW2AR-18
--Device Version: C
--Created Time: Fri Jun 16 19:18:54 2023

--Change the instance name and port connections to the signal names
----------Copy here to design--------

component Gowin_CLKDIV
    port (
        clkout: out std_logic;
        hclkin: in std_logic;
        resetn: in std_logic
    );
end component;

your_instance_name: Gowin_CLKDIV
    port map (
        clkout => clkout_o,
        hclkin => hclkin_i,
        resetn => resetn_i
    );

----------Copy end-------------------
