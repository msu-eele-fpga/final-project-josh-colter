# Software source code

Software source code for RGB led.

|File|Device Drivers Required|Usage|
|----|---|---|
|RGB_control|rgb.ko<br> de10nano_adc.ko| Controls the R, G, and B values (on GPIO_0 pins 1, 2, and 3) of the LED based on inputs from ADC channels 1, 2, and 3. Meant for use for potentiometers to control RGB LED|
|LED_button_fade| led_fade.ko<br>   rgb.ko<br> de10nano_adc.ko |Fades RGB to black on push button hold|
|Servo_control|servo.ko<br> de10nano_adc.ko| Controls a servo using GPIO pin 4 using ADC channel 4. NOT FUNCTIONAL, connect a servo at your own risk

## Build Instructions

C files must be cross-compiled for the 32-bit ARM CPU of the DE-10 nano. For this example, the Linaro cross-compilation toolchain was used.

### 1. Cross-Compile for ARM CPU

On a Linux machine with the tools installed, run

``` /usr/bin/arm-linux-gnueabihf-gcc -o<compiled_filename> <source_code_filename.c>```

### 2. Move to SOC's home directory

This step relies on files being served to the SOC using an NFS server. Alternatively, the file can be loaded from an SD card or other media.

```mv <filename> /srv/nfs/de10nano/ubuntu-rootfs/home/soc```

### 3. Run in SOC's CLI

Using PuTTY or a similar program, run ```sudo ./<filename>``` in the terminal