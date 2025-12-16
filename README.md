## 📱 Liên Quân Mod Installer

App iOS giúp tự động cài skin mod cho **Liên Quân Mobile** bằng cách copy/ghi đè các file resources (AssetRefs, Prefab_Characters, Databin, assetbundle, v.v.) từ gói mod vào game.  
**Dùng cho mục đích cá nhân/học tập – tự chịu trách nhiệm khi sử dụng.**

---

## 📋 Yêu cầu cơ bản

- iOS 14.0 trở lên  
- Đã cài **Liên Quân Mobile** từ App Store và mở game ít nhất 1 lần  
- Gói mod dạng `.zip` có cấu trúc:

```text
Resources/
  └── <version> (ví dụ: 1.60.1)/
      ├── AssetRefs/
      ├── Prefab_Characters/
      ├── assetbundle/
      ├── Databin/
      ├── Ages/
      └── Languages/
```

- Thiết bị có quyền truy cập sâu vào file game:
  - Ưu tiên: **TrollStore** hoặc máy đã **jailbreak**
  - Hoặc: iOS 17–18 dùng **AltStore / Sideloadly** để sideload `.ipa` (Apple ID free chỉ có hạn 7 ngày)

> ❌ **Không khuyến nghị** dùng eSign / các ứng dụng “ký IPA” bên thứ ba.  
> Dễ bị revoke chứng chỉ, và bạn không kiểm soát được việc họ chỉnh sửa IPA/chèn mã độc.

---

## 🚀 Cách cài đặt (.ipa)

- **– TrollStore (khuyến nghị nếu iOS hỗ trợ, còn không hỗ trợ thì phải chịu):**
  1. Tải file `.ipa` từ phần **Releases** hoặc artifact GitHub Actions  
  2. Chuyển `.ipa` vào iPhone (AirDrop / Files)  
  3. Mở **TrollStore** → nhấn `+` → chọn `.ipa` → Install

---

## 🎮 Cách sử dụng nhanh

1. Mở app **Mod Installer** sau khi cài xong.  
2. Nhấn **“Thêm Mod Pack”**, chọn file mod `.zip` với cấu trúc như trên.  
3. App sẽ:
   - Giải nén và tự tìm thư mục mod phù hợp  
   - **Tự động cài luôn mod vừa import** (copy/ghi đè đầy đủ, đệ quy toàn bộ cây thư mục được map)  
4. Lần đầu dùng nên nhấn **“Tạo Backup”** để lưu bản gốc của game.  
5. Nếu muốn quay về phiên bản gốc, nhấn **“Restore Backup”** rồi tắt/mở lại Liên Quân.

---

## ⚠️ Lưu ý

- App truy cập và chỉnh sửa file của game → **không thể phát hành qua App Store/TestFlight**.  
- Nên test trước trên **tài khoản phụ** để tránh rủi ro cho tài khoản chính.  
- Không dùng app để chia sẻ, kinh doanh mod hoặc cố ý vi phạm điều khoản dịch vụ của game.  
- Nếu thấy dự án hữu ích, hãy ⭐ repo để ủng hộ tác giả.


