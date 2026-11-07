# Define an option for enabling AddressSanitizer, defaulted to OFF.
option(ENABLE_ASAN "Enable AddressSanitizer" OFF)

if(ENABLE_ASAN)
    if(MSVC)
        message(STATUS "AddressSanitizer (ASan) is enabled for this build (MSVC).")

        add_compile_options(/fsanitize=address)

        # Remove the /RTC1 flag to prevent conflicts.
        string(REPLACE "/RTC1" "" CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}")
        string(REPLACE "/RTC1" "" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")

    # Check for GCC or Clang compilers, which use the same flags for ASan
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        message(STATUS "AddressSanitizer (ASan) is enabled for this build (GCC/Clang).")

        add_compile_options(-fsanitize=address -fno-omit-frame-pointer)
        add_link_options(-fsanitize=address)
    else()
        message(WARNING "ENABLE_ASAN is ON, but the current compiler (${CMAKE_CXX_COMPILER_ID}) is not supported by this script.")
    endif()
endif()
