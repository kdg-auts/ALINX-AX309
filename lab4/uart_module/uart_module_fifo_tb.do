# Script to run lab4 - testbench for uart functional verification
SetActiveLib -work
comp -include "$dsn\src\baud_generator.vhd"
comp -include "$dsn\src\uart_receiver.vhd"
comp -include "$dsn\src\uart_transmitter.vhd"
comp -include "$dsn\src\fifo_buffer.vhd"
comp -include "$dsn\src\uart_module_fifo.vhd"
comp -include "$dsn\src\uart_module_fifo_tb.vhd"
asim +access +r uart_module_fifo_tb 
wave
# testbench signals
wave -noreg CLK
wave -noreg RST
wave -noreg write_tx_fifo
wave -noreg test_data
wave -noreg serial_line
wave -noreg tx_fifo_full
wave -noreg received_data
wave -noreg receive_acknoledge
wave -noreg rx_fifo_full

# tx_buffer signals
wave -vgroup "TX BUFFER - FIFO" "uut/tx_buffer/RD" "uut/tx_buffer/WR" "uut/tx_buffer/DI" "uut/tx_buffer/EMPT" "uut/tx_buffer/FULL" "uut/tx_buffer/DO" "uut/tx_buffer/array_reg" "uut/tx_buffer/read_ptr_reg" "uut/tx_buffer/write_ptr_reg"
wave -vgroup "RX BUFFER - FIFO" "uut/rx_buffer/RD" "uut/rx_buffer/WR" "uut/rx_buffer/DI" "uut/rx_buffer/EMPT" "uut/rx_buffer/FULL" "uut/rx_buffer/DO" "uut/rx_buffer/array_reg" "uut/rx_buffer/read_ptr_reg" "uut/rx_buffer/write_ptr_reg"
wave -vgroup "TRANSMITTER" "uut/transmit_unit/state_reg" "uut/transmit_unit/tx_byte_reg" "uut/transmit_unit/STX" "uut/transmit_unit/DIN" "uut/transmit_unit/FTX" "uut/transmit_unit/TXO"
wave -vgroup "RECEIVER" "uut/receive_unit/state_reg" "uut/receive_unit/rx_data_reg" "uut/receive_unit/RXI" "uut/receive_unit/PDO" "uut/receive_unit/RDY"
wave -vgroup "UART INTERNAL SIGNALS" "uut/fifo_empty_sig" "uut/finish_tx_sig" "uut/start_tx_sig" "uut/read_tx_fifo_sig" "uut/tx_is_busy_sig"

run 13 ms