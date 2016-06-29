cmake_minimum_required(VERSION 3.1)
project(boson)

set(CMAKE_CXX_STANDARD 14)
set(QT_REQUIRED_VERSION 5.5.0)

# Find includes in corresponding build directories
#set(CMAKE_INCLUDE_CURRENT_DIR ON)
# Instruct CMake to run moc automatically when needed.
set(CMAKE_AUTOMOC ON)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

add_subdirectory(src)
