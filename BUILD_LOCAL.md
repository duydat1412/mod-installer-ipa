# Build & Test Locally

## Prerequisites (macOS required for iOS build)

```bash
# Install dependencies
brew install xcodegen ldid

# For testing GitHub Actions locally (optional)
brew install act
```

## Method 1: Quick Local Build

**Run the build script:**

```bash
chmod +x build_local.sh
./build_local.sh
```

**Output:** `build/Build/Products/Release-iphoneos/ModInstaller.ipa`

**Test:**
1. AirDrop IPA to iPhone
2. Open in TrollStore
3. Check entitlements before installing

---

## Method 2: Test GitHub Actions Locally

**Using `act`:**

```bash
# Install act
brew install act

# Run workflow locally (requires Docker)
act -j build --secret-file .secrets

# Or specific event
act push -j build
```

**Note:** May not work perfectly due to macOS-specific commands.

---

## Method 3: Xcode Build (No ldid signing)

**Steps:**

1. Open project:
   ```bash
   xcodegen generate
   open ModInstaller.xcodeproj
   ```

2. Select target device: **Any iOS Device**

3. Product → Archive

4. Export → **Development** → Save IPA

**⚠️ Limitation:** Xcode won't sign with private entitlements. Still need ldid!

---

## Verify Entitlements

**Check if entitlements are embedded:**

```bash
# Extract entitlements from IPA
unzip -q ModInstaller.ipa
ldid -e Payload/ModInstaller.app/ModInstaller

# Should show XML with all entitlements
```

**Expected output:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist...>
<dict>
    <key>platform-application</key>
    <true/>
    <key>com.apple.private.security.no-container</key>
    <true/>
    ...
</dict>
```

---

## Quick Test Checklist

Before pushing to GitHub:

- [ ] `xcodegen generate` works
- [ ] Build completes without errors
- [ ] `ldid -e` shows entitlements
- [ ] IPA installs via TrollStore
- [ ] App shows correct permissions in TrollStore
- [ ] App can access `/var/mobile/Containers`

---

## Debugging

**If build fails:**

```bash
# Check logs
cat build/Build/Logs/Build/*.xcactivitylog

# Clean build
rm -rf build/
xcodebuild clean

# Rebuild
./build_local.sh
```

**If entitlements missing:**

```bash
# Manual ldid sign
ldid -SModInstaller/ModInstaller.entitlements \
     build/.../ModInstaller.app/ModInstaller

# Verify again
ldid -e build/.../ModInstaller.app/ModInstaller
```

---

## Windows Alternative

**Can't build on Windows!** iOS builds require macOS.

**Options:**

1. Use macOS VM (VMware/VirtualBox)
2. Rent macOS cloud (MacStadium, AWS Mac)
3. Just use GitHub Actions (free!)

**GitHub Actions is actually the easiest** - no local setup needed.
