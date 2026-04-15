# LED-Ping-Pong-DE1-project
 Digital electronics 1 project, 16-LEd ping-pong game on Nexys-A7-50T FPGa development board

 ## Project Summary
 
 Simulate a bouncing ball with LEDs moving left and right. Update the ball’s position based on button presses and flash LEDs when the player misses.

 ## Top level schematic
 
 ![schema](schema.png)

 ## Components
### bin2led
converts input from counter into led position

<div align="center">
  <img src="bin2led_tb.png" width="400" />
</div>
 
### control_logic
controls main logic
### reverse_counter
counts from 15 to 0


 
 ## Hardware

- Nexys A7-50T
- 16 onboard LEDs
- Push buttons
