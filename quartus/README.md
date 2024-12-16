# Quartus project folder

This folder contains all quartus projects used to create the device. **full_integration** is the final combination of all components, and is what should be used to generate the RBF file for the de-10 nano. 

## RBF file generation with Quartus

### Step 1: Open final_integration\/final_integration.qpf in Quartus

### Step 2: Open final_integration\/soc_system.qsys in Platform Designer

### Step 3: Generate HDL

In platform designer, click generate > generate HDL > generate

### Step 4: Compile HDL

In Quartus, click 'Compile Design'

### Step 5: Generate RBF

In Quartus, click file > convert programming files

Set Programming file type to .rbf, File name to rgb_final.rbf, and mode to Passive Parallel x16

In the input files, click SOF data then 'Add File...'. Navigate to output files and add de10nano_top.sof

Click Generate

### Step 6: Move RBF to server
> [!NOTE]
> This relies upon using a TFTP server to serve boot-related files to the FPGA. The RBF file should be placed wherever u-boot looks for the FPGA image

In the linux CLI, run 
```sudo cp <full_integration quartus directory>/rgb_final.rbf /srv/tftp/de10nano/rgb_final/rgb_final.rbf```