#!/bin/bash
#
# Build script for TimeWarrior MenuBar app
#
# Usage:
#   ./build.sh              - Build for current architecture
#   ./build.sh --universal  - Build universal binary (x86_64 + arm64)
#   ./build.sh --arch arm64 - Build for specific architecture
#

set -e

APP_NAME="TimeWarriorMenuBar"
BUILD_DIR="build"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

# Parse command line arguments
BUILD_UNIVERSAL=false
TARGET_ARCH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --universal)
            BUILD_UNIVERSAL=true
            shift
            ;;
        --arch)
            TARGET_ARCH="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--universal] [--arch <architecture>]"
            exit 1
            ;;
    esac
done

echo "Building TimeWarrior MenuBar for macOS..."

# Clean previous build
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Create app bundle structure
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

if [ "$BUILD_UNIVERSAL" = true ]; then
    echo "Building Universal Binary (x86_64 + arm64)..."

    # Build for Intel
    echo "  - Compiling for x86_64 (Intel)..."
    swiftc -O -target x86_64-apple-macosx10.13 \
        TimeWarriorMenuBar.swift \
        -o "${BUILD_DIR}/${APP_NAME}-x86_64"

    # Build for Apple Silicon
    echo "  - Compiling for arm64 (Apple Silicon)..."
    swiftc -O -target arm64-apple-macosx11.0 \
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

elif [ -n "$TARGET_ARCH" ]; then
    echo "Building for architecture: $TARGET_ARCH..."

    # Determine minimum macOS version based on architecture
    if [ "$TARGET_ARCH" = "arm64" ]; then
        MIN_OS="11.0"
    else
        MIN_OS="10.13"
    fi

    swiftc -O -target "${TARGET_ARCH}-apple-macosx${MIN_OS}" \
        TimeWarriorMenuBar.swift \
        -o "${MACOS_DIR}/${APP_NAME}"
else
    echo "Building for current architecture..."
    swiftc -O TimeWarriorMenuBar.swift -o "${MACOS_DIR}/${APP_NAME}"
fi

# Copy Info.plist
cp Info.plist "${CONTENTS_DIR}/"

# Make executable
chmod +x "${MACOS_DIR}/${APP_NAME}"

# Show binary info
echo ""
echo "Binary information:"
file "${MACOS_DIR}/${APP_NAME}"

echo ""
echo "Build complete!"
echo "Application bundle created at: ${APP_DIR}"
echo ""
echo "To install, copy to Applications folder:"
echo "  cp -r ${APP_DIR} /Applications/"
echo ""
echo "To run directly:"
echo "  open ${APP_DIR}"
