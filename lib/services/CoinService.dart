import 'package:cloud_firestore/cloud_firestore.dart';
import 'AuthService.dart';

// Kết quả thao tác xu
class CoinResult {
  CoinResult({required this.thanhCong, this.loi});

  final bool thanhCong; // true nếu thao tác thành công
  final String? loi; // Thông báo lỗi nếu thất bại
}

// Gói nạp xu
class CoinPackage {
  CoinPackage({
    required this.ten,
    required this.xu,
    required this.id,
    required this.giaVnd,
  });

  final String ten; // Tên gói nạp
  final int xu; // Số xu nhận được
  final String id; // ID của gói nạp
  final int giaVnd; // Giá trong VND
}

// Service quản lý xu của người dùng
class CoinService {
  CoinService({AuthService? authService})
    : _authService = authService ?? AuthService();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService; // Dùng để lấy thông tin user hiện tại

  // Danh sách gói nạp xu có sẵn
  static final List<CoinPackage> packages = [
    CoinPackage(id: 'coins_50', ten: 'Gói 50 xu', xu: 50, giaVnd: 1),
    CoinPackage(id: 'coins_100', ten: 'Gói 100 xu', xu: 100, giaVnd: 2),
    CoinPackage(id: 'coins_200', ten: 'Gói 200 xu', xu: 200, giaVnd: 3),
  ];

  // Lắng nghe số xu của user theo thời gian thực
  Stream<int> layXu() {
    final user = _authService.firebaseUser;
    if (user == null) return const Stream.empty(); // Chưa đăng nhập

    return _db.collection('nguoiDung').doc(user.uid).snapshots().map((doc) {
      final data = doc.data();
      return (data?['xu'] ?? 0) as int;
    });
  }

  // ==== NAP XU ====
  // Cộng xu thẳng vào tài khoản
  Future<bool> napXu(CoinPackage goi) async {
    final user = _authService.firebaseUser;
    if (user == null) return false;

    final ref = _db.collection('nguoiDung').doc(user.uid);
    await ref.update({'xu': FieldValue.increment(goi.xu)});
    await _authService.taiLaiUser();
    return true;
  }

  // === Mở khóa chương ====
  // Trừ xu và đánh dấu chương đã mua bằng transaction
  Future<CoinResult> moKhoaChuong({
    required String truyenID,
    required String chuongID,
    required int xuCan,
  }) async {
    final user = _authService.firebaseUser;
    if (user == null) {
      return CoinResult(thanhCong: false, loi: 'Chưa đăng nhập');
    }

    final ref = _db.collection('nguoiDung').doc(user.uid);
    final key = '${truyenID}_$chuongID'; // Khóa định danh chương đã mua

    try {
      await _db.runTransaction((transaction) async {
        final doc = await transaction.get(ref);
        final data = doc.data() ?? {};
        final xuHienTai = (data['xu'] ?? 0) as int; // Xu hiện tại của user
        final chuongDaMua = Map<String, dynamic>.from(
          data['chuongDaMua'] ?? {},
        );

        if (chuongDaMua[key] == true) return; // đã mua rồi, không trừ xu nữa
        if (xuHienTai < xuCan) throw Exception('Không đủ xu');

        // Trừ xu và đánh dấu chương đã mua
        transaction.update(ref, {
          'xu': FieldValue.increment(-xuCan),
          'chuongDaMua.$key': true,
        });
      });
    } catch (e) {
      return CoinResult(
        thanhCong: false,
        loi: e.toString().replaceAll('Exception: ', ''),
      );
    }

    await _authService.taiLaiUser(); // Cập nhật cache sau giao dịch
    return CoinResult(thanhCong: true);
  }

  // ==== Kiểm tra nếu chương đã được mở khóa bởi user ====
  Future<bool> chuongDaMua(String truyenID, String chuongID) async {
    final user = _authService.firebaseUser;
    if (user == null) return false;

    final doc = await _db.collection('nguoiDung').doc(user.uid).get();
    final data = doc.data() ?? {};
    final map = Map<String, bool>.from(data['chuongDaMua'] ?? {});

    final key = '${truyenID}_$chuongID'; // Tạo khóa để kiểm tra
    return map[key] == true;
  }
}
