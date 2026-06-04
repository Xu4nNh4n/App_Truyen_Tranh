// Model đại diện cho một chương truyện
class Chuong {
  Chuong({
    required this.id,
    required this.soChuong,
    required this.tieuDe,
    required this.trang,
    required this.ngayDang,
  });

  final String id; // ID chương trên Firestore
  final double soChuong; // Số chương (dùng double để hỗ trợ chương 1.5...)
  final String tieuDe; // Tiêu đề chương
  final List<String> trang; // Danh sách URL ảnh từng trang
  final DateTime ngayDang; // Ngày đăng chương

  // Hiển thị số chương dạng chuỗi (bỏ .0 nếu là số nguyên)
  String get soChuongText =>
      soChuong % 1 == 0 ? soChuong.toInt().toString() : soChuong.toString();

  // Chuyển đổi dữ liệu Firestore thành đối tượng Chuong
  factory Chuong.fromFirestore(Map<String, dynamic> data, String id) {
    return Chuong(
      id: id,
      soChuong: (data['soChuong'] ?? 0).toDouble(),
      tieuDe: (data['tieuDe'] ?? '') as String,
      trang: List<String>.from(data['trang'] ?? []),
      ngayDang: _toDateTime(data['ngayDang']),
    );
  }

  // Chuyển đổi đối tượng thành Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'soChuong': soChuong,
      'tieuDe': tieuDe,
      'trang': trang,
      'ngayDang': ngayDang,
    };
  }

  // Hàm nội bộ: chuyển giá trị thô thành DateTime
  static DateTime _toDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }
}
