#!/bin/bash
# Local build script - giống GitHub Actions

echo "🔨 Building ModInstaller locally..."

# 1. Generate Xcode project
echo "📋 Generating Xcode project..."
xcodegen generate

# 2. Build
echo "🏗️ Building app..."
xcodebuild -project ModInstaller.xcodeproj \
  -scheme ModInstaller \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath build \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO

# 3. Sign with ldid
echo "🔐 Signing with entitlements..."
ldid -SModInstaller/ModInstaller.entitlements build/Build/Products/Release-iphoneos/ModInstaller.app/ModInstaller

# 4. Verify
echo "✅ Verifying signature..."
ldid -e build/Build/Products/Release-iphoneos/ModInstaller.app/ModInstaller

# 5. Create IPA
echo "📦 Creating IPA..."
cd build/Build/Products/Release-iphoneos
mkdir -p Payload
cp -r ModInstaller.app Payload/
zip -r ModInstaller.ipa Payload
cd ../../../../

echo ""
echo "✅ Build complete!"
echo "📍 IPA location: build/Build/Products/Release-iphoneos/ModInstaller.ipa"
echo ""
echo "Next steps:"
echo "1. Copy IPA to iPhone (AirDrop/Files)"
echo "2. Open in TrollStore → Install"
echo "3. Test app"
