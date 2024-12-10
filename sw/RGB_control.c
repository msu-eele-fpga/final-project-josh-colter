#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>




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
    const int ADC_MAX_VALUE = 0xfff;
    const uint32_t RGB_FULL_DUTY_CYCLE = 0b100000000000000000;
    const uint32_t RGB_HALF_SECOND_PERIOD = 0b000000100000000000000000;

    const uint32_t PWM_RED_OFFSET = 0x0;
    const uint32_t PWM_GREEN_OFFSET = 0x4;
    const uint32_t PWM_BLUE_OFFSET = 0x8;
    const uint32_t PWM_PERIOD_OFFSET = 0xC;

    const uint32_t ADC_CH0_OFFSET = 0x0;
    const uint32_t ADC_CH1_OFFSET = 0x4;
    const uint32_t ADC_CH2_OFFSET = 0x8;

    uint32_t red_ADC_value;
    uint32_t green_ADC_value;
    uint32_t blue_ADC_value;
    uint32_t red_duty_cycle;
    uint32_t green_duty_cycle;
    uint32_t blue_duty_cycle;
    size_t ret;
    uint32_t val;

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

    ret = fseek(RGB_controller_file, PWM_PERIOD_OFFSET, SEEK_SET);
    ret = fwrite(&RGB_HALF_SECOND_PERIOD, 4, 1, RGB_controller_file);
    fflush(RGB_controller_file);

    signal(SIGINT, int_handler);
    while(read_ADC){
        ret = fread(&red_ADC_value, 4, 1, ADC_file);
        ret = fread(&green_ADC_value, 4, 1, ADC_file);
        ret = fread(&blue_ADC_value, 4, 1, ADC_file);
        
        ret = fseek(ADC_file, 0, SEEK_SET);

        red_duty_cycle = (uint32_t)(((float)red_ADC_value / ADC_MAX_VALUE) * RGB_FULL_DUTY_CYCLE);
        green_duty_cycle = (uint32_t)(((float)green_ADC_value / ADC_MAX_VALUE) * RGB_FULL_DUTY_CYCLE);
        blue_duty_cycle = (uint32_t)(((float)blue_ADC_value / ADC_MAX_VALUE) * RGB_FULL_DUTY_CYCLE);

        ret = fseek(RGB_controller_file, PWM_RED_OFFSET, SEEK_SET);
        ret = fwrite(&red_duty_cycle, 4, 1, RGB_controller_file);
        fflush(RGB_controller_file);

        ret = fseek(RGB_controller_file, PWM_GREEN_OFFSET, SEEK_SET);
        ret = fwrite(&green_duty_cycle, 4, 1, RGB_controller_file);
        fflush(RGB_controller_file);

        ret = fseek(RGB_controller_file, PWM_BLUE_OFFSET, SEEK_SET);
        ret = fwrite(&blue_duty_cycle, 4, 1, RGB_controller_file);
        fflush(RGB_controller_file);
    }

    fclose(ADC_file);
    fclose(RGB_controller_file);
}
