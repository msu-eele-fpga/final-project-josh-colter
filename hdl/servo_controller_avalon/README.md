# Servo controller Avalon Component

## Overview
This component creates a PWM controller, and period register and duty cycle registers to control a servo motor. It is intended for use with the servo_control.ko device driver for software control of the servo motor.

## Memory Map
|Register|Address|
|--------|-------|
| duty_cycle1| 00|
| pwm_period| 01|
