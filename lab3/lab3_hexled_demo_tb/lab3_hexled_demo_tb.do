# Script to run lab3 main testbench
SetActiveLib -work
comp -include "$dsn\src\beep_driver.vhd"
comp -include "$dsn\src\led_driver.vhd"
comp -include "$dsn\src\switch_driver.vhd"
comp -include "$dsn\src\hexled_driver.vhd"
comp -include "$dsn\src\control_fsm.vhd"
comp -include "$dsn\src\lab3_hexled_demo_tb\lab3_hexled_demo_tb.vhd"
asim +access +r lab3_hexled_demo_tb 
wave
# testbench signals
wave -noreg CLK
wave -noreg RST
wave -noreg swi_test
wave -noreg sw_prev
wave -noreg sw_next
wave -noreg sw_right
wave -noreg sw_left
wave -noreg segment_data
wave -noreg digit_select
wave -noreg led_state
wave -noreg beep_sound
# hexdigit display decoder
wave -noreg hexdisplay
# main fsm signals
wave -vgroup "main FSM" "UUT/main_fsm/fsm_state" "UUT/main_fsm/reg_sig"
# switch driver LEFT signals
wave -vgroup "SW-LEFT" "UUT/sw_drv1/sw_state_shiftreg" "UUT/sw_drv1/RIE" "UUT/sw_drv1/FAE"
# switch driver RIGHT signals
wave -vgroup "SW-LEFT" "UUT/sw_drv2/sw_state_shiftreg" "UUT/sw_drv2/RIE" "UUT/sw_drv2/FAE"
# switch driver NEXT signals
wave -vgroup "SW-LEFT" "UUT/sw_drv3/sw_state_shiftreg" "UUT/sw_drv3/RIE" "UUT/sw_drv3/FAE"
# switch driver PREV signals
wave -vgroup "SW-LEFT" "UUT/sw_drv4/sw_state_shiftreg" "UUT/sw_drv4/RIE" "UUT/sw_drv4/FAE"
# switch driver BEEPER signals
wave -vgroup "BEEPER" "UUT/beep_drv/snd_state" "UUT/beep_drv/beep_counter" "UUT/beep_drv/snd_counter"  
run 360 us