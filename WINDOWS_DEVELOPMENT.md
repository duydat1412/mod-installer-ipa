# 🪟 iOS Development on Windows - Complete Guide

## 🎯 The Challenge

Windows không có:
- ❌ Xcode
- ❌ iOS Simulator  
- ❌ Native build tools

**Nhưng bạn vẫn phát triển được iOS app!**

---

## ✅ Solution: GitHub Actions as Remote Mac

### **Strategy: Fast Feedback Loop**

Mục tiêu: **Giảm từ 10 phút xuống 3-5 phút** mỗi lần test!

---

## 📋 Setup Instructions

### **Step 1: Tạo Development Branch**

```powershell
# Windows PowerShell
cd C:\Users\DAT\Desktop\project\ModInstaller

# Tạo branch riêng cho testing
git checkout -b dev
git push -u origin dev
```

**Lợi ích:**
- `main` branch: stable releases
- `dev` branch: testing, có thể push막

### **Step 2: Enable Artifacts for Dev Branch**

Edit `.github/workflows/build-ipa.yml`:

```yaml
on:
  push:
    branches: [ main, master, dev ]  # ← Thêm dev
```

**Bây giờ:**
- Push lên `dev` → tự động build
- Không cần tạo tag/release mỗi lần

### **Step 3: Quick Test Cycle**

```powershell
# 1. Sửa code (2 phút)
# Edit trong VS Code

# 2. Commit + push (10 giây)
git add -A
git commit -m "test: try new feature"
git push

# 3. Wait for build (3-5 phút)
# Mở: https://github.com/duydat1412/mod-installer-ipa/actions

# 4. Download artifact (30 giây)
# Actions → latest run → Artifacts → ModInstaller-IPA

# 5. Test trên iPhone (2 phút)
# AirDrop → TrollStore → Install

# Total: ~8 phút (thay vì 15+ phút)
```

---

## ⚡ Speed Optimizations

### **1. Cached Dependencies**

Thêm vào workflow để GitHub cache Xcode modules:

```yaml
- name: Cache Xcode DerivedData
  uses: actions/cache@v3
  with:
    path: ~/Library/Developer/Xcode/DerivedData
    key: ${{ runner.os }}-xcode-${{ hashFiles('**/*.swift') }}
```

**Result:** Build nhanh hơn 30-50%!

### **2. Skip Release Step on Dev**

```yaml
- name: Create Release
  if: startsWith(github.ref, 'refs/tags/')  # Chỉ chạy khi có tag
```

**Result:** Tiết kiệm 30 giây mỗi build!

### **3. Parallel Steps (nếu có test)**

```yaml
jobs:
  build:
    # Build job
  
  test:
    # Test job chạy song song
    runs-on: macos-latest
    steps:
      - run: swift test
```

---

## 🔔 Real-time Notifications

### **Option A: GitHub CLI (Windows)**

```powershell
# Install GitHub CLI
winget install GitHub.cli

# Watch workflow
gh run watch

# Sẽ notify khi build xong!
```

### **Option B: GitHub Mobile App**

1. Install GitHub app trên iPhone
2. Enable notifications
3. Push code → nhận thông báo khi build xong → download ngay!

---

## 📱 Streamlined iPhone Testing

### **Setup AirDrop Alternative (Windows → iPhone)**

**Method 1: OneDrive/iCloud**
1. GitHub Actions upload artifact
2. Tự động sync vào OneDrive
3. iPhone mở OneDrive → install

**Method 2: Telegram Bot**

```python
# telegram_bot.py - chạy trên GitHub Actions
import requests

def send_ipa(bot_token, chat_id, ipa_path):
    url = f"https://api.telegram.org/bot{bot_token}/sendDocument"
    files = {'document': open(ipa_path, 'rb')}
    data = {'chat_id': chat_id}
    requests.post(url, files=files, data=data)
```

Thêm vào workflow:
```yaml
- name: Send to Telegram
  env:
    BOT_TOKEN: ${{ secrets.TELEGRAM_BOT_TOKEN }}
    CHAT_ID: ${{ secrets.TELEGRAM_CHAT_ID }}
  run: |
    python telegram_bot.py
```

**Result:** Build xong → IPA tự động gửi vào Telegram → mở trên iPhone!

---

## 🎮 Alternative: Cloud Mac Services

Nếu cần testing thường xuyên hơn:

### **MacStadium / MacinCloud**

**Pricing:**
- $20-50/tháng
- Remote access vào Mac thật
- Chạy Xcode như bình thường

**Setup:**
1. Thuê Mac cloud
2. Remote Desktop từ Windows
3. Git clone project
4. Xcode development bình thường

**Pros:**
- ✅ Full Xcode experience
- ✅ Live testing với simulator
- ✅ Debugging

**Cons:**
- ❌ Tốn tiền
- ❌ Latency khi remote

---

## 🖥️ Hackintosh VM (Advanced)

**⚠️ Không khuyến khích** - vi phạm EULA của Apple

Nhưng technically possible:
1. VMware + macOS image
2. Cài Xcode trong VM
3. Develop như Mac thật

**Issues:**
- Lag
- Không stable
- Legal gray area

---

## 📊 Workflow Comparison

| Method | Speed | Cost | Recommendation |
|--------|-------|------|----------------|
| **GitHub Actions (optimized)** | ⚡⚡ 3-5min | FREE | ✅ BEST |
| Telegram Bot auto-send | ⚡⚡⚡ 3min | FREE | ✅ Great |
| Cloud Mac | ⚡⚡⚡ instant | $20-50/mo | 🤔 If serious |
| Hackintosh VM | ⚡ slow | FREE | ❌ Not worth |

---

## 🎯 Recommended Workflow for You

### **Phase 1: Code Editing (Windows)**

```
VS Code → Edit Swift files → Git commit
```

**Tools:**
- VS Code với Swift extension
- Git for Windows
- GitHub CLI

### **Phase 2: Build (GitHub Actions)**

```
Push → Auto build (3-5 min) → Artifact ready
```

### **Phase 3: Testing (iPhone)**

**Option A: Manual download**
```
Actions page → Download artifact → AirDrop → Install
```

**Option B: Telegram bot (sau khi setup)**
```
Push → Wait → Telegram notification → Open IPA → Install
```

### **Phase 4: Iteration**

```
See issue → Fix code → Push → Wait 3min → Test
```

**Realistic cycle:** 10-15 phút/iteration

**Better than:** 30+ phút nếu không optimize!

---

## 🔧 Complete Setup Commands

```powershell
# Windows PowerShell

# 1. Setup dev branch
git checkout -b dev
git push -u origin dev

# 2. Install GitHub CLI
winget install GitHub.cli

# 3. Create alias for quick push
function Quick-Test {
    param([string]$message = "test: quick iteration")
    git add -A
    git commit -m $message
    git push
    gh run watch
}

# Sử dụng:
Quick-Test "test: new UI"
# Auto commit + push + watch build!
```

Add vào PowerShell profile:
```powershell
notepad $PROFILE
# Paste function Quick-Test vào
```

---

## 📈 Real Example Timeline

**Traditional flow:**
```
Edit code (5min) → 
Commit (1min) → 
Push (30s) → 
Wait for build (10min) → 
Download artifact (1min) → 
Transfer to iPhone (2min) → 
Install (1min) → 
Test (3min)
= 23+ phút
```

**Optimized flow:**
```
Edit code (5min) → 
Quick-Test command (10s) → 
Build notification (3min) → 
Telegram auto-send (instant) → 
Install (1min) → 
Test (3min)
= 12 phút (giảm 50%!)
```

---

## 💡 Pro Tips

### **1. Multiple test devices**

Setup TestFlight nếu có nhiều tester:
- Upload IPA lên App Store Connect
- Add internal testers
- Push → auto distribute

### **2. Automated testing**

Add Swift tests vào workflow:
```yaml
- name: Run Tests
  run: xcodebuild test -scheme ModInstaller
```

Failed tests → không build IPA → tiết kiệm thời gian!

### **3. Version bumping script**

```powershell
# bump_version.ps1
$version = Get-Content ModInstaller/Info.plist | 
    Select-String -Pattern "CFBundleShortVersionString"
    
# Auto increment version
# Commit + tag + push
```

---

## ✅ Action Items

**Immediate (10 phút setup):**
- [ ] Tạo `dev` branch
- [ ] Update workflow để build dev branch
- [ ] Install GitHub CLI
- [ ] Test một lần push

**This week (optional):**
- [ ] Setup Telegram bot
- [ ] Create PowerShell aliases
- [ ] Add workflow caching

**Long term:**
- [ ] Consider Cloud Mac nếu develop thường xuyên
- [ ] Setup CI/CD pipeline hoàn chỉnh

---

## 🆘 Troubleshooting

**"Build quá lâu"**
→ Check workflow logs, có thể optimize thêm

**"Download artifact mỏi tay"**
→ Setup Telegram bot automation

**"Cần test nhiều hơn 10 lần/ngày"**
→ Cân nhắc thuê Cloud Mac ($20/tháng)

---

**TL;DR:** 
- Windows không build được iOS native
- **Dùng GitHub Actions làm "cloud Mac"** - FREE!
- Optimize để 3-5 phút/build thay vì 10+ phút
- Setup Telegram bot để auto-send IPA
- **Total cycle: ~10-12 phút** thay vì 20+ phút

**This is the way!** 🚀
