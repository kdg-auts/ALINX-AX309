# Script to run lab4 - testbench for uart module with fifo
SetActiveLib -work
comp -include "$dsn\src\fifo_buffer.vhd"
comp -include "$dsn\src\fifo_buffer_tb.vhd"
asim +access +r fifo_buffer_tb 
wave
# testbench signals
wave -noreg CLK
wave -noreg RST
wave -noreg read_data
wave -noreg write_data
wave -noreg data_in
wave -noreg fifo_empty
wave -noreg fifo_full
wave -noreg data_out  

## tx_buffer signals
wave -vgroup "FIFO BUFFER" "uut/write_ptr_reg" "uut/read_ptr_reg" "uut/array_reg" "uut/wr_en"

run 1000 ns