#!/usr/bin/env bash
# =============================================================================
# iOS Build Script for LX Music (Unsigned / Fake-Signed IPA)
# =============================================================================
# This script builds the iOS app WITHOUT a real Apple certificate.
# The resulting IPA can ONLY be installed on JAILBROKEN devices.
#
# Prerequisites:
#   - macOS with Xcode 15+ installed
#   - Node.js 18+ and npm
#   - CocoaPods (gem install cocoapods)
#   - ldid (brew install ldid)
#
# Usage:
#   chmod +x build-ios.sh
#   ./build-ios.sh
#
# Output: ios/build/LxMusic-unsigned.ipa
# =============================================================================

set -euo pipefail

echo "=== LX Music iOS Build Script ==="
echo ""

# 1. Install npm dependencies
echo "[1/6] Installing npm dependencies..."
npm install --ignore-scripts

# 2. Install Pods
echo "[2/6] Installing CocoaPods..."
cd ios
pod install --repo-update
cd ..

# 3. Generate JS Bundle
echo "[3/6] Generating JS bundle..."
mkdir -p ios/build
npx react-native bundle \
  --platform ios \
  --dev false \
  --entry-file index.js \
  --bundle-output ios/build/main.jsbundle \
  --assets-dest ios/build/assets

# 4. Build .app (unsigned)
echo "[4/6] Building unsigned .app..."
cd ios
xcodebuild \
  -workspace LxMusic.xcworkspace \
  -scheme LxMusic \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath ./build/derived \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_IDENTITY="" \
  PROVISIONING_PROFILE_SPECIFIER="" \
  clean build \
  BUILD_DIR=./build/Build

# Locate the .app
APP_PATH=$(find ./build -name "LxMusic.app" -type d -path "*/Release-iphoneos/*" | head -1)
if [ -z "$APP_PATH" ]; then
  echo "ERROR: Could not find built .app in build directory"
  exit 1
fi
echo "Found .app at: $APP_PATH"
cd ..

# 5. Fake-sign with ldid
echo "[5/6] Fake-signing with ldid..."

# Remove any existing _CodeSignature directory
rm -rf "$APP_PATH/_CodeSignature" 2>/dev/null || true

# Fake-sign the mach-o binary
ldid -Sios/entitlements.plist "$APP_PATH/LxMusic"

echo "Fake-sign complete."

# Verify
echo "Signature info:"
codesign -dvvv "$APP_PATH" 2>&1 || echo "(Expected: unsigned binary with ldid hash)"

# 6. Package as IPA
echo "[6/6] Packaging IPA..."
mkdir -p ios/build/Payload
cp -R "$APP_PATH" ios/build/Payload/
cd ios/build
zip -r LxMusic-unsigned.ipa Payload/ -x "*.DS_Store"
cd ../..

echo ""
echo "=== Build complete! ==="
echo "IPA: ios/build/LxMusic-unsigned.ipa"
ls -lh ios/build/LxMusic-unsigned.ipa
echo ""
echo "Install on jailbroken device via Filza + AppSync or TrollStore."
