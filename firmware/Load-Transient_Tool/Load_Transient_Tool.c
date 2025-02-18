/****************************************
 * File: Load_Transient_Tool.c
 * Author: Yasir Shahzad
 * Email: yasirshahzad918@gmail.com
 * Company: Mastermind Technologies
 * Created: January 22, 2025
 * Version: 1.1
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
#define SEC_US         76150     // SEC to Micro Second Scale


typedef unsigned char uint8_t;
typedef unsigned int uint16_t;
 typedef unsigned long uint32_t;

// Pin Definitions
sbit UP_BUTTON   at GPIO.B3; // UP button
sbit DOWN_BUTTON at GPIO.B4; // DOWN button
sbit FREQ_BUTTON at GPIO.B5; // Frequency adjustment button
sbit MOSFET_GATE at GPIO.B2; // PWM output to MOSFET gate
sbit POWER_LED   at GPIO.B1; // Power indicator LED

// Global Variables
uint8_t dutyCycle = DEFAULT_DUTY;
uint16_t frequency = DEFAULT_FREQ;
uint32_t period;
uint32_t onTime;
uint32_t offTime;
bool update = true;

// Function Prototypes
void init(void);
void handleButtons(void);
void handleFreq(void);
void generatePWM(uint16_t freq, uint8_t duty);
void blinkPowerLED(void);
void customDelay_us(uint32_t time);

void main(void)
{
    init();

    // Default start-up configuration
    POWER_LED = 1;  // Indicate power is ON
    Delay_ms(1000); // Initial LED indication
    POWER_LED = 0;

    while (1)
    {
        handleButtons(); // Check and handle button presses
        handleFreq();
    }
}

/**
 * @brief Initializes the hardware peripherals and I/O pins.
 */
void init(void)
{
    // Configure GPIO pins
    TRISIO = 0b00111000; // GP0, GP1, GP2 as inputs (buttons), others as outputs
    ANSEL  = 0;          // Disable analog functionality
    CMCON0 = 0x07;       // Disable comparators

    // Initialize LED state
    POWER_LED = 0;
    
    // Calculate initial period for frequency
    period = (SEC_US / DEFAULT_FREQ); // Convert Hz to microseconds
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
            blinkPowerLED(); // Indicate adjustment
            update = true; // Set update flag
        }
    }

    // Adjust duty cycle DOWN
    if (DOWN_BUTTON == 0)
    {
        Delay_ms(20); // Debounce delay
        if (DOWN_BUTTON == 0 && dutyCycle > MIN_DUTY)
        {
            dutyCycle--;
            blinkPowerLED(); // Indicate adjustment
            update = true; // Set update flag
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
            period = (SEC_US / frequency); // Update period calculation
            blinkPowerLED(); // Indicate adjustment
            update = true; // Set update flag
        }
    }
}

/**
 * @brief Generates PWM signal using delay-based timing.
 * @param freq The desired frequency (Hz).
 * @param duty The desired duty cycle (%).
 */
void handleFreq(void)
{
    if(update){
    onTime = (period * dutyCycle) / 100; // ON time in microseconds
    offTime = period - onTime; // OFF time in microseconds
    update = false; // Reset update flag
    }
    MOSFET_GATE = 1;
    customDelay_us(onTime);
    MOSFET_GATE = 0;
    customDelay_us(offTime);
}

/**
 * @brief Blinks the power LED to indicate an adjustment.
 */
void blinkPowerLED(void)
{
    POWER_LED = 1;
    Delay_ms(100);
    POWER_LED = 0;
    Delay_ms(100);
}

/**
 * @brief Custom delay function for microseconds.
 * @param time Delay duration in microseconds.
 */
void customDelay_us(uint32_t time)
{
    while (time--)
    {
        asm nop;  // 1 cycle (1 �s)
    }
}
