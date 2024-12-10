#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/mman.h> //for map
#include <fcntl.h> //for file open flags
#include <getopt.h>
#include <unistd.h> //for getting the page size
#include <math.h>
#include <string.h>
#include <signal.h>

/**
 * usage() - Prints usage info for led-patterns.c
 */
void usage()
{
    fprintf(stderr, "usage: led-patterns [-h] [-v] [-p pattern1, time1, pattern2, time2 ...] [-f filename]\n");
    fprintf(stderr, "led-patterns can be used to write patterns to the DE-10 Nano's LEDs using software.\n\n");
    fprintf(stderr, "Options:\n");
    fprintf(stderr, "-h                                     show this help message and exit \n");
    fprintf(stderr, "-v                                     verbose: print LED pattern displayed as a\n");
    fprintf(stderr, "                                       binary string, as well as how long each \n");
    fprintf(stderr, "                                       pattern is displayed\n");
    fprintf(stderr, "                                       IE: LED pattern = 11110000\n");
    fprintf(stderr, "                                       Time = 500ms\n");
    fprintf(stderr, "-f [filename]                          file mode: reads from text file of given \n");
    fprintf(stderr, "                                       filename and writes the corresponding patterns.\n");
    fprintf(stderr, "                                       Patterns and time will be given as shown:\n");
    fprintf(stderr, "                                           <pattern1> <time1> \n");
    fprintf(stderr, "                                           <pattern2> <time2>\n");
    fprintf(stderr, "                                       where pattern is a hexadecimal value and\n");
    fprintf(stderr, "                                       time is an unsigned int in ms. \n");
    fprintf(stderr, "-p [pattern1, time1, pattern2 ...]     pattern mode: display each pattern for\n");
    fprintf(stderr, "                                       its respective time, where pattern is a\n");
    fprintf(stderr, "                                       hexadecimal value and time is an");
    fprintf(stderr, "                                       unsigned int in ms. \n");
    fprintf(stderr, "                                       loop until exit command Ctrl-C is entered. \n");
    fprintf(stderr, "                                       if odd number of arguments, print error message\n");
    fprintf(stderr, "                                       and exit.MUST be enetered as last argument.\n");
    fprintf(stderr, "\n");
}

/**
 * devmem_read(char reg) - reads a register using /dev/mem
 * @reg: Register to read from
 * 
 * This method is used to automatically add the appropriate offset and calculate the virtual address for devmem read. This was done
 * so read operations can be simplified only passing in the register to read.
 * This is based on devmem.c. Original comments from that file have been left for clarity when debugging.
 * 
 * Return: uint32_t VALUE
 * This is the value that was read from the register
 */
int devmem_read(uint32_t address){
    const size_t PAGE_SIZE = sysconf(_SC_PAGE_SIZE);

    //Open the /dev/mem file, which is an image of the main system memory.
    //Using synchronous write operations (O_SYNC) to ensure that the value
    //is fully written to the underlying hardware before the write call returns
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd == -1)
    {
        fprintf(stderr, "failed to open /dev/mem. \n");
        return 1;
    }
    
    //mmap needs to map memory at page boundaries (address we're mapping must be aligned to a page).
    //~(PAGE_SIZE -1) bitmask returns the closest page-alligned address that contains ADDRESS in the page.
    //For 4096 byte page, (PAGE_SIZE -1 ) = 0xFFF; after flipping and converting to 32-bit we have a mask of -xFFFF_F000.
    //AND'ing with this mask will make the 3 least significant nibbles of ADDRESS 0.
    //This ensures the returned address is a multple of page size. Because 4096 - 0x1000, anything with three zeros for
    //the least significant nibbles must be a multiple.

    uint32_t page_aligned_addr = address & ~(PAGE_SIZE - 1);

    // Map a page of physical memory into virtual memory. 
    // mor infos at mmap man page: https://www.man7.org/linux/man-pages/man2/mmap.2.html
    uint32_t *page_virtual_addr = (uint32_t *)mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, page_aligned_addr);
    if(page_virtual_addr == MAP_FAILED)
    {
        fprintf(stderr, "failed to map memory. \n");
        return 1;
    }

    //The address we want to access is probably not page-aligned, so we need to find how far away from the page boundary it is.
    //Using this offset, we can compute the virtual addres corresponding to the physical targed address (ADDRESS)
    uint32_t offset_in_page =  address & (PAGE_SIZE -1);

    //Compute virtual address corrsponding to ADDRESS.
    //Because virtual addresses are both uint32_t (integer) pointers, the pointer addition multiplies the address by the number
    //of bytes needed to store a uint32_t. This is not what we want. So, we divide by this size (4 bytes) to make it return the
    //right address. 

    //We use volatile because the target virtual address could change outside the program.
    //Volatile tells the compiler to not optimize accesses to this address.
    volatile uint32_t *target_virtual_addr = page_virtual_addr + offset_in_page/sizeof(uint32_t*);
    close(fd);
    return(*target_virtual_addr);
}   

/**
 * devmem_write(char reg, uint32_t write_value) - Write to a register using dev/mem.
 * @reg: register to read from
 * @write_value: value to write
 * 
 * This method is used to automatically add the appropriate offset and calculate the virtual address for devmem write. This was done
 * so write operations can be simplified to passing 2 arguments. write_value MUST be a uint32_t, as the device has 32-bit registers.
 * This is based on devmem.c. Original comments from that file have been left for clarity when debugging.
 */
int devmem_write(uint32_t address, uint32_t write_value){
    const size_t PAGE_SIZE = sysconf(_SC_PAGE_SIZE);

    //Open the /dev/mem file, which is an image of the main system memory.
    //Using synchronous write operations (O_SYNC) to ensure that the value
    //is fully written to the underlying hardware before the write call returns
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd == -1)
    {
        fprintf(stderr, "failed to open /dev/mem. \n");
        return 1;
    }
    
    //mmap needs to map memory at page boundaries (address we're mapping must be aligned to a page).
    //~(PAGE_SIZE -1) bitmask returns the closest page-alligned address that contains ADDRESS in the page.
    //For 4096 byte page, (PAGE_SIZE -1 ) = 0xFFF; after flipping and converting to 32-bit we have a mask of -xFFFF_F000.
    //AND'ing with this mask will make the 3 least significant nibbles of ADDRESS 0.
    //This ensures the returned address is a multple of page size. Because 4096 - 0x1000, anything with three zeros for
    //the least significant nibbles must be a multiple.

    uint32_t page_aligned_addr = address & ~(PAGE_SIZE - 1);

    // Map a page of physical memory into virtual memory. 
    // mor infos at mmap man page: https://www.man7.org/linux/man-pages/man2/mmap.2.html
    uint32_t *page_virtual_addr = (uint32_t *)mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, page_aligned_addr);
    if(page_virtual_addr == MAP_FAILED)
    {
        fprintf(stderr, "failed to map memory. \n");
        return 1;
    }


    //The address we want to access is probably not page-aligned, so we need to find how far away from the page boundary it is.
    //Using this offset, we can compute the virtual addres corresponding to the physical targed address (ADDRESS)
    uint32_t offset_in_page =  address & (PAGE_SIZE -1);


    //Compute virtual address corrsponding to ADDRESS.
    //Because virtual addresses are both uint32_t (integer) pointers, the pointer addition multiplies the address by the number
    //of bytes needed to store a uint32_t. This is not what we want. So, we divide by this size (4 bytes) to make it return the
    //right address. 

    //We use volatile because the target virtual address could change outside the program.
    //Volatile tells the compiler to not optimize accesses to this address.
    volatile uint32_t *target_virtual_addr = page_virtual_addr + offset_in_page/sizeof(uint32_t*);

    const uint32_t VALUE = (uint32_t)write_value;
    *target_virtual_addr = VALUE;
    close(fd);
    return 0;
}

bool read_ADC = true;
/**
 * int_handler(int dummy) - handler for ctrl+c interrupt
 * @dummy: information from signal handler. Required by the signal, but not used in this function.
 * 
 * Stops the patterns from looping in pattern mode and closes the program
 */
void int_handler(int dummy){
   read_ADC = false;
   return;
}
    
/**
 * main(int argc, char **argv) - main functionality of led-patterns
 * 
 * @argc: command line argument count
 * @argv: command line arguments
 * 
 * Writes patterns to the DE10-Nano's LEDs while it is running the led-patterns .rbf file. 
 * Type "./led-patterns -h" for in-depth usage information.
 * 
 * Return: Exit code. Returns 0 if successful exit, 1 if error
 */
int main(int argc, char **argv)
{   
    //Component Addresses
    const uint32_t BRIDGE_ADDRESS = 0xff200000;
    const uint32_t ADC_BASE_ADDRESS = 0x00000000;
    const uint32_t RGB_CONTROLLER_BASE_ADDRESS = 0x007AD40;

    //ADC Addresses
    const uint32_t ADC_CH0_OFFSET = 0x00000000;
    const uint32_t ADC_CH1_OFFSET = 0x00000004;
    const uint32_t ADC_CH2_OFFSET = 0x00000008;

    //ADC constant values
    const uint32_t ADC_MAX_VALUE = 0x00000fff;

    //RGB LED Controller addresses
    const uint32_t RGB_RED_DUTY_CYCLE_OFFSET = 0x00000000;
    const uint32_t RGB_GREEN_DUTY_CYCLE_OFFSET = 0x00000004;
    const uint32_t RGB_BLUE_DUTY_CYCLE_OFFSET = 0x00000008;
    const uint32_t RGB_PERIOD_OFFSET = 0x0000000C;

    //RGB LED Controller constants
    const uint32_t RGB_FULL_DUTY_CYCLE = 0b100000000000000000;
    const uint32_t RGB_HALF_SECOND_PERIOD = 0b000000100000000000000000;

    uint32_t red_ADC_value;
    uint32_t green_ADC_value;
    uint32_t blue_ADC_value;
    uint32_t red_duty_cycle;
    uint32_t green_duty_cycle;
    uint32_t blue_duty_cycle;

    devmem_write(BRIDGE_ADDRESS + RGB_CONTROLLER_BASE_ADDRESS + RGB_PERIOD_OFFSET, RGB_HALF_SECOND_PERIOD);

    signal(SIGINT, int_handler);
    while (read_ADC){
        red_ADC_value = devmem_read(BRIDGE_ADDRESS + ADC_BASE_ADDRESS + ADC_CH0_OFFSET);
        green_ADC_value = devmem_read(BRIDGE_ADDRESS + ADC_BASE_ADDRESS + ADC_CH1_OFFSET);
        blue_ADC_value = devmem_read(BRIDGE_ADDRESS + ADC_BASE_ADDRESS + ADC_CH2_OFFSET);
        fprintf(stderr, "ADC: %d \n", red_ADC_value);
        red_duty_cycle = (uint32_t)(((float)red_ADC_value / ADC_MAX_VALUE) * RGB_FULL_DUTY_CYCLE);
        fprintf(stderr,"DUTY CYCLE: %d \n", red_duty_cycle);
        green_duty_cycle = (uint32_t)(((float)green_ADC_value / ADC_MAX_VALUE) * RGB_FULL_DUTY_CYCLE);
        blue_duty_cycle = (uint32_t)(((float)blue_ADC_value / ADC_MAX_VALUE) * RGB_FULL_DUTY_CYCLE);

        devmem_write(BRIDGE_ADDRESS + RGB_CONTROLLER_BASE_ADDRESS + RGB_RED_DUTY_CYCLE_OFFSET, red_duty_cycle);
        devmem_write(BRIDGE_ADDRESS + RGB_CONTROLLER_BASE_ADDRESS + RGB_GREEN_DUTY_CYCLE_OFFSET, green_duty_cycle);
        devmem_write(BRIDGE_ADDRESS + RGB_CONTROLLER_BASE_ADDRESS + RGB_BLUE_DUTY_CYCLE_OFFSET, blue_duty_cycle);
    }



}
