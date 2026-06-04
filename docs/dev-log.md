# Dev Log — Truyện Tranh App

## 1. Fix lỗi build Android (AGP incompatibility)

**Lỗi:** `FlutterFirebaseStoragePlugin` cannot find symbol khi chạy `flutter run`

**Nguyên nhân:** AGP 9.0.1 không tương thích với `firebase_storage` (plugin dùng KGP riêng, gây lỗi thứ tự compile Kotlin/Java)

**Fix:** Hạ phiên bản trong `android/settings.gradle.kts` và `gradle-wrapper.properties`

| | Trước | Sau |
|---|---|---|
| AGP | 9.0.1 | 8.7.3 |
| Gradle | 9.1.0 | 8.11.1 |
| KGP | 2.3.20 | 2.1.0 |
| google-services | 4.3.15 | 4.4.2 |

---

## 2. Fix Firebase Auth — CONFIGURATION_NOT_FOUND

**Lỗi:** `RecaptchaCallWrapper: CONFIGURATION_NOT_FOUND` khi đăng ký/đăng nhập

**Nguyên nhân:** `firebase_auth` 6.x yêu cầu SHA-1 fingerprint để dùng reCAPTCHA cho Email/Password auth

**Fix:**
1. Lấy SHA-1 debug: `& "D:\Android\jbr\bin\keytool" -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android`
2. Thêm SHA-1 vào Firebase Console → Project Settings → Android app
3. Download lại `google-services.json`
4. Bật **Email/Password** trong Firebase Console → Authentication → Sign-in method
5. Tắt **Email Enumeration Protection** trong Authentication → Settings → User Actions

---

## 3. Hệ thống upload ảnh — HuggingFace

**Vấn đề:** Firebase Storage cần thẻ tín dụng (Blaze plan)

**Giải pháp:** Dùng **HuggingFace Datasets** (free, không cần thẻ, unlimited storage public)

### Upload ảnh lên HuggingFace
```python
from huggingface_hub import HfApi
api = HfApi(token="hf_xxxx")
api.upload_folder(
    folder_path=r"D:\manga-images\...",
    repo_id="username/manga-images",
    repo_type="dataset",
    path_in_repo="ten-truyen"
)
```

### Download manga từ MangaDex
```powershell
# Cài gallery-dl
pip install gallery-dl

# Tải toàn bộ truyện, lọc tiếng Việt
gallery-dl --filter "lang == 'vi'" -d "D:\manga-images" "https://mangadex.org/title/..."
```

### Đổi tên folder về dạng c001, c002...
```powershell
$root = "D:\..."
Get-ChildItem $root -Directory | ForEach-Object {
    $name = $_.Name
    if ($name -match 'c(\d+)') {
        $newName = "c$($matches[1])"
        $newPath = Join-Path $root $newName
        if ($name -ne $newName -and !(Test-Path $newPath)) {
            Rename-Item $_.FullName $newPath
        }
    }
}
```

### HuggingFace API list file
```
GET https://huggingface.co/api/datasets/{user}/{repo}/tree/main/{path}
```
App tự fetch danh sách ảnh → sort theo tên → lưu URL vào Firestore

---

## 4. Thay đổi model & code

### soChuong: int → double
Hỗ trợ chương thập phân (14.1, 25.5...)

- `Chuong.soChuong`: `int` → `double`
- Thêm getter `soChuongText` (14.0 → "14", 14.1 → "14.1")
- `ChuongMoiForm`: dùng `double.tryParse` thay `int.tryParse`
- Firestore đọc: `(data['soChuong'] ?? 0).toDouble()`

### Bug fix: danhSachChuong luôn rỗng khi đọc truyện
`Truyen.fromFirestore` luôn set `danhSachChuong = []` vì chapters ở subcollection. Khi mở `ReadingScreen` → crash `RangeError`.

**Fix:** Thêm `withDanhSachChuong()` vào Truyen model:
```dart
// truyen_detail_screen.dart
void _openReading(int chapterIndex) {
    final truyenVoiChuong = _controller.truyen
        .withDanhSachChuong(_controller.danhSachChuong);
    Navigator.push(... ReadingScreen(truyen: truyenVoiChuong, ...));
}
```

---

## 5. Admin — Quản lý chương

### Thêm chương (HuggingFace)
Dialog nhập:
- Số chương (hỗ trợ 14.1)
- Tiêu đề
- Folder path: `username/manga-images/ten-truyen/c001`

App gọi `HuggingFaceService.fetchImageUrls()` → sort tự nhiên → lưu URL list vào Firestore

### Sửa chương
- Đổi số chương, tiêu đề
- Nhập folder HF mới để re-fetch ảnh (để trống = giữ ảnh cũ)

### Quản lý chương (xem + xóa)
Popup menu truyện → "Quản lý chương" → danh sách chương từ Firestore (FutureBuilder), mỗi chương có nút sửa + xóa

### Kiểm tra trùng chương
Trước khi thêm, kiểm tra `soChuong` đã tồn tại chưa → hiện cảnh báo

---

## 6. View counting

Mỗi chương chỉ +1 view **1 lần/session** (dùng `Set<String>` trong memory)

- Khi mở ReadingScreen → gọi `ghiNhanXemChuong(initialChapterIndex)`
- Khi chuyển chương → gọi `ghiNhanXemChuong(newIndex)`
- Nếu `chuongID` đã trong `_chuongDaXem` → bỏ qua
- Firestore: `FieldValue.increment(1)` trên field `luotXem` của truyen

---

## 7. Thư Viện

**Trước:** 3 tab placeholder (Đang đọc, Yêu thích, Đã đọc xong)

**Sau:** 2 tab với data thực từ Firestore

### Đang đọc
- Tự động lưu khi user đọc bất kỳ chương nào
- Firestore: `nguoiDung/{uid}/thuVien/{truyenID}` với `dangDoc: true`

### Yêu thích
- Lưu khi nhấn icon tim trên màn hình chi tiết truyện
- Firestore: `yeuThich: true` (merge với dangDoc, không ghi đè)
- Trạng thái tim load từ Firestore khi mở lại màn hình (`kiemTraYeuThich`)

**Lưu ý:** 1 truyện có thể xuất hiện ở cả 2 tab (đang đọc VÀ yêu thích)

---

## 8. Bình luận

**Firestore:** `truyen/{truyenID}/binhLuan/{id}`
```
{
    uid: string,
    tenHienThi: string,
    noiDung: string,
    taoLuc: timestamp
}
```

**Tính năng:**
- Xem bình luận real-time (stream orderBy taoLuc descending)
- Đăng bình luận (cần đăng nhập)
- Xóa bình luận của chính mình (icon ✕)
- Hiển thị avatar chữ cái đầu + thời gian relative ("5 phút trước")
- Chưa đăng nhập → hiện nút "Đăng nhập để bình luận"

**Vị trí UI:** Kéo xuống dưới danh sách chương trong màn hình chi tiết truyện

---

## Cấu trúc Firestore

```
truyen/{truyenID}
  ├── tenTruyen, tacGia, anhBia, moTa
  ├── soChuong (int - tổng số chương)
  ├── luotXem, danhGia, trangThai
  ├── chuongMienPhi, xuMoiChuong
  ├── chuong/{chuongID}
  │     ├── soChuong (double), tieuDe
  │     ├── trang: List<String> (URLs ảnh)
  │     └── ngayDang
  └── binhLuan/{binhLuanID}
        ├── uid, tenHienThi, noiDung
        └── taoLuc

nguoiDung/{uid}
  ├── email, tenHienThi, vaiTro
  ├── xu, chuongDaMua
  ├── thuVien/{truyenID}
  │     ├── truyenID, tenTruyen, anhBia
  │     ├── dangDoc: bool
  │     ├── yeuThich: bool
  │     └── capNhatLuc
  └── danhgia/ (rating)

theLoai/{id}
  └── ten
```

---

## Vai trò người dùng

| vaiTro | Quyền |
|---|---|
| `user` | Đọc truyện, mua chương, bình luận, yêu thích |
| `admin` | + Thêm/sửa/xóa truyện, chương, thể loại |

Đổi vai trò: Firestore Console → `nguoiDung/{uid}` → sửa field `vaiTro`
