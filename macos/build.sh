#!/bin/bash
#
# Build script for TimeWarrior MenuBar app
#
# Usage:
#   ./build.sh                           - Build for current architecture
#   ./build.sh --universal               - Build universal binary (x86_64 + arm64)
#   ./build.sh --arch arm64              - Build for specific architecture
#   ./build.sh --sign "Developer ID"     - Sign the application
#   ./build.sh --universal --sign "..."  - Build universal and sign
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
SIGN_IDENTITY=""

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
        --sign)
            SIGN_IDENTITY="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--universal] [--arch <architecture>] [--sign <identity>]"
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

elif [ -n "$TARGET_ARCH" ]; then
    echo "Building for architecture: $TARGET_ARCH..."

    # Both architectures target macOS 12.0 (Monterey)
    MIN_OS="12.0"

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

# Code signing
if [ -n "$SIGN_IDENTITY" ]; then
    echo ""
    echo "Signing application with identity: ${SIGN_IDENTITY}"

    # Sign the binary
    codesign --force --options runtime --sign "${SIGN_IDENTITY}" \
        --timestamp \
        "${MACOS_DIR}/${APP_NAME}"

    # Sign the app bundle
    codesign --force --options runtime --sign "${SIGN_IDENTITY}" \
        --timestamp \
        "${APP_DIR}"

    echo "  ✓ Application signed successfully"

    # Verify signature
    echo "  - Verifying signature..."
    codesign --verify --verbose "${APP_DIR}"
    echo "  ✓ Signature verified"
fi

# Show binary info
echo ""
echo "Binary information:"
file "${MACOS_DIR}/${APP_NAME}"

# Show code signature info
if [ -n "$SIGN_IDENTITY" ]; then
    echo ""
    echo "Code signature:"
    codesign -dvv "${APP_DIR}" 2>&1 | grep -E "(Authority|Identifier|TeamIdentifier)"
fi

echo ""
echo "Build complete!"
echo "Application bundle created at: ${APP_DIR}"
echo ""
echo "To install, copy to Applications folder:"
echo "  cp -r ${APP_DIR} /Applications/"
echo ""
echo "To run directly:"
echo "  open ${APP_DIR}"
