if(NOT DEFINED EXE)
  message(FATAL_ERROR "EXE not set")
endif()

# Ensure emulator is booted
execute_process(COMMAND xcrun simctl bootstatus booted RESULT_VARIABLE simulator_booted)
if(NOT simulator_booted EQUAL 0)
  message(FATAL_ERROR "No booted simulator")
endif()

set(DEVICE_PATH "/tmp/integration_test_ios")

# Ensure any previous binaries are removed
execute_process(
  COMMAND xcrun simctl spawn booted /bin/rm -f ${DEVICE_PATH}
)

# Copy executable into simulator
execute_process(
  COMMAND xcrun simctl spawn booted /bin/sh -c "/bin/cat > ${DEVICE_PATH}"
  INPUT_FILE "${EXE}"
  RESULT_VARIABLE r1
)
if(NOT r1 EQUAL 0)
  message(FATAL_ERROR "Failed to copy executable into simulator")
endif()

# Give executable permissions
execute_process(
  COMMAND xcrun simctl spawn booted /bin/chmod 755 ${DEVICE_PATH}
  RESULT_VARIABLE r2
)
if(NOT r2 EQUAL 0)
  message(FATAL_ERROR "chmod failed")
endif()

# Run process
execute_process(
  COMMAND xcrun simctl spawn booted ${DEVICE_PATH}
  RESULT_VARIABLE r3
)

# Ensure 0 exit code
if(NOT r3 EQUAL 0)
  message(FATAL_ERROR "integration_test_ios failed with exit code ${r3}")
endif()

# Remove binary
execute_process(
  COMMAND xcrun simctl spawn booted /bin/rm -f ${DEVICE_PATH}
)