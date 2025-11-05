#!/bin/bash
#
# Code signing script for TimeWarrior MenuBar app
#
# Usage:
#   ./sign.sh "Developer ID Application: Your Name (TEAM_ID)"
#   ./sign.sh "Developer ID Application: Your Name (TEAM_ID)" path/to/TimeWarriorMenuBar.app
#

set -e

SIGN_IDENTITY="$1"
APP_PATH="${2:-build/TimeWarriorMenuBar.app}"

if [ -z "$SIGN_IDENTITY" ]; then
    echo "Error: No signing identity provided"
    echo "Usage: $0 <signing-identity> [app-path]"
    echo ""
    echo "Example:"
    echo "  $0 \"Developer ID Application: Your Name (TEAM_ID)\""
    echo ""
    echo "To find your signing identity:"
    echo "  security find-identity -v -p codesigning"
    exit 1
fi

if [ ! -d "$APP_PATH" ]; then
    echo "Error: App bundle not found at $APP_PATH"
    exit 1
fi

echo "Signing application with identity: ${SIGN_IDENTITY}"
echo "App path: ${APP_PATH}"

# Sign the binary
codesign --force --options runtime --sign "${SIGN_IDENTITY}" \
    --timestamp \
    "${APP_PATH}/Contents/MacOS/TimeWarriorMenuBar"

# Sign the app bundle
codesign --force --options runtime --sign "${SIGN_IDENTITY}" \
    --timestamp \
    "${APP_PATH}"

echo "✓ Application signed successfully"

# Verify signature
echo ""
echo "Verifying signature..."
codesign --verify --verbose "${APP_PATH}"
echo "✓ Signature verified"

# Show code signature info
echo ""
echo "Code signature:"
codesign -dvv "${APP_PATH}" 2>&1 | grep -E "(Authority|Identifier|TeamIdentifier)"
