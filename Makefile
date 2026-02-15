# Makefile for OpenCog Lua System Package (ocsys)

# Detect Lua version and paths
LUA_VERSION ?= 5.4
LUA_INCDIR ?= /usr/include/lua$(LUA_VERSION)
LUA ?= lua$(LUA_VERSION)

# Compiler settings
CC = gcc
CFLAGS = -Wall -Wextra -fPIC -I$(LUA_INCDIR)
LDFLAGS = -shared -llua$(LUA_VERSION)

# Target library
TARGET = libsys.so

# Source files
SRC = sys.c

# Default target
all: $(TARGET)

# Build the shared library
$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(TARGET) $(LDFLAGS)
	@echo "Built $(TARGET) successfully"

# Run tests
test: $(TARGET)
	@echo "Running tests..."
	$(LUA) test_opencog_functions.lua

# Clean build artifacts
clean:
	rm -f $(TARGET) *.o *.tmp.*
	@echo "Cleaned build artifacts"

# Install (placeholder for future implementation)
install: $(TARGET)
	@echo "Installation not yet implemented"
	@echo "To use: require 'init' from this directory"

# Help target
help:
	@echo "OpenCog Lua System Package - Build System"
	@echo ""
	@echo "Targets:"
	@echo "  all       - Build the shared library (default)"
	@echo "  test      - Build and run tests"
	@echo "  clean     - Remove build artifacts"
	@echo "  install   - Install the package (not yet implemented)"
	@echo "  help      - Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  LUA_VERSION - Lua version to use (default: 5.4)"
	@echo "  LUA_INCDIR  - Lua include directory"
	@echo "  LUA         - Lua interpreter to use"

.PHONY: all test clean install help
