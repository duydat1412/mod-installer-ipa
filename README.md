<div align="center">

# 📱 Liên Quân Mod Installer

[![Build IPA](https://github.com/duydat1412/mod-installer-ipa/actions/workflows/build-ipa.yml/badge.svg)](https://github.com/duydat1412/mod-installer-ipa/actions/workflows/build-ipa.yml)
[![iOS 14.0+](https://img.shields.io/badge/iOS-14.0%2B-blue.svg)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**iOS app to automatically install skin mods for Arena of Valor (Liên Quân Mobile)**

[🇻🇳 Tiếng Việt](#-hướng-dẫn-sử-dụng) | [🇬🇧 English](#-user-guide)

</div>

---

## 🇻🇳 Hướng Dẫn Sử Dụng

### ✨ Tính Năng

- 🎮 **Cài mod tự động** - Chỉ cần chọn file `.zip`, app tự xử lý mọi thứ
- 💾 **Backup & Restore** - Sao lưu bản gốc, khôi phục bất cứ lúc nào
- 🔄 **Hỗ trợ mọi phiên bản game** - Tự động detect version
- 📦 **Giao diện đơn giản** - Dễ sử dụng, không cần kiến thức kỹ thuật

### 📋 Yêu Cầu

| Yêu cầu | Chi tiết |
|---------|----------|
| **iOS** | 14.0 trở lên |
| **Cài đặt** | Qua **TrollStore** (bắt buộc) |
| **Game** | Liên Quân Mobile đã cài và mở ít nhất 1 lần |

> ⚠️ **Quan trọng**: App cần quyền truy cập file hệ thống, chỉ hoạt động khi cài qua TrollStore.

### 📥 Cách Cài Đặt

1. Tải file `.ipa` từ [**Releases**](https://github.com/duydat1412/mod-installer-ipa/releases/latest)
2. Chuyển file `.ipa` vào iPhone (AirDrop hoặc Files)
3. Mở **TrollStore** → Nhấn `+` → Chọn file `.ipa` → Install

### 🎮 Cách Sử Dụng

```
┌─────────────────────────────────────────────────────────┐
│  1️⃣  Mở app Mod Installer                               │
│  2️⃣  Nhấn "Tạo Backup" (lần đầu - quan trọng!)          │
│  3️⃣  Nhấn "Thêm Mod Pack" → Chọn file mod .zip          │
│  4️⃣  App tự động cài mod                                │
│  5️⃣  Tắt và mở lại Liên Quân để thấy skin mới           │
└─────────────────────────────────────────────────────────┘
```

### 📁 Cấu Trúc File Mod

File mod `.zip` cần có cấu trúc như sau:

```
ModPack.zip
└── Resources/
    └── <phiên bản>/        ← VD: 1.60.1, 1.61.2, 1.62.0
        ├── AssetRefs/
        ├── Prefab_Characters/
        ├── assetbundle/
        ├── Databin/
        ├── Ages/
        └── Languages/
```

### ❓ Khắc Phục Lỗi

| Vấn đề | Giải pháp |
|--------|-----------|
| "Không tìm thấy game" | Cài game từ App Store và mở game ít nhất 1 lần |
| "Không có quyền truy cập" | Đảm bảo app được cài qua TrollStore |
| Skin không hiển thị | Tắt hoàn toàn game (force close) rồi mở lại |
| Muốn gỡ mod | Nhấn "Restore Backup" trong app |

---

## 🇬🇧 User Guide

### ✨ Features

- 🎮 **Auto mod installation** - Just select a `.zip` file, the app handles everything
- 💾 **Backup & Restore** - Save original files, restore anytime
- 🔄 **All game versions supported** - Auto-detects version
- 📦 **Simple UI** - Easy to use, no technical knowledge required

### 📋 Requirements

| Requirement | Details |
|-------------|---------|
| **iOS** | 14.0 or later |
| **Installation** | Via **TrollStore** (required) |
| **Game** | Arena of Valor installed and opened at least once |

> ⚠️ **Important**: The app requires system file access and only works when installed via TrollStore.

### 📥 Installation

1. Download the `.ipa` from [**Releases**](https://github.com/duydat1412/mod-installer-ipa/releases/latest)
2. Transfer the `.ipa` to your iPhone (AirDrop or Files app)
3. Open **TrollStore** → Tap `+` → Select the `.ipa` → Install

### 🎮 How to Use

```
┌─────────────────────────────────────────────────────────┐
│  1️⃣  Open Mod Installer app                             │
│  2️⃣  Tap "Create Backup" (first time - important!)      │
│  3️⃣  Tap "Add Mod Pack" → Select mod .zip file          │
│  4️⃣  App automatically installs the mod                 │
│  5️⃣  Close and reopen Arena of Valor to see new skins   │
└─────────────────────────────────────────────────────────┘
```

### 📁 Mod File Structure

The mod `.zip` file should have this structure:

```
ModPack.zip
└── Resources/
    └── <version>/          ← e.g., 1.60.1, 1.61.2, 1.62.0
        ├── AssetRefs/
        ├── Prefab_Characters/
        ├── assetbundle/
        ├── Databin/
        ├── Ages/
        └── Languages/
```

### ❓ Troubleshooting

| Issue | Solution |
|-------|----------|
| "Game not found" | Install game from App Store and open it at least once |
| "No access permission" | Make sure app is installed via TrollStore |
| Skins not showing | Force close the game completely and reopen |
| Want to remove mods | Tap "Restore Backup" in the app |

---

## ⚠️ Disclaimer

- This app is for **personal use and educational purposes only**
- **Not affiliated** with Garena, Tencent, or Arena of Valor
- Use at your own risk - **test on a secondary account first**
- Do not use for commercial purposes or distribution of mods

---

## 🛠️ Build from Source

```bash
# Requirements: macOS with Xcode, XcodeGen, ldid
brew install xcodegen ldid

# Build
./build_local.sh

# Output: build/Build/Products/Release-iphoneos/ModInstaller.ipa
```

---

<div align="center">

**Made with ❤️ by [@duydat1412](https://github.com/duydat1412)**

⭐ Star this repo if you find it useful!

</div>
