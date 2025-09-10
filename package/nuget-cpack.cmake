# SPDX-License-Identifier: GPL-3.0-only
#
# @file nuget.cpack
#
# @copyright Copyright (C) 2014-2024 srcML, LLC. (www.srcML.org)
#
# CPack configuration for NuGet installers

# Exclude other platforms
if(NOT WIN32)
    return()
endif()

# Update the generator list
list(APPEND CPACK_GENERATOR "NuGet")
list(REMOVE_DUPLICATES CPACK_GENERATOR)

# License
set(CPACK_NUGET_SRCML_PACKAGE_LICENSE_EXPRESSION "GPL-3.0-only")
set(CPACK_NUGET_DEVLIBS_PACKAGE_LICENSE_EXPRESSION "GPL-3.0-only")

# Set base file name for test targets  
set(BASE_SRCML_FILE_NAME "${CPACK_PACKAGE_NAME}-${PROJECT_VERSION}")

# Add workflow test targets so test_client target is available on Windows
add_workflow_test_targets(${CMAKE_BINARY_DIR} ${CPACK_OUTPUT_FILE_PREFIX} ${BASE_SRCML_FILE_NAME})
