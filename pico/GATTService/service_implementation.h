#include "btstack_defines.h"
#include "ble/att_db.h"
#include "ble/att_server.h"
#include "btstack_util.h"
#include "bluetooth_gatt.h"
#include "hardware/sync.h"

// Create a struct for managing this service
typedef struct {

	// Connection handle for service
	hci_con_handle_t con_handle ;

	// Temperature Sensor 1 Information
	char * 		temp_1_value ;
	char * 		temp_1_user_description ;
    
    // Temp Sensor 2 Information
	char * 		temp_2_value ;
	char * 		temp_2_user_description ;

    // Temp Sensor 3 Information
    char * 		temp_3_value ;
	char * 		temp_3_user_description ;

    // Duty Cycle - Fan 1 
    char * 		pwm_1_value ;
	char * 		pwm_1_user_description ;

    // Duty Cycle - Fan 2
    char * 		pwm_2_value ;
	char * 		pwm_2_user_description ;

	//Control Mode
	char * 		mode_value;
	char * 		mode_user_description ;


	// Characteristic temp 1 handles
	uint16_t  	temp_1_handle ;
	uint16_t 	temp_1_user_description_handle ;
	uint16_t    temp_1_client_configuration ;
	uint16_t    temp_1_client_configuration_handle ;

    // Characteristic Temperature 2 handles
	uint16_t  	temp_2_handle ;
	uint16_t 	temp_2_user_description_handle ;
	uint16_t    temp_2_client_configuration ;
	uint16_t    temp_2_client_configuration_handle ;

    // Characteristic Temp 3 handles
	uint16_t  	temp_3_handle ;
	uint16_t 	temp_3_user_description_handle ;
	uint16_t    temp_3_client_configuration ;
	uint16_t    temp_3_client_configuration_handle ;

    // Characteristic PWM 1 handles
	uint16_t  	pwm_1_handle ;
	uint16_t 	pwm_1_user_description_handle ;
	uint16_t    pwm_1_client_configuration ;
	uint16_t    pwm_1_client_configuration_handle ;

    // Characteristic PWM 2 handles
	uint16_t  	pwm_2_handle ;
	uint16_t 	pwm_2_user_description_handle ;
	uint16_t    pwm_2_client_configuration ;
	uint16_t    pwm_2_client_configuration_handle ;

	// Characteristic mode handles
	uint16_t  	mode_handle ;
	uint16_t 	mode_user_description_handle ;
	uint16_t    mode_client_configuration ;
	uint16_t    mode_client_configuration_handle ;

	// Callback functions
	btstack_context_callback_registration_t callback_temp_1 ;
    btstack_context_callback_registration_t callback_temp_2 ;
    btstack_context_callback_registration_t callback_temp_3 ;
    btstack_context_callback_registration_t callback_pwm_1 ;
    btstack_context_callback_registration_t callback_pwm_2 ;
	btstack_context_callback_registration_t callback_mode ;

} GYATT_DB ;

// Create a callback registration object, and an att service handler object
static att_service_handler_t service_handler ;
static GYATT_DB service_object ;

// Characteristic user descriptions (appear in LightBlue app)
char char_temp_1[] = "Temperature 1 deg C" ;
char char_temp_2[] = "Temperature 2 deg C" ;
char char_temp_3[] = "Temperature 3 deg C" ;
char char_pwm_1[] = "PWM 1 Duty Cycle" ;
char char_pwm_2[] = "PWM 2 Duty Cycle" ;
char char_mode[] = "Mode" ; 

// Protothreads semaphore
struct pt_sem BLUETOOTH_READY ;

// Callback functions for ATT notifications on characteristics
static void characteristic_temp_1_callback(void * context){
	// Associate the void pointer input with our custom service object
	GYATT_DB * instance = (GYATT_DB *) context ;
	// Send a notification
	att_server_notify(instance->con_handle, instance->temp_1_handle, (uint8_t*)instance->temp_1_value, strlen(instance->temp_1_value)) ;
}

static void characteristic_temp_2_callback(void * context){
	// Associate the void pointer input with our custom service object
	GYATT_DB * instance = (GYATT_DB *) context ;
	// Send a notification
	att_server_notify(instance->con_handle, instance->temp_2_handle, (uint8_t*)instance->temp_2_value, strlen(instance->temp_2_value)) ;
}

static void characteristic_temp_3_callback(void * context){
	// Associate the void pointer input with our custom service object
	GYATT_DB * instance = (GYATT_DB *) context ;
	// Send a notification
	att_server_notify(instance->con_handle, instance->temp_3_handle, (uint8_t*)instance->temp_3_value, strlen(instance->temp_3_value)) ;
}

static void characteristic_pwm_1_callback(void * context){
	// Associate the void pointer input with our custom service object
	GYATT_DB * instance = (GYATT_DB *) context ;
	// Send a notification
	att_server_notify(instance->con_handle, instance->pwm_1_handle, (uint8_t*)instance->pwm_1_value, strlen(instance->pwm_1_value)) ;
}

static void characteristic_pwm_2_callback(void * context){
	// Associate the void pointer input with our custom service object
	GYATT_DB * instance = (GYATT_DB *) context ;
	// Send a notification
	att_server_notify(instance->con_handle, instance->pwm_2_handle, (uint8_t*)instance->pwm_2_value, strlen(instance->pwm_2_value)) ;
}

static void characteristic_mode_callback(void * context){
	// Associate the void pointer input with our custom service object
	GYATT_DB * instance = (GYATT_DB *) context ;
	// Send a notification
	att_server_notify(instance->con_handle, instance->mode_handle, (uint8_t*)instance->mode_value, strlen(instance->mode_value)) ;
}


// Read callback (no client configuration handles on characteristics without Notify)
static uint16_t custom_service_read_callback(hci_con_handle_t con_handle, uint16_t attribute_handle, uint16_t offset, uint8_t * buffer, uint16_t buffer_size){
	UNUSED(con_handle);

	// Characteristic Temp 1
	if (attribute_handle == service_object.temp_1_handle){
		return att_read_callback_handle_blob((uint8_t*)service_object.temp_1_value, strlen(service_object.temp_1_value), offset, buffer, buffer_size);
	}
	if (attribute_handle == service_object.temp_1_user_description_handle) {
		return att_read_callback_handle_blob((uint8_t*)service_object.temp_1_user_description, strlen(service_object.temp_1_user_description), offset, buffer, buffer_size);
	}
	if (attribute_handle == service_object.temp_1_client_configuration_handle){
        return att_read_callback_handle_little_endian_16(service_object.temp_1_client_configuration, offset, buffer, buffer_size);
    }

    // Characteristic Temp 2
	if (attribute_handle == service_object.temp_2_handle){
		return att_read_callback_handle_blob((uint8_t*)service_object.temp_2_value, strlen(service_object.temp_2_value), offset, buffer, buffer_size);
	}
	if (attribute_handle == service_object.temp_2_user_description_handle) {
		return att_read_callback_handle_blob((uint8_t*)service_object.temp_2_user_description, strlen(service_object.temp_2_user_description), offset, buffer, buffer_size);
	}
	if (attribute_handle == service_object.temp_2_client_configuration_handle){
        return att_read_callback_handle_little_endian_16(service_object.temp_2_client_configuration, offset, buffer, buffer_size);
    }

    // Characteristic Temp 3
	if (attribute_handle == service_object.temp_3_handle){
		return att_read_callback_handle_blob((uint8_t*)service_object.temp_3_value, strlen(service_object.temp_3_value), offset, buffer, buffer_size);
	}
	if (attribute_handle == service_object.temp_3_user_description_handle) {
		return att_read_callback_handle_blob((uint8_t*)service_object.temp_3_user_description, strlen(service_object.temp_3_user_description), offset, buffer, buffer_size);
	}
	if (attribute_handle == service_object.temp_3_client_configuration_handle){
        return att_read_callback_handle_little_endian_16(service_object.temp_3_client_configuration, offset, buffer, buffer_size);
    }

    // Characteristic PWM 1
	if (attribute_handle == service_object.pwm_1_handle){
		return att_read_callback_handle_blob((uint8_t*)service_object.pwm_1_value, strlen(service_object.pwm_1_value), offset, buffer, buffer_size);
	}
	if (attribute_handle == service_object.pwm_1_user_description_handle) {
		return att_read_callback_handle_blob((uint8_t*)service_object.pwm_1_user_description, strlen(service_object.pwm_1_user_description), offset, buffer, buffer_size);
	}
	if (attribute_handle == service_object.pwm_1_client_configuration_handle){
        return att_read_callback_handle_little_endian_16(service_object.pwm_1_client_configuration, offset, buffer, buffer_size);
    }

    // Characteristic PWM 2
	if (attribute_handle == service_object.pwm_2_handle){
		return att_read_callback_handle_blob((uint8_t*)service_object.pwm_2_value, strlen(service_object.pwm_2_value), offset, buffer, buffer_size);
	}
	if (attribute_handle == service_object.pwm_2_user_description_handle) {
		return att_read_callback_handle_blob((uint8_t*)service_object.pwm_2_user_description, strlen(service_object.pwm_2_user_description), offset, buffer, buffer_size);
	}
	if (attribute_handle == service_object.pwm_2_client_configuration_handle){
        return att_read_callback_handle_little_endian_16(service_object.pwm_2_client_configuration, offset, buffer, buffer_size);
    }

	// Characteristic Mode
	if (attribute_handle == service_object.mode_handle){
		return att_read_callback_handle_blob((uint8_t*)service_object.mode_value, strlen(service_object.mode_value), offset, buffer, buffer_size);
	}
	if (attribute_handle == service_object.mode_user_description_handle) {
		return att_read_callback_handle_blob((uint8_t*)service_object.mode_user_description, strlen(service_object.mode_user_description), offset, buffer, buffer_size);
	}
	if (attribute_handle == service_object.mode_client_configuration_handle){
        return att_read_callback_handle_little_endian_16(service_object.mode_client_configuration, offset, buffer, buffer_size);
    }
    return 0;
}

// Write callback
static int custom_service_write_callback(hci_con_handle_t con_handle, uint16_t attribute_handle, uint16_t transaction_mode, uint16_t offset, uint8_t *buffer, uint16_t buffer_size){
    UNUSED(transaction_mode);
    UNUSED(offset);
    UNUSED(buffer_size);

	// Write value directly to PWM 1 characteristic
	if (attribute_handle == service_object.pwm_1_handle) {
		memcpy(service_object.pwm_1_value, buffer, buffer_size);
		service_object.pwm_1_value[buffer_size] = '\0';  // Null-terminate
	}
	// Alert the application of a bluetooth RX
	PT_SEM_SAFE_SIGNAL(pt, &BLUETOOTH_READY) ;

	// Write value directly to PWM 2 characteristic
	if (attribute_handle == service_object.pwm_2_handle) {
		memcpy(service_object.pwm_2_value, buffer, buffer_size);
		service_object.pwm_2_value[buffer_size] = '\0';  // Null-terminate
	}
	// Alert the application of a bluetooth RX
	PT_SEM_SAFE_SIGNAL(pt, &BLUETOOTH_READY) ;

	// Write value directly to mode characteristic
	if (attribute_handle == service_object.mode_handle) {
		memcpy(service_object.mode_value, buffer, buffer_size);
		service_object.mode_value[buffer_size] = '\0';  // Null-terminate
	}
	// Alert the application of a bluetooth RX
	PT_SEM_SAFE_SIGNAL(pt, &BLUETOOTH_READY) ;

	// Enable/disable notifications - Temp 1 
    if (attribute_handle == service_object.temp_1_client_configuration_handle){
        service_object.temp_1_client_configuration = little_endian_read_16(buffer, 0);
        service_object.con_handle = con_handle;
    }
    // Enable/disable notifications - Temp 2
    if (attribute_handle == service_object.temp_2_client_configuration_handle){
        service_object.temp_2_client_configuration = little_endian_read_16(buffer, 0);
        service_object.con_handle = con_handle;
    }
	// Enable/disable notifications - Temp 3
    if (attribute_handle == service_object.temp_3_client_configuration_handle){
        service_object.temp_3_client_configuration = little_endian_read_16(buffer, 0);
        service_object.con_handle = con_handle;
    }
    // Enable/disable notifications - PWM 1
    if (attribute_handle == service_object.pwm_1_client_configuration_handle){
        service_object.pwm_1_client_configuration = little_endian_read_16(buffer, 0);
        service_object.con_handle = con_handle;
    }
	// Enable/disable notifications - PWM 2
    if (attribute_handle == service_object.pwm_2_client_configuration_handle){
        service_object.pwm_2_client_configuration = little_endian_read_16(buffer, 0);
        service_object.con_handle = con_handle;
    }
	// Enable/disable notifications - Mode
    if (attribute_handle == service_object.mode_client_configuration_handle){
        service_object.mode_client_configuration = little_endian_read_16(buffer, 0);
        service_object.con_handle = con_handle;
    }
	return 0;

}
/////////////////////////////////////////////////////////////////////////////
////////////////////////////// USER API /////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

void custom_service_server_init(char * tmp_1_ptr, char * tmp_2_ptr, char * tmp_3_ptr, char * pwm_1_ptr, char * pwm_2_ptr, char * mode_ptr)
{
	// Initialize the semaphore
	PT_SEM_SAFE_INIT(&BLUETOOTH_READY, 0) ;

    // Pointer to our service object
	GYATT_DB * instance = &service_object ;

    // Assign characteristic value
	instance->temp_1_value = tmp_1_ptr ;
	instance->temp_2_value = tmp_2_ptr ;
	instance->temp_3_value = tmp_3_ptr ;
	instance->pwm_1_value = pwm_1_ptr ;
	instance->pwm_2_value = pwm_2_ptr ;
	instance->mode_value = mode_ptr ;

    // Assign characteristic user description
	instance->temp_1_user_description = char_temp_1;
	instance->temp_2_user_description = char_temp_2 ;
	instance->temp_3_user_description = char_temp_3 ;
	instance->pwm_1_user_description = char_pwm_1 ;
	instance->pwm_2_user_description = char_pwm_2 ;
	instance->mode_user_description = char_mode ;

    // Assigning Characteristic Handles
    instance->temp_1_handle=ATT_CHARACTERISTIC_00000002_0000_0715_2006_853A52A41A44_01_VALUE_HANDLE ;
    instance->temp_1_user_description_handle=ATT_CHARACTERISTIC_00000002_0000_0715_2006_853A52A41A44_01_USER_DESCRIPTION_HANDLE ;
    instance->temp_2_handle=ATT_CHARACTERISTIC_00000003_0000_0715_2006_853A52A41A44_01_VALUE_HANDLE;
    instance->temp_2_user_description_handle=ATT_CHARACTERISTIC_00000003_0000_0715_2006_853A52A41A44_01_USER_DESCRIPTION_HANDLE;
    instance->temp_3_handle=ATT_CHARACTERISTIC_00000004_0000_0715_2006_853A52A41A44_01_VALUE_HANDLE;
    instance->temp_3_user_description_handle=ATT_CHARACTERISTIC_00000004_0000_0715_2006_853A52A41A44_01_USER_DESCRIPTION_HANDLE;
    instance->pwm_1_handle=ATT_CHARACTERISTIC_00000005_0000_0715_2006_853A52A41A44_01_VALUE_HANDLE;
    instance->pwm_1_user_description_handle=ATT_CHARACTERISTIC_00000005_0000_0715_2006_853A52A41A44_01_USER_DESCRIPTION_HANDLE;
    instance->pwm_2_handle=ATT_CHARACTERISTIC_00000006_0000_0715_2006_853A52A41A44_01_VALUE_HANDLE;
    instance->pwm_2_user_description_handle=ATT_CHARACTERISTIC_00000006_0000_0715_2006_853A52A41A44_01_USER_DESCRIPTION_HANDLE;
    instance->mode_handle=ATT_CHARACTERISTIC_00000007_0000_0715_2006_853A52A41A44_01_VALUE_HANDLE;
	instance->mode_user_description_handle=ATT_CHARACTERISTIC_00000007_0000_0715_2006_853A52A41A44_01_USER_DESCRIPTION_HANDLE;

    // Service Start and End Handles
    service_handler.start_handle = ATT_SERVICE_00000001_0000_0715_2006_853A52A41A44_START_HANDLE;
    service_handler.end_handle = ATT_SERVICE_00000001_0000_0715_2006_853A52A41A44_END_HANDLE;
    service_handler.read_callback = &custom_service_read_callback;
	service_handler.write_callback = &custom_service_write_callback ;

    // Register the service handler
	att_server_register_service_handler(&service_handler);
}

// Update Temp 1 value
void set_temp_1_value(float * value){
	// Pointer to our service object
	GYATT_DB * instance = &service_object ;

	// Update field value
	sprintf(instance->temp_1_value, "%.3f", *value);

	if (instance->temp_1_client_configuration) {
		// Register a callback
		instance->callback_temp_1.callback = characteristic_temp_1_callback;
		instance->callback_temp_1.context  = (void*) instance;
		att_server_register_can_send_now_callback(&instance->callback_temp_1, instance->con_handle);
	}
}

// Update Temperature 2  value
void set_temp_2_value(float * value){
	// Pointer to our service object
	GYATT_DB * instance = &service_object ;

	// Update field value
	sprintf(instance->temp_2_value, "%.3f", *value) ;

	if (instance->temp_2_client_configuration) {
		// Register a callback
		instance->callback_temp_2.callback = characteristic_temp_2_callback;
		instance->callback_temp_2.context  = (void*) instance;
		att_server_register_can_send_now_callback(&instance->callback_temp_2, instance->con_handle);
	}
}

// Update Temp 3 value
void set_temp_3_value(float * value){

	// Pointer to our service object
	GYATT_DB * instance = &service_object ;

	// Update field value
	sprintf(instance->temp_3_value, "%.3f", *value) ;

	if (instance->temp_3_client_configuration) {
		// Register a callback
		instance->callback_temp_3.callback = characteristic_temp_3_callback;
		instance->callback_temp_3.context  = (void*) instance;
		att_server_register_can_send_now_callback(&instance->callback_temp_3, instance->con_handle);
	}
}

// Update PWM 1 value
void set_pwm_1_value(int32_t * value){

	// Pointer to our service object
	GYATT_DB * instance = &service_object ;

	// Update field value
	sprintf(instance->pwm_1_value, "%d", *value) ;

	if (instance->pwm_1_client_configuration) {
		// Register a callback
		instance->callback_pwm_1.callback = characteristic_pwm_1_callback;
		instance->callback_pwm_1.context  = (void*) instance;
		att_server_register_can_send_now_callback(&instance->callback_pwm_1, instance->con_handle);
	}
}

// Update PWM 2 value
void set_pwm_2_value(int32_t * value){

	// Pointer to our service object
	GYATT_DB * instance = &service_object ;

	// Update field value
	sprintf(instance->pwm_2_value, "%d", *value) ;

	if (instance->pwm_2_client_configuration) {
		// Register a callback
		instance->callback_pwm_2.callback = characteristic_pwm_2_callback;
		instance->callback_pwm_2.context  = (void*) instance;
		att_server_register_can_send_now_callback(&instance->callback_pwm_2, instance->con_handle);
	}
}

// Update mode value
void set_mode_value(bool * value){

	// Pointer to our service object
	GYATT_DB * instance = &service_object ;

	// Update field value
	sprintf(instance->mode_value, "%d", *value) ;

	if (instance->mode_client_configuration) {
		// Register a callback
		instance->callback_mode.callback = characteristic_mode_callback;
		instance->callback_mode.context  = (void*) instance;
		att_server_register_can_send_now_callback(&instance->callback_mode, instance->con_handle);
	}
}

void set_All(float * temp_1, float * temp_2, float * temp_3, int32_t * pwm_1, int32_t * pwm_2, bool * mode) {
	set_temp_1_value(temp_1);
	set_temp_2_value(temp_2);
	set_temp_3_value(temp_3);
	set_pwm_1_value(pwm_1);
	set_pwm_2_value(pwm_2);
}