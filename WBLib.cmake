#
# Defines WB_TARGET_LINK_LIBRARIES
# which can then be used to integrate wifibroadcast into your project

cmake_minimum_required(VERSION 3.16.3)
set(CMAKE_CXX_STANDARD 17)

#if(WIFIBROADCAST_LIBRARIES_ALREADY_BUILD)
#if(get_property(source_list GLOBAL PROPERTY source_list_property))
#    message(STATUS "WIFIBROADCAST_LIBRARIES_ALREADY_BUILD")
#    return()
#endif()
if (TARGET wifibroadcast)
    message(STATUS "WIFIBROADCAST_LIBRARIES_ALREADY_BUILD")
    return()
endif()

find_library(WIFIBROADCAST_LIB wifibroadcast)
if(WIFIBROADCAST_LIB)
    message(STATUS "wifibroadcast already here")
    return()
endif()

# Build and include wifibroadcast
# ----------------------------------
#add_library( radiotap
#        SHARED
#        ${CMAKE_CURRENT_LIST_DIR}/src/external/radiotap/radiotap.c
#        )

#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=native")
#add_library( fec
#        SHARED
#        ${CMAKE_CURRENT_LIST_DIR}/src/external/fec/fec.cpp
#        )

add_library( wifibroadcast
        SHARED
        # radiotap and fec
        ${CMAKE_CURRENT_LIST_DIR}/src/external/radiotap/radiotap.c
        ${CMAKE_CURRENT_LIST_DIR}/src/external/fec/fec.cpp
        # the couple of non-header-only files for wifibroadcast
        ${CMAKE_CURRENT_LIST_DIR}/src/WBReceiver.cpp
        ${CMAKE_CURRENT_LIST_DIR}/src/WBTransmitter.cpp
        )
## FEC Optimizations begin ---------------------------------
set(WIFIBROADCAST_FEC_OPTIMIZATION_FLAGS_X86 -mavx2 -faligned-new=256)
set(WIFIBROADCAST_FEC_OPTIMIZATION_FLAGS_ARM -mfpu=neon -march=armv7-a -marm)
include(CheckCXXCompilerFlag)
check_cxx_compiler_flag("-mavx2" COMPILER_SUPPORTS_MAVX2)
if(COMPILER_SUPPORTS_MAVX2)
    target_compile_options(wifibroadcast PRIVATE ${WIFIBROADCAST_FEC_OPTIMIZATION_FLAGS_X86})
endif()
check_cxx_compiler_flag("-mfpu=neon" COMPILER_SUPPORTS_NEON)
if(COMPILER_SUPPORTS_NEON)
    target_compile_options(wifibroadcast PRIVATE ${WIFIBROADCAST_FEC_OPTIMIZATION_FLAGS_ARM})
endif()
## FEC Optimizations end ---------------------------------

include(${CMAKE_CURRENT_LIST_DIR}/cmake/FindPCAP.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/FindSodium.cmake)

target_include_directories(wifibroadcast PUBLIC ${sodium_INCLUDE_DIR})
target_include_directories(wifibroadcast PUBLIC ${PCAP_INCLUDE_DIR})
#include_directories(${sodium_INCLUDE_DIR})
#include_directories(${PCAP_INCLUDE_DIR})

target_link_libraries(wifibroadcast PUBLIC ${PCAP_LIBRARY})
target_link_libraries(wifibroadcast PUBLIC ${sodium_LIBRARY_RELEASE})

#SET(WB_TARGET_LINK_LIBRARIES wifibroadcast radiotap fec ${PCAP_LIBRARY} ${sodium_LIBRARY_RELEASE})
SET(WB_TARGET_LINK_LIBRARIES wifibroadcast)
SET(WB_INCLUDE_DIRECTORES ${CMAKE_CURRENT_LIST_DIR}/src)

include_directories(${CMAKE_CURRENT_LIST_DIR}/src/HelperSources)

#SET(WIFIBROADCAST_LIBRARIES_ALREADY_BUILD)
#set_property(GLOBAL PROPERTY WIFIBROADCAST_LIBRARIES_ALREADY_BUILD)

#set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}  -mavx2 -faligned-new=256")
# ----------------------------------