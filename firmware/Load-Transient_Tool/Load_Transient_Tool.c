/****************************************
 * File: Load-Transient-Tool.c
 * Author: Yasir Shahzad
 * Email: yasirshahzad918@gmail.com
 * Company: Mastermind Technologies
 * Created: January 22, 2025
 * Version: 1.0
 * Description:
 *      This file contains the main program for the Load Transient Tool.
 *      It uses a PIC12F683 microcontroller to generate fast load transients
 *      using a MOSFET driver. The tool supports configurable duty cycle and
 *      frequency adjustments for transient load testing.
 *
 * License: MIT License
 ****************************************/

#include <stdbool.h>

// Configuration Constants
#define DEFAULT_FREQ        1000   // Default frequency (Hz)
#define DEFAULT_DUTY_CYCLE  5     // Default duty cycle (%)
#define MAX_DUTY_CYCLE      50    // Maximum duty cycle (%)
#define MIN_DUTY_CYCLE      1   // Minimum duty cycle (%)
#define FREQ_STEPS          4     // Frequency adjustment steps

typedef unsigned char uint8_t;
typedef unsigned int uint16_t;

// Pin Definitions
sbit UP_BUTTON at GPIO.B0;
sbit DOWN_BUTTON at GPIO.B1;
sbit FREQ_BUTTON at GPIO.B2;
sbit MOSFET_GATE at GPIO.B4;
sbit POWER_LED at GPIO.B5;

// Global Variables
uint8_t dutyCycle = DEFAULT_DUTY_CYCLE;
uint16_t frequency = DEFAULT_FREQ;
bool powerState = false;

// Function Prototypes
void init(void);
void handleButtons(void);
void updatePWM(uint16_t freq, uint8_t duty);
void blinkPowerLED(void);

void main(void)
{
    init();

    // Default start-up configuration
    updatePWM(frequency, dutyCycle);
    POWER_LED = 1; // Indicate power is ON
    Delay_ms(1000); // Initial LED indication

    while (1)
    {
        handleButtons(); // Check and handle button presses
        // Maintain the load transient generation based on current settings
    }
}

/**
 * @brief Initializes the hardware peripherals and I/O pins.
 */
void init(void)
{
    // Configure GPIO pins
    TRISIO = 0b00000111; // GP0, GP1, GP2 as inputs (buttons), others as outputs
    ANSEL  = 0;          // Disable analog functionality
    CMCON0 = 0x07;       // Disable comparators

    // Initialize PWM for MOSFET gate drive
    PWM1_Init(DEFAULT_FREQ);
    PWM1_Start();

    // Initialize LED state
    POWER_LED = 0;
}

/**
 * @brief Handles button presses to adjust duty cycle and frequency.
 */
void handleButtons(void)
{
    // Adjust duty cycle
    if (UP_BUTTON == 0)
    {
        Delay_ms(200); // Debounce delay
        if (UP_BUTTON == 0 && dutyCycle < MAX_DUTY_CYCLE)
        {
            dutyCycle++;
            updatePWM(frequency, dutyCycle);
            blinkPowerLED(); // Indicate adjustment
        }
    }

    if (DOWN_BUTTON == 0)
    {
        Delay_ms(200); // Debounce delay
        if (DOWN_BUTTON == 0 && dutyCycle > MIN_DUTY_CYCLE)
        {
            dutyCycle--;
            updatePWM(frequency, dutyCycle);
            blinkPowerLED(); // Indicate adjustment
        }
    }

    // Adjust frequency
    if (FREQ_BUTTON == 0)
    {
        Delay_ms(200); // Debounce delay
        if (FREQ_BUTTON == 0)
        {
            // Cycle through frequency steps (15Hz, 61Hz, 244Hz, 976Hz)
            switch (frequency)
            {
                case 15:
                    frequency = 61;
                    break;
                case 61:
                    frequency = 244;
                    break;
                case 244:
                    frequency = 976;
                    break;
                default:
                    frequency = 15;
            }
            updatePWM(frequency, dutyCycle);
            blinkPowerLED(); // Indicate adjustment
        }
    }
}

/**
 * @brief Updates the PWM settings for the MOSFET gate drive.
 * @param freq The desired frequency (Hz).
 * @param duty The desired duty cycle (%).
 */
void updatePWM(uint16_t freq, uint8_t duty)
{
    PWM1_Init(freq);
    PWM1_set_Duty(duty * (255 / 100)); // Convert percentage to 8-bit value
    PWM1_Start();
}

/**
 * @brief Blinks the power LED to indicate an adjustment.
 */
void blinkPowerLED(void)
{
    POWER_LED = 1;
    Delay_ms(200);
    POWER_LED = 0;
    Delay_ms(200);
}
