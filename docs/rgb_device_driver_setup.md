# Setup for the rgb device tree

## Step 1

Copy the soc_system.qip file from the quartus project to the /srv/tftp/de10nano directory

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


# Setup for the rgb Device Driver

