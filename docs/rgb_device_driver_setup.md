# Setup for the rgb device tree

## Step 1

Copy the rgb.rbf file from the quartus project to the /srv/tftp/de10nano directory

## Step 3

Create the rgb.dts within the /linux/dts directory

### code for the socfpga_cyclone5_de10nano_rgb.dts file

```C?
#include "socfpga_cyclone5_de10nano.dtsi"
/{
rgb: rgb@ff27AD40 {
compatible = "joshcolter,rgb";
reg = <0xff27AD40 16>;
};
};
```

## Step 4

Create a symbolic link (absolute path) between the rgb file in your repo and the one in the linux-socfpga repo:

```ln -s /home/josh/Desktop/final-project-josh-colter/linux/dts/socfpga_cyclone5_de10nano_rgb.dts /home/josh/Desktop/linux-socfpga/arch/arm/boot/dts/intel/socfpga/```

## Step 5

Add this: 

socfpga_cyclone5_de10nano_rgb.dtb, to the makefile located at:

```linux-socfpga/arch/arm/boot/dts/intel/socfpga/```

## Step 6

(With sudo permissions) Navigate to linux-socfpga/ and build the dtb with:

```make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- dtbs```

## Step 7 


```cp socfpga_cyclone5_de10nano_rgb.dtb /srv/tftp/de10nano/rgb/rgb.dtb```

## Step 8

put the following into an rgb.script file in /srv/tftp/de10nano/bootscipts:

```
# file directories
setenv tftpkerneldir ${tftpdir}/kernel
setenv tftpprojectdir ${tftpdir}/rgb
setenv nfsrootdir /srv/nfs/de10nano/ubuntu-rootfs
# kernel bootargs
setenv bootargs console=ttyS0,115200 ip=${ipaddr} root=/dev/nfs rw nfsroot=${serverip}:${nfsrootdir},v4,tcp nfsrootdebug earlyprintk=serial
# file names
setenv fpgaimage rgb.rbf
setenv dtbimage rgb.dtb
setenv bootimage zImage
# memory addresses where files get loaded into
setenv fpgadata 0x2000000
setenv fpgadatasize 0x700000
setenv dtbaddr 0x00000100
setenv kerneladdr 0x8000
# commands to get files, configure the fpga, and load the kernel
setenv getfpgadata 'tftp ${fpgadata} ${tftpprojectdir}/${fpgaimage}'
setenv getdtb 'tftp ${dtbaddr} ${tftpprojectdir}/${dtbimage}'
setenv getkernel 'tftp ${kerneladdr} ${tftpkerneldir}/${bootimage}'
setenv loadfpga 'fpga load 0 ${fpgadata} ${fpgadatasize}'
# get all of the files and boot the device
run getfpgadata;
run loadfpga;
run getdtb;
run getkernel;
run bridge_enable_handoff;
bootz ${kerneladdr} - ${dtbaddr}
```

## Step 9

within the bootscripts directory run:

```mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "rgb bootscript" -d rgb.script rgb.scr```

## Step 10 

Tell FPGA (with sudo permissions) to look at boot image (remove old u-boot-scr before creating new one):

```ln -s rgb.scr u-boot.scr```


# Setup for the rgb Device Driver

## Step 1

copy over a makefile from previous work, and change the object file to the appropriate name

## Step 2

Create an rgb.c following the zero-to-hero guidlines within a linux/rgb-led directory.

Compile the code with: 

```make```

## Step 3

Do this:

4. Copy the .ko file that gets generated to /srv/nfs/de10nano/ubuntu-rootfs/home/soc .
5. Boot the FPGA - you should be able to load and remove the module from the home directory using insmod
<component_name>.ko and rmmod <component.ko> . Check if it was loaded successfully by running dmesg | tail and
checking to see if the print statement from the probe function shows up.
6. To check if the character device driver works, load the module, navigate to /sys/devices/platform/ and then cd
into the directory corrisponding to the component you created. You should be able to read and write to the
registers using cat <register_name> and echo <value> > <register_name>
7. To control them via software, see this example file. Cross-compile it with /usr/bin/arm-linux -gnueabihf -gcc -o
<file_name> <file_name>.c , and copy the executable to /srv/nfs/de10nano/ubuntu-rootfs/home/soc/ .

## Step 4


