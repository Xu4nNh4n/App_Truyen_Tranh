import 'package:flutter/material.dart';

// === MAU SAC CHINH CUA APP ===
class AppColors {
  // Gradient chinh - tong tim xanh premium
  static const Color primaryDark = Color(0xFF1A1A2E); // Nền tối chính
  static const Color primaryMid = Color(0xFF16213E); // Nền tối trung
  static const Color primaryLight = Color(0xFF0F3460); // Nền tối sáng hơn
  static const Color accent = Color(0xFFE94560); // Màu nhấn đỏ hồng

  // Gradient phu
  static const Color gradientStart = Color(
    0xFF667EEA,
  ); // Xanh tím bắt đầu gradient
  static const Color gradientEnd = Color(0xFF764BA2); // Tím kết thúc gradient

  // Mau nen doc truyen
  static const Color readingWhite = Color(0xFFFAFAFA); // Nền trắng
  static const Color readingSepia = Color(0xFFF5E6CA); // Nền sepia (vàng nhạt)
  static const Color readingDark = Color(0xFF1E1E1E); // Nền tối
  static const Color readingGreen = Color(0xFFCCE8CF); // Nền xanh lá nhạt

  // Mau chu doc truyen
  static const Color textOnWhite = Color(0xFF2D2D2D); // Chữ trên nền trắng
  static const Color textOnSepia = Color(0xFF5B4636); // Chữ trên nền sepia
  static const Color textOnDark = Color(0xFFD4D4D4); // Chữ trên nền tối
  static const Color textOnGreen = Color(0xFF2D4A30); // Chữ trên nền xanh

  // Mau phu tro
  static const Color starGold = Color(0xFFFFD700); // Màu vàng ngôi sao đánh giá
  static const Color success = Color(0xFF4CAF50); // Màu xanh thành công
  static const Color cardDark = Color(0xFF252540); // Nền card ở chế độ tối
  static const Color shimmerBase = Color(0xFF2A2A40); // Màu nền shimmer loading
  static const Color shimmerHighlight = Color(
    0xFF3A3A50,
  ); // Màu sáng shimmer loading
}

// === KICH THUOC CHU ===
class AppFontSizes {
  static const double small = 12.0; // Chữ nhỏ (nhãn, chú thích)
  static const double body = 14.0; // Chữ thân bài thông thường
  static const double medium = 16.0; // Chữ vừa
  static const double large = 18.0; // Chữ lớn
  static const double title = 20.0; // Tiêu đề section
  static const double heading = 24.0; // Tiêu đề lớn
  static const double hero = 32.0; // Chữ hero (rất lớn)
}

// === KHOANG CACH ===
class AppSpacing {
  static const double xs = 4.0; // Khoảng cách rất nhỏ
  static const double sm = 8.0; // Khoảng cách nhỏ
  static const double md = 12.0; // Khoảng cách vừa
  static const double lg = 16.0; // Khoảng cách lớn (phổ biến nhất)
  static const double xl = 24.0; // Khoảng cách rất lớn
  static const double xxl = 32.0; // Khoảng cách cực lớn
  static const double xxxl = 48.0; // Khoảng cách tối đa
}

// === BO TRON ===
class AppRadius {
  static const double sm = 8.0; // Bo tròn nhỏ
  static const double md = 12.0; // Bo tròn vừa
  static const double lg = 16.0; // Bo tròn lớn
  static const double xl = 24.0; // Bo tròn rất lớn
  static const double full = 999.0; // Bo tròn hoàn toàn (pill shape)
}

// === CHUOI KY TU ===
class AppStrings {
  static const String appName = 'MangaHay'; // Tên ứng dụng
  static const String home = 'Trang Chủ';
  static const String library = 'Thư Viện';
  static const String profile = 'Cá Nhân';
  static const String hotStories = 'Truyện Hot 🔥';
  static const String newUpdates = 'Mới Cập Nhật';
  static const String featured = 'Truyện Đề Xuất';
  static const String readNow = 'Đọc Ngay';
  static const String addToLibrary = 'Thêm vào Thư Viện';
  static const String chapters = 'Danh Sách Chương';
  static const String search = 'Tìm kiếm truyện tranh...';
  static const String ongoing = 'Đang ra';
  static const String completed = 'Hoàn thành';
  static const String reading = 'Đang đọc';
  static const String favorites = 'Yêu thích';
  static const String finished = 'Đã đọc xong';

  // Auth strings
  static const String login = 'Đăng Nhập';
  static const String register = 'Đăng Ký';
  static const String logout = 'Đăng Xuất';
  static const String username = 'Tên tài khoản';
  static const String password = 'Mật khẩu';
  static const String confirmPassword = 'Xác nhận mật khẩu';
  static const String loginRequired = 'Đăng nhập để tiếp tục đọc';
  static const String loginSubtitle = 'Đăng nhập vào tài khoản của bạn';
  static const String registerSubtitle = 'Tạo tài khoản mới để bắt đầu';
  static const String noAccount = 'Chưa có tài khoản?';
  static const String hasAccount = 'Đã có tài khoản?';
  static const String registerNow = 'Đăng ký ngay';
  static const String loginNow = 'Đăng nhập ngay';
  static const String guest = 'Khách';
  static const String vipContent = 'Mở khóa nội dung'; // Tiêu đề màn hình khóa
  static const String unlockContent =
      'Mở khóa toàn bộ nội dung truyện bằng cách đăng nhập hoặc tạo tài khoản miễn phí.';

  static const String dangHot = 'Đang Hot 🔥';
  static const String trendingToday = '24 giờ';
  static const String trendingWeek = '7 ngày';
  static const String theLoai = 'Thể Loại';
  static const String truyenNoiBat = 'Truyện Nổi Bật ⭐';
  static const String resetFilter = 'Xóa lọc';
  static const String noResults = 'Không tìm thấy truyện phù hợp';
  static const String tryResetFilter = 'Thử xóa bộ lọc để xem tất cả truyện';
}
