
# Overview

This driver implements a miscdevice driver for the servo component. This allows software control of the Servo PWM controller through sysfs directories.

# Device Tree node

```c
servo: servo@ff201000 {
    compatible = "adsd,servo";
    reg = <0xff201000 32>;
};
```

See README in \/linux\/dts directory for more info on the device tree

# Setup for the servo Device Driver

## Step 1 : Compile the device driver

Navigate to the servo directory, and update the file path KDIR= to point to your linux-socfpga directory. 

```make```

## Step 2: Copy the device driver to the linux SoC

Copy the .ko file that gets generated to /srv/nfs/de10nano/ubuntu-rootfs/home/soc

## Step 3: Insert device driver Kernel Module

In the SOC's command line, load the device driver using
```sudo insmod servo.ko``` 
Check if it was loaded successfully by running dmesg | tail and checking for an inserted successfully message

# Usage
servo sysfs attributes can be found at /dev/rgb

|sysfs directory| usage|
|---------------|------|
|duty_cycle| Servo duty cycle. Most standard servos should not exceed 10%|
|period_reg| Servo period. Most standard servos use 20 ms|

