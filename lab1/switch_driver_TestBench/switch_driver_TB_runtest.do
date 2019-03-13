SetActiveLib -work
comp -include "$dsn\src\switch_driver.vhd" 
comp -include "$dsn\src\switch_driver_TestBench\switch_driver_TB.vhd" 
asim +access +r TESTBENCH_FOR_switch_driver 
wave 
wave -noreg clk
wave -noreg rst
wave -noreg sw
wave -noreg Redge
wave -noreg Fedge
wave -noreg LVL
wave -noreg Toggle
wave -noreg LPress	  
run 2 ms;
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\switch_driver_TestBench\switch_driver_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_switch_driver 
