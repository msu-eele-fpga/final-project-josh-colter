# Overview

    This driver implements a miscdevice driver for the servo component. This allows for a potentiometer to adjust the angle of the servo motor

# Device Tree node

    ```c
    servo: servo@ff202000 {
        compatible = "adsd,servo";
        reg = <0xff202000 16>;
    };
    ```

    See README in \/linux\/dts directory for more info on the device tree

# Setup for the servo Device Driver

## Step 1 : Compile the device driver

Navigate to the servo directory, compile the code with: 

```make```

## Step 2: Copy the device driver to the linux SoC

Copy the .ko file that gets generated to /srv/nfs/de10nano/ubuntu-rootfs/home/soc .

## Step 3: Insert device driver Kernel Module

In the SOC's command window, load the device driver using
```sudo insmod servo.ko``` 
Check if it was loaded successfully by running dmesg | tail and checking for an inserted successfully message