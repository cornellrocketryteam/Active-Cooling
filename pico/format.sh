#!/bin/bash
# Format all C++ source files in pico/

clang-format -i *.cpp *.hpp ./**/*.cpp ./**/*.hpp