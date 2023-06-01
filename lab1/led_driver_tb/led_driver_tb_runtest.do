# simulation run script for led_driver_tb
# to use in Avtive-HDL environment
SetActiveLib -work
comp -include "$dsn\src\led_driver.vhd"
comp -include "$dsn\src\led_driver_tb\led_driver_tb.vhd"
asim +access +r led_driver_tb_conf
wave
wave -noreg clk
wave -noreg rst
wave -noreg mode
wave -noreg led
run 500 us