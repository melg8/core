
# Generic boolean options
option(BUILD_FOR_HOST_CPU             "Build specifically for the host CPU via `-march=native` (might not run on different machines)" ON)
option(BUILD_WARNINGS_AS_ERROR        "Treat compiler warnings as errors (/WX on MSVC, -Werror on GCC/Clang)"                         OFF)
option(USE_SCRIPTS                    "Build scripts"                                                                                 ON)
option(BUILD_EXTRACTORS               "Build extractors"                                                                              OFF)
option(BUILD_REALMMERGE               "Build helper tool for merging character databases"                                             OFF)
option(ENABLE_MAILSENDER              "Enables support for sending emails via sendgrid.com (requires libcurl)"                        OFF)
option(ENABLE_CPPTRACE                "Enables cpptrace stack tracing; can be disabled if using other tools like GDB"                 ON)

if(USE_EXTRACTORS)
  message(WARNING "USE_EXTRACTORS is deprecated, please use BUILD_EXTRACTORS instead")
  set(BUILD_EXTRACTORS ON CACHE BOOL "Build extractors" FORCE)
endif()

if(USE_REALMMERGE)
  message(WARNING "USE_REALMMERGE is deprecated, please use BUILD_REALMMERGE instead")
  set(BUILD_REALMMERGE ON CACHE BOOL "Build helper tool for merging character databases" FORCE)
endif()

option(USE_PCH "Use precompiled headers" ON)

if(ENABLE_ASAN)
  # Prevent usage of tbb malloc which interfieres with sanitizer.
  set(USE_STD_MALLOC ON CACHE BOOL "Forced ON because ENABLE_ASAN is ON and doesnt work with TBB allocators" FORCE)
endif()

# Other options
set(SUPPORTED_CLIENT_BUILD "CLIENT_BUILD_1_12_1" CACHE STRING "Client version the core will support")

if(UNIX)
  option(DEBUG_SYMBOLS "Include Debug Symbols" ON)
endif()

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "" FORCE)
endif()

message("")
message(STATUS
  "This script builds the vMaNGOS server.
  Options that can be used in order to configure the process:
    PREFIX                    Path where the server should be installed to
    CMAKE_INSTALL_PREFIX      Path where the server should be installed to
    USE_PCH                   Use precompiled headers
    USE_STD_MALLOC            Use standard malloc instead of TBB
    BUILD_FOR_HOST_CPU        Build specifically for the host CPU via `-march=native` (might not run on different machines)
    BUILD_WARNINGS_AS_ERROR   Treat compiler warnings as errors (/WX on MSVC, -Werror on GCC/Clang)
    USE_SCRIPTS               Build scripts
    BUILD_EXTRACTORS          Build extractors
    BUILD_REALMMERGE          Build helper tool for merging character databases
    ENABLE_MAILSENDER         Enables support for sending emails via sendgrid.com (requires libcurl)
    SUPPORTED_CLIENT_BUILD    Client version the core will support
    ENABLE_CPPTRACE           Enables cpptrace stack tracing; can be disabled if using other tools like GDB


  To set an option simply type -D<OPTION>=<VALUE> after 'cmake <srcs>'.
  Also, you can specify the generator with -G. see 'cmake --help' for more details
  For example:
    Build server with default settings:
    $ mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=../opt/vmangos ..
")
