/**
 * Nandita Nagarajan (nn234)
 * Nissi Ragland (nkr33)
 * Cameron Goddard (csg83)
 * HARDWARE CONNECTIONS
 *   - GPIO 6 ---> I2C1 SDA
 *   - GPIO 7 ---> I2C1 SCL
 *   - GPIO 21 ---> I2C0 SCL
 *   - GPIO 22 ---> I2C0 SDA
 *   - GPIO 23 ---> PWM output to Fan 2
 *   - GPIO 24 ---> PWM output to Fan 1
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
#include "../lib/BME280-Pico/bme280.hpp"

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

//Define I2C variables
#define I2C_CHAN_0 i2c0
#define I2C_CHAN_1 i2c1
#define I2C0_SDA 22
#define I2C0_SCL 21
#define I2C1_SDA 6
#define I2C1_SCL 7

//temp variables that will be in driver - DELETE when integrated
#define I2C_BAUD_RATE 400000
// Variable to hold PWM slice number
uint slice_num_1 ;
uint slice_num_2 ;

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
        pwm_set_chan_level(slice_num_1, PWM_CHAN_A, control);
        pwm_set_chan_level(slice_num_2, PWM_CHAN_B, control);
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
int main() {

    // Initialize stdio
    stdio_init_all();

    ////////////////////////////////////////////////////////////////////////
    ///////////////////////// I2C CONFIGURATION ////////////////////////////
    i2c_init(I2C_CHAN_0, I2C_BAUD_RATE) ;
    gpio_set_function(I2C0_SCL, GPIO_FUNC_I2C) ;
    gpio_set_function(I2C0_SDA, GPIO_FUNC_I2C) ;

    i2c_init(I2C_CHAN_1, I2C_BAUD_RATE) ; 
    gpio_set_function(I2C1_SCL, GPIO_FUNC_I2C);
    gpio_set_function(I2C1_SDA, GPIO_FUNC_I2C); 


    ////////////////////////////////////////////////////////////////////////
    ///////////////////////// PWM CONFIGURATION ////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    // Tell GPIO PWM_OUT that it is allocated to the PWM
    gpio_set_function(PWM_OUT_1, GPIO_FUNC_PWM);
    gpio_set_function(PWM_OUT_2, GPIO_FUNC_PWM);

    // Find out which PWM slice is connected to GPIO PWM_OUT (it's slice 2)
    slice_num_1 = pwm_gpio_to_slice_num(PWM_OUT_1);
    slice_num_2 = pwm_gpio_to_slice_num(PWM_OUT_2);

    // Mask our slice's IRQ output into the PWM block's single interrupt line,
    // and register our interrupt handler
    pwm_clear_irq(slice_num_1);
    pwm_clear_irq(slice_num_2);
    pwm_set_irq_enabled(slice_num_1, true);
    pwm_set_irq_enabled(slice_num_2, true);
    irq_set_exclusive_handler(PWM_IRQ_WRAP, on_pwm_wrap);
    irq_set_enabled(PWM_IRQ_WRAP, true);

    // This section configures the period of the PWM signals
    pwm_set_wrap(slice_num_1, WRAPVAL) ;
    pwm_set_wrap(slice_num_2, WRAPVAL);
    pwm_set_clkdiv(slice_num_1, CLKDIV) ;
    pwm_set_clkdiv(slice_num_2, CLKDIV) ; 

    pwm_set_output_polarity(slice_num_1, 1, 1);
    pwm_set_output_polarity(slice_num_2, 1, 1);

    // This sets duty cycle
    pwm_set_chan_level(slice_num_1, PWM_CHAN_A, 3125);
    pwm_set_chan_level(slice_num_2, PWM_CHAN_A, 3125);

    // Start the channel
    pwm_set_mask_enabled((1u << slice_num_1));
    pwm_set_mask_enabled((1u << slice_num_2));

    ////////////////////////////////////////////////////////////////////////
    ///////////////////////////// ROCK AND ROLL ////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    // // start core 1 
    // multicore_reset_core1();
    // multicore_launch_core1(core1_entry);

    // // start core 0
    // pt_add_thread(protothread_serial) ;
    // pt_schedule_start ;

}
