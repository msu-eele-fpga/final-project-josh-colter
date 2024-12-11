#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>

bool keep_looping = true;
/**
 * int_handler(int dummy) - handler for ctrl+c interrupt
 * @dummy: information from signal handler. Required by the signal, but not used in this function.
 *
 * Stops the patterns from looping in pattern mode and closes the program
 */
void int_handler(int dummy)
{
    keep_looping = false;
    return;
}

/**
 * main(int argc, char **argv) - main functionality of RGB_control
 *
 * @argc: command line argument count
 * @argv: command line arguments
 *
 * Reads the values on ADC channels 0, 1, and 2, converts them to
 * duty cycle values, and writes them to the sysfs directory for
 * the RGB controller's R,G, and B values.
 *
 * Depends on device drivers rgb.ko and de10nano_adc.ko
 *
 * Return: Exit code. Returns 0 if successful exit, 1 if error
 */
int main(int argc, char **argv)
{
    // RGB controller value constants
    const int ADC_MAX_VALUE = 0xfff;
    const uint32_t RGB_FULL_DUTY_CYCLE = 0b100000000000000000;
    const uint32_t RGB_HALF_SECOND_PERIOD = 0b000000100000000000000000;

    //LED fade value constants
    const int LED_FADE_DELAY_US = 100;

    //Register offsets for RGB controller
    const uint32_t RGB_RED_OFFSET = 0x0;
    const uint32_t RGB_GREEN_OFFSET = 0x4;
    const uint32_t RGB_BLUE_OFFSET = 0x8;
    const uint32_t PWM_PERIOD_OFFSET = 0xC;

    //Register offsets for ADC
    const uint32_t ADC_CH0_OFFSET = 0x0;
    const uint32_t ADC_CH1_OFFSET = 0x4;
    const uint32_t ADC_CH2_OFFSET = 0x8;

    //Register offsets for led_fade
    const uint32_t LED_FADE_LED_BUTTON_REG_OFFSET = 0X0;


    uint32_t LED_button_reg_value;

    uint32_t red_ADC_value = 0;
    uint32_t green_ADC_value = 0;
    uint32_t blue_ADC_value = 0;
    uint32_t red_duty_cycle = 0xFFFF;
    uint32_t green_duty_cycle = 0xFFFF;
    uint32_t blue_duty_cycle = 0xFFFF;
    int counter = 0;

    size_t ret;
    uint32_t val;

    FILE *ADC_file;
    ADC_file = fopen("/dev/adc", "rb+");
    if (ADC_file == NULL)
    {
        printf("failed to open file\n");
        exit(1);
    }

    FILE *RGB_controller_file;
    RGB_controller_file = fopen("/dev/rgb", "rb+");
    if (RGB_controller_file == NULL)
    {
        printf("failed to open RGB controller file\n");
        exit(1);
    }

    FILE *LED_fade_file;
    LED_fade_file = fopen("/dev/led_fade", "rb+");
    if (LED_fade_file == NULL)
    {
        printf("failed to open LED fade file\n");
        exit(1);
    }

    //Write half second period to RGB controller
    ret = fseek(RGB_controller_file, PWM_PERIOD_OFFSET, SEEK_SET);
    ret = fwrite(&RGB_HALF_SECOND_PERIOD, 4, 1, RGB_controller_file);
    fflush(RGB_controller_file);

    signal(SIGINT, int_handler);
    while (keep_looping)
    {
        //Read LED fade button
        ret = fseek(LED_fade_file, 0, SEEK_SET);
        ret = fread(&LED_button_reg_value, 4, 1, LED_fade_file);
        

        if(LED_button_reg_value > 0)
        {
            //Read ADC values
            ret = fread(&red_ADC_value, 4, 1, ADC_file);
            ret = fread(&green_ADC_value, 4, 1, ADC_file);
            ret = fread(&blue_ADC_value, 4, 1, ADC_file);

            ret = fseek(ADC_file, 0, SEEK_SET);

            //Convert ADC to duty cycle value
            red_duty_cycle = (uint32_t)(((float)red_ADC_value / ADC_MAX_VALUE) * RGB_FULL_DUTY_CYCLE);
            green_duty_cycle = (uint32_t)(((float)green_ADC_value / ADC_MAX_VALUE) * RGB_FULL_DUTY_CYCLE);
            blue_duty_cycle = (uint32_t)(((float)blue_ADC_value / ADC_MAX_VALUE) * RGB_FULL_DUTY_CYCLE);

            //Write R,G,B to RGB controller
            ret = fseek(RGB_controller_file, RGB_RED_OFFSET, SEEK_SET);
            ret = fwrite(&red_duty_cycle, 4, 1, RGB_controller_file);
            fflush(RGB_controller_file);

            ret = fseek(RGB_controller_file, RGB_GREEN_OFFSET, SEEK_SET);
            ret = fwrite(&green_duty_cycle, 4, 1, RGB_controller_file);
            fflush(RGB_controller_file);

            ret = fseek(RGB_controller_file, RGB_BLUE_OFFSET, SEEK_SET);
            ret = fwrite(&blue_duty_cycle, 4, 1, RGB_controller_file);
            fflush(RGB_controller_file);

        } 
        else 
        {
 
            usleep(LED_FADE_DELAY_US);
            //Fade to black
            if(red_duty_cycle > 0)
            {
                red_duty_cycle--;
            }
            if(green_duty_cycle > 0)
            {
                green_duty_cycle--;
            }
            if(blue_duty_cycle > 0)
            {
                blue_duty_cycle--;
            }
     
            ret = fseek(RGB_controller_file, RGB_RED_OFFSET, SEEK_SET);
            ret = fwrite(&red_duty_cycle, 4, 1, RGB_controller_file);
            fflush(RGB_controller_file);

            ret = fseek(RGB_controller_file, RGB_GREEN_OFFSET, SEEK_SET);
            ret = fwrite(&green_duty_cycle, 4, 1, RGB_controller_file);
            fflush(RGB_controller_file);

            ret = fseek(RGB_controller_file, RGB_BLUE_OFFSET, SEEK_SET);
            ret = fwrite(&blue_duty_cycle, 4, 1, RGB_controller_file);
            fflush(RGB_controller_file);
        }
        
    }

    fclose(ADC_file);
    fclose(RGB_controller_file);
    return 0;
}
