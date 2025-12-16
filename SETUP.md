# 🚀 Hướng Dẫn Build IPA qua GitHub Actions

## 📋 Yêu Cầu

- ✅ Tài khoản GitHub (free)
- ✅ Git installed trên Windows
- ✅ Không cần macOS/Xcode!

---

## 🔧 Bước 1: Setup Git Repository

### 1.1. Install Git (nếu chưa có)

Download từ: https://git-scm.com/download/win

### 1.2. Initialize Git Repository

```powershell
# Navigate to project
cd C:\Users\DAT\Desktop\project\ModInstaller

# Initialize git
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - iOS Mod Installer"
```

---

## 🌐 Bước 2: Tạo GitHub Repository

### 2.1. Tạo repo mới trên GitHub

1. Vào https://github.com
2. Click **"New repository"**
3. Điền thông tin:
   - **Repository name:** `ModInstaller`
   - **Description:** `iOS app for Liên Quân Mobile mod installation`
   - **Visibility:** Private (hoặc Public)
4. **KHÔNG** check:
   - ❌ Add README
   - ❌ Add .gitignore
   - ❌ Choose a license
5. Click **"Create repository"**

### 2.2. Push code lên GitHub

```powershell
# Add remote
git remote add origin https://github.com/YOUR_USERNAME/ModInstaller.git

# Push code
git branch -M main
git push -u origin main
```

**Thay `YOUR_USERNAME`** bằng username GitHub của bạn!

---

## ⚙️ Bước 3: Enable GitHub Actions

### 3.1. Kiểm tra Actions đã enable

1. Vào repository trên GitHub
2. Click tab **"Actions"**
3. Nếu bị disable → Click **"I understand my workflows, enable them"**

### 3.2. Workflow sẽ tự chạy

Sau khi push code, GitHub Actions tự động:
- ✅ Checkout code
- ✅ Setup Xcode (trên macOS runner)
- ✅ Generate Xcode project
- ✅ Build app
- ✅ Create IPA file
- ✅ Upload artifact

---

## 📥 Bước 4: Download IPA

### 4.1. Chờ build hoàn tất

1. Vào tab **"Actions"**
2. Click vào workflow run mới nhất
3. Chờ status = ✅ (khoảng 5-10 phút)

### 4.2. Download artifact

1. Scroll xuống **"Artifacts"** section
2. Click **"ModInstaller-IPA"** để download
3. Giải nén file ZIP
4. File `ModInstaller.ipa` sẽ bên trong!

---

## 📱 Bước 5: Install qua TrollStore

### 5.1. Transfer IPA sang iPhone

**Option A: AirDrop (dễ nhất)**
```
1. Share IPA qua AirDrop sang iPhone
2. Save to Files app
```

**Option B: iCloud Drive**
```
1. Upload IPA lên iCloud Drive
2. Mở Files app trên iPhone
3. Navigate đến iCloud Drive
```

**Option C: Direct download**
```
1. Host IPA trên server/Dropbox/Google Drive
2. Mở link trên iPhone Safari
3. Download file
```

### 5.2. Install với TrollStore

```
1. Open TrollStore app
2. Tap "+" button
3. Browse to IPA file
4. Tap file → Install
5. Done! ✅
```

---

## 🔄 Bước 6: Update App (sau này)

Khi có thay đổi code:

```powershell
# 1. Edit code
# 2. Commit changes
git add .
git commit -m "Update: [mô tả thay đổi]"

# 3. Push
git push

# 4. GitHub Actions sẽ auto build IPA mới
# 5. Download artifact mới từ Actions tab
```

---

## 🏷️ Bước 7: Create Release (Optional)

Để tạo version có số:

```powershell
# Tag version
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions sẽ:
# - Build IPA
# - Tự động tạo Release
# - Attach IPA vào Release
```

Download từ: **Releases** → Latest → **Assets** → `ModInstaller.ipa`

---

## 🐛 Troubleshooting

### Build failed?

**Check logs:**
1. Actions tab → Click failed run
2. Click "Build iOS App" job
3. Xem log chi tiết ở bước nào lỗi

**Common issues:**

**Lỗi: "No space left on device"**
```yaml
# Hiếm khi xảy ra, retry build
```

**Lỗi: "Xcode not found"**
```yaml
# GitHub Actions tự fix, không cần làm gì
```

**Lỗi: "Code signing"**
```yaml
# Workflow đã disable code signing
# Nếu vẫn lỗi, check workflow file
```

### IPA không install được?

**Unsigned IPA → Cần TrollStore/Jailbreak:**
- ✅ TrollStore: Install OK
- ✅ Jailbreak + AppSync: Install OK
- ❌ Stock iOS + Sideloadly: CẦN sign lại

**Sign với Sideloadly:**
```
1. Open Sideloadly
2. Drag IPA vào
3. Connect iPhone
4. Sign with Apple ID
5. Install
```

---

## 📊 Summary

| Bước | Tool | Time |
|------|------|------|
| 1. Setup Git | Windows | 2 min |
| 2. Create GitHub repo | Browser | 2 min |
| 3. Push code | Git | 1 min |
| 4. Wait for build | GitHub Actions | 5-10 min |
| 5. Download IPA | Browser | 1 min |
| 6. Install via TrollStore | iPhone | 1 min |

**Total: ~10-15 phút** (lần đầu)

Lần sau chỉ cần: **Commit → Push → Wait → Download** = 5 phút!

---

## 🎯 Next Steps

Sau khi cài app thành công:

1. ✅ Copy mod pack vào iPhone (qua Filza/iTunes)
2. ✅ Mở ModInstaller app
3. ✅ Scan mod pack
4. ✅ Create backup
5. ✅ Install mod
6. ✅ Restart Liên Quân Mobile
7. ✅ Enjoy custom skins! 🎨

---

## 📞 Support

Có vấn đề? Check:
- GitHub Actions logs
- [README.md](README.md)
- Test script: `python test_mod_installer.py`

---

**Version:** 1.0  
**Last Updated:** 2025-12-16
