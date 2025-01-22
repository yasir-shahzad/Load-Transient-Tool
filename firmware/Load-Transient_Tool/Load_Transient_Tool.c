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
 * License: MIT License/****************************************
 * File: Load_Transient_Tool.c
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
#define FREQ_15         15    // 15 Hz frequency
#define FREQ_61         61    // 61 Hz frequency
#define FREQ_244        244   // Default frequency (244 Hz)
#define FREQ_976        976   // 976 Hz frequency

#define DEFAULT_FREQ    FREQ_244 // Default frequency
#define DEFAULT_DUTY    5        // Default duty cycle (%)
#define MAX_DUTY        50       // Maximum duty cycle (%)
#define MIN_DUTY        1        // Minimum duty cycle (%)


typedef unsigned char uint8_t;
typedef unsigned int uint16_t;

// Pin Definitions
sbit UP_BUTTON   at GPIO.B0; // UP button
sbit DOWN_BUTTON at GPIO.B1; // DOWN button
sbit FREQ_BUTTON at GPIO.B2; // Frequency adjustment button
sbit MOSFET_GATE at GPIO.B4; // PWM output to MOSFET gate
sbit POWER_LED   at GPIO.B5; // Power indicator LED

// Global Variables
uint8_t dutyCycle = DEFAULT_DUTY;
uint16_t frequency = DEFAULT_FREQ;

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
    // Adjust duty cycle UP
    if (UP_BUTTON == 0)
    {
        Delay_ms(20); // Debounce delay
        if (UP_BUTTON == 0 && dutyCycle < MAX_DUTY)
        {
            dutyCycle++;
            updatePWM(frequency, dutyCycle);
            blinkPowerLED(); // Indicate adjustment
        }
    }

    // Adjust duty cycle DOWN
    if (DOWN_BUTTON == 0)
    {
        Delay_ms(20); // Debounce delay
        if (DOWN_BUTTON == 0 && dutyCycle > MIN_DUTY)
        {
            dutyCycle--;
            updatePWM(frequency, dutyCycle);
            blinkPowerLED(); // Indicate adjustment
        }
    }

    // Adjust frequency
    if (FREQ_BUTTON == 0)
    {
        Delay_ms(20); // Debounce delay
        if (FREQ_BUTTON == 0)
        {
            // Cycle through frequency steps (15Hz, 61Hz, 244Hz, 976Hz)
            switch (frequency)
            {
                case FREQ_15:
                    frequency = FREQ_61;
                    break;
                case FREQ_61:
                    frequency = FREQ_244;
                    break;
                case FREQ_244:
                    frequency = FREQ_976;
                    break;
                default:
                    frequency = FREQ_15;
            }
            updatePWM(frequency, dutyCycle);
            blinkPowerLED(); // Indicate adjustment
        }
    }
}

/**
 * @brief Updates the PWM settings for the MOSFET gate drive.
 * @param freq The desired frequency (Hz) (predefined constant).
 * @param duty The desired duty cycle (%).
 */
void updatePWM(uint16_t freq, uint8_t duty)
{
    // Set the frequency based on predefined steps
    switch (freq)
    {
    case FREQ_15:
        PWM1_Init(FREQ_15); // Use constant frequency for 15 Hz
        break;
    case FREQ_61:
        PWM1_Init(FREQ_61); // Use constant frequency for 61 Hz
        break;
    case FREQ_244:
        PWM1_Init(FREQ_244); // Use constant frequency for 244 Hz
        break;
    case FREQ_976:
        PWM1_Init(FREQ_976); // Use constant frequency for 976 Hz
        break;
    default:
        PWM1_Init(FREQ_244); // Default to 244 Hz if invalid frequency
        break;
    }
    // Update the duty cycle
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
