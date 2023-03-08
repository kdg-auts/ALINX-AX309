# lab4 - Working with Universal Serial Data Port (UART)

**Main goal:** Learn how to perform information exchange between a PC and an FPGA-based development board using a universal serial transceiver (UART). Learn how to design complex devices with their own control FSM and learn how to coordinate their interaction. Learn to think through, implement and correctly apply communication protocols.

**Tasks:**
1. Implement a Universal Serial Asynchronous Receiver-Transmitter (UART) driver module
1. Integrate previously developed modules for working with involved peripherals into the project
1. Implement a system, including the necessary interface modules, memory circuits and control FSM, which allows storing a multi-bit data vector, changing its state with visual control on a 7-segment LED indicator, as well as sending the current state of this vector to a PC and receiving a new state by commands, sent over the UART interface. The project involves using the system designed in lab3.

If it is necessary to debug and check the operation of the transceiver module, use a logic analyzer.

**Involved resources:**
* 4 buttons
* 6-position seven-segment hex-digit LED display module
* piezoelectric sound emitter
* UART-USB converter chip CP2102 and mini-USB connector on the board for connecting to a PC

On the PC, you will need to install the driver for working with the CP2102 chip (if it is not already installed) and application software for working with the serial port (Terminal or similar is recommended)
