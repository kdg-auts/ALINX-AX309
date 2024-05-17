# Script to run lab4 main testbench
SetActiveLib -work
comp -include "$dsn\src\beep_driver.vhd"
comp -include "$dsn\src\led_driver.vhd"
comp -include "$dsn\src\switch_driver.vhd"
comp -include "$dsn\src\hexled_driver.vhd"
comp -include "$dsn\src\control_fsm.vhd"
# compile uart submodules
comp -include "$dsn\src\uart_module\baud_generator.vhd"
comp -include "$dsn\src\uart_module\uart_receiver.vhd"
comp -include "$dsn\src\uart_module\uart_transmitter.vhd"
comp -include "$dsn\src\uart_module\fifo_buffer.vhd"
comp -include "$dsn\src\uart_module\uart_module_fifo.vhd"
# compile testbench
comp -include "$dsn\src\lab4_hexled_uart_demo_tb.vhd"
asim +access +r lab4_hexled_uart_demo_tb 
wave
# testbench signals
add wave -noreg -logic {/lab4_hexled_uart_demo_tb/clk}
add wave -noreg -logic {/lab4_hexled_uart_demo_tb/rst}
add wave -noreg -color 0,128,128 -hexadecimal -literal -unsigned {/lab4_hexled_uart_demo_tb/swi_test}
add wave -noreg -color 0,192,192 -logic {/lab4_hexled_uart_demo_tb/sw_prev}
add wave -noreg -color 0,192,192 -logic {/lab4_hexled_uart_demo_tb/sw_next}
add wave -noreg -color 0,192,192 -logic {/lab4_hexled_uart_demo_tb/sw_right}
add wave -noreg -color 0,192,192 -logic {/lab4_hexled_uart_demo_tb/sw_left}
add wave -noreg -color 128,0,128 -hexadecimal -literal {/lab4_hexled_uart_demo_tb/segment_data}
add wave -noreg -color 128,0,128 -hexadecimal -literal {/lab4_hexled_uart_demo_tb/digit_select}
add wave -noreg -color 255,128,0 -hexadecimal -literal -unsigned {/lab4_hexled_uart_demo_tb/led_state}
add wave -noreg -color 132,4,0 -logic {/lab4_hexled_uart_demo_tb/beep_sound}
add wave -noreg -color 0,0,255 -logic -bold {/lab4_hexled_uart_demo_tb/tx_output}
add wave -noreg -binary -literal {/lab4_hexled_uart_demo_tb/transmit_data_reg}
add wave -noreg -color 0,128,0 -logic -bold {/lab4_hexled_uart_demo_tb/rx_input}
# hexdigit display decoder
add wave -noreg -color 255,0,255 -hexadecimal -literal {/lab4_hexled_uart_demo_tb/hexdisplay}
# main FSM signals
add wave -noreg -vgroup "main FSM" -bold {/lab4_hexled_uart_demo_tb/UUT/main_fsm/reg_sig} {/lab4_hexled_uart_demo_tb/UUT/main_fsm/fsm_state} {/lab4_hexled_uart_demo_tb/UUT/main_fsm/send_pointer_sig} {/lab4_hexled_uart_demo_tb/UUT/main_fsm/TX_DATA} {/lab4_hexled_uart_demo_tb/UUT/main_fsm/TX_DATA_WR} {/lab4_hexled_uart_demo_tb/UUT/main_fsm/TX_BUF_FULL} {/lab4_hexled_uart_demo_tb/UUT/main_fsm/send_timer_sig} {/lab4_hexled_uart_demo_tb/UUT/main_fsm/count_start_sig} {/lab4_hexled_uart_demo_tb/UUT/main_fsm/count_finish_sig} {/lab4_hexled_uart_demo_tb/UUT/main_fsm/RX_DATA} {/lab4_hexled_uart_demo_tb/UUT/main_fsm/RX_DATA_RDY} {/lab4_hexled_uart_demo_tb/UUT/main_fsm/RX_DATA_ACK} {/lab4_hexled_uart_demo_tb/UUT/main_fsm/fsm_proc/update_pointer}
# switch driver LEFT signals
add wave -noreg -vgroup "SW-LEFT" -bold {/lab4_hexled_uart_demo_tb/UUT/sw_drv1/sw_state_shiftreg} {/lab4_hexled_uart_demo_tb/UUT/sw_drv1/RIE} {/lab4_hexled_uart_demo_tb/UUT/sw_drv1/FAE}
# switch driver RIGHT signals
add wave -noreg -vgroup "SW-RIGHT" -bold {/lab4_hexled_uart_demo_tb/UUT/sw_drv2/sw_state_shiftreg} {/lab4_hexled_uart_demo_tb/UUT/sw_drv2/RIE} {/lab4_hexled_uart_demo_tb/UUT/sw_drv2/FAE}
# switch driver NEXT signals
add wave -noreg -vgroup "SW-NEXT" -bold {/lab4_hexled_uart_demo_tb/UUT/sw_drv3/sw_state_shiftreg} {/lab4_hexled_uart_demo_tb/UUT/sw_drv3/RIE} {/lab4_hexled_uart_demo_tb/UUT/sw_drv3/FAE}
# switch driver PREV signals
add wave -noreg -vgroup "SW-PREV" -bold {/lab4_hexled_uart_demo_tb/UUT/sw_drv4/sw_state_shiftreg} {/lab4_hexled_uart_demo_tb/UUT/sw_drv4/RIE} {/lab4_hexled_uart_demo_tb/UUT/sw_drv4/FAE}
# BEEPER driver signals
add wave -noreg -vgroup "BEEPER" -bold -decimal -signed2 {/lab4_hexled_uart_demo_tb/UUT/beep_drv/snd_state} {/lab4_hexled_uart_demo_tb/UUT/beep_drv/beep_counter} {/lab4_hexled_uart_demo_tb/UUT/beep_drv/snd_counter}  
# UART transmitter signals
add wave -noreg -vgroup "TRANSMITTER"  -bold {/lab4_hexled_uart_demo_tb/UUT/uart_module/transmit_unit/BDT} {/lab4_hexled_uart_demo_tb/UUT/uart_module/transmit_unit/STX} {/lab4_hexled_uart_demo_tb/UUT/uart_module/transmit_unit/DIN} {/lab4_hexled_uart_demo_tb/UUT/uart_module/transmit_unit/FTX} {/lab4_hexled_uart_demo_tb/UUT/uart_module/transmit_unit/state_reg} {/lab4_hexled_uart_demo_tb/UUT/uart_module/transmit_unit/baud_tick_count_reg} {/lab4_hexled_uart_demo_tb/UUT/uart_module/transmit_unit/bit_count_reg} {/lab4_hexled_uart_demo_tb/UUT/uart_module/transmit_unit/tx_byte_reg}
# UART transmitter data buffer signals
add wave -noreg -vgroup "TX BUFFER"  -bold {/lab4_hexled_uart_demo_tb/UUT/uart_module/tx_buffer/RD} {/lab4_hexled_uart_demo_tb/UUT/uart_module/tx_buffer/WR} {/lab4_hexled_uart_demo_tb/UUT/uart_module/tx_buffer/DI} {/lab4_hexled_uart_demo_tb/UUT/uart_module/tx_buffer/EMPT} {/lab4_hexled_uart_demo_tb/UUT/uart_module/tx_buffer/FULL} {/lab4_hexled_uart_demo_tb/UUT/uart_module/tx_buffer/DO} {/lab4_hexled_uart_demo_tb/UUT/uart_module/tx_buffer/array_reg}
# UART receiver signals
add wave -noreg -vgroup "RECEIVER"  -bold {/lab4_hexled_uart_demo_tb/UUT/uart_module/receive_unit/RDY} {/lab4_hexled_uart_demo_tb/UUT/uart_module/receive_unit/PDO} {/lab4_hexled_uart_demo_tb/UUT/uart_module/receive_unit/state_reg} {/lab4_hexled_uart_demo_tb/UUT/uart_module/receive_unit/sample_count_reg} {/lab4_hexled_uart_demo_tb/UUT/uart_module/receive_unit/bit_count_reg} {/lab4_hexled_uart_demo_tb/UUT/uart_module/receive_unit/rx_data_reg}
# UART receiver data buffer signals
add wave -noreg -vgroup "RX BUFFER"  -bold {/lab4_hexled_uart_demo_tb/UUT/uart_module/rx_buffer/RD} {/lab4_hexled_uart_demo_tb/UUT/uart_module/rx_buffer/WR} {/lab4_hexled_uart_demo_tb/UUT/uart_module/rx_buffer/DI} {/lab4_hexled_uart_demo_tb/UUT/uart_module/rx_buffer/EMPT} {/lab4_hexled_uart_demo_tb/UUT/uart_module/rx_buffer/FULL} {/lab4_hexled_uart_demo_tb/UUT/uart_module/rx_buffer/DO} {/lab4_hexled_uart_demo_tb/UUT/uart_module/rx_buffer/array_reg}
 
run 2000 us