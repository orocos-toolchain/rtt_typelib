cmake_minimum_required(VERSION 2.6)
project(rtt_typelib)
include(FindPkgConfig)

#
# Do setup in case of ros package, If ROS_ROOT is set, it is
# recommended to use RTT/OCL through the ros packages.
#
set (ROS_ROOT $ENV{ROS_ROOT} )
if (ROS_ROOT)
  include($ENV{ROS_ROOT}/core/rosbuild/rosbuild.cmake)
  rosbuild_init()
  rosbuild_find_ros_package( rtt )
  set( RTT_HINTS HINTS ${rtt_PACKAGE_PATH}/install )
endif()
# Set the CMAKE_PREFIX_PATH in case you're not using Orocos through ROS
# for helping these find commands find RTT.
find_package(Orocos-RTT REQUIRED ${RTT_HINTS})
include( ${OROCOS-RTT_USE_FILE} )

if (NOT OROCOS-RTT_FOUND)
  message(FATAL_ERROR "Could not Find Orocos-RTT.")
endif()

if (OROCOS-RTT_MQUEUE_FOUND)
    message(STATUS "MQ transport found, MQ typelib marshaller enabled")
    set(mqsupport_sources MQTypelibMarshaller.cpp)
else()
    message(STATUS "MQ transport not found, MQ typelib marshaller disabled")
endif()

# Typelib specific:
pkg_check_modules(Typelib REQUIRED typelib)
include_directories(${Typelib_INCLUDE_DIRS})
link_directories(${Typelib_LIBRARY_DIRS})
add_definitions(${Typelib_CFLAGS})

# This takes care of proper install locations:
# We do our linking ourselves...
set(OROCOS_NO_AUTO_LINKING TRUE)
orocos_library(rtt-typelib SHARED
    TypelibMarshallerBase.cpp ${mqsupport_sources})

target_link_libraries(rtt-typelib
    ${Typelib_LIBRARIES})
if (OROCOS-RTT_MQUEUE_FOUND)
    target_link_libraries(rtt-typelib
        ${OROCOS-RTT_MQUEUE_LIBRARIES})
endif()

orocos_install_headers( TypelibMarshallerBase.hpp TypelibMarshaller.hpp
    TypelibMarshallerHandle.hpp
    MQTypelibMarshaller.hpp OpaqueTypelibMarshaller.hpp
    INSTALL include/rtt/typelib)

# custom written .pc file, so don't use orocos_generated_package():
#configure_file(${CMAKE_CURRENT_SOURCE_DIR}/rtt-typelib.pc.in
#    ${CMAKE_CURRENT_BINARY_DIR}/rtt-typelib.pc @ONLY)
#install(FILES ${CMAKE_CURRENT_BINARY_DIR}/rtt-typelib.pc
#    DESTINATION lib/pkgconfig)

orocos_generate_package()
