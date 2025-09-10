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

# use Bash to run tests on Windows
set(BASH bash)
if (WIN32)
    # Try to find bash.exe first (preferred for no window creation)
    find_program(BASH_EXE "bash.exe" PATHS 
        "C:/Program Files/Git/bin"
        "C:/Program Files (x86)/Git/bin"
        "C:/msys64/usr/bin"
        "C:/msys32/usr/bin"
        NO_DEFAULT_PATH)
    
    # If bash.exe not found, try git-bash.exe with no-window flags
    if (NOT BASH_EXE)
        find_program(GIT_BASH_EXE "git-bash.exe" PATHS 
            "C:/Program Files/Git"
            "C:/Program Files (x86)/Git"
            NO_DEFAULT_PATH)
        if (GIT_BASH_EXE)
            # Use git-bash.exe with flags to prevent window creation
            set(BASH ${GIT_BASH_EXE} --no-cd --hide)
        endif()
    else()
        set(BASH ${BASH_EXE})
    endif()
endif()

foreach(CLIENT_TEST IN ITEMS ${CLIENT_TESTS})
    get_filename_component(TEST_NAME ${CLIENT_TEST} NAME)

    add_test(NAME srcml.${TEST_NAME} COMMAND ${BASH} ${CLIENT_TEST})
    # Command line --timeout does NOT override this value
    #set_tests_properties(${TEST_NAME} PROPERTIES TIMEOUT 10)

    set_tests_properties(srcml.${TEST_NAME} PROPERTIES WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
endforeach()
