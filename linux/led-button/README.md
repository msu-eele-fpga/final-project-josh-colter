# Overview

This driver implements a miscdevice driver for the led_fade component. This allows access to the button register from software, essentially allowing linux to read the de-10 nano's push button

# Device Tree node

```c
led_fade: led_fade@ff21000 {
    compatible = "joshcolter,rgb";
    reg = <0xff21000 16>;
};
```

>[!NOTE] 
>See README in \/linux\/dts directory for more info on the device tree

# Setup for the led_fade Device Driver

## Step 1 : Compile the device driver

Navigate to the led-button directory, compile the code with: 

```make```

## Step 2: Copy the device driver to the linux SoC

Copy the .ko file that gets generated to /srv/nfs/de10nano/ubuntu-rootfs/home/soc .

## Step 3: Insert device driver Kernel Module

In the SOC's command window, load the device driver using
```sudo insmod led_fade.ko``` 
Check if it was loaded successfully by running dmesg | tail and checking for an inserted successfully message

# Usage
Led button sysfs attribute can be found at /dev/led_fade

|sysfs directory| usage|
|---------------|------|
|led_button_reg| Stores button input from the de10-nano. 0 for button pressed, nonzero value for button not pressed. Can be written to manually set button input|
