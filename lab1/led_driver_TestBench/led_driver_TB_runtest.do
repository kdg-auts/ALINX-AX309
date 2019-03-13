SetActiveLib -work
comp -include "$dsn\src\led_driver.vhd" 
comp -include "$dsn\src\led_driver_TestBench\led_driver_TB.vhd" 
asim +access +r TESTBENCH_FOR_led_driver 
wave 
wave -noreg clk
wave -noreg rst
wave -noreg state
wave -noreg blink
wave -noreg led	 
run 5 us; 
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\led_driver_TestBench\led_driver_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_led_driver 
