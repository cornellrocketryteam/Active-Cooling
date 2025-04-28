/**
 * Nandita Nagarajan (nn234)
 * Nissi Ragland (nkr33)
 * Cameron Goddard (csg83)
 * HARDWARE CONNECTIONS
 *  - GPIO 23 ---> PWM output to Fan 2
 *  - GPIO 24 ---> PWM output to Fan 1
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


#define min(a,b) ((a<b) ? a:b)
#define max(a,b) ((a<b) ? b:a)
#define abs(a) ((a>0) ? a:-a)

// PWM wrap value and clock divide value
// For a CPU rate of 125 MHz, this gives
// a PWM frequency of 1 kHz.
#define WRAPVAL 5000
#define CLKDIV 25.0f

// GPIO we're using for PWM
#define PWM_OUT_1 27
#define PWM_OUT_2 26

// Variable to hold PWM slice number
uint slice_num_1 ;
uint slice_num_2 ;

// PWM duty cycle
volatile int control ;
volatile int old_control ;

//Serial input variables
char serial_buffer[64];
u_int8_t buffer_index;
bool is_read;
// PWM interrupt service routine
void on_pwm_wrap() {
    // Clear the interrupt flag that brought us here
    pwm_clear_irq(pwm_gpio_to_slice_num(PWM_OUT_1));
    pwm_clear_irq(pwm_gpio_to_slice_num(PWM_OUT_2));

    // Update duty cycle
    control = 4000;
    if (control!=old_control) {
        old_control = control ;
        pwm_set_chan_level(slice_num_1, PWM_CHAN_A, control);
        pwm_set_chan_level(slice_num_2, PWM_CHAN_B, control);
    }
   
}
void process_serial(){
    if(serial_buffer != nullptr){
        int pwm_val = atoi(serial_buffer);
        control = pwm_val;
    }
}
void read_Serial(){
    int c = getchar_timeout_us(0);
    
    while(c != PICO_ERROR_TIMEOUT){
        if(!is_read){
            is_read = true;
            buffer_index = 0;
        }
        else if(buffer_index > 4){
            is_read = false;
            serial_buffer[buffer_index] = '\0';
            buffer_index = 0;
            process_serial();
        }
        else {
            serial_buffer[buffer_index++] = c;
        }
        c = getchar_timeout_us(0);
    }
}

int main() {

    // Initialize stdio
    stdio_init_all();

    ////////////////////////////////////////////////////////////////////////
    ///////////////////////// I2C CONFIGURATION ////////////////////////////


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
    
}
