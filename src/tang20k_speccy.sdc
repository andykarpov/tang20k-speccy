//Copyright (C)2014-2023 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8.11 Education
//Created Time: 2023-06-17 00:37:27
//create_clock -name clk_tmds -period 7 -waveform {0 3} [get_nets {clk_tmds}]
create_clock -name clk27M -period 37 -waveform {0 18} [get_ports {clk27M}]
//create_generated_clock -name cpuclk -source [get_nets {clk_vga}] -master_clock clk_vga -divide_by 2 [get_nets {cpuclk}]
//create_generated_clock -name clk_usb -source [get_nets {clk_tmds}] -master_clock clk_tmds -divide_by 11 [get_nets {clk_usb}]
//create_generated_clock -name clk_vga -source [get_nets {clk_tmds}] -master_clock clk_tmds -divide_by 5 [get_nets {clk_vga}]
