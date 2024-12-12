# Device tree

This folder should contain your device tree source file.


## Instructions

1. Create a new dts file called `socfpga_cyclone5_de10nano_final_project.dts` (or something similar, if you can come up with a better name than "final project").
2. Symlink this file into `linux-socfpga/arch/arm/boot/dts/intel/socfpga/` using ```ln -s <repo-location>/linux/dts/*.dta <linux-socfpga>/arch/arm/boot/dts/intel/socfpga/```
3. Navigate to linux-socfpga/ and build the dtb using ```make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- dtbs```
4. Add your new dtb file name to the Makefile in `linux-socfpga/arch/arm/boot/dts/intel/socfgpa/`.
