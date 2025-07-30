#!/bin/bash

# Build script for the egui-Love2D bridge on macOS
set -e

echo "Building egui-Love2D bridge for macOS..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v cargo &> /dev/null; then
    echo -e "${RED}Error: Rust/Cargo not found. Please install Rust from https://rustup.rs/${NC}"
    exit 1
fi

if ! command -v pkg-config &> /dev/null; then
    echo -e "${YELLOW}Warning: pkg-config not found. Installing via Homebrew...${NC}"
    if command -v brew &> /dev/null; then
        brew install pkg-config
    else
        echo -e "${RED}Error: Homebrew not found. Please install pkg-config manually or install Homebrew.${NC}"
        exit 1
    fi
fi

# Check for Lua development libraries
if ! pkg-config --exists lua5.4; then
    echo -e "${YELLOW}Warning: Lua 5.4 development libraries not found. Installing via Homebrew...${NC}"
    if command -v brew &> /dev/null; then
        brew install lua
    else
        echo -e "${RED}Error: Homebrew not found. Please install Lua manually or install Homebrew.${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}Prerequisites check complete.${NC}"

# Build the Rust library
echo "Building Rust library..."
cd egui-love2d

# Clean previous builds
cargo clean

# Build release version
echo "Building release version..."
cargo build --release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Rust library built successfully!${NC}"
else
    echo -e "${RED}Failed to build Rust library.${NC}"
    exit 1
fi

cd ..

# Copy library to example directory for easy testing
echo "Setting up example..."
LIB_FILE="libegui_love2d.dylib"

if [ -f "egui-love2d/target/release/$LIB_FILE" ]; then
    cp "egui-love2d/target/release/$LIB_FILE" example/
    echo -e "${GREEN}Library copied to example directory.${NC}"
else
    echo -e "${RED}Library file not found: egui-love2d/target/release/$LIB_FILE${NC}"
fi

# Create a symlink for the love2d-egui module in the example directory
if [ ! -L "example/love2d-egui" ]; then
    ln -s "../love2d-egui" "example/love2d-egui"
    echo -e "${GREEN}Created symlink for love2d-egui module in example directory.${NC}"
fi

echo -e "${GREEN}Build complete!${NC}"
echo ""
echo "To run the example:"
echo "  cd example"
if command -v love &> /dev/null; then
    echo "  love ."
else
    echo "  # Install Love2D first, then run: love ."
fi
echo ""
echo "Library files:"
echo "  Rust library: egui-love2d/target/release/$LIB_FILE"
echo "  Lua module: love2d-egui/egui.lua"
echo "  Example: example/main.lua"