# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.16

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /workspace/cybercache-cluster

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /workspace/cybercache-cluster

# Include any dependencies generated for this target.
include src/utils/epoll/CMakeFiles/epoll.dir/depend.make

# Include the progress variables for this target.
include src/utils/epoll/CMakeFiles/epoll.dir/progress.make

# Include the compile flags for this target's objects.
include src/utils/epoll/CMakeFiles/epoll.dir/flags.make

src/utils/epoll/CMakeFiles/epoll.dir/main.cc.o: src/utils/epoll/CMakeFiles/epoll.dir/flags.make
src/utils/epoll/CMakeFiles/epoll.dir/main.cc.o: src/utils/epoll/main.cc
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/workspace/cybercache-cluster/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object src/utils/epoll/CMakeFiles/epoll.dir/main.cc.o"
	cd /workspace/cybercache-cluster/src/utils/epoll && /usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/epoll.dir/main.cc.o -c /workspace/cybercache-cluster/src/utils/epoll/main.cc

src/utils/epoll/CMakeFiles/epoll.dir/main.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/epoll.dir/main.cc.i"
	cd /workspace/cybercache-cluster/src/utils/epoll && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /workspace/cybercache-cluster/src/utils/epoll/main.cc > CMakeFiles/epoll.dir/main.cc.i

src/utils/epoll/CMakeFiles/epoll.dir/main.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/epoll.dir/main.cc.s"
	cd /workspace/cybercache-cluster/src/utils/epoll && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /workspace/cybercache-cluster/src/utils/epoll/main.cc -o CMakeFiles/epoll.dir/main.cc.s

# Object files for target epoll
epoll_OBJECTS = \
"CMakeFiles/epoll.dir/main.cc.o"

# External object files for target epoll
epoll_EXTERNAL_OBJECTS =

bin/epoll: src/utils/epoll/CMakeFiles/epoll.dir/main.cc.o
bin/epoll: src/utils/epoll/CMakeFiles/epoll.dir/build.make
bin/epoll: lib/libc3lib_ce.a
bin/epoll: src/utils/epoll/CMakeFiles/epoll.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/workspace/cybercache-cluster/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable ../../../bin/epoll"
	cd /workspace/cybercache-cluster/src/utils/epoll && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/epoll.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
src/utils/epoll/CMakeFiles/epoll.dir/build: bin/epoll

.PHONY : src/utils/epoll/CMakeFiles/epoll.dir/build

src/utils/epoll/CMakeFiles/epoll.dir/clean:
	cd /workspace/cybercache-cluster/src/utils/epoll && $(CMAKE_COMMAND) -P CMakeFiles/epoll.dir/cmake_clean.cmake
.PHONY : src/utils/epoll/CMakeFiles/epoll.dir/clean

src/utils/epoll/CMakeFiles/epoll.dir/depend:
	cd /workspace/cybercache-cluster && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /workspace/cybercache-cluster /workspace/cybercache-cluster/src/utils/epoll /workspace/cybercache-cluster /workspace/cybercache-cluster/src/utils/epoll /workspace/cybercache-cluster/src/utils/epoll/CMakeFiles/epoll.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : src/utils/epoll/CMakeFiles/epoll.dir/depend

