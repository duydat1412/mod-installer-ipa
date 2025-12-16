# 🚀 Live Testing Guide - Như Android Studio

## ⚡ Quick Setup (One-time)

### 1. Kết nối iPhone với Mac

**Cách 1: USB Cable**
1. Cắm iPhone vào Mac
2. Trust device

**Cách 2: WiFi (Recommended)**
1. Xcode → Window → Devices and Simulators
2. Chọn iPhone → Connect via network
3. Sau đó rút dây, vẫn debug được!

### 2. Cấu hình Xcode Project

```bash
# Generate project
xcodegen generate
open ModInstaller.xcodeproj
```

**Trong Xcode:**
1. Chọn target: **Your iPhone** (không phải simulator!)
2. Signing & Capabilities:
   - Team: Your Apple ID
   - Bundle ID: `com.duydat1412.modinstaller.dev` (khác production)
   - ⚠️ Remove entitlements file tạm thời (sẽ add lại sau)

---

## 🔥 Live Development Workflow

### **Step 1: Run lần đầu**

```
Xcode → Product → Run (⌘R)
```

- App cài lên iPhone
- Xcode attached debugger
- Logs realtime trong Console

### **Step 2: Sửa code**

```swift
// Trong ContentView.swift
Text("Test version 1") // Thay đổi bất kỳ

// Save (⌘S)
```

### **Step 3: Hot Reload**

```
⌘R (Run again) - chỉ mất 5-10 giây!
```

**Không cần:**
- ❌ Build IPA
- ❌ Upload lên GitHub
- ❌ Download về
- ❌ Cài lại qua TrollStore

**Giống Android Studio!** 🎉

---

## 🧪 Testing Without Root Access

Vì Xcode sideload không có entitlements, test logic riêng:

### **Mock Data Pattern:**

```swift
// GameFinder.swift - Add debug mode
class GameFinder {
    static let shared = GameFinder()
    
    #if DEBUG
    var useMockData = true
    #else
    var useMockData = false
    #endif
    
    func findGameDirectory() -> URL? {
        #if DEBUG
        if useMockData {
            // Fake game directory in app's own sandbox
            let mockPath = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("MockGame/Documents")
            
            try? FileManager.default.createDirectory(
                at: mockPath, 
                withIntermediateDirectories: true
            )
            
            print("🧪 DEBUG: Using mock path: \(mockPath)")
            return mockPath
        }
        #endif
        
        // Real implementation (needs entitlements)
        // ...
    }
}
```

### **Test với Mock Mods:**

```swift
// ModInstallerViewModel.swift
#if DEBUG
func loadMockMods() {
    let mockPack = ModPack(
        name: "Test Mod",
        version: "1.0",
        files: []
    )
    modPacks = [mockPack]
}
#endif
```

---

## 📱 SwiftUI Live Preview (Fastest!)

**Cho UI testing - 0 giây build!**

```swift
// ContentView.swift - thêm ở cuối file
#Preview {
    ContentView()
}
```

**Trong Xcode:**
- Mở ContentView.swift
- Canvas panel bên phải (⌥⌘↩)
- Thấy UI live, sửa code → UI update ngay!

**Với mock data:**

```swift
#Preview {
    let viewModel = ModInstallerViewModel()
    viewModel.gameFound = true
    viewModel.statusMessage = "Mock: Game found!"
    
    return ContentView()
        .environmentObject(viewModel)
}
```

---

## 🎯 Recommended Workflow

### **Phase 1: UI Development (SwiftUI Preview)**
- Làm UI
- Test layout, colors, spacing
- 0 giây feedback!

### **Phase 2: Logic Testing (Xcode Run)**
- Mock data
- Test flows, state management
- 5-10 giây rebuild

### **Phase 3: Final Test (TrollStore)**
- Khi đã chắc code OK
- Push lên GitHub → Download IPA
- Test entitlements thực tế

---

## 🐛 Debug Console

**Trong Xcode khi run:**

```
⌘Y (Debug Area)
```

Thấy:
- `print()` statements
- Errors realtime
- Variable inspection
- Breakpoints

**Giống Android Logcat!**

---

## 💡 Pro Tips

### **1. Conditional Compilation**

```swift
#if DEBUG
    print("🐛 Debug mode")
#else
    print("📦 Production")
#endif
```

### **2. Schemes cho từng environment**

- **Debug Scheme:** Xcode run, mock data
- **Release Scheme:** GitHub Actions, real entitlements

### **3. Quick iteration cycle**

```
1. Sửa code (5s)
2. ⌘R rebuild (5s)
3. Test trên iPhone (30s)
Total: 40s thay vì 10 phút!
```

### **4. Breakpoints**

Click dòng code → đặt breakpoint
App sẽ pause, inspect variables!

---

## ⚙️ Setup Script

**One-time setup:**

```bash
#!/bin/bash
# setup_dev.sh

echo "Setting up development environment..."

# 1. Generate Xcode project
xcodegen generate

# 2. Open Xcode
open ModInstaller.xcodeproj

echo "✅ Ready!"
echo ""
echo "Next steps:"
echo "1. Connect iPhone"
echo "2. Select your iPhone as target"
echo "3. Press ⌘R to run"
```

---

## 🚨 Common Issues

### **"No provisioning profile"**

**Fix:**
1. Xcode → Signing & Capabilities
2. Team → Add Account → Sign in với Apple ID
3. Auto manage signing ✅

### **"Untrusted Developer"**

**On iPhone:**
1. Settings → General → VPN & Device Management
2. Trust developer certificate

### **Entitlements errors**

**For dev builds:**
- Remove hoặc comment entitlements file
- Chỉ dùng entitlements cho production (GitHub Actions)

---

## 📊 Comparison

| Method | Speed | Real Entitlements | Use Case |
|--------|-------|-------------------|----------|
| SwiftUI Preview | ⚡⚡⚡ (0s) | ❌ | UI only |
| Xcode Run | ⚡⚡ (5s) | ❌ | Logic + UI |
| GitHub Actions | 🐌 (10min) | ✅ | Final test |

**Best practice:** 90% dev với Xcode, 10% final test với TrollStore!

---

## 🎬 Final Workflow Example

```bash
# Morning: Start dev
./setup_dev.sh
# Xcode opens

# Work: Iterate fast
# 1. Edit ContentView.swift
# 2. ⌘R
# 3. Test on iPhone
# 4. Repeat 10x in 1 hour

# Afternoon: Push tested code
git add -A
git commit -m "feat: New UI tested locally"
git push
# GitHub Actions builds production IPA

# Evening: Final test
# Download IPA → TrollStore → Test with real entitlements
```

**Result:** 10x faster development! 🚀
