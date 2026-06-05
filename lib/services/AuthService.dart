import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Lớp chứa kết quả đăng nhập/đăng ký
class AuthResult {
  AuthResult({required this.thanhCong, this.loi}); // Kết quả đăng nhập/đăng ký

  final bool thanhCong; // true nếu thành công
  final String? loi; // Thông báo lỗi nếu thất bại
}

// Service xử lý xác thực người dùng (Singleton)
class AuthService {
  // Singleton pattern: chỉ tạo một instance duy nhất
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  final FirebaseFirestore _db =
      FirebaseFirestore.instance; // Firestore instance

  // Getter: lấy thông tin user hiện tại
  User? get firebaseUser => _auth.currentUser;
  bool get daDangNhap => firebaseUser != null; // Kiểm tra đã đăng nhập chưa

  //Thông tin user cache
  String tenHienThi = ''; // Tên hiển thị của user
  String vaiTro = 'user'; // Vai trò: 'user' hoặc 'admin'
  int xu = 0; // Số xu hiện có
  Map<String, dynamic> chuongDaMua = {}; // Map các chương đã mua khóa
  Map<String, bool> chuongDaDoc = {};
  // Khởi tạo service: tải thông tin user từ Firestore
  Future<void> init() async {
    await taiLaiUser();
  }

  // Đăng nhập bằng email và mật khẩu
  Future<AuthResult> dangNhap(String email, String matKhau) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: matKhau);
      await taiLaiUser(); // Cập nhật cache sau khi đăng nhập
      return AuthResult(thanhCong: true);
    } catch (e) {
      return AuthResult(thanhCong: false, loi: e.toString());
    }
  }

  // Đăng ký tài khoản mới
  Future<AuthResult> dangKy(String email, String matKhau, {String? ten}) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: matKhau,
      );

      final uid = cred.user!.uid;

      // Tao document user moi
      await _db.collection('nguoiDung').doc(uid).set({
        'uid': uid,
        'email': email,
        'tenHienThi': ten ?? '',
        'vaiTro': 'user',
        'xu': 100, // tang 100 xu khi dang ky
        'chuongDaMua': {},
        'taoLuc': DateTime.now(),
      });

      await taiLaiUser(); // Cập nhật cache sau khi đăng ký
      return AuthResult(thanhCong: true);
    } catch (e) {
      return AuthResult(thanhCong: false, loi: e.toString());
    }
  }

  // Đăng xuất khỏi tài khoản
  Future<void> dangXuat() async {
    await _auth.signOut();
    tenHienThi = '';
    vaiTro = 'user';
    xu = 0;
    chuongDaMua = {};
    chuongDaDoc = {};
  }

  // Tải lại thông tin user từ Firestore vào cache
  Future<void> taiLaiUser() async {
    final user = firebaseUser;
    if (user == null) return; // Chưa đăng nhập thì bỏ qua

    final doc = await _db.collection('nguoiDung').doc(user.uid).get();
    if (!doc.exists) return; // Document không tồn tại thì bỏ qua

    final data = doc.data()!;
    tenHienThi = (data['tenHienThi'] ?? '') as String;
    vaiTro = (data['vaiTro'] ?? 'user') as String;
    xu = (data['xu'] ?? 0) as int;

    // Cập nhật danh sách chương đã mua
    final map = data['chuongDaMua'] ?? {};
    chuongDaMua = Map<String, bool>.from(map);
    // Cập nhật danh sách chương đã đọc
    final mapDoc = data['chuongDaDoc'] ?? {};
    chuongDaDoc = Map<String, bool>.from(mapDoc);
  }

  // Kiểm tra user có thể đọc chương không (miễn phí hoặc đã mua)
  bool coTheDocChuong(
    int chiSoChuong, {
    required int chuongMienPhi,
    required String truyenID,
    required String chuongID,
  }) {
    if (chiSoChuong < chuongMienPhi) return true; // Chương miễn phí
    if (!daDangNhap) return false; // Chưa đăng nhập không đọc được

    // Kiểm tra chương này đã được mua chưa
    final key = '${truyenID}_$chuongID';
    return chuongDaMua[key] == true;
  }

  Future<void> danhDauDaDoc(String truyenID, String chuongID) async {
    final user = firebaseUser;
    if (user == null) return; // Chưa đăng nhập thì bỏ qua
    final key = '${truyenID}_$chuongID';
    chuongDaDoc[key] = true; // Cập nhật cache
    await _db.collection('nguoiDung').doc(user.uid).update({
      'chuongDaDoc.$key': true, // Cập nhật Firestore
    });
  }

  bool daDocChuong(String truyenID, String chuongID) {
    return chuongDaDoc['${truyenID}_$chuongID'] == true;
  }
}
