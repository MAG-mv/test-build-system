cmake_minimum_required(VERSION 3.15)
project(integration_test LANGUAGES CXX)

enable_testing()

find_package(TestLib CONFIG REQUIRED)

add_executable(integration_test Main.cpp)
target_link_libraries(integration_test PRIVATE TestLib::test-lib)

# Allow user to provide any shared libraries
set(RUNTIME_LIBS "" CACHE STRING "Semicolon-separated list of runtime shared libs (.so) to push")

# Allow user to provide adb path. Otherwise assume it's in PATH
set(ADB_EXECUTABLE "adb" CACHE STRING "Path to adb executable")

# Where to place binaries on device/emulator
set(ANDROID_TMP_DIR "//data//local//tmp//integration_test" CACHE STRING "Device temp dir")

# Test command: push exe (and optionally libs) then run
add_test(NAME integration_test_android
    COMMAND ${CMAKE_COMMAND}
    -DADB=${ADB_EXECUTABLE}
    -DDEVICE_DIR=${ANDROID_TMP_DIR}
    -DEXE=$<TARGET_FILE:integration_test>
    -DRUNTIME_LIBS=${RUNTIME_LIBS}
    -P ${CMAKE_CURRENT_LIST_DIR}/RunAndroidTest.cmake
  )