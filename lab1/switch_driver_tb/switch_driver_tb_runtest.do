# simulation run script for switch_driver_tb
# to use in Avtive-HDL environment
SetActiveLib -work
comp -include "$dsn\src\switch_driver.vhd"
comp -include "$dsn\src\switch_driver_tb\switch_driver_tb.vhd"
asim +access +r switch_driver_tb_conf
wave
wave -noreg clk
wave -noreg rst
wave -noreg swi
wave -noreg rie
wave -noreg fae
wave -noreg lvl
wave -noreg tgl
wave -noreg lpr
run 3 ms;
