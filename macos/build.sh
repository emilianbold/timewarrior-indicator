#!/bin/bash
#
# Build script for TimeWarrior MenuBar app
# Builds a universal binary (x86_64 + arm64)
#

set -e

APP_NAME="TimeWarriorMenuBar"
BUILD_DIR="build"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "Building TimeWarrior MenuBar for macOS..."
echo "Creating universal binary (x86_64 + arm64)..."

# Clean previous build
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Create app bundle structure
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Build for Intel
echo "  - Compiling for x86_64 (Intel)..."
swiftc -O -target x86_64-apple-macosx12.0 \
    TimeWarriorMenuBar.swift \
    -o "${BUILD_DIR}/${APP_NAME}-x86_64"

# Build for Apple Silicon
echo "  - Compiling for arm64 (Apple Silicon)..."
swiftc -O -target arm64-apple-macosx12.0 \
    TimeWarriorMenuBar.swift \
    -o "${BUILD_DIR}/${APP_NAME}-arm64"

# Create universal binary
echo "  - Creating universal binary..."
lipo -create -output "${MACOS_DIR}/${APP_NAME}" \
    "${BUILD_DIR}/${APP_NAME}-x86_64" \
    "${BUILD_DIR}/${APP_NAME}-arm64"

# Verify
echo "  - Verifying universal binary..."
lipo -info "${MACOS_DIR}/${APP_NAME}"

# Clean up temporary files
rm "${BUILD_DIR}/${APP_NAME}-x86_64" "${BUILD_DIR}/${APP_NAME}-arm64"

# Copy Info.plist
cp Info.plist "${CONTENTS_DIR}/"

# Make executable
chmod +x "${MACOS_DIR}/${APP_NAME}"

# Show binary info
echo ""
echo "Binary information:"
file "${MACOS_DIR}/${APP_NAME}"

echo ""
echo "✓ Build complete: ${APP_DIR}"


