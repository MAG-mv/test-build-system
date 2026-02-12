cmake_minimum_required(VERSION 3.15...4.2)

project(TestLib VERSION 1.0
    DESCRIPTION "Test library for build system"
    LANGUAGES CXX)

add_library(test-lib Library/src/TestLib.cpp Library/include/TestLib.h)

# Generate export header that defines the TEST_LIB_EXPORT macro for exporting in shared library builds
include(GenerateExportHeader)

generate_export_header(test-lib
  EXPORT_FILE_NAME ${CMAKE_CURRENT_BINARY_DIR}/TestLibExport.h
)

# Disable export macro for static builds by defining TEST_LIB_STATIC_DEFINE
# This is handled inside the generated TestLibExport.h
target_compile_definitions(test-lib PUBLIC
  $<$<NOT:$<BOOL:${BUILD_SHARED_LIBS}>>:TEST_LIB_STATIC_DEFINE>
)

# Set include directories
target_include_directories(test-lib PUBLIC
  # Include dir when building from source
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Library/include>
  # Include binary dir for TestLibExport.h
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
  # Include dir after installation 
  $<INSTALL_INTERFACE:include>
)

# Project uses C++17
target_compile_features(test-lib PUBLIC cxx_std_17)

include(CTest)

if(BUILD_TESTING)

  # Create test executable
  find_package(GTest CONFIG REQUIRED)

  add_executable(test-lib-tests Tests/Tests.cpp)

  target_link_libraries(test-lib-tests
    PRIVATE test-lib
    GTest::gtest
    GTest::gtest_main
  )

endif()

# Install ---------------------------------------------------------

# Get cross platform install vars
include(GNUInstallDirs)
# Get install helper functions
include(CMakePackageConfigHelpers)

# Create namespaced target name
add_library(TestLib::test-lib ALIAS test-lib)

install(TARGETS test-lib
  EXPORT TestLibTargets
  # Windows dll location
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  # .so/.dylib location
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  # .a or import .lib location
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  # Includes location
  INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# Install public headers
# What is this for when we have INCLUDES DESTINATION above?
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/Library/include/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# Install the generated export header
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/TestLibExport.h
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# Create config files

# Location of package config files
set(TestLibConfigInstallDir "${CMAKE_INSTALL_LIBDIR}/cmake/TestLib")

# Create Config.cmake
configure_package_config_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/cmake/TestLibConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/TestLibConfig.cmake
  INSTALL_DESTINATION ${TestLibConfigInstallDir}
)

# Create ConfigVersion.cmake
write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/TestLibConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
)

# Install the config files
install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/TestLibConfig.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/TestLibConfigVersion.cmake
  DESTINATION ${TestLibConfigInstallDir}
)

# Install the exported targets file
install(EXPORT TestLibTargets
  NAMESPACE TestLib::
  DESTINATION ${TestLibConfigInstallDir}
)