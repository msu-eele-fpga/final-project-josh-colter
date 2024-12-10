# TCL File Generated by Component Editor 23.1
# Tue Dec 10 15:32:19 MST 2024
# DO NOT MODIFY


# 
# pwm_comp "pwm_comp" v1.0
# Joshua Wilcox 2024.12.10.15:32:19
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module pwm_comp
# 
set_module_property DESCRIPTION ""
set_module_property NAME pwm_comp
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR "Joshua Wilcox"
set_module_property DISPLAY_NAME pwm_comp
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL rgb_led_avalon
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file rgb_button_avalon.vhd VHDL PATH ../../../hdl/avalon/rgb_button_avalon.vhd TOP_LEVEL_FILE


# 
# parameters
# 


# 
# display items
# 


# 
# connection point rgb_button_avalon
# 
add_interface rgb_button_avalon avalon end
set_interface_property rgb_button_avalon addressUnits WORDS
set_interface_property rgb_button_avalon associatedClock clk
set_interface_property rgb_button_avalon associatedReset rst
set_interface_property rgb_button_avalon bitsPerSymbol 8
set_interface_property rgb_button_avalon burstOnBurstBoundariesOnly false
set_interface_property rgb_button_avalon burstcountUnits WORDS
set_interface_property rgb_button_avalon explicitAddressSpan 0
set_interface_property rgb_button_avalon holdTime 0
set_interface_property rgb_button_avalon linewrapBursts false
set_interface_property rgb_button_avalon maximumPendingReadTransactions 0
set_interface_property rgb_button_avalon maximumPendingWriteTransactions 0
set_interface_property rgb_button_avalon readLatency 0
set_interface_property rgb_button_avalon readWaitTime 1
set_interface_property rgb_button_avalon setupTime 0
set_interface_property rgb_button_avalon timingUnits Cycles
set_interface_property rgb_button_avalon writeWaitTime 0
set_interface_property rgb_button_avalon ENABLED true
set_interface_property rgb_button_avalon EXPORT_OF ""
set_interface_property rgb_button_avalon PORT_NAME_MAP ""
set_interface_property rgb_button_avalon CMSIS_SVD_VARIABLES ""
set_interface_property rgb_button_avalon SVD_ADDRESS_GROUP ""

add_interface_port rgb_button_avalon avs_read read Input 1
add_interface_port rgb_button_avalon avs_write write Input 1
add_interface_port rgb_button_avalon avs_address address Input 3
add_interface_port rgb_button_avalon avs_readdata readdata Output 32
add_interface_port rgb_button_avalon avs_writedata writedata Input 32
set_interface_assignment rgb_button_avalon embeddedsw.configuration.isFlash 0
set_interface_assignment rgb_button_avalon embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment rgb_button_avalon embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment rgb_button_avalon embeddedsw.configuration.isPrintableDevice 0


# 
# connection point clk
# 
add_interface clk clock end
set_interface_property clk clockRate 0
set_interface_property clk ENABLED true
set_interface_property clk EXPORT_OF ""
set_interface_property clk PORT_NAME_MAP ""
set_interface_property clk CMSIS_SVD_VARIABLES ""
set_interface_property clk SVD_ADDRESS_GROUP ""

add_interface_port clk clk clk Input 1


# 
# connection point rst
# 
add_interface rst reset end
set_interface_property rst associatedClock clk
set_interface_property rst synchronousEdges DEASSERT
set_interface_property rst ENABLED true
set_interface_property rst EXPORT_OF ""
set_interface_property rst PORT_NAME_MAP ""
set_interface_property rst CMSIS_SVD_VARIABLES ""
set_interface_property rst SVD_ADDRESS_GROUP ""

add_interface_port rst rst reset Input 1


# 
# connection point export
# 
add_interface export conduit end
set_interface_property export associatedClock clk
set_interface_property export associatedReset rst
set_interface_property export ENABLED true
set_interface_property export EXPORT_OF ""
set_interface_property export PORT_NAME_MAP ""
set_interface_property export CMSIS_SVD_VARIABLES ""
set_interface_property export SVD_ADDRESS_GROUP ""

add_interface_port export button_push new_signal Input 1
