# 📱 Arena of Valor - Mod Installer

Automated iOS app for installing skin mods for Arena of Valor (Liên Quân Mobile).

**⚠️ Educational purposes only. Use at your own risk.**

---

## ✨ Features

- ✅ Automatic game directory detection
- ✅ Scan and import mod packs
- ✅ Backup original files before installation
- ✅ Auto file mapping (6 folders, 100+ files)
- ✅ Real-time progress tracking
- ✅ Easy backup restoration
- ✅ Modern SwiftUI interface
- ✅ Filza-like root access via entitlements

---

## 📋 Requirements

- **TrollStore** or Jailbroken iPhone (recommended)
- iOS 14.0+
- Arena of Valor installed from App Store (run at least once)
- Mod pack with structure:
  ```
  ModPack/
  └── 1.60.1/
      ├── AssetRefs/
      ├── Prefab_Characters/
      ├── assetbundle/
      ├── Databin/
      ├── Ages/
      └── Languages/
  ```

---

## 🚀 Installation

### Method 1: GitHub Actions (Recommended - No macOS needed!)

1. **Download IPA:**
   - Go to [Actions](../../actions)
   - Click latest workflow run
   - Scroll to "Artifacts"
   - Download `ModInstaller-IPA`
   - Extract ZIP

2. **Install via TrollStore:**
   ```
   1. Transfer IPA to iPhone (AirDrop/Files)
   2. Open TrollStore
   3. Tap "+" → Select IPA
   4. Install
   ```

3. **Install via Sideloadly (alternative):**
   ```
   1. Open Sideloadly on PC
   2. Drag IPA file
   3. Connect iPhone → Sign & install
   ```

### Method 2: Build from source (Requires macOS)

```bash
git clone https://github.com/duydat1412/mod-installer-ipa.git
cd mod-installer-ipa/ModInstaller
xcodegen generate
xcodebuild -project ModInstaller.xcodeproj -scheme ModInstaller
```

---

## 📖 Usage

### 1. Import Mod Pack

```
1. Transfer mod pack folder to iPhone via:
   - Filza File Manager
   - iMazing / iFunBox
   - iTunes File Sharing

2. Open ModInstaller app

3. Tap "Add Mod Pack"

4. Browse to mod folder
```

### 2. Install Mod

```
1. Tap "Create Backup" (one time only)
   → Backs up original files for restoration

2. Select mod pack from list

3. Tap "Install Mod"
   → App automatically copies 100+ files

4. Wait for progress bar to complete (~30 seconds)

5. Restart Arena of Valor
```

### 3. Restore Original Files

```
1. Tap "Restore Backup"

2. Restart game

→ Game returns to vanilla state
```

---

## 🛠️ Project Structure

```
ModInstaller/
├── ModInstallerApp.swift       # App entry point
├── Models/
│   └── ModPack.swift            # Data models
├── Services/
│   ├── GameFinder.swift         # Tìm game directory
│   └── ModInstallService.swift  # Core install logic
├── ViewModels/
│   └── ModInstallerViewModel.swift  # State management
├── Views/
│   └── ContentView.swift        # Main UI
└── Info.plist                   # App configuration
```

---

## 🎯 File Mappings

App tự động map files theo cấu trúc:

| Source Folder | Target Folder | Recursive |
|--------------|---------------|-----------|
| AssetRefs/Hero/ | AssetRefs/Hero/ | ❌ |
| Prefab_Characters/ | Prefab_Characters/ | ❌ |
| assetbundle/ | assetbundle/ | ❌ |
| Databin/Client/ | Databin/Client/ | ✅ |
| Ages/Prefab_Characters/Prefab_Hero/ | Ages/... | ❌ |
| Languages/VN_Garena_VN/ | Languages/... | ❌ |

**Base Path:** `/var/mobile/Containers/Data/Application/[UUID]/Documents/Resources/1.60.1/`

---

## 🔐 How It Works

### Entitlements (Filza-like access):

The app uses **private entitlements** to bypass iOS sandbox:

```xml
<key>platform-application</key>
<key>com.apple.private.security.no-container</key>
<key>com.apple.private.security.container-manager</key>
```

These entitlements allow:
- ✅ Root file system access
- ✅ Access to all app containers
- ✅ Read/write game files like Filza

**Note:** Requires TrollStore or jailbreak to activate entitlements.

---

## ⚠️ Important Notes

### Safety:
- ✅ **ALWAYS** create backup before installing mods
- ✅ Test on alt account first
- ✅ Don't share modded IPA publicly

### Troubleshooting:

**"Game not found"**
```
→ Run Arena of Valor at least once to download resources
→ Check in Filza: /var/mobile/Containers/Data/Application/
```

**"Invalid mod pack"**
```
→ Verify folder structure
→ Must contain 1.60.1 folder inside
```

**"File copy error"**
```
→ Check permissions in Filza
→ Restart app and try again
→ Reinstall via TrollStore if entitlements not working
```

**"No root access"**
```
→ App must be installed via TrollStore (not regular sideload)
→ Update TrollStore to latest version
→ Check iOS compatibility
```

---

## 🔧 Development

**Build from source:**
```bash
# Clone repo
git clone https://github.com/duydat1412/mod-installer-ipa.git
cd mod-installer-ipa/ModInstaller

# Install XcodeGen (if needed)
brew install xcodegen

# Generate Xcode project
xcodegen generate

# Build
xcodebuild -scheme ModInstaller -configuration Release
```

**Dependencies:**
- None! Pure SwiftUI + Foundation

---

## 📝 Changelog

### v1.0 (2025-12-16)
- ✅ Initial release
- ✅ Auto game finder with root access
- ✅ Mod pack scanner
- ✅ Backup/restore system
- ✅ Real-time progress tracking
- ✅ 6 folder mappings (167+ files)
- ✅ Filza-like entitlements

---

## ⚖️ Legal Disclaimer

**Educational purposes only.**

- ❌ Do NOT unlock premium skins you don't own
- ❌ Do NOT violate game ToS intentionally  
- ❌ Do NOT distribute modded content
- ✅ Only for custom textures YOU created
- ✅ Offline testing / personal use

**Use at your own risk.**

---

## 🙏 Credits

- Analysis & Development: [duydat1412](https://github.com/duydat1412)
- Powered by: SwiftUI, TrollStore entitlements
- Inspired by: iOS modding community

---

## 📞 Support

- 🐛 **Issues:** [GitHub Issues](../../issues)
- 💬 **Discussions:** [GitHub Discussions](../../discussions)
- ⭐ **Star this repo** if you find it useful!

---

**Version:** 1.0  
**Last Updated:** 2025-12-16
