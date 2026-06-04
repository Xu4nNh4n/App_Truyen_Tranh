import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Truyen.dart';
import '../models/Chuong.dart';
import '../models/TheLoai.dart';
import '../models/binh_luan.dart';

// Service truy cập dữ liệu từ Firestore
class FirestoreService {
  //Kết nối Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Lắng nghe real-time một truyện theo ID
  Stream<Truyen> layTruyenTheoID(String truyenID) {
    return _db.collection('truyen').doc(truyenID).snapshots().map(
          (doc) => Truyen.fromFirestore(doc.data()!, doc.id),
        );
  }

  //Lấy danh sách truyện từ Firestore
  Stream<List<Truyen>> layDanhSachTruyen() {
    return _db
        .collection('truyen')
        .orderBy(
          'capNhatLuc',
          descending: true,
        ) // Sắp xếp theo thời gian cập nhật mới nhất
        .snapshots() // Lắng nghe thay đổi dữ liệu
        .map((snapshot) {
          // Chuyển đổi dữ liệu từ Firestore thành danh sách Truyen
          return snapshot.docs.map((doc) {
            return Truyen.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }

  // Lấy danh sách truyện 1 lần
  Future<List<Truyen>> layDanhSachTruyenMotLan() async {
    final snapshot =
        await _db
            .collection('truyen')
            .orderBy('capNhatLuc', descending: true)
            .get();
    return snapshot.docs
        .map((doc) => Truyen.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  //Lấy danh sách chương của truyện từ Firestore
  Future<List<Chuong>> layDanhSachChuong(String truyenID) async {
    final snapshot = await _db
        .collection('truyen')
        .doc(truyenID)
        .collection('chuong')
        .orderBy('soChuong') // Sắp xếp theo số chương tăng dần
        .get();
    return snapshot.docs
        .map((doc) => Chuong.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // Đánh giá truyện bằng transaction (tránh xung đột dữ liệu)
  Future<void> danhGiaTruyen({
    required String truyenID,
    required String uid,
    required double soSao,
  }) async {
    final truyenRef = _db.collection('truyen').doc(truyenID);
    final danhGiaRef = truyenRef.collection('danhgia').doc(uid);

    await _db.runTransaction((transaction) async {
      final truyenSnap = await transaction.get(truyenRef);
      if (!truyenSnap.exists) {
        throw Exception('Khong tim thay truyen');
      }
      final danhGiaSnap = await transaction.get(danhGiaRef);
      final truyenData = truyenSnap.data() as Map<String, dynamic>;
      final currentAvg = (truyenData['danhGia'] ?? 0.0).toDouble(); // Điểm trung bình hiện tại
      final currentCount = (truyenData['ratingCount'] ?? 0).toInt(); // Số lượt đánh giá

      // Lấy đánh giá cũ của user (nếu có) để tính lại trung bình
      final oldStars = danhGiaSnap.exists
          ? ((danhGiaSnap.data() as Map<String, dynamic>)['soSao'] ?? 0)
                .toDouble()
          : 0.0;
      final newCount = danhGiaSnap.exists ? currentCount : currentCount + 1;
      // Tính điểm trung bình mới
      final totalScore = currentAvg * currentCount - oldStars + soSao;
      final newAvg = newCount == 0 ? 0.0 : totalScore / newCount;

      // Lưu đánh giá của user và cập nhật truyện
      transaction.set(danhGiaRef, {
        'soSao': soSao,
        'capNhatLuc': Timestamp.now(),
      });
      transaction.update(truyenRef, {'danhGia': newAvg, 'ratingCount': newCount});
    });
  }

  // Lấy điểm đánh giá của một user cho một truyện
  Future<double?> layDanhGiaUser(String truyenID, String uid) async {
    final doc = await _db
        .collection('truyen')
        .doc(truyenID)
        .collection('danhgia')
        .doc(uid)
        .get();

    if (!doc.exists) return null;
    return (doc.data()?['soSao'] ?? 0).toDouble();
  }

  // ==== TRUYEN CRUD ====
  // Thêm truyện mới vào Firestore
  Future<void> themTruyen(Truyen truyen) async {
    await _db.collection('truyen').add(truyen.toMap());
  }

  // Cập nhật thông tin truyện
  Future<void> capNhatTruyen(Truyen truyen) async {
    await _db.collection('truyen').doc(truyen.truyenID).update(truyen.toMap());
  }

  // Xóa truyện khỏi Firestore
  Future<void> xoaTruyen(String truyenID) async {
    await _db.collection('truyen').doc(truyenID).delete();
  }

  // Tăng lượt xem của truyện thêm 1
  Future<void> tangLuotXem(String truyenID) async {
    await _db.collection('truyen').doc(truyenID).update({
      'luotXem': FieldValue.increment(1),
    });
  }

  // Cập nhật thông tin một chương (chỉ cập nhật các field được truyền vào)
  Future<void> capNhatChuong(
    String truyenID,
    String chuongID, {
    double? soChuong,
    String? tieuDe,
    List<String>? trang,
  }) async {
    final Map<String, dynamic> data = {};
    if (soChuong != null) data['soChuong'] = soChuong;
    if (tieuDe != null) data['tieuDe'] = tieuDe;
    if (trang != null) data['trang'] = trang;
    if (data.isEmpty) return; // Không có gì để cập nhật
    await _db
        .collection('truyen')
        .doc(truyenID)
        .collection('chuong')
        .doc(chuongID)
        .update(data);
  }

  // Xóa chương và giảm soChuong của truyện
  Future<void> xoaChuong(String truyenID, String chuongID) async {
    await _db
        .collection('truyen')
        .doc(truyenID)
        .collection('chuong')
        .doc(chuongID)
        .delete();
    // Giảm soChuong và cập nhật thời gian
    await _db.collection('truyen').doc(truyenID).update({
      'soChuong': FieldValue.increment(-1),
      'capNhatLuc': FieldValue.serverTimestamp(),
    });
  }

  // Thêm chương mới và tăng soChuong của truyện
  Future<void> themChuong(String truyenID, Chuong chuong) async {
    await _db
        .collection('truyen')
        .doc(truyenID)
        .collection('chuong')
        .add(chuong.toMap());

    // tang soChuong tren truyen
    await _db.collection('truyen').doc(truyenID).update({
      'soChuong': FieldValue.increment(1),
      'capNhatLuc': FieldValue.serverTimestamp(),
    });
  }

  // ==== BINH LUAN ====
  // Lắng nghe danh sách bình luận real-time (mới nhất trước)
  Stream<List<BinhLuan>> layBinhLuan(String truyenID) {
    return _db
        .collection('truyen')
        .doc(truyenID)
        .collection('binhLuan')
        .orderBy('taoLuc', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => BinhLuan.fromFirestore(d.data(), d.id))
            .toList());
  }

  // Thêm bình luận mới vào truyện
  Future<void> themBinhLuan(
    String truyenID,
    String uid,
    String tenHienThi,
    String noiDung,
  ) async {
    await _db
        .collection('truyen')
        .doc(truyenID)
        .collection('binhLuan')
        .add({
      'uid': uid,
      'tenHienThi': tenHienThi,
      'noiDung': noiDung,
      'taoLuc': FieldValue.serverTimestamp(), // Dùng server time để đồng bộ
    });
  }

  // Xóa một bình luận
  Future<void> xoaBinhLuan(String truyenID, String binhLuanID) async {
    await _db
        .collection('truyen')
        .doc(truyenID)
        .collection('binhLuan')
        .doc(binhLuanID)
        .delete();
  }

  // ==== THE LOAI ====
  // Lắng nghe danh sách thể loại real-time
  Stream<List<TheLoai>> layDanhSachTheLoai() {
    return _db.collection('theLoai').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TheLoai.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Thêm thể loại mới
  Future<void> themTheLoai(String ten) async {
    await _db.collection('theLoai').add({'ten': ten});
  }

  // Cập nhật tên thể loại
  Future<void> capNhatTheLoai(String id, String tenMoi) async {
    await _db.collection('theLoai').doc(id).update({'ten': tenMoi});
  }

  // Xóa thể loại
  Future<void> xoaTheLoai(String id) async {
    await _db.collection('theLoai').doc(id).delete();
  }
}
