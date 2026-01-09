# FILE: basys3_constraints.xdc
# PURPOSE: Pin assignments and timing constraints for Basys 3 FPGA board
# USAGE: Add this file to your Vivado project as a constraints file

# ============================================
# CLOCK SIGNAL (100 MHz system clock)
# ============================================
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

# ============================================
# RESET BUTTON (Center button - BTNC)
# ============================================
set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

# ============================================
# COIN INPUT SWITCHES
# ============================================
# SW0 - 5 Rupee Coin (rightmost switch)
set_property PACKAGE_PIN V17 [get_ports coin5]
set_property IOSTANDARD LVCMOS33 [get_ports coin5]

# SW1 - 10 Rupee Coin
set_property PACKAGE_PIN V16 [get_ports coin10]
set_property IOSTANDARD LVCMOS33 [get_ports coin10]

# SW2 - 15 Rupee Coin
set_property PACKAGE_PIN W16 [get_ports coin15]
set_property IOSTANDARD LVCMOS33 [get_ports coin15]

# ============================================
# NEWSPAPER OUTPUT LED (LED15 - leftmost LED)
# ============================================
set_property PACKAGE_PIN L1 [get_ports newspaper]
set_property IOSTANDARD LVCMOS33 [get_ports newspaper]

# ============================================
# AMOUNT DISPLAY LEDs (LED4 to LED0)
# ============================================
# LED0 - rightmost LED for amount display
set_property PACKAGE_PIN U16 [get_ports {led_amount[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_amount[0]}]

# LED1
set_property PACKAGE_PIN E19 [get_ports {led_amount[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_amount[1]}]

# LED2
set_property PACKAGE_PIN U19 [get_ports {led_amount[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_amount[2]}]

# LED3
set_property PACKAGE_PIN V19 [get_ports {led_amount[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_amount[3]}]

# LED4
set_property PACKAGE_PIN W18 [get_ports {led_amount[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_amount[4]}]

# ============================================
# CONFIGURATION OPTIONS
# ============================================
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
