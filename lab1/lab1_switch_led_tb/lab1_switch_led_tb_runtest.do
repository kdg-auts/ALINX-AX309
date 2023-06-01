# simulation run script for lab1_switch_led_tb
# to use in Avtive-HDL environment
SetActiveLib -work
comp -include "$dsn\src\switch_driver.vhd"
comp -include "$dsn\src\led_driver.vhd"
comp -include "$dsn\src\control_fsm.vhd"
comp -include "$dsn\src\switch_led_tester.vhd"
comp -include "$dsn\src\lab1_switch_led.vhd"
comp -include "$dsn\src\lab1_switch_led_tb.vhd"
asim +access +r lab1_switch_led_tb
wave
wave -noreg clk
wave -noreg rst
wave -noreg swi
wave -noreg led
wave -divider "switch_driver"
wave -noreg "uut/U1/U1/sw_state_shiftreg"
wave -noreg "uut/U1/U1/sw_fsm_state"
wave -noreg "uut/U1/U1/sw_scan_counter"
wave -noreg "uut/U1/U1/shiftreg_en"
wave -noreg "uut/U1/U1/rie"
wave -noreg "uut/U1/U1/fae"
wave -noreg "uut/U1/U1/lpr"
wave -noreg "uut/U1/U1/long_press_counter"
wave -divider "control_fsm"
wave -noreg "uut/U1/U2/fsm_state"
wave -noreg "uut/U1/U2/led_mode_sig"
wave -divider "led_driver"
wave -noreg "uut/U1/U3/counter_1"
wave -noreg "uut/U1/U3/wave_1sec"	
wave -noreg "uut/U1/U3/counter_2"
wave -noreg "uut/U1/U3/wave_100ms"
run 3 ms;
