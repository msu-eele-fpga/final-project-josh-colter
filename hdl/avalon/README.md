# RGB LED Driver Avalon Component

## Overview
This component creates 3 PWM controllers, and assigns a collective period register and 3 duty_cycle registers to control the R,G,and B values of an RGB LED. It is intended for use with the rgb.ko device driver for software control of the RGB LED.

## Memory Map
|Register|Address|
|--------|-------|
| duty_cycle1| 00|
| duty_cycle2| 01|
| duty_cycle3| 10|
| PWM period | 11|