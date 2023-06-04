# Script to test hexled_driver module
SetActiveLib -work
comp -include "$dsn\src\hexled_driver.vhd"
comp -include "$dsn\src\hexled_driver_tb\hexled_driver_tb.vhd"
asim +access +r hexled_driver_tb 
wave 
wave -noreg CLK
wave -noreg RST
wave -noreg dot_test
wave -noreg digit_test
# add outputs
wave -divider "hexled outputs"
wave -noreg segment_data
wave -noreg digit_select
# add special signal
wave -noreg hexdigit
run 3250 us