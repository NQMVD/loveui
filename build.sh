#!/bin/bash

# Cross-platform build script for the egui-Love2D bridge
set -e

echo "Cross-platform egui-Love2D bridge build script"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect the operating system
SYSTEM=$(uname -s)
echo "Detected system: $SYSTEM"

case "$SYSTEM" in
    Linux*)
        echo -e "${GREEN}Running Linux build script...${NC}"
        if [ -f "build-linux.sh" ]; then
            chmod +x build-linux.sh
            ./build-linux.sh
        else
            echo -e "${RED}Error: build-linux.sh not found${NC}"
            exit 1
        fi
        ;;
    Darwin*)
        echo -e "${GREEN}Running macOS build script...${NC}"
        if [ -f "build-macos.sh" ]; then
            chmod +x build-macos.sh
            ./build-macos.sh
        else
            echo -e "${RED}Error: build-macos.sh not found${NC}"
            exit 1
        fi
        ;;
    CYGWIN*|MINGW*|MSYS*)
        echo -e "${GREEN}Running Windows build script...${NC}"
        if [ -f "build-windows.ps1" ]; then
            if command -v powershell &> /dev/null; then
                powershell -ExecutionPolicy Bypass -File build-windows.ps1
            else
                echo -e "${RED}Error: PowerShell not found. Please run build-windows.ps1 manually.${NC}"
                exit 1
            fi
        else
            echo -e "${RED}Error: build-windows.ps1 not found${NC}"
            exit 1
        fi
        ;;
    *)
        echo -e "${YELLOW}Unknown system: $SYSTEM${NC}"
        echo -e "${YELLOW}Attempting to build with generic Linux script...${NC}"
        if [ -f "build-linux.sh" ]; then
            chmod +x build-linux.sh
            ./build-linux.sh
        else
            echo -e "${RED}Error: No suitable build script found${NC}"
            exit 1
        fi
        ;;
esac

echo -e "${GREEN}Cross-platform build completed!${NC}"