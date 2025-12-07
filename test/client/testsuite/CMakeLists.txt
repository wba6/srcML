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

# ensure we have the srcml executable available to the test scripts
# rely on PATH to resolve srcml so we work for single and multi-config builds
if (WIN32)
    # Escape semicolons because CTest splits ENVIRONMENT on ';'
    string(REPLACE ";" "\\;" ESC_PATH "$ENV{PATH}")
    string(REPLACE ";" "\\;" ESC_BIN "$<TARGET_FILE_DIR:srcml>")
    set(TEST_ENV "SRCML=$<TARGET_FILE:srcml>;PATH=${ESC_BIN}\\;${ESC_PATH}")
else()
    set(TEST_ENV "SRCML=$<TARGET_FILE:srcml>;PATH=$<TARGET_FILE_DIR:srcml>:${CMAKE_BINARY_DIR}/bin:${CMAKE_BINARY_DIR}/bin/$<CONFIG>:$ENV{PATH}")
endif()

# use Git Bash to run tests on Windows
set(BASH bash)
#if (WIN32)
#    find_program(GIT_BASH "git-bash" PATHS
#        "C:/Program Files/Git"
#        "C:/Program Files/Git/usr"
#        "C:/Program Files (x86)/Git/usr"
#        "C:/Program Files (x86)/Git"
#    NO_DEFAULT_PATH)
#    if (GIT_BASH)
#        set(BASH ${GIT_BASH} --hide)
#    endif()
#endif()

foreach(CLIENT_TEST IN ITEMS ${CLIENT_TESTS})
    get_filename_component(TEST_NAME ${CLIENT_TEST} NAME)

    # Normalize the path so plain bash.exe on Windows understands it (avoids
    # relying on git-bash.exe for C:\ style paths).
    file(TO_CMAKE_PATH "${CLIENT_TEST}" CLIENT_TEST_PATH)

    add_test(NAME srcml.${TEST_NAME} COMMAND ${BASH} ${CLIENT_TEST_PATH})
    # Command line --timeout does NOT override this value
    #set_tests_properties(${TEST_NAME} PROPERTIES TIMEOUT 10)

    set_tests_properties(srcml.${TEST_NAME} PROPERTIES
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        ENVIRONMENT "${TEST_ENV}"
    )
endforeach()
