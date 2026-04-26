# LED-Ping-Pong-DE1-project
 Digital electronics 1 project, 16-LEd ping-pong game on Nexys-A7-50T FPGa development board

 ## Project Summary
 
This project simulate s Ping-pong game on development board NEXYS A7-50T. The ball is presents by led witch is shining in actual momet. When ball ratch on border of led array, player must push button. For left edging of led array is assignment a left butto, equally for right is right butto. When player don't push button in time, he loos and signal rgb led turn on or turn green when payer push button in time. 

<div align="center">
| signal name | I/O | Size | Note |
| :---: | :---: | :---: | :---: |
| `clk` | input | 1 | system clock (internal) |
| `reset` | input | 1 | system reset |
| `btn_r` | input | 1 | right button|
| `btn_l` | input | 1 | left button |
| `led` | output | 15:0 | Výstup pre 7-segmentovku |
| `led_g` | output | 1 | output for green segment rdb led |
| `led_r` | output | 1 | output for red segment rdb led  |

 <i>Tab.1 I/O table</i>
</div>


 ## Top level schematic
 
 ![schema](top_level_schema.png)

 ## Components
### 1. bin2led
Component bin2led converting binary number to code which turn on only 1 led.

<div align="center">
  <img src="tb_bin2led.png" width="500"/><br/>
 <i>Pic.1 Simulation of bin2led</i>
</div>

### 2. front_counter
This component couting input impulses. If on the inputs clk and en are both on high level , then the output signal are increased by 1.
Reset input (rst) are deleted output value and set it to 0.

### 3. reverse_counter
Reverse couter is almost same as front counter except for one change. It counting "back", from 7 to 0. 

<div align="center">
<img src="reverse_counter_sim.png"/><br/>
 <i>Pic.2 Simulation of reverse_counter</i>
 </div>
 
### 4. control_logic (work in progress)
This is the biggest component of this code. Propouse of this component is switching couters and sensing player imputs. 
When front counter have on output value 7 (witch is maximum output value for this counter) the control logic reset front counter and start
interval during witch user must push button. Result show rgb led (red or green). Next counting back counter and proces repeat. 

<div align="center">
<img src="tb_control_logic.png"/><br/>
 <i>Pic.3 Simulation of control_logic</i>
 </div>


#### Description of control logic simulation:
 On first line is clk signal witch is main clock source. Signal named en interprete signal form clk_en module. It id slowed main clk signal. Press of buttons are presents btn_r and btn_l signals. For ressenting front counter and back counter (see top level schema) serving front_counter_rst and back_counter_rst. Output from these counters present fcnt and bcnt. The signal new_game setting both counters to value witch presenting central led (center in led array) when game starting and sig_cnt presenting counter which determines time to push button. In code is used value named current_state witch signalising game status.



### 5. debounce
When the switch is pressed, there are slight transitions between another states, until the switch settles into its new state.
Debounce component eliminates this bounce efect. 

### 6. clk_en
Clock enable creat slower signal from reference clock.

 ## Hardware

- Nexys A7-50T
- 16 onboard LEDs
- Push buttons
