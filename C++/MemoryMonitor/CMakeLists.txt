cmake_minimum_required(VERSION 3.10)
project(MemoryMonitor)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add executable
add_executable(memory_monitor
    main.cpp
)

# Link with Windows libraries
if(WIN32)
    target_link_libraries(memory_monitor psapi)
endif()

# Compiler warnings
if(MSVC)
    target_compile_options(memory_monitor PRIVATE /W4)
else()
    target_compile_options(memory_monitor PRIVATE -Wall -Wextra -pedantic)
endif()

# Installation
install(TARGETS memory_monitor DESTINATION bin)
