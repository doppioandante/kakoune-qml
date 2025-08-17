cmake_minimum_required(VERSION 3.16)
project(kakouneqml)

set(CMAKE_CXX_STANDARD 14)

#find_package(Qt5 5.13.0 REQUIRED COMPONENTS Core Qml Quick)
find_package(Qt6 5.13.0 REQUIRED COMPONENTS Core Qml Quick)
qt_standard_project_setup()
# Find includes in corresponding build directories
#set(CMAKE_INCLUDE_CURRENT_DIR ON)
# Instruct CMake to run moc automatically when needed.
set(CMAKE_AUTOMOC ON)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

add_subdirectory(src)
