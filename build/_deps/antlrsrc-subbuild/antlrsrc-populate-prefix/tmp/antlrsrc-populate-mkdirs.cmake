# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION ${CMAKE_VERSION}) # this file comes with cmake

# If CMAKE_DISABLE_SOURCE_CHANGES is set to true and the source directory is an
# existing directory in our source tree, calling file(MAKE_DIRECTORY) on it
# would cause a fatal error, even though it would be a no-op.
if(NOT EXISTS "/home/runner/work/srcML/srcML/build/_deps/antlrsrc-src")
  file(MAKE_DIRECTORY "/home/runner/work/srcML/srcML/build/_deps/antlrsrc-src")
endif()
file(MAKE_DIRECTORY
  "/home/runner/work/srcML/srcML/build/_deps/antlrsrc-build"
  "/home/runner/work/srcML/srcML/build/_deps/antlrsrc-subbuild/antlrsrc-populate-prefix"
  "/home/runner/work/srcML/srcML/build/_deps/antlrsrc-subbuild/antlrsrc-populate-prefix/tmp"
  "/home/runner/work/srcML/srcML/build/_deps/antlrsrc-subbuild/antlrsrc-populate-prefix/src/antlrsrc-populate-stamp"
  "/home/runner/work/srcML/srcML/build/_deps/antlrsrc-subbuild/antlrsrc-populate-prefix/src"
  "/home/runner/work/srcML/srcML/build/_deps/antlrsrc-subbuild/antlrsrc-populate-prefix/src/antlrsrc-populate-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/home/runner/work/srcML/srcML/build/_deps/antlrsrc-subbuild/antlrsrc-populate-prefix/src/antlrsrc-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/home/runner/work/srcML/srcML/build/_deps/antlrsrc-subbuild/antlrsrc-populate-prefix/src/antlrsrc-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
