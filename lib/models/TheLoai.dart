// Model đại diện cho một thể loại truyện
class TheLoai {
  TheLoai({required this.id, required this.ten});

  final String id; // ID thể loại trên Firestore
  final String ten; // Tên thể loại (vd: "Hành động", "Lãng mạn")

  // Chuyển đổi dữ liệu Firestore thành đối tượng TheLoai
  factory TheLoai.fromFirestore(Map<String, dynamic> data, String id) {
    return TheLoai(id: id, ten: (data['ten'] ?? '') as String);
  }

  // Chuyển đổi đối tượng thành Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {'ten': ten};
  }
}
