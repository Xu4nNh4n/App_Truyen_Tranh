# 📚 MangaHay — Ứng dụng Đọc Truyện Tranh

**MangaHay** là ứng dụng đọc truyện tranh mobile được xây dựng bằng **Flutter**, tích hợp **Firebase** làm backend. Ứng dụng hỗ trợ hệ thống xu để mở khóa chương trả phí, đọc truyện online với ảnh lưu trữ trên **Hugging Face Datasets**, và đầy đủ các tính năng quản trị nội dung.

---

## ✨ Tính Năng Nổi Bật

### 👤 Người Dùng
- **Đăng ký / Đăng nhập** bằng Email & Password qua Firebase Auth
- **Trang chủ** hiển thị danh sách truyện mới cập nhật
- **Tìm kiếm** truyện theo tên, tác giả hoặc thể loại
- **Thư viện cá nhân** lưu truyện yêu thích
- **Đọc truyện** dạng cuộn dọc (vertical scroll), hỗ trợ nhiều chế độ hiển thị
- **Đánh giá truyện** (1–5 sao) với tính toán điểm trung bình bằng Firestore Transaction
- **Bình luận** realtime trên trang chi tiết truyện
- **Hệ thống Xu (Coin)**: nạp xu và dùng xu để mở khóa chương trả phí
- **Hồ sơ cá nhân**: đổi ảnh đại diện, tên hiển thị, xem lịch sử xu
- **Dark / Light Mode**: tự động theo hệ thống hoặc chuyển thủ công

### 🛡️ Quản Trị (Admin)
- **Thêm / Sửa / Xóa** truyện và chương
- **Quản lý thể loại** (Genre)
- **Upload ảnh bìa** lên Firebase Storage
- **Liên kết ảnh chương** từ Hugging Face Datasets

---

## 🏗️ Kiến Trúc Dự Án

Dự án áp dụng mô hình **MVC-like** với sự phân tách rõ ràng giữa UI, logic và dữ liệu.

```
lib/
├── main.dart                  # Entry point, cấu hình theme & Firebase
├── firebase_options.dart      # Cấu hình Firebase theo từng platform
│
├── models/                    # Data models
│   ├── Truyen.dart            # Model bộ truyện
│   ├── Chuong.dart            # Model chương
│   ├── TheLoai.dart           # Model thể loại
│   ├── ThuVien.dart           # Model thư viện cá nhân
│   └── binh_luan.dart         # Model bình luận
│
├── services/                  # Tầng truy cập dữ liệu & logic nghiệp vụ
│   ├── FirestoreService.dart  # CRUD Firestore (truyện, chương, bình luận, thể loại)
│   ├── AuthService.dart       # Xác thực người dùng (Firebase Auth)
│   ├── CoinService.dart       # Quản lý xu: nạp, trừ, mở khóa chương
│   ├── StorageService.dart    # Upload ảnh lên Firebase Storage
│   └── hugging_face_service.dart # Lấy URL ảnh từ Hugging Face Datasets
│
├── controllers/               # Business logic & state management
│   ├── HomeController.dart
│   ├── AuthController.dart
│   ├── AdminController.dart
│   ├── ChiTietTruyenController.dart
│   ├── ReadingController.dart
│   ├── TimKiemController.dart
│   ├── ThuVienController.dart
│   ├── ProfileController.dart
│   ├── MainNavigationController.dart
│   ├── SplashController.dart
│   └── ChapterAccess.dart
│
├── screens/                   # Các màn hình UI
│   ├── splash_screen.dart     # Màn hình khởi động
│   ├── login_screen.dart      # Đăng nhập
│   ├── register_screen.dart   # Đăng ký
│   ├── main_navigation.dart   # Bottom navigation chính
│   ├── home_screen.dart       # Trang chủ
│   ├── search_screen.dart     # Tìm kiếm
│   ├── truyen_detail_screen.dart  # Chi tiết truyện
│   ├── doc_truyen_screen.dart     # Màn hình đọc truyện
│   ├── thu_vien_screen.dart       # Thư viện cá nhân
│   ├── all_stories_screen.dart    # Danh sách tất cả truyện
│   ├── profile_screen.dart        # Hồ sơ người dùng
│   └── admin_screen.dart          # Quản trị nội dung
│
├── widgets/                   # Các widget tái sử dụng
│   ├── truyen_card.dart           # Card hiển thị một bộ truyện
│   ├── chuong_list_tile.dart      # Item danh sách chương
│   ├── login_wall_overlay.dart    # Overlay yêu cầu đăng nhập
│   └── reading_settings_sheet.dart # Bottom sheet cài đặt đọc truyện
│
├── utils/                     # Tiện ích & cấu hình theme
│   └── themes.dart
│
├── processors/                # Xử lý dữ liệu bổ sung
│
└── icons/
    └── logo.png               # Logo ứng dụng
```

---

## 🛠️ Tech Stack

| Thành phần | Công nghệ |
|---|---|
| Framework | Flutter (Dart SDK ^3.12.0) |
| Authentication | Firebase Auth ^6.5.1 |
| Database | Cloud Firestore ^6.4.1 |
| File Storage | Firebase Storage ^13.4.1 |
| Image Storage | Hugging Face Datasets |
| Fonts | Google Fonts ^6.2.1 |
| Image Caching | cached_network_image ^3.4.1 |
| Local Storage | shared_preferences ^2.3.4 |
| HTTP Client | http ^1.2.2 |

---

## 🗄️ Cấu Trúc Dữ Liệu Firestore

```
Firestore
├── truyen/                        # Collection truyện
│   └── {truyenID}/
│       ├── tenTruyen, tacGia, theLoai[], anhBia, moTa
│       ├── soChuong, danhGia, ratingCount, trangThai, luotXem
│       ├── chuongMienPhi, xuMoiChuong
│       ├── taoLuc, capNhatLuc
│       │
│       ├── chuong/                # Sub-collection chương
│       │   └── {chuongID}/
│       │       ├── soChuong, tieuDe
│       │       └── trang[]        # Danh sách URL ảnh (Hugging Face path)
│       │
│       ├── danhgia/               # Sub-collection đánh giá
│       │   └── {uid}/
│       │       └── soSao, capNhatLuc
│       │
│       └── binhLuan/              # Sub-collection bình luận
│           └── {binhLuanID}/
│               └── uid, tenHienThi, noiDung, taoLuc
│
├── nguoiDung/                     # Collection người dùng
│   └── {uid}/
│       ├── xu                     # Số xu hiện có
│       └── chuongDaMua{}          # Map chương đã mở khóa
│
└── theLoai/                       # Collection thể loại
    └── {theLoaiID}/
        └── ten
```

---

## 💰 Hệ Thống Xu (Coin System)

Ứng dụng có hệ thống xu để kiếm tiền từ nội dung trả phí:

| Gói | Số xu | Giá |
|---|---|---|
| Gói 50 xu | 50 xu | 1,000 VND |
| Gói 100 xu | 100 xu | 2,000 VND |
| Gói 200 xu | 200 xu | 3,000 VND |

- **Chương miễn phí**: Mỗi bộ truyện có thể cấu hình số chương đọc miễn phí (`chuongMienPhi`).
- **Chương trả phí**: Người dùng dùng xu để mở khóa. Giao dịch được bảo vệ bằng **Firestore Transaction** để tránh race condition.
- **Đã mua = mãi mãi**: Sau khi mở khóa, chương được đánh dấu trong `chuongDaMua` của user, không bị trừ xu lần thứ hai.

---

## 🚀 Cài Đặt & Chạy Dự Án

### Yêu Cầu
- Flutter SDK >= 3.12.0
- Dart SDK >= 3.12.0
- Firebase project đã được tạo và cấu hình

### Các Bước

```bash
# 1. Clone repository
git clone <repo-url>
cd truyentranh

# 2. Cài đặt dependencies
flutter pub get

# 3. Chạy ứng dụng (debug)
flutter run
```

> **Lưu ý**: File `lib/firebase_options.dart` chứa cấu hình Firebase và không được commit lên git công khai. Bạn cần tự cấu hình Firebase project của mình bằng FlutterFire CLI:
> ```bash
> dart pub global activate flutterfire_cli
> flutterfire configure
> ```

---

## 📱 Các Màn Hình Chính

| Màn hình | Mô tả |
|---|---|
| Splash Screen | Kiểm tra trạng thái đăng nhập, điều hướng ban đầu |
| Home | Danh sách truyện mới cập nhật, banner nổi bật |
| Search | Tìm kiếm theo tên / thể loại / tác giả |
| Truyen Detail | Thông tin bộ truyện, danh sách chương, đánh giá, bình luận |
| Doc Truyen | Đọc truyện cuộn dọc, cài đặt hiển thị |
| Thu Vien | Truyện đã lưu của người dùng |
| Profile | Thông tin tài khoản, số xu, đổi ảnh đại diện |
| Admin | Quản lý truyện, chương, thể loại (chỉ admin) |

---

## 📄 License

Dự án này được phát triển phục vụ mục đích học tập và thực hành. Không dùng cho mục đích thương mại khi chưa có sự đồng ý của tác giả.
