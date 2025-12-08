cmake_minimum_required(VERSION 3.10)
project(bbcp VERSION 1.0.0 LANGUAGES C CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Set C standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Options
option(BUILD_SHARED_LIBS "Build shared libraries" OFF)
option(ENABLE_TESTS "Enable test building" OFF)

# Find required packages
find_package(Threads REQUIRED)
find_package(ZLIB REQUIRED)
find_package(OpenSSL REQUIRED)

# Platform detection
if(UNIX AND NOT APPLE)
    set(LINUX TRUE)
endif()

# Compiler definitions
add_compile_definitions(
    -Dunix
    -D_BSD
    -D_ALL_SOURCE
    -D_LARGEFILE_SOURCE
    -D_FILE_OFFSET_BITS=64
    -D_REENTRANT
    -DOO_STD
    -DNL_THREADSAFE
)

# Platform-specific definitions
if(LINUX)
    add_compile_definitions(-DLINUX -D_GNU_SOURCE)
elseif(APPLE)
    add_compile_definitions(-DMACOS)
    set(CMAKE_MACOSX_RPATH ON)
elseif(CMAKE_SYSTEM_NAME MATCHES "FreeBSD")
    add_compile_definitions(-DFREEBSD)
elseif(CMAKE_SYSTEM_NAME MATCHES "SunOS")
    add_compile_definitions(-DSUN)
elseif(CMAKE_SYSTEM_NAME MATCHES "AIX")
    add_compile_definitions(-DAIX)
endif()

# Compiler flags
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(
        -Wall
        -Wno-deprecated
        -g
    )

    # Optimization for release builds
    if(CMAKE_BUILD_TYPE MATCHES "Release")
        add_compile_options(-O3)
    endif()
endif()

# Include directories
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${OPENSSL_INCLUDE_DIR}
    ${ZLIB_INCLUDE_DIRS}
)

# Source files
set(BBCP_SOURCES
    src/bbcp.C
    src/bbcp_Args.C
    src/bbcp_BuffPool.C
    src/bbcp_C32.C
    src/bbcp_ChkSum.C
    src/bbcp_Config.C
    src/bbcp_Emsg.C
    src/bbcp_File.C
    src/bbcp_FileSpec.C
    src/bbcp_FileSystem.C
    src/bbcp_FS_Null.C
    src/bbcp_FS_Pipe.C
    src/bbcp_FS_Unix.C
    src/bbcp_IO.C
    src/bbcp_IO_Null.C
    src/bbcp_IO_Pipe.C
    src/bbcp_Link.C
    src/bbcp_LogFile.C
    src/bbcp_MD5.C
    src/bbcp_MD5_openssl.C
    src/bbcp_NetAddr.C
    src/bbcp_NetAddrInfo.C
    src/bbcp_NetLogger.C
    src/bbcp_Network.C
    src/bbcp_Node.C
    src/bbcp_ProcMon.C
    src/bbcp_ProgMon.C
    src/bbcp_Protocol.C
    src/bbcp_Pthread.C
    src/bbcp_RTCopy.C
    src/bbcp_Stream.C
    src/bbcp_System.C
    src/bbcp_Timer.C
    src/bbcp_Version.C
    src/bbcp_ZCX.C
    src/NetLogger.c
)

# Create executable
add_executable(bbcp ${BBCP_SOURCES})

# Link libraries
target_link_libraries(bbcp
    ${CMAKE_THREAD_LIBS_INIT}
    ZLIB::ZLIB
    OpenSSL::Crypto
)

# Platform-specific linking
if(LINUX)
    target_link_libraries(bbcp rt dl)
elseif(APPLE)
    # macOS might need additional frameworks in the future
    # target_link_libraries(bbcp "-framework CoreFoundation")
endif()

# Installation
install(TARGETS bbcp
    RUNTIME DESTINATION bin
    COMPONENT runtime
)

# Install documentation
install(FILES README.md LICENSE
    DESTINATION share/doc/bbcp
    COMPONENT documentation
)

# Print configuration summary
message(STATUS "")
message(STATUS "Configuration Summary")
message(STATUS "=====================")
message(STATUS "  Project:          ${PROJECT_NAME}")
message(STATUS "  Version:          ${PROJECT_VERSION}")
message(STATUS "  Build type:       ${CMAKE_BUILD_TYPE}")
message(STATUS "  System:           ${CMAKE_SYSTEM_NAME}")
message(STATUS "  C++ Compiler:     ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "  C Compiler:       ${CMAKE_C_COMPILER_ID} ${CMAKE_C_COMPILER_VERSION}")
message(STATUS "  Install prefix:   ${CMAKE_INSTALL_PREFIX}")
message(STATUS "  OpenSSL:          ${OPENSSL_VERSION}")
message(STATUS "  ZLIB:             ${ZLIB_VERSION_STRING}")
message(STATUS "")
