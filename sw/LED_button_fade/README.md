# LED_button_fade Program

## Usage
LED_button_fade

LED_button_fade can be used to read the ADC values of channels 0-2 of the DE10-nano, and write pwm signals with corresponding duty cycles to GPIO pins 0-2. This is intended to be used to control an RGB LED with potentiometers (discussed further below) but can be used to control any similar PWM device with any ADC input signal. In addition, it implements a feature which will slowly decrease all duty cycles to zero when the register led_button is above zero. This is intended to be used with the de10-nano's push button, to fade the LED to black on push button input

Options:

   No command line arguments

## Installation Instructions
> [!IMPORTANT]
> Building this code relies on cross-compiling for the 32-bit ARM CPU. Linaro GCC ARM Tools were used for this example.

In order to run, this code must be built, then moved to the proper location on the NFS server used to boot the DE-10 nano. In order to boot from the server, all configuration slide switches on the FPGA must be in the ON position. Alternatively, the software can be loaded via SD card.

### Dependencies
This code depends on the rgb.ko, de10nano_adc.ko and led-button.ko linux device drivers, as well as the rgb-led device tree. See the respective README's in \/linux for more details

### Linux Command Line Build
```
<linaro_tools_location>-gcc -o LED_button_fade LED_button_fade.c
```
### Moving Compiled Program to FPGA

```
cp LED_button_fade /srv/nfs/de10nano/ubuntu-rootfs/home/soc
```

>[!NOTE]
> This depends on serving the files to the DE-10 nano using an NFS server, and hosting boot-related files on a TFTP server.

## Hardware Configuration

This system relies on the FPGA being programmed with the rgb_led.rbf file. For this example, the provided Quartus project was used to convert programming files.

