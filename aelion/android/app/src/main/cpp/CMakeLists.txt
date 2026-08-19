cmake_minimum_required(VERSION 3.22.1)
project(aelion_android C)

set(AELION_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/../../../../../)

add_library(aelion_android SHARED
    aelion_android_bridge.c
    ${AELION_ROOT}/src/core/usp/usp.c
    ${AELION_ROOT}/src/core/bus/bus.c
    ${AELION_ROOT}/src/core/registry/registry.c
)

target_include_directories(aelion_android PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${AELION_ROOT}/src/core/usp
    ${AELION_ROOT}/src/core/bus
    ${AELION_ROOT}/src/core/registry
)

find_library(log-lib log)

target_link_libraries(aelion_android
    ${log-lib}
)
