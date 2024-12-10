
# PWM Controller

## Overview
This component creates a PWM controller with customizable duty cycle/period values

## I/O

# Inputs
|Input | Data Type | Function |
|------|-----------|----------|
|clk| std_logic | system clock|
|rst| std_logic | reset|
|period| unsigned (W24 F18) | PWM period in seconds|
|duty_cycle| std_logic_vector (W18 F17) | Fractional duty cycle|

# Outputs
|Output | Data Type | Function |
|-------|-----------|----------|
|output|std_logic|PWM signal|


