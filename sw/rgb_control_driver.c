#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>

#define PWM_RED_OFFSET 0x0;
#define PWM_GREEN_OFFSET 0x4;
#define PWM_BLUE_OFFSET 0x8;
#define PWM_PERIOD_OFFSET 0xC;

#define ADC_CH0_OFFSET 0x0;
#define ADC_CH1_OFFSET 0x4;
#define ADC_CH2_OFFSET 0x8;

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
    uint32_t red_ADC_value;
    uint32_t green_ADC_value;
    uint32_t blue_ADC_value;
    uint32_t red_duty_cycle;
    uint32_t green_duty_cycle;
    uint32_t blue_duty_cycle;
    size_t ret;

    FILE *ADC_file;
    ADC_file = fopen("/dev/adc", "rb+");
    if(ADC_file == NULL) {
        printf("failed to open file\n");
        exit(1);
    }
    FILE *RGB_controller_file;
    RGB_controller_file = fopen("/dev/rgb", "rb+");
    if(RGB_controller_file == NULL) {
        printf("failed to open RGB controller file\n");
        exit(1);
    }


    signal(SIGINT, int_handler);
    
    printf("read test read test \n");
    
    signal(SIGINT, int_handler);
    while(read_ADC){
        ret = fread(&red_ADC_value, 4, 1, ADC_file);
        ret = fread(&green_ADC_value, 4, 1, ADC_file);
        ret = fread(&blue_ADC_value, 4, 1, ADC_file);
        printf("R: %d  G: %d  B: %d\n", red_ADC_value, green_ADC_value, blue_ADC_value);
        ret = fseek(ADC_file, 0, SEEK_SET);
    }
}
