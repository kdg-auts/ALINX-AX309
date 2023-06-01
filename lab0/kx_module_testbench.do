SetActiveLib -work
comp -include "$dsn\src\kxx_module.vhd"
comp -include "$dsn\src\kxx_module_tb.vhd"
asim +access +r kxx_module_testbench
wave
wave -noreg t_x
wave -noreg t_y
wave -noreg uut/int_x
wave -noreg uut/int_y
run 200 ns