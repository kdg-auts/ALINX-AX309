# lab1 - Working with simple I/O resources

**Main goal:** Learn how to properly process data input from the buttons and provide various indication modes on the LEDs. Learn to describe devices with internal states: automata, counters

**Tasks:**
1. Implement a module for reading data from a set of user buttons on a development board, taking into account bounce effects. The module must recognize short-term and long-term pressing, generate event signals "pressing" and "release" for each button. Regardless of the schematics connecting button with FPGA intput, the pressing signal must be issued in active-high logic (1 - the button is pressed, 0 - the button is not pressed)
1. Implement a module for outputting signals to LEDs with several display modes: the LED is constantly lit, the LED works in a flashing mode with low frequency (with a period of about a second) and in a flashing mode with high frequency (a period of about 100 milliseconds)
1. Implement a system that switches the LED glow mode depending on the type of pressing the button associated with it; bind the control of the glow mode of the LED0 LED to the KEY1 button, the LED1 LED to the KEY2 button, etc.; a short-time press of the button should switch the modes "off", "steady on", "slow flashing" (period 1 s) in a circular way, a long-time press should switch the LED to the "fast flashing" mode.

**Involved resources:**
* 4 buttons
* 4 LEDs
