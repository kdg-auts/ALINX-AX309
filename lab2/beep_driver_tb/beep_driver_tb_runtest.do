# test beep_driver module
comp -include "$dsn\src\beep_driver.vhd"
comp -include "$dsn\src\beep_driver_tb.vhd"
asim +access +r beep_driver_tb 
wave 
wave -noreg CLK
wave -noreg RST
wave -noreg start
wave -noreg mode
wave -noreg sound 
wave -divider "beep_driver"
wave -noreg "uut/snd_state"	
wave -noreg "uut/beep_counter"
wave -noreg "uut/snd_counter"
wave -noreg "uut/db_stage_count"
wave -noreg "uut/beep_en"