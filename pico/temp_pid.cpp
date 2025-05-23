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

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "pico/multicore.h"
#include "pico/stdlib.h"

// Include hardware libraries
#include "hardware/i2c.h"
#include "hardware/irq.h"
#include "hardware/pwm.h"

// Include custom libraries
#include "pt_cornell_rp2040_v1_3.h"

//Driver for temp sensor library
#include "../lib/BME280-Pico/bme280.hpp"

//Tiny USB header and associated file imports
#include "tusb.h"
#include <cstdio>

// Add imports for BLE and bluetooth for app connection
#include "pico/btstack_cyw43.h"
#include "pico/cyw43_arch.h"

#include "btstack.h"
#include "btstack_config.h"
#include "pid_db.h"
#include <cmath>

#include "hardware/sync.h"
#include "pico/time.h"

#include "GAP_Advertisement/gap_config.h"
#include "GATTService/service_implementation.h"



// PWM wrap value and clock divide value
#define WRAPVAL 10000
#define CLKDIV 50.0f

// GPIO we're using for PWM
#define PWM_OUT_1 27
#define PWM_OUT_2 26

// Define I2C variables
#define I2C_CHAN_0 i2c0
#define I2C_CHAN_1 i2c1
#define I2C0_SDA 20
#define I2C0_SCL 21
#define I2C1_SDA 6
#define I2C1_SCL 7

enum Mode { manual,
            controller };

Mode mode;

// Variable to hold PWM slice number
uint slice_num_1;
uint slice_num_2;

// PWM duty cycle
int32_t control;
int32_t old_control;

// PWM control flag
volatile bool update_PWM_1;
volatile bool update_PWM_2;

int32_t manual_pwm_1 = 101;
int32_t manual_pwm_2 = 101;

// P Controller + Intermediary variables
float proportional_gain = 100;
float desired_temp = 25;
float measured_temp;
float error;
float prev_error;

// Sensor Variables
BME280 sensor_1(I2C_CHAN_0);
BME280 sensor_2(I2C_CHAN_0);
BME280 sensor_3(I2C_CHAN_1);

// Bluetooth variables
static btstack_packet_callback_registration_t hci_event_callback_registration;

// buffers for sending values as byte arrays
char temp_1_bytes[64];
char temp_2_bytes[64];
char temp_3_bytes[64];
char pwm_1_bytes[64];
char pwm_2_bytes[64];
char kp_bytes[64];
char mode_bytes[64];
char desired_temp_bytes[64];
bool received_first = false;

//Update PWM 1 callback - From App 
void update_pwm_1_callback(uint32_t new_pwm) {
    manual_pwm_1 = new_pwm;
}

//Update PWM 2 callback - From App
void update_pwm_2_callback(uint32_t new_pwm) {
    manual_pwm_2 = new_pwm;
}

//Update Kp callback - From App
void update_kp_callback(float new_kp) { proportional_gain = new_kp; }

//Update Mode callback - From App
void update_mode_callback(uint8_t new_mode) {
    if (new_mode == 0) {
        mode = manual;
        printf("[MAIN] Set mode to manual\n");
    } else if (new_mode == 1) {
        mode = controller;
        printf("[MAIN] Set mode to controller\n");
    }
}

//Update Desired Temperature Callback - From App
void update_desired_temp_callback(float new_temp) {
    desired_temp = new_temp;
}

// PWM interrupt service routine
void on_pwm_wrap() {
    uint32_t status = pwm_get_irq_status_mask();

    //If interrupt is on PWM1 Pin
    if (status & (1 << slice_num_1)) {
        //clear interrupt handler 
        pwm_clear_irq(pwm_gpio_to_slice_num(PWM_OUT_1));
        //update PWM1 flag for main thread
        update_PWM_1 = true;
    }
    //If interrupt is on PWM2 pin
    if (status & (1 << slice_num_2)) {
        //clear interrupt handler
        pwm_clear_irq(pwm_gpio_to_slice_num(PWM_OUT_2));
        //update PWM2 flag for main thread
        update_PWM_2 = true;
    }
}

// Temperature polling thread
static PT_THREAD(protothread_temp(struct pt *pt)) {
    PT_BEGIN(pt);
    float temp_1_val;
    float temp_2_val;
    float temp_3_val;
    bool useOne = true;
    bool useTwo = true;
    bool useThree = true;
    while (1) {
    // Read Temp sensor 1
        if (!sensor_1.read_temperature(&temp_1_val)) {
            printf("Error: Sensor 1 failed to read temperature\n");
            useOne = false;
        }
        //set temperature 1 value in the app
        set_temp_1_value(&temp_1_val);

    // Read Temp sensor 2
        if (!sensor_2.read_temperature(&temp_2_val)) {
            printf("Error: Sensor 2 failed to read temperature\n");
            useTwo = false;
        }
        //set temperature 2 value in the app
        set_temp_2_value(&temp_2_val);

    // Temp Sensor 3
        if (!sensor_3.read_temperature(&temp_3_val)) {
            printf("Error: Sensor 3 failed to read temperature\n");
            useThree = false;
        }
        //set temperature 3 value in the app
        set_temp_3_value(&temp_3_val);

        //Choose valid temperature sensor data to average for measured_temp
        float sum = 0;
        int count = 0;

        if (useOne) {
            sum += temp_1_val;
            count++;
        }
        if (useTwo) {
            sum += temp_2_val;
            count++;
        }
        if (useThree) {
            sum += temp_3_val;
            count++;
        }

        // Default to temp_3_val if no sensors active
        if (count == 0) {
            sum = temp_3_val;
            count = 1;
            useOne = useTwo = true;
        }

        if (count < 3) {
            useOne = useTwo = useThree = true;
        }
        //Calculate average measured temperature
        measured_temp = sum / count;

        //Calculate error from desired temperature 
        error = desired_temp - measured_temp;

        if (update_PWM_1) {
      // Handle manual mode
            if (mode == 0) {
                pwm_set_chan_level(slice_num_1, PWM_CHAN_B, (uint16_t)(manual_pwm_1));
                set_pwm_1_value(&manual_pwm_1);
            } 
            //Handle controller mode
            else {
                //Update PWM 1
                if (control != old_control) {
                    old_control = control;
                    pwm_set_chan_level(slice_num_1, PWM_CHAN_B, (uint16_t)(control));
                }
                //calculate controller value 
                control = (int32_t)(proportional_gain * error);
                //check if calculated controller value is above limits
                if (control < 0) {
                    control = 0;
                } else if (control > 1500) {
                    control = 1500;
                }
                //set PWM value from the controller
                set_pwm_1_value(&control);
            }
            update_PWM_1 = false;
        }
        if (update_PWM_2) {
      // Handle manual mode
            if (mode == 0) {
                pwm_set_chan_level(slice_num_2, PWM_CHAN_A, (uint16_t)(manual_pwm_2));
                set_pwm_2_value(&manual_pwm_2);
            
            }
            //Handle controller modew 
            else {
                //update PWM 2
                if (control != old_control) {
                    old_control = control;
                    pwm_set_chan_level(slice_num_2, PWM_CHAN_A, (uint16_t)(control));
                }
                //calculate new control value
                control = (int32_t)(proportional_gain * error);
                //Check if the control is over specified max and min
                if (control < 0) {
                    control = 0;
                } 
                else if (control > 1500) {
                    control = 1500;
                }
                //Set PWM value from controller
                set_pwm_2_value(&control);
            }
            //re-initialize PWM update
            update_PWM_2 = false;
        }
        //update previous error
        prev_error = error;
    }
    PT_END(pt);
}

int main() {

  // Initialize stdio
    stdio_init_all();

    sleep_ms(5000);
  // Initialize bluetooth
    if (cyw43_arch_init()) {
        printf("Bluetooth init failed \n");
        return -1;
    }

    l2cap_init();
    sm_init();

    att_server_init(profile_data, NULL, NULL);

    //Initialize bluetooth service with characteristics
    custom_service_server_init(
        temp_1_bytes, temp_2_bytes, temp_3_bytes, pwm_1_bytes,
        update_pwm_1_callback, pwm_2_bytes, update_pwm_2_callback, kp_bytes,
        update_kp_callback, mode_bytes, update_mode_callback, desired_temp_bytes,
        update_desired_temp_callback
    );

    //register bluetooth callback functions
    hci_event_callback_registration.callback = &packet_handler;

    //add bluetooth event handler
    hci_add_event_handler(&hci_event_callback_registration);

    //register bluetooth packet handler
    att_server_register_packet_handler(packet_handler);

    hci_power_control(HCI_POWER_ON);
    cyw43_arch_gpio_put(CYW43_WL_GPIO_LED_PIN, 1);

    //initial, temporary values for characteristic initialization
    float temp_1_val = 25.0;
    float temp_2_val = 25.0;
    float temp_3_val = 25.0;
    int32_t pwm_1_val = 100;
    int32_t pwm_2_val = 100;

    printf("Should have initialized \n");
    set_temp_1_value(&temp_1_val);
    set_temp_2_value(&temp_2_val);
    set_temp_3_value(&temp_3_val);
    set_pwm_1_value(&pwm_1_val);
    set_pwm_2_value(&pwm_2_val);

    sleep_ms(5000);

    ////////////////////////////////////////////////////////////////////////
    ///////////////////////// I2C CONFIGURATION ////////////////////////////
    
    //Initialize I2C0 channel and pins
    i2c_init(I2C_CHAN_0, 400 * 1000);
    gpio_set_function(I2C0_SCL, GPIO_FUNC_I2C);
    gpio_set_function(I2C0_SDA, GPIO_FUNC_I2C);

    //Enable pull-up resistors on I2C0
    gpio_pull_up(I2C0_SDA);
    gpio_pull_up(I2C0_SCL);

    //Initialize I2C1 channel and pins 
    i2c_init(I2C_CHAN_1, 400 * 1000);
    gpio_set_function(I2C1_SCL, GPIO_FUNC_I2C);
    gpio_set_function(I2C1_SDA, GPIO_FUNC_I2C);

    //Enable pull-up resistors on I2C1
    gpio_pull_up(I2C1_SCL);
    gpio_pull_up(I2C1_SDA);

    //Initialize temperature sensor 1
    if (!sensor_1.begin()) {
        printf("Error: Sensor 1 failed to initialize\n");
    }
    //Initialize temperature sensor 2
    if (!sensor_2.begin(0x77)) {
        printf("Error: Sensor 2 failed to initialize\n");
    }
    //Initializae temperatuer sensor 3
    if (!sensor_3.begin()) {
        printf("Error: Sensor 3 failed to initialize\n");
    }

    //////////////////////////////////////////////////////////////////////////
    /////////////////////////// PWM CONFIGURATION //////////////////////////////
    //////////////////////////////////////////////////////////////////////////

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
    pwm_set_wrap(slice_num_1, WRAPVAL);
    pwm_set_wrap(slice_num_2, WRAPVAL);
    pwm_set_clkdiv(slice_num_1, CLKDIV);
    pwm_set_clkdiv(slice_num_2, CLKDIV);

    pwm_set_output_polarity(slice_num_1, 1, 1);
    pwm_set_output_polarity(slice_num_2, 1, 1);

    // This sets duty cycle
    pwm_set_chan_level(slice_num_1, PWM_CHAN_B, 3125);
    pwm_set_chan_level(slice_num_2, PWM_CHAN_A, 3125);

    // Start the channel
    pwm_set_mask_enabled((1u << slice_num_1));
    pwm_set_mask_enabled((1u << slice_num_2));

    //start main protothread
    pt_add_thread(protothread_temp);
    pt_schedule_start;
}
