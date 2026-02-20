cmake_minimum_required(VERSION 3.15)
project(integration_test LANGUAGES CXX)

enable_testing()

find_package(TestLib CONFIG REQUIRED)

add_executable(integration_test_ios Main.cpp)

target_link_libraries(integration_test_ios PRIVATE TestLib::test-lib)

set_target_properties(integration_test_ios PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.test.integration"
    MACOSX_BUNDLE_BUNDLE_NAME "IntegrationTest"
)

add_test(NAME integration_test_ios
  COMMAND ${CMAKE_COMMAND}
    -DEXE=$<TARGET_FILE:integration_test_ios>
    -P ${CMAKE_CURRENT_LIST_DIR}/RunIOS_VisionOSTest.cmake
)