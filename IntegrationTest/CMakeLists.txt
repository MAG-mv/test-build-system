cmake_minimum_required(VERSION 3.15)
project(integration_test LANGUAGES CXX)

enable_testing()

find_package(TestLib CONFIG REQUIRED)

add_executable(integration_test Main.cpp)

target_link_libraries(integration_test PRIVATE TestLib::test-lib)

add_test(NAME integration_test COMMAND $<TARGET_FILE:integration_test>)

# Add the dll directory to the path on Windows
if(WIN32)
    get_target_property(_t TestLib::test-lib TYPE)

    if(_t STREQUAL "SHARED_LIBRARY")
        if(NOT TESTLIB_INSTALL_PREFIX)
            message(FATAL_ERROR "TESTLIB_INSTALL_PREFIX must be set when testing shared TestLib on Windows")
        endif()

        set_tests_properties(integration_test PROPERTIES
            ENVIRONMENT "PATH=${TESTLIB_INSTALL_PREFIX}/bin;$ENV{PATH}"
        )
    endif()
endif()