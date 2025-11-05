#!/bin/bash
#
# Build script for TimeWarrior MenuBar app
#

set -e

APP_NAME="TimeWarriorMenuBar"
BUILD_DIR="build"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "Building TimeWarrior MenuBar for macOS..."

# Clean previous build
rm -rf "${BUILD_DIR}"

# Create app bundle structure
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Compile Swift code
echo "Compiling Swift code..."
swiftc -O TimeWarriorMenuBar.swift -o "${MACOS_DIR}/${APP_NAME}"

# Copy Info.plist
cp Info.plist "${CONTENTS_DIR}/"

# Make executable
chmod +x "${MACOS_DIR}/${APP_NAME}"

echo "Build complete!"
echo "Application bundle created at: ${APP_DIR}"
echo ""
echo "To install, copy to Applications folder:"
echo "  cp -r ${APP_DIR} /Applications/"
echo ""
echo "To run directly:"
echo "  open ${APP_DIR}"
