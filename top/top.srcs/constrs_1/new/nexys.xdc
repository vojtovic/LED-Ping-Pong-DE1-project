# =================================================
# Nexys A7-50T - Constraints for ping_pong_top
# Based on https://github.com/Digilent/digilent-xdc
# =================================================

# -----------------------------------------------
# Clock
# -----------------------------------------------
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports {clk}];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk}];

# -----------------------------------------------
# Push buttons (active-high on Nexys A7)
# -----------------------------------------------
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports {rst}];
set_property -dict { PACKAGE_PIN P17 IOSTANDARD LVCMOS33 } [get_ports {btn_l_in}];
set_property -dict { PACKAGE_PIN M17 IOSTANDARD LVCMOS33 } [get_ports {btn_r_in}];
# set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33 } [get_ports {btnu}];
# set_property -dict { PACKAGE_PIN P18 IOSTANDARD LVCMOS33 } [get_ports {btnd}];

# -----------------------------------------------
# LEDs
# -----------------------------------------------
set_property PACKAGE_PIN H17 [get_ports {led[0]}];
set_property PACKAGE_PIN K15 [get_ports {led[1]}];
set_property PACKAGE_PIN J13 [get_ports {led[2]}];
set_property PACKAGE_PIN N14 [get_ports {led[3]}];
set_property PACKAGE_PIN R18 [get_ports {led[4]}];
set_property PACKAGE_PIN V17 [get_ports {led[5]}];
set_property PACKAGE_PIN U17 [get_ports {led[6]}];
set_property PACKAGE_PIN U16 [get_ports {led[7]}];
set_property PACKAGE_PIN V16 [get_ports {led[8]}];
set_property PACKAGE_PIN T15 [get_ports {led[9]}];
set_property PACKAGE_PIN U14 [get_ports {led[10]}];
set_property PACKAGE_PIN T16 [get_ports {led[11]}];
set_property PACKAGE_PIN V15 [get_ports {led[12]}];
set_property PACKAGE_PIN V14 [get_ports {led[13]}];
set_property PACKAGE_PIN V12 [get_ports {led[14]}];
set_property PACKAGE_PIN V11 [get_ports {led[15]}];
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

# -----------------------------------------------
# Seven-segment cathodes CA..CG (active-low)
# seg(6)=g, seg(5)=f, seg(4)=e, seg(3)=d, seg(2)=c, seg(1)=b, seg(0)=a
# -----------------------------------------------
set_property PACKAGE_PIN T10 [get_ports {seg[0]}]; # CA (segment a)
set_property PACKAGE_PIN R10 [get_ports {seg[1]}]; # CB (segment b)
set_property PACKAGE_PIN K16 [get_ports {seg[2]}]; # CC (segment c)
set_property PACKAGE_PIN K13 [get_ports {seg[3]}]; # CD (segment d)
set_property PACKAGE_PIN P15 [get_ports {seg[4]}]; # CE (segment e)
set_property PACKAGE_PIN T11 [get_ports {seg[5]}]; # CF (segment f)
set_property PACKAGE_PIN L18 [get_ports {seg[6]}]; # CG (segment g)
set_property IOSTANDARD LVCMOS33 [get_ports {seg[*]}]

# -----------------------------------------------
# Seven-segment anodes AN7..AN0 (active-low)
# -----------------------------------------------
set_property PACKAGE_PIN J17 [get_ports {anode[0]}];
set_property PACKAGE_PIN J18 [get_ports {anode[1]}];
set_property PACKAGE_PIN T9  [get_ports {anode[2]}];
set_property PACKAGE_PIN J14 [get_ports {anode[3]}];
set_property PACKAGE_PIN P14 [get_ports {anode[4]}];
set_property PACKAGE_PIN T14 [get_ports {anode[5]}];
set_property PACKAGE_PIN K2  [get_ports {anode[6]}];
set_property PACKAGE_PIN U13 [get_ports {anode[7]}];
set_property IOSTANDARD LVCMOS33 [get_ports {anode[*]}]

# -----------------------------------------------
# RGB LED16 — hit/miss indicator
# -----------------------------------------------
set_property -dict { PACKAGE_PIN N15 IOSTANDARD LVCMOS33 } [get_ports {led_r}];
set_property -dict { PACKAGE_PIN M16 IOSTANDARD LVCMOS33 } [get_ports {led_g}];
# set_property -dict { PACKAGE_PIN R12 IOSTANDARD LVCMOS33 } [get_ports {led16_b}];

# -----------------------------------------------
# Unused peripherals (active constraints removed)
# -----------------------------------------------
# Switches:     sw[15:0]   — not used
# RGB LED17:    N16/R11/G14 — not used
# USB-RS232:    C4/D4/D3/E5 — not used
# Pmod JA:      C17/D18/E18/G17/D17/E17/F18/G18 — not used
