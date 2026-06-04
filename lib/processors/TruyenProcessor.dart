import 'package:truyentranh/models/Truyen.dart';

// Lớp tiện ích xử lý dữ liệu truyện (tìm kiếm, format, tách chuỗi)
class TruyenProcessor {
  //Định dạng thời gian "x phút trước", "x giờ trước", "x ngày trước"
  static String dinhDangThoiGian(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  // Tìm kiếm truyện theo tên/tác giả và lọc theo thể loại
  static List<Truyen> timKiemTruyen(
    List<Truyen> danhSach, {
    required String query,
    required Set<String> theLoaiDaChon,
  }) {
    final q = query.toLowerCase(); // Chuẩn hóa từ khóa tìm kiếm
    return danhSach.where((truyen) {
      final timKiemTen = truyen.tenTruyen.toLowerCase().contains(q); // Khớp tên truyện
      final timKiemTacGia = truyen.tacGia.toLowerCase().contains(q); // Khớp tên tác giả
      final timKiemTheLoai =
          theLoaiDaChon.isEmpty || // Không lọc nếu chưa chọn thể loại
          truyen.theLoai.any((g) => theLoaiDaChon.contains(g)); // Có thể loại được chọn
      if (q.isEmpty) {
        return timKiemTheLoai; // Nếu không có từ khóa, chỉ lọc theo thể loại
      }
      return (timKiemTen || timKiemTacGia) && timKiemTheLoai;
    }).toList();
  }

  // Tach the loai tu chuoi "a, b, c"
  static List<String> tachTheLoai(String input) {
    return input
        .split(',') // Tách theo dấu phẩy
        .map((e) => e.trim()) // Bỏ khoảng trắng hai đầu
        .where((e) => e.isNotEmpty) // Bỏ phần tử rỗng
        .toSet() // Loại bỏ trùng lặp
        .toList();
  }

  // Tach trang tu chuoi moi dong 1 trang
  static List<String> tachDong(String input) {
    return input
        .split('\n') // Tách theo xuống dòng
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty) // Bỏ dòng trống
        .toList();
  }
}
