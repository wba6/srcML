# SPDX-License-Identifier: GPL-3.0-only
##
# @file CMakeLists.txt
# 
# @copyright Copyright (C) 2014-2024 srcML, LLC. (www.srcML.org)
# 
# CMake files for client tests

# add client tests
file(GLOB CLIENT_TESTS "${CMAKE_CURRENT_SOURCE_DIR}/*.sh")
list(REMOVE_ITEM CLIENT_TESTS "${CMAKE_CURRENT_SOURCE_DIR}/framework_test.sh")

foreach(CLIENT_TEST IN ITEMS ${CLIENT_TESTS})
    get_filename_component(TEST_NAME ${CLIENT_TEST} NAME)

    add_test(NAME srcml.${TEST_NAME} COMMAND bash ${CLIENT_TEST})
    # Command line --timeout does NOT override this value
    #set_tests_properties(${TEST_NAME} PROPERTIES TIMEOUT 10)

    set_tests_properties(srcml.${TEST_NAME} PROPERTIES WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

    message(STATUS "Adding test: ${CLIENT_TEST}")
endforeach()
