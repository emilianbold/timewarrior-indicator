#!/bin/bash
#
# Package release script for TimeWarrior MenuBar app
# Creates ZIP and DMG distribution files
#

set -e

APP_NAME="TimeWarriorMenuBar"
BUILD_DIR="build"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"
DIST_DIR="${BUILD_DIR}/dist"
VERSION=${1:-"dev"}

echo "Packaging TimeWarrior MenuBar v${VERSION}..."

# Check if app bundle exists
if [ ! -d "${APP_DIR}" ]; then
    echo "Error: App bundle not found at ${APP_DIR}"
    echo "Please run ./build.sh first"
    exit 1
fi

# Create distribution directory
mkdir -p "${DIST_DIR}"

# Create ZIP archive
echo "Creating ZIP archive..."
cd "${BUILD_DIR}"
zip -r "dist/${APP_NAME}-${VERSION}.zip" "${APP_NAME}.app"
cd ..

echo "  ✓ Created: ${DIST_DIR}/${APP_NAME}-${VERSION}.zip"

# Create DMG disk image
echo "Creating DMG disk image..."

# Create temporary directory for DMG contents
DMG_TEMP="${BUILD_DIR}/dmg-temp"
rm -rf "${DMG_TEMP}"
mkdir -p "${DMG_TEMP}"

# Copy app bundle to temp directory
cp -R "${APP_DIR}" "${DMG_TEMP}/"

# Create a symbolic link to Applications folder
ln -s /Applications "${DMG_TEMP}/Applications"

# Create DMG
hdiutil create -volname "TimeWarrior MenuBar ${VERSION}" \
    -srcfolder "${DMG_TEMP}" \
    -ov -format UDZO \
    "${DIST_DIR}/${APP_NAME}-${VERSION}.dmg"

# Clean up
rm -rf "${DMG_TEMP}"

echo "  ✓ Created: ${DIST_DIR}/${APP_NAME}-${VERSION}.dmg"

# Show file sizes
echo ""
echo "Distribution files:"
ls -lh "${DIST_DIR}"

echo ""
echo "✓ Packaging complete!"
echo ""
echo "Distribution files are in: ${DIST_DIR}"
