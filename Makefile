#**************************************************************************************************
#
#   raylib makefile for Desktop platforms, Raspberry Pi, Android and HTML5
#
#**************************************************************************************************

.PHONY: all clean

# Define required raylib variables
PROJECT_NAME       ?= tetris
RAYLIB_VERSION     ?= 5.0
RAYLIB_PATH        ?= C:/Users/ciste/OneDrive/Escritorio/Code/Cpp/Libraries/raylib-5.0_win64_mingw-w64

# Define default options
PLATFORM           ?= PLATFORM_DESKTOP

# Locations of your newly installed library and associated headers
RAYLIB_INSTALL_PATH ?= $(RAYLIB_PATH)/lib
RAYLIB_H_INSTALL_PATH ?= $(RAYLIB_PATH)/include

# Define the path for msys64 mingw64
MSYS64_MINGW64_PATH ?= C:/msys64/mingw64

# Library type used for raylib: STATIC (.a) or SHARED (.so/.dll)
RAYLIB_LIBTYPE     ?= STATIC

# Build mode for project: DEBUG or RELEASE
BUILD_MODE         ?= RELEASE

# Use external GLFW library instead of rglfw module
USE_EXTERNAL_GLFW  ?= FALSE

# Use Wayland display server protocol on Linux desktop
USE_WAYLAND_DISPLAY ?= FALSE

# Determine PLATFORM_OS in case PLATFORM_DESKTOP selected
ifeq ($(PLATFORM),PLATFORM_DESKTOP)
    UNAMEOS := $(shell uname)
    ifeq ($(UNAMEOS),Linux)
        PLATFORM_OS = LINUX
    endif
    ifeq ($(UNAMEOS),Darwin)
        PLATFORM_OS = OSX
    endif
    ifeq ($(OS),Windows_NT)
        PLATFORM_OS = WINDOWS
    endif
endif
ifeq ($(PLATFORM),PLATFORM_RPI)
    UNAMEOS := $(shell uname)
    ifeq ($(UNAMEOS),Linux)
        PLATFORM_OS = LINUX
    endif
endif

# Define raylib release directory for compiled library
RAYLIB_RELEASE_PATH ?= $(RAYLIB_PATH)/lib

# EXAMPLE_RUNTIME_PATH embeds a custom runtime location of libraylib.so or other desired libraries
EXAMPLE_RUNTIME_PATH ?= $(RAYLIB_RELEASE_PATH)

# Define default C++ compiler: g++
CXX = $(MSYS64_MINGW64_PATH)/bin/g++

ifeq ($(PLATFORM),PLATFORM_DESKTOP)
    ifeq ($(PLATFORM_OS),OSX)
        CXX = clang++
    endif
    ifeq ($(PLATFORM_OS),BSD)
        CXX = clang++
    endif
endif
ifeq ($(PLATFORM),PLATFORM_WEB)
    CXX = em++
endif

# Define default make program
MAKE = mingw32-make

# Define compiler flags
CXXFLAGS += -Wall -std=c++14 -D_DEFAULT_SOURCE -Wno-missing-braces -mconsole

ifeq ($(BUILD_MODE),DEBUG)
    CXXFLAGS += -g -O0
else
    CXXFLAGS += -s -O1
endif

ifeq ($(PLATFORM_OS),LINUX)
    ifeq ($(RAYLIB_LIBTYPE),STATIC)
        CXXFLAGS += -D_DEFAULT_SOURCE
    endif
    ifeq ($(RAYLIB_LIBTYPE),SHARED)
        CXXFLAGS += -Wl,-rpath,$(EXAMPLE_RUNTIME_PATH)
    endif
endif

# Define include paths for required headers
INCLUDE_PATHS = -I. -I$(RAYLIB_H_INSTALL_PATH) -I$(RAYLIB_PATH)/src/external -I./src

# Define library paths containing required libs
LDFLAGS = -L.

LDFLAGS += -L$(RAYLIB_PATH)/lib
LDFLAGS += -L$(MSYS64_MINGW64_PATH)/lib

# Define any libraries required on linking
LDLIBS = -lraylib -lopengl32 -lgdi32 -lwinmm

# Define a recursive wildcard function
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

# Define all source files required
SRC_DIR = src
OBJ_DIR = obj

# Define all object files from source files
SRC = $(call rwildcard, $(SRC_DIR)/, *.cpp)
OBJS = $(patsubst $(SRC_DIR)/%.cpp, $(OBJ_DIR)/%.o, $(SRC))

# Default target entry
all: $(PROJECT_NAME)

# Project target defined by PROJECT_NAME
$(PROJECT_NAME): $(OBJS)
	$(CXX) -o $(PROJECT_NAME) $(OBJS) $(CXXFLAGS) $(INCLUDE_PATHS) $(LDFLAGS) $(LDLIBS) -D$(PLATFORM)

# Compile source files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	mkdir -p $(OBJ_DIR)
	$(CXX) -c $< -o $@ $(CXXFLAGS) $(INCLUDE_PATHS) -D$(PLATFORM)

# Clean everything
clean:
ifeq ($(PLATFORM_OS),WINDOWS)
	@rm -f $(OBJ_DIR)/*.o $(PROJECT_NAME)
endif
ifeq ($(PLATFORM_OS),LINUX)
	find . -type f -executable -delete
	rm -fv $(OBJ_DIR)/*.o
endif
ifeq ($(PLATFORM_OS),OSX)
	find . -type f -perm +ugo+x -delete
	rm -f $(OBJ_DIR)/*.o
endif
	@echo Cleaning done
