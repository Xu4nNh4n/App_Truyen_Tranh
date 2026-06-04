import 'package:cloud_firestore/cloud_firestore.dart';

// Model đại diện cho một bình luận truyện
class BinhLuan {
  BinhLuan({
    required this.id,
    required this.uid,
    required this.tenHienThi,
    required this.noiDung,
    required this.taoLuc,
  });

  final String id; // ID bình luận trên Firestore
  final String uid; // UID của người dùng đã bình luận
  final String tenHienThi; // Tên hiển thị của người bình luận
  final String noiDung; // Nội dung bình luận
  final DateTime taoLuc; // Thời điểm tạo bình luận

  // Chuyển đổi dữ liệu Firestore thành đối tượng BinhLuan
  factory BinhLuan.fromFirestore(Map<String, dynamic> data, String id) {
    return BinhLuan(
      id: id,
      uid: (data['uid'] ?? '') as String,
      tenHienThi: (data['tenHienThi'] ?? 'Ẩn danh') as String,
      noiDung: (data['noiDung'] ?? '') as String,
      taoLuc: _toDateTime(data['taoLuc']),
    );
  }

  // Hàm nội bộ: chuyển Timestamp/DateTime/null thành DateTime
  static DateTime _toDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate(); // Firestore Timestamp
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
