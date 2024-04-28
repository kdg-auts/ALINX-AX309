# Script to run lab4 - testbench for uart functional verification
SetActiveLib -work
comp -include "$dsn\src\baud_generator.vhd"
comp -include "$dsn\src\uart_receiver.vhd"
comp -include "$dsn\src\uart_transmitter.vhd"
comp -include "$dsn\src\buf_flag_register.vhd"
comp -include "$dsn\src\uart_module.vhd"
comp -include "$dsn\src\uart_module_tb.vhd"
asim +access +r uart_module_tb 
wave
# testbench signals
wave -noreg CLK
wave -noreg RST
wave -noreg start_tx
wave -noreg test_data
wave -noreg serial_line
wave -noreg tx_is_busy
wave -noreg received_data
wave -noreg receive_acknoledge

## tx_buffer signals
wave -vgroup "TX BUFFER" "uut/tx_buffer/DTI" "uut/tx_buffer/STF" "uut/tx_buffer/DTO" "uut/tx_buffer/FLG" "uut/tx_buffer/CLF" "uut/tx_buffer/data_reg" "uut/tx_buffer/flag_reg"
wave -vgroup "TRANSMITTER" "uut/transmit_unit/STX" "uut/transmit_unit/DIN" "uut/transmit_unit/FTX" "uut/transmit_unit/BDT" "uut/transmit_unit/TXO" "uut/transmit_unit/state_reg" "uut/transmit_unit/tx_byte_reg" "uut/transmit_unit/bit_count_reg" "uut/transmit_unit/baud_tick_count_reg" "uut/transmit_unit/tx_bit_reg"
wave -vgroup "RECEIVER" "uut/receive_unit/RXI" "uut/receive_unit/PDO" "uut/receive_unit/RDY" "uut/receive_unit/BDT" "uut/receive_unit/state_reg" "uut/receive_unit/rx_data_reg" "uut/receive_unit/bit_count_reg" "uut/receive_unit/sample_count_reg"
wave -vgroup "RX BUFFER" "uut/rx_buffer/DTI" "uut/rx_buffer/STF" "uut/rx_buffer/DTO" "uut/rx_buffer/FLG" "uut/rx_buffer/CLF" "uut/rx_buffer/data_reg" "uut/rx_buffer/flag_reg"


run 3100 us