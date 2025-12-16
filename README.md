# 📱 Liên Quân Mobile - Mod Installer

iOS app tự động cài đặt skin mods cho Liên Quân Mobile.

---

## ✨ Features

- ✅ Tự động tìm game directory
- ✅ Scan và import mod packs
- ✅ Backup files gốc trước khi install
- ✅ Auto mapping files theo cấu trúc đã phân tích
- ✅ Progress tracking real-time
- ✅ Restore backup dễ dàng
- ✅ SwiftUI modern interface

---

## 📋 Yêu Cầu

- iPhone Jailbroken (Filza installed)
- iOS 14.0+
- Liên Quân Mobile đã cài đặt và chạy ít nhất 1 lần
- Mod pack với cấu trúc:
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

## 🚀 Cách Sử Dụng

### 1. Build App

**Trong Xcode:**
```bash
1. Open project: ModInstaller.xcodeproj
2. Select target: iPhone (your device)
3. Sign with Apple Developer account
4. Build & Run (Cmd+R)
```

**Sideload (không cần Xcode):**
```bash
1. Export IPA từ Xcode: Product → Archive → Export
2. Sideload qua Sideloadly / AltStore
3. Trust certificate: Settings → General → VPN & Device Management
```

### 2. Import Mod Pack

```
1. Copy mod pack folder vào iPhone qua:
   - Filza File Manager
   - iMazing / iFunBox
   - iTunes File Sharing

2. Trong app, tap "Thêm Mod Pack"

3. Browse đến folder mod pack
```

### 3. Cài Đặt Mod

```
1. Tap "Tạo Backup" (chỉ cần 1 lần)
   → Backup files gốc để restore sau này

2. Chọn mod pack từ danh sách

3. Tap "Cài Đặt Mod"
   → App sẽ tự động copy files

4. Chờ progress bar hoàn tất

5. Restart Liên Quân Mobile
```

### 4. Restore Files Gốc

```
1. Tap "Restore Backup"

2. Restart game

→ Game trở về trạng thái ban đầu
```

---

## 🛠️ Cấu Trúc Project

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

**Path gốc:** `/var/mobile/Containers/Data/Application/[UUID]/Documents/Resources/1.60.1/`

---

## ⚠️ Lưu Ý

### An Toàn:
- ✅ **LUÔN** tạo backup trước khi install mod
- ✅ Test trên alt account trước
- ✅ Không share IPA có mod publicly

### Troubleshooting:

**"Không tìm thấy game"**
```
→ Chạy Liên Quân ít nhất 1 lần để game tải resources
→ Check trong Filza: /var/mobile/Containers/Data/Application/
```

**"Mod pack không hợp lệ"**
```
→ Kiểm tra cấu trúc folder có đúng không
→ Phải có folder 1.60.1 bên trong
```

**"Lỗi khi copy files"**
```
→ Check permissions trong Filza
→ Restart app và thử lại
```

---

## 📸 Screenshots

*(Add screenshots sau khi build)*

---

## 🔧 Development

**Build từ source:**
```bash
# Clone repo
git clone <repo-url>
cd ModInstaller

# Open in Xcode
open ModInstaller.xcodeproj

# Build
xcodebuild -scheme ModInstaller -configuration Release
```

**Dependencies:**
- None! Pure SwiftUI + Foundation

---

## 📝 Changelog

### v1.0 (2025-12-16)
- ✅ Initial release
- ✅ Auto game finder
- ✅ Mod pack scanner
- ✅ Backup/restore system
- ✅ Progress tracking
- ✅ 6 folder mappings support

---

## ⚖️ Legal

**Educational purposes only.**

- ❌ Không unlock premium skins không sở hữu
- ❌ Không vi phạm game ToS
- ✅ Chỉ dùng cho custom content TỰ TẠO

**Use at your own risk.**

---

## 🙏 Credits

- Mod pack analysis by: DAT
- App developed by: GitHub Copilot
- Inspired by: Mod community

---

**Version:** 1.0  
**Last Updated:** 2025-12-16
