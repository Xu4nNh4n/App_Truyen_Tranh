import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/AuthService.dart';
import '../models/ThuVien.dart';
import '../models/Truyen.dart';

// Controller quản lý thư viện truyện của người dùng
class ThuVienController {
  ThuVienController({AuthService? authService})
    : _authService = authService ?? AuthService();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService;

  // Lấy DocumentReference đến mục thư viện của truyện (null nếu chưa đăng nhập)
  DocumentReference? _docRef(String truyenID) {
    final user = _authService.firebaseUser;
    if (user == null) return null; // Chưa đăng nhập không có ref
    return _db
        .collection('nguoiDung')
        .doc(user.uid)
        .collection('thuVien')
        .doc(truyenID);
  }

  // Thêm truyện vào thư viện với trạng thái "yêu thích"
  Future<void> themVaoThuVien(Truyen truyen) async {
    final ref = _docRef(truyen.truyenID);
    if (ref == null) return;

    final doc = await ref.get();
    if (doc.exists) {
      // Document đã tồn tại → chỉ update yeuThich, KHÔNG đụng dangDoc
      await ref.update({
        'tenTruyen': truyen.tenTruyen,
        'anhBia': truyen.anhBia,
        'yeuThich': true,
        'capNhatLuc': FieldValue.serverTimestamp(),
      });
    } else {
      // Document chưa tồn tại → tạo mới với dangDoc: false
      await ref.set({
        'truyenID': truyen.truyenID,
        'tenTruyen': truyen.tenTruyen,
        'anhBia': truyen.anhBia,
        'yeuThich': true,
        'dangDoc': false,
        'capNhatLuc': FieldValue.serverTimestamp(),
      });
    }
  }

  // Xóa truyện khỏi danh sách yêu thích
  // Nếu đang đọc thì chỉ đặt yeuThich=false, không xóa document
  Future<void> xoaKhoiThuVien(String truyenID) async {
    final ref = _docRef(truyenID);
    if (ref == null) return;
    final doc = await ref.get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    final dangDoc = (data['dangDoc'] ?? false) as bool;
    if (dangDoc) {
      await ref.update({'yeuThich': false}); // Vẫn giữ document vì đang đọc
    } else {
      await ref.delete(); // Xóa hẳn nếu không đang đọc
    }
  }

  // Ghi nhận user đang đọc truyện (cập nhật thư viện "đang đọc")
  Future<void> ghiNhanDocTruyen(Truyen truyen) async {
    final ref = _docRef(truyen.truyenID);
    if (ref == null) return;
    await ref.set({
      'truyenID': truyen.truyenID,
      'tenTruyen': truyen.tenTruyen,
      'anhBia': truyen.anhBia,
      'dangDoc': true, // Đánh dấu đang đọc
      'capNhatLuc': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // merge để không xóa trạng thái 'yeuThich'
  }

  // Lắng nghe danh sách truyện yêu thích real-time
  Stream<List<ThuVienItem>> layYeuThich() {
    final user = _authService.firebaseUser;
    if (user == null) return const Stream.empty(); // Chưa đăng nhập
    return _db
        .collection('nguoiDung')
        .doc(user.uid)
        .collection('thuVien')
        .where('yeuThich', isEqualTo: true) // Chỉ lấy truyện yêu thích
        .snapshots()
        .map((s) => s.docs
            .map((d) => ThuVienItem.fromFirestore(d.data(), d.id))
            .toList());
  }

  // Lắng nghe danh sách truyện đang đọc real-time
  Stream<List<ThuVienItem>> layDangDoc() {
    final user = _authService.firebaseUser;
    if (user == null) return const Stream.empty();
    return _db
        .collection('nguoiDung')
        .doc(user.uid)
        .collection('thuVien')
        .where('dangDoc', isEqualTo: true) // Chỉ lấy truyện đang đọc
        .snapshots()
        .map((s) => s.docs
            .map((d) => ThuVienItem.fromFirestore(d.data(), d.id))
            .toList());
  }

  // Kiểm tra một truyện có trong danh sách yêu thích không
  Future<bool> kiemTraYeuThich(String truyenID) async {
    final ref = _docRef(truyenID);
    if (ref == null) return false;
    final doc = await ref.get();
    if (!doc.exists) return false;
    return ((doc.data() as Map<String, dynamic>)['yeuThich'] ?? false) as bool;
  }

  // Giữ tương thích với StoryDetailController
  Stream<List<ThuVienItem>> layThuVien() => layYeuThich();
}
