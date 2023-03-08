# lab3 - Working with a seven-segment hex-digit LED display module

**Main goal:** Learn how to use the seven-segment hex-digit LED indicator. Learn to reuse previously described modules. Learn how to correctly use finite state machines (FSM) in the development

**Tasks:**
1. Implement n-bit seven-segment hex-digit LED driver module
1. Integrate previously developed modules for working with buttons, LEDs and a sound emitter into the project
1. Implement a control FSM that provides the possibility of arbitrary setting of the numbers displayed on the seven-segment indicators. The choice of a position on the indicator and the change of the displayed number in descending or ascending order must be carried out using the user buttons, the indication of the active position should be carried out using the decimal point indicator. A change in the value in the selected segment is accompanied by an sound signal 

**Alternative task (increased difficulty):**
Provide differentiation between the modes of changing the indicator and editing the displayed number: change the active indicator by short-term pressing KEY1 and KEY2 buttons, enter the value change mode by long pressing the KEY3 button followed by with a long beep. After entering the editing mode, the KEY1 and KEY2 buttons should provide a changing the values of the selected segment. Exit from the edit mode (switch to the segment selection mode) by long pressing the KEY3 button followed by a long beep. Display the active segment with a constant glow of the decimal point, in the edit mode - with a decimal point blinking with a period of 1 second.

**Involved resources:**
* 4 buttons
* 6-position seven-segment hex-digit LED display module
* piezoelectric sound emitter
