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
    const uint32_t SERVO_FULL_DUTY_CYCLE = 0b000100000000000000;
    const uint32_t SERVO_HALF_SECOND_PERIOD = 0b000000000001010000000000;

    //Register offsets for RGB controller
    const uint32_t DUTY_CYCLE_OFFSET = 0x0;
    const uint32_t PWM_PERIOD_OFFSET = 0x4;

    //Register offsets for ADC
    const uint32_t ADC_CH4_OFFSET = 0xC;

    uint32_t ADC_value;
    uint32_t duty_cycle;
    size_t ret;
    uint32_t val;

    FILE *ADC_file;
    ADC_file = fopen("/dev/adc", "rb+");
    if (ADC_file == NULL)
    {
        printf("failed to open file\n");
        exit(1);
    }

    FILE *SERVO_controller_file;
    SERVO_controller_file = fopen("/dev/servo", "rb+");
    if (SERVO_controller_file == NULL)
    {
        printf("failed to open SERVO controller file\n");
        exit(1);
    }

    //Write half second period to RGB controller
    ret = fseek(SERVO_controller_file, PWM_PERIOD_OFFSET, SEEK_SET);
    ret = fwrite(&SERVO_HALF_SECOND_PERIOD, 4, 1, SERVO_controller_file);
    fflush(SERVO_controller_file);

    signal(SIGINT, int_handler);
    while (keep_looping)
    {
        //Read ADC values

        ret = fseek(ADC_file, ADC_CH4_OFFSET, SEEK_SET);

        ret = fread(&ADC_value, 4, 1, ADC_file);
        printf("ADC VALUE: %d", ADC_value);
        //Convert ADC to duty cycle value
        duty_cycle = (uint32_t)(((float)ADC_value / ADC_MAX_VALUE) * SERVO_FULL_DUTY_CYCLE);
        printf("DUTY CYCLE: %d", duty_cycle);
        //Write duty cycle to servo controller
        ret = fseek(SERVO_controller_file, DUTY_CYCLE_OFFSET, SEEK_SET);
        ret = fwrite(&duty_cycle, 4, 1, SERVO_controller_file);
        fflush(SERVO_controller_file);
    }

    fclose(ADC_file);
    fclose(SERVO_controller_file);
    return 0;
}