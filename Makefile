ifdef ROS_ROOT
default: install
include $(shell rospack find mk)/cmake.mk
export PKG_CONFIG_PATH:=$(shell rospack find rtt)/../install/lib/pkgconfig
EXTRA_CMAKE_FLAGS=-DCMAKE_INSTALL_PREFIX=`rospack find rtt`/../install\
                  -DLIBRARY_OUTPUT_PATH=`rospack find rtt_typelib`/lib

#ifdef ROS_STACK_DIR_FINAL
#EXTRA_CMAKE_FLAGS +=-DRTT_TYPELIB_PLUGIN_PATH="${ROS_STACK_DIR_FINAL}/orocos_toolchain_ros/rtt_typelib/install/lib/rtt_typelib"
#endif

install: all
	mkdir -p build && cd build && cmake .. && ${MAKE} install
else
$(warning This Makefile only works with ROS rosmake. Without rosmake, create a build directory and run cmake ..)
endif
