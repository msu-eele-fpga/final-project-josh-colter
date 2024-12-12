# Overview

This driver implements a miscdevice driver for the rgb component. This allows software control of the RGB LED controller through sysfs directories.

# Device Tree node

```c
rgb: rgb@ff27AD40 {
    compatible = "joshcolter,rgb";
    reg = <0xff27AD40 16>;
};
```

See README in \/linux\/dts directory for more info on the device tree

# Setup for the rgb Device Driver

## Step 1 : Compile the device driver

Navigate to the rgb-led directory, and update the file path KDIR= to point to your linux-socfpga directory. 

```make```

## Step 2: Copy the device driver to the linux SoC

Copy the .ko file that gets generated to /srv/nfs/de10nano/ubuntu-rootfs/home/soc

## Step 3: Insert device driver Kernel Module

In the SOC's command line, load the device driver using
```sudo insmod rgb.ko``` 
Check if it was loaded successfully by running dmesg | tail and checking for an inserted successfully message

# Usage
RGB_LED sysfs attribute can be found at /dev/rgb

|sysfs directory| usage|
|---------------|------|
|duty_cycle_r| Red PWM duty cycle|
|duty_cycle_g| Green PWM duty cycle|
|duty_cycle_b| Blue PWM duty cycle|
|period_reg| period for R, G, and B PWM signals|
