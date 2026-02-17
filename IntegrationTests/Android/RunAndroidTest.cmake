# RunOnAndroid.cmake
if(NOT DEFINED ADB OR NOT DEFINED DEVICE_DIR OR NOT DEFINED EXE)
  message(FATAL_ERROR "Missing ADB/DEVICE_DIR/EXE")
endif()

# Create dir
execute_process(COMMAND ${ADB} shell "mkdir -p ${DEVICE_DIR}"
  RESULT_VARIABLE r)
if(NOT r EQUAL 0)
  message(FATAL_ERROR "adb mkdir failed")
endif()

# Push exe
execute_process(COMMAND ${ADB} push "${EXE}" "${DEVICE_DIR}/integration_test"
                RESULT_VARIABLE r)
if(NOT r EQUAL 0)
  message(FATAL_ERROR "adb push exe failed")
endif()

# Push any shared libs
if(DEFINED RUNTIME_LIBS AND NOT "${RUNTIME_LIBS}" STREQUAL "")
    separate_arguments(RUNTIME_LIBS)

    foreach(lib IN LISTS RUNTIME_LIBS)
        execute_process(COMMAND ${ADB} push "${lib}" "${DEVICE_DIR}/"
            RESULT_VARIABLE r)
            
        if(NOT r EQUAL 0)
            message(FATAL_ERROR "adb push lib failed: ${lib}")
        endif()
    endforeach()
endif()

# Make executable
execute_process(COMMAND ${ADB} shell "chmod 755 ${DEVICE_DIR}/integration_test"
    RESULT_VARIABLE r)

if(NOT r EQUAL 0)
  message(FATAL_ERROR "adb chmod failed")
endif()

# Run executable
execute_process(
  COMMAND ${ADB} shell "LD_LIBRARY_PATH=${DEVICE_DIR} ${DEVICE_DIR}/integration_test"
  RESULT_VARIABLE r
)

if(NOT r EQUAL 0)
  message(FATAL_ERROR "integration_test failed with code ${r}")
endif()