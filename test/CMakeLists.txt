cmake_minimum_required(VERSION 3.12)

# Comment the line below in for the Pico W examples to build
# set(PICO_BOARD pico_w)

# Pull in SDK (must be before project)
include(../pico_sdk_import.cmake)

project(test C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)


# Initialize the SDK
pico_sdk_init()

add_compile_options(-Wall
    -Wno-format
    -Wno-unused-function
    -Wno-maybe-uninitialized
)

add_executable(test)

# must match with pio filename and executable name from above

# must match with executable name and source file names
target_sources(test PRIVATE test_pwm.cpp)

# Add pico_multicore which is required for multicore functionality
target_link_libraries(test pico_stdlib pico_multicore pico_bootsel_via_double_reset hardware_pwm hardware_irq hardware_i2c hardware_pio hardware_dma)

# create map/bin/hex file etc.
pico_add_extra_outputs(test)