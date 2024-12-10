# RGB LED Avalon Component

## Overview
This component creates a PWM controller, and aperiod register and duty_cycle registers to control a servo motor. It is intended for use with the servo_control.ko device driver for software control of the Servo motor.

## Memory Map
|Register|Address|
|--------|-------|
| duty_cycle1| 00|
| pwm_period| 01|
