// Model đại diện cho một mục trong thư viện của người dùng
class ThuVienItem {
  ThuVienItem({
    required this.truyenID,
    required this.tenTruyen,
    required this.anhBia,
    required this.yeuThich,
    required this.dangDoc,
    required this.capNhatLuc,
  });

  final String truyenID; // ID truyện được lưu
  final String tenTruyen; // Tên truyện (cache lại để hiển thị nhanh)
  final String anhBia; // URL ảnh bìa (cache lại)
  final bool yeuThich; // Người dùng đã thêm vào yêu thích chưa
  final bool dangDoc; // Người dùng đang đọc truyện này chưa
  final DateTime capNhatLuc; // Lần cuối cập nhật trạng thái

  // Chuyển đổi dữ liệu Firestore thành đối tượng ThuVienItem
  factory ThuVienItem.fromFirestore(Map<String, dynamic> data, String id) {
    return ThuVienItem(
      truyenID: (data['truyenID'] ?? id) as String,
      tenTruyen: (data['tenTruyen'] ?? '') as String,
      anhBia: (data['anhBia'] ?? '') as String,
      yeuThich: (data['yeuThich'] ?? false) as bool,
      dangDoc: (data['dangDoc'] ?? false) as bool,
      capNhatLuc: _toDateTime(data['capNhatLuc']),
    );
  }

  // Hàm nội bộ: chuyển giá trị thô thành DateTime
  static DateTime _toDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }
}
