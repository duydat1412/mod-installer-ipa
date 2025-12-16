# 🔓 Entitlements & Root Access - Giải Thích Chi Tiết

## 📚 **Kiến Thức Nền Tảng:**

### **1. iOS Sandbox là gì?**

Mỗi app iOS chạy trong "sandbox" - một container riêng biệt:

```
App A → /var/mobile/Containers/Data/Application/UUID-A/
App B → /var/mobile/Containers/Data/Application/UUID-B/

❌ App A KHÔNG THỂ đọc/ghi vào UUID-B
```

**Mục đích:** Bảo mật, ngăn app độc hại.

---

### **2. Entitlements là gì?**

Entitlements = **Permissions đặc biệt** được nhúng trong app signature.

**Cấu trúc:**
```
ModInstaller.app/
├── ModInstaller (binary)
├── Info.plist
├── ModInstaller.entitlements ← QUAN TRỌNG!
└── _CodeSignature/
    └── CodeResources ← Chứa hash của entitlements
```

**Apple kiểm tra:**
1. App có signature hợp lệ?
2. Entitlements có match với signature?
3. Entitlements có được phép không?

---

## 🔐 **Các Entitlements Quan Trọng:**

### **1. `platform-application`**

```xml
<key>platform-application</key>
<true/>
```

**Ý nghĩa:**
- App được coi như **system app**
- Bypass nhiều sandbox restrictions
- Giống như Settings.app, Filza

**Filza dùng:** ✅

---

### **2. `com.apple.private.security.no-container`**

```xml
<key>com.apple.private.security.no-container</key>
<true/>
```

**Ý nghĩa:**
- App KHÔNG chạy trong sandbox container
- Có thể truy cập toàn bộ file system
- Root access!

**Filza dùng:** ✅

---

### **3. `com.apple.private.security.container-manager`**

```xml
<key>com.apple.private.security.container-manager</key>
<true/>
```

**Ý nghĩa:**
- Quản lý app containers
- List tất cả app UUIDs
- Đọc/ghi vào bất kỳ app nào

**Filza dùng:** ✅

---

### **4. `com.apple.private.security.storage.AppDataContainers`**

```xml
<key>com.apple.private.security.storage.AppDataContainers</key>
<true/>
```

**Ý nghĩa:**
- Access vào tất cả app data containers
- Tương tự container-manager

**Filza dùng:** ✅

---

## 🎯 **Tại sao App Thông Thường KHÔNG Có?**

### **Apple Developer Account limitations:**

**Free account:**
```
❌ Không sign được với private entitlements
❌ Chỉ có basic entitlements (keychain, iCloud, etc.)
```

**Paid Developer ($99/year):**
```
✅ Nhiều entitlements hơn
❌ VẪN KHÔNG có private entitlements (com.apple.private.*)
```

**Apple Internal:**
```
✅ Full access - chỉ Apple engineers
✅ Sign với private entitlements
```

---

## 🔓 **TrollStore Magic:**

### **CoreTrust Bypass:**

TrollStore exploit CoreTrust để:

1. **Fake signature:** App trông như được Apple sign
2. **Inject entitlements:** Add bất kỳ entitlement nào
3. **Permanent install:** Không expire sau 7 ngày

**Cách hoạt động:**
```
Normal install:
App.ipa → Apple checks signature → ❌ Invalid private entitlements

TrollStore:
App.ipa → TrollStore patches → ✅ Fake Apple signature → iOS accepts
```

---

## 🛠️ **Áp Dụng Vào ModInstaller:**

### **File đã tạo:**

**ModInstaller.entitlements:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"...>
<plist version="1.0">
<dict>
    <!-- Giống Filza -->
    <key>platform-application</key>
    <true/>
    
    <key>com.apple.private.security.no-container</key>
    <true/>
    
    <key>com.apple.private.security.container-manager</key>
    <true/>
    
    <!-- ... -->
</dict>
</plist>
```

### **Workflow đã update:**

GitHub Actions sẽ:
1. Build app với entitlements file
2. Embed vào binary
3. Create unsigned IPA
4. TrollStore sẽ sign + activate entitlements

---

## 🧪 **Test Entitlements:**

### **Sau khi install via TrollStore:**

**1. Check root access:**

```swift
// Trong GameFinder.swift
func checkRootAccess() -> Bool {
    let testPath = "/var/mobile"
    return FileManager.default.isReadableFile(atPath: testPath)
}

// Gọi trong app:
if GameFinder.shared.checkRootAccess() {
    print("✅ ROOT ACCESS GRANTED!")
} else {
    print("❌ Still sandboxed")
}
```

**2. Test container access:**

```swift
let appDir = "/var/mobile/Containers/Data/Application"
let apps = try? FileManager.default.contentsOfDirectory(atPath: appDir)

if let apps = apps {
    print("✅ Found \(apps.count) app containers")
    // Tìm Liên Quân trong đây
} else {
    print("❌ No access")
}
```

---

## ⚠️ **Lưu Ý Quan Trọng:**

### **1. TrollStore có thể từ chối entitlements:**

Một số TrollStore version giới hạn entitlements.

**Solution:** Update TrollStore lên latest.

### **2. iOS version:**

- iOS 14-15: TrollStore 1.x works
- iOS 15-16.6.1: TrollStore 2.x works  
- iOS 17+: Cần exploit mới

### **3. Không abuse:**

Entitlements mạnh = Trách nhiệm lớn!

**KHÔNG:**
- ❌ Access app data của người khác
- ❌ Modify system files
- ❌ Bypass DRM/IAP

**CHỈ:**
- ✅ Manage mod files của chính bạn
- ✅ Educational purposes

---

## 📊 **So Sánh:**

| Feature | Normal App | App w/ Entitlements | Filza |
|---------|-----------|---------------------|-------|
| Sandbox | ✅ Yes | ❌ No | ❌ No |
| Root access | ❌ | ✅ | ✅ |
| Container access | Own only | All apps | All apps |
| Install method | Sideload | **TrollStore** | **TrollStore** |

---

## 🔬 **Deep Dive - Kỹ thuật:**

### **Binary structure:**

```bash
# Check entitlements in IPA
unzip ModInstaller.ipa
cd Payload/ModInstaller.app

# Extract entitlements from binary
codesign -d --entitlements - ModInstaller

# Output sẽ show XML entitlements
```

### **Mach-O format:**

iOS binary (Mach-O) có sections:
```
__TEXT    → Code
__DATA    → Variables
__LINKEDIT → Signatures & Entitlements ← ĐÂY!
```

TrollStore modify `__LINKEDIT` để inject entitlements!

---

## 🎓 **Học Thêm:**

**Resources:**
1. Apple Docs: https://developer.apple.com/documentation/bundleresources/entitlements
2. TrollStore Source: https://github.com/opa334/TrollStore
3. iOS Internals: "iOS App Reverse Engineering" (book)
4. Entitlements Database: https://newosxbook.com/ent.jl

**Tools để research:**
- `ldid` - Sign binaries with custom entitlements
- `jtool2` - Analyze Mach-O files
- `otool` - Dump binary info

---

## ✅ **Summary:**

**Đã làm:**
1. ✅ Tạo ModInstaller.entitlements với private entitlements
2. ✅ Update workflow để embed entitlements
3. ✅ Add root access check vào code

**Next:**
1. Push code lên GitHub
2. GitHub Actions build IPA (với entitlements)
3. Install via TrollStore
4. Test root access
5. App sẽ thấy được Liên Quân container! 🎉

---

**Version:** 1.0  
**Last Updated:** 2025-12-16
