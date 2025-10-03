cmake_minimum_required(VERSION 3.10)
project(FileEncryptionTool)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add executable
add_executable(file_encrypt
    main.cpp
    aes.cpp
    sha256.cpp
)

# Compiler warnings
if(MSVC)
    target_compile_options(file_encrypt PRIVATE /W4)
else()
    target_compile_options(file_encrypt PRIVATE -Wall -Wextra -pedantic)
endif()

# Installation
install(TARGETS file_encrypt DESTINATION bin)
