/**
 * Nandita Nagarajan (nn234)
 * Nissi Ragland (nkr33)
 * Cameron Goddard (csg83)
 * HARDWARE CONNECTIONS
 *   - GPIO 6 ---> I2C1 SDA
 *   - GPIO 7 ---> I2C1 SCL
 *   - GPIO 21 ---> I2C0 SCL
 *   - GPIO 22 ---> I2C0 SDA
 *   - GPIO 26 ---> PWM output to Fan 2
 *   - GPIO 27 ---> PWM output to Fan 1
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
#include "tusb.h"
#include <cstdio>

#define min(a,b) ((a<b) ? a:b)
#define max(a,b) ((a<b) ? b:a)
#define abs(a) ((a>0) ? a:-a)

float proportional_gain = 100;
float desired_temp = 23;
float measured_temp ;

// PWM wrap value and clock divide value
// For a CPU rate of 125 MHz, this gives
// a PWM frequency of 1 kHz.
#define WRAPVAL 5000
#define CLKDIV 25.0f

// GPIO we're using for PWM
#define PWM_OUT_1 27
#define PWM_OUT_2 26

//Define I2C variables
#define I2C_CHAN_0 i2c0
#define I2C_CHAN_1 i2c1
#define I2C0_SDA 20
#define I2C0_SCL 21
#define I2C1_SDA 6
#define I2C1_SCL 7
#define GPIO_TEST 0

//temp variables that will be in driver - DELETE when integrated
#define I2C_BAUD_RATE 100000
// Variable to hold PWM slice number
uint slice_num_1 ;
uint slice_num_2 ;

// PWM duty cycle
volatile int control_1;
volatile int old_control_1;
volatile int control_2 ;
volatile int old_control_2 ;

//Controller variables
volatile float k_p;
volatile float k_i;
volatile float k_d; 

//PID + Intermediary variables
float dt = 0.001;

float error_1;
float prev_error_1;
float error_2;
float prev_error_2;

// Sensor Variables
BME280 sensor(I2C_CHAN_0);

// PWM interrupt service routine - Fan 1
void on_pwm_wrap_1() {
    //printf("in pwm wrap");
    // Clear the interrupt flag that brought us here
    pwm_clear_irq(pwm_gpio_to_slice_num(PWM_OUT_1));

    // Update duty cycle
    if (control_1!=old_control_1) {
        //printf("change duty cycle");
        old_control_1 = control_1 ;
        pwm_set_chan_level(slice_num_1, PWM_CHAN_B, control_1);
    }
    error_1 = measured_temp - desired_temp;
    control_1 = (int)(proportional_gain*error_1);
    prev_error_1 = error_1;
    printf("Error: %f\n", error_1);
    printf("Control: %i\n",control_1);
    if (control_1 < 0) {
        control_1 = 0;
    }
    else if (control_1 > 1500){
        control_1 = 1500;
    }
    //sleep_ms(20);
}

// PWM interrupt service routine - Fan 2
void on_pwm_wrap_2() {
    //printf("in pwm wrap");
    // Clear the interrupt flag that brought us here
    //pwm_clear_irq(pwm_gpio_to_slice_num(PWM_OUT_1));
    gpio_put(GPIO_TEST, 1);
    pwm_clear_irq(pwm_gpio_to_slice_num(PWM_OUT_2));

    // Update duty cycle
    if (control_2!=old_control_2) {
        //printf("change duty cycle");
        old_control_2 = control_2 ;
       // pwm_set_chan_level(slice_num_1, PWM_CHAN_B, control);
        pwm_set_chan_level(slice_num_2, PWM_CHAN_A, control_2);
    }
    error_2 = measured_temp - desired_temp;
    control_2 = (int)(proportional_gain*error_2);
    prev_error_2 = error_2;
    // printf("Error: %f\n", error_2);
    // printf("Control: %i\n",control_2);
    if (control_2 < 0) {
        control_2 = 0;
    }
    else if (control_2 > 1500){
        control_2 = 1500;
    }
    //sleep_ms(20);
}

// Temperature polling thread
static PT_THREAD (protothread_temp(struct pt *pt)){
    PT_BEGIN(pt);
    sensor.read_temperature(&measured_temp);

    if (!sensor.read_temperature(&measured_temp)) {
        printf("Error: Sensor failed to read temperature\n");
    }
    printf("Temperature: %.2f\n\n", measured_temp);
    PT_END(pt);
}


int main() {

    // Initialize stdio
    stdio_init_all();

    ////////////////////////////////////////////////////////////////////////
    ///////////////////////// I2C CONFIGURATION ////////////////////////////
    i2c_init(I2C_CHAN_0, I2C_BAUD_RATE) ;
    gpio_set_function(I2C0_SCL, GPIO_FUNC_I2C) ;
    gpio_set_function(I2C0_SDA, GPIO_FUNC_I2C) ;
    gpio_pull_up(I2C0_SDA);
    gpio_pull_up(I2C0_SCL);

    while (!tud_cdc_connected()) {
        sleep_ms(500);
    }
    printf("Connected\n");

    while (!sensor.begin()) {
        printf("Error: Sensor failed to initialize\n");
        sleep_ms(50);
    }
    // printf("Left Sensor Begin Loop");

    // i2c_init(I2C_CHAN_1, I2C_BAUD_RATE) ; 
    // gpio_set_function(I2C1_SCL, GPIO_FUNC_I2C);
    // gpio_set_function(I2C1_SDA, GPIO_FUNC_I2C); 



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
   // irq_set_exclusive_handler(PWM_IRQ_WRAP, on_pwm_wrap);
    irq_add_shared_handler(PWM_IRQ_WRAP, on_pwm_wrap_1, 1);
    irq_add_shared_handler(PWM_IRQ_WRAP, on_pwm_wrap_2, 0);
    irq_set_enabled(PWM_IRQ_WRAP, true);
    // This section configures the period of the PWM signals
    pwm_set_wrap(slice_num_1, WRAPVAL) ;
    pwm_set_wrap(slice_num_2, WRAPVAL);
    pwm_set_clkdiv(slice_num_1, CLKDIV) ;
    pwm_set_clkdiv(slice_num_2, CLKDIV) ; 

    pwm_set_output_polarity(slice_num_1, 1, 1);
    pwm_set_output_polarity(slice_num_2, 1, 1);
    // This sets duty cycle
    pwm_set_chan_level(slice_num_1, PWM_CHAN_B, 3125);
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

    // start core 0
    pt_add_thread(protothread_temp) ;
    pt_schedule_start ;
    // while(1)
    // {

    // }

}
