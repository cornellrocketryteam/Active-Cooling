/**
 * Nandita Nagarajan (nn234)
 * Nissi Ragland (nkr33)
 * Cameron Goddard (csg83)
 * HARDWARE CONNECTIONS
 *   - GPIO 23 ---> PWM output to Fan 2
 *   - GPIO 24 ---> PWM output to Fan 1
 * 
 */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#include "pico/stdlib.h"
#include "pico/multicore.h"

// Include hardware libraries
#include "hardware/pwm.h"
#include "hardware/irq.h"
#include "hardware/i2c.h"

// Include custom libraries
#include "pt_cornell_rp2040_v1_3.h"
//Add driver for temp sensor library here

#define min(a,b) ((a<b) ? a:b)
#define max(a,b) ((a<b) ? b:a)
#define abs(a) ((a>0) ? a:-a)

int proportional_gain = 100;
int derivative_gain = 0;
int integral_gain = 0;
float desired_temp = 30;
float measured_temp = 30;

// PWM wrap value and clock divide value
// For a CPU rate of 125 MHz, this gives
// a PWM frequency of 1 kHz.
#define WRAPVAL 5000
#define CLKDIV 25.0f

// GPIO we're using for PWM
#define PWM_OUT_1 24
#define PWM_OUT_2 23


// Variable to hold PWM slice number
uint slice_num ;

// PWM duty cycle
volatile int control ;
volatile int old_control ;

//Controller variables
volatile float k_p;
volatile float k_i;
volatile float k_d; 

//PID Sensor + Intermediary variables
float dt = 0.001;

float error;
float prev_error;
float integral_error;
float derivative_error;
// PWM interrupt service routine
void on_pwm_wrap() {
    // Clear the interrupt flag that brought us here
    pwm_clear_irq(pwm_gpio_to_slice_num(PWM_OUT_1));
    pwm_clear_irq(pwm_gpio_to_slice_num(PWM_OUT_2));

    // Update duty cycle
    if (control!=old_control) {
        old_control = control ;
        pwm_set_chan_level(slice_num, PWM_CHAN_A, control);
    }
    
    // Read the temp sensor
    // 
    
    error = desired_temp - measured_temp;
    integral_error += error*dt;
    derivative_error = (error - prev_error)/dt;
    control = proportional_gain*error + integral_gain*integral_error + derivative_gain*derivative_error;
    prev_error = error;
    if (control < 0) {
        control = 0;
    }
    else if (control > 2500){
        control = 2500;
    }
}