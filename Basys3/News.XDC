# Basys 3 constraints file

# Clock (100 MHz)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

# Reset button 
set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

# Coin input switches
# SW0 = 5 rupee
set_property PACKAGE_PIN V17 [get_ports coin5]
set_property IOSTANDARD LVCMOS33 [get_ports coin5]

# SW1 = 10 rupee
set_property PACKAGE_PIN V16 [get_ports coin10]
set_property IOSTANDARD LVCMOS33 [get_ports coin10]

# SW2 = 15 rupee
set_property PACKAGE_PIN W16 [get_ports coin15]
set_property IOSTANDARD LVCMOS33 [get_ports coin15]

# Newspaper output LED
set_property PACKAGE_PIN L1 [get_ports newspaper]
set_property IOSTANDARD LVCMOS33 [get_ports newspaper]

# Amount display LEDs
set_property PACKAGE_PIN U16 [get_ports {led_amount[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_amount[0]}]

set_property PACKAGE_PIN E19 [get_ports {led_amount[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_amount[1]}]

set_property PACKAGE_PIN U19 [get_ports {led_amount[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_amount[2]}]

set_property PACKAGE_PIN V19 [get_ports {led_amount[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_amount[3]}]

set_property PACKAGE_PIN W18 [get_ports {led_amount[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_amount[4]}]

# Board configuration
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
