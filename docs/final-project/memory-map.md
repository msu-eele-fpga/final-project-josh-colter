# System Overview

Three main components:

- System components
    - vhdl for required and custom components (pwm controller, avalon files, top level files)
    - A Device Tree that contains nodes for all drivers
    - Device Drivers for all components
    - Custom C code to perform specific software operations.

(See below for desc. on the custom components)

## Memory Map for Registers

| 0xff200000 | ... | 0xff201000 | 0xff201001 | 0xff201002 | ... | 0xff202000 | 0xff202002 | ... | 0xff27ad4f | 0xff27ad50 | 0xff27ad51 | 0xff27ad52 | 0xff27ad53 |
| ---    | ---   | ---     | ---    | ---    | ---    | ---    | ---    | ---    | ---    | ---    | ---    | ---    | ---    |
| Base for ADC  | ... | Base for Servo | duty cycle | period register | ... | Base for RGB Button | Button Press Register | ... | Base for RGB | duty cycle red | duty cycle green | duty cycle blue | period register |

## Block Diagram

 < insert here >

# Custom Component 1 - rgb button

This component includes taking input from a button, when the button is pressed and held, the RGB led will slowly start to fade until it is turned off.

# Custom Component 2 - servo motor

This component takes input from a potentiometer, this ADC signal is converted to a pwm signal, and then sent to a GPIO pin that outputs to a servo motor.