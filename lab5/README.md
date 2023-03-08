# lab5 - Working with non-volatile memory chip (EEPROM)

**Main goal:** Learn how to work with external non-volatile memory (EEPROM): save application data until the device is powered off and restore them after power is restored. Learn how to work with a two-wire I2C communication interface (TWI). Consolidate the skills of designing complex devices with their own control machines and coordinating their interactions. Learn to think through, implement and correctly apply data storage formats in memory devices

**Tasks:**
1. Implement the I2C (TWI) receive-transmit driver module, check and debug it using the necessary hardware and software tools
1. Integrate previously developed modules for working with the necessary peripherals into the project
1. Implement a system that allows you to store a multi-bit data vector, change its state with visual control on a 7-segment LED indicator, and also save the current state of this vector to non-volatile memory and restore this state after the system is turned on or reset by user commands. The project involves using the system designed in lab3. As commands for saving and restoring, it is proposed to use a long press of those buttons for which such a press has not yet been activated.

**Alternative task (increased difficulty):**
*Build a system based on the design from lab4, i.e. both save/restore of the state using non-vilatile memory and receive/transmit of the state via the UART interface must be simultaneously used in the system. Implement a mechanism for saving/restoring the state by a command transmitted via the UART interface.*

**Involved resources:**
* 4 buttons
* 6-position seven-segment hex-digit LED display module
* piezoelectric sound emitter
* electrically erasable programmable ROM chip (EEPROM) AT24C04

To implement an alternative task, a UART-USB converter chip CP2102 and a mini-USB connector for connecting to a PC must be used. When debugging and verifying the correct functioning, you can use the logic analyzer and the specialized ChipScope Pro on-chip debugging tool.
