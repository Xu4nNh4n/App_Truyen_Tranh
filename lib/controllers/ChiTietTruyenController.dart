import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/Truyen.dart';
import '../models/Chuong.dart';
import '../services/FirestoreService.dart';
import '../services/AuthService.dart';
import '../services/CoinService.dart';
import 'ThuVienController.dart';

// Controller quản lý màn hình chi tiết truyện
class StoryDetailController extends ChangeNotifier {
  StoryDetailController({
    required this.truyen,
    FirestoreService? firestoreService,
    AuthService? authService,
    CoinService? coinService,
    ThuVienController? thuVienController,
  }) : _firestoreService = firestoreService ?? FirestoreService(),
       authService = authService ?? AuthService(),
       _coinService = coinService ?? CoinService(),
       _thuVienController = thuVienController ?? ThuVienController();

  Truyen truyen; // Thông tin truyện hiện tại
  final FirestoreService _firestoreService;
  final AuthService authService; // Public để màn hình có thể truy cập user
  final CoinService _coinService;
  final ThuVienController _thuVienController;
  StreamSubscription<Truyen>? _truyenSub; // Subscription lắng nghe real-time

  // ==== STATE ====
  bool dangTaiChuong = true; // Đang tải danh sách chương
  bool moMoTa = false; // Trạng thái mở rộng/thu gọn mô tả
  List<Chuong> danhSachChuong = []; // Danh sách chương đã tải
  bool yeuThich = false; // Truyện này có trong thư viện yêu thích không

  // rating
  double? danhGiaCuaToi; // Điểm đánh giá của user hiện tại
  bool dangGuiDanhGia = false; // Đang gửi đánh giá lên server

  // ==== LOAD CHUONG ====
  Future<void> taiDanhSachChuong() async {
    // Lắng nghe thay đổi real-time của truyen (danhGia, ratingCount, luotXem...)
    _truyenSub = _firestoreService
        .layTruyenTheoID(truyen.truyenID)
        .listen((updatedTruyen) {
      truyen = updatedTruyen; // Cập nhật dữ liệu mới nhất
      notifyListeners();
    });

    try {
      // Tải song song: danh sách chương và trạng thái yêu thích
      final results = await Future.wait([
        _firestoreService.layDanhSachChuong(truyen.truyenID),
        _thuVienController.kiemTraYeuThich(truyen.truyenID),
      ]);
      danhSachChuong = results[0] as List<Chuong>;
      yeuThich = results[1] as bool;
    } catch (_) {
      danhSachChuong = []; // Lỗi thì để danh sách rỗng
    } finally {
      dangTaiChuong = false; // Tắt loading dù thành công hay lỗi
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _truyenSub?.cancel(); // Hủy subscription khi widget bị destroy
    super.dispose();
  }

  // ==== TOGGLE MO TA ====
  // Chuyển đổi trạng thái mở rộng/thu gọn mô tả
  void doiTrangThaiMoTa() {
    moMoTa = !moMoTa;
    notifyListeners();
  }

  // ==== YEU THICH ====
  // Thêm/xóa truyện khỏi thư viện yêu thích
  Future<void> doiYeuThich() async {
    yeuThich = !yeuThich;
    notifyListeners(); // Cập nhật UI ngay lập tức
    if (yeuThich) {
      await _thuVienController.themVaoThuVien(truyen);
    } else {
      await _thuVienController.xoaKhoiThuVien(truyen.truyenID);
    }
  }

  // ==== KIEM TRA QUYEN DOC ====
  // Kiểm tra chương tại chỉ số có bị khóa không
  bool laChuongBiKhoa(int chiSoChuong) {
    if (chiSoChuong < truyen.chuongMienPhi) return false; // Chương miễn phí
    if (!authService.daDangNhap) return true; // Chưa đăng nhập thì khóa hết
    if (chiSoChuong >= danhSachChuong.length) return true;
    final chuong = danhSachChuong[chiSoChuong];
    final key = '${truyen.truyenID}_${chuong.id}';
    return authService.chuongDaMua[key] != true; // Chưa mua thì bị khóa
  }

  // ==== MO KHOA CHUONG ====
  // Dùng xu để mở khóa chương trả phí
  Future<CoinResult> unlockChuong(int chiSoChuong) async {
    if (chiSoChuong >= danhSachChuong.length) {
      return CoinResult(thanhCong: false, loi: 'Chuong khong ton tai');
    }
    final chuong = danhSachChuong[chiSoChuong];
    final result = await _coinService.moKhoaChuong(
      truyenID: truyen.truyenID,
      chuongID: chuong.id,
      xuCan: truyen.xuMoiChuong,
    );
    if (result.thanhCong) {
      await authService.taiLaiUser(); // Cập nhật cache sau mua
      notifyListeners();
    }
    return result;
  }

  // ==== RATING ====
  // Tải điểm đánh giá của user hiện tại cho truyện này
  Future<void> taiDanhGiaUser(String uid) async {
    danhGiaCuaToi = await _firestoreService.layDanhGiaUser(
      truyen.truyenID,
      uid,
    );
    notifyListeners();
  }

  // Gửi đánh giá sao lên Firestore
  Future<void> guiDanhGia(String uid, double soSao) async {
    dangGuiDanhGia = true;
    notifyListeners();

    await _firestoreService.danhGiaTruyen(
      truyenID: truyen.truyenID,
      uid: uid,
      soSao: soSao,
    );

    danhGiaCuaToi = soSao; // Cập nhật điểm đánh giá cục bộ
    dangGuiDanhGia = false;
    notifyListeners();
  }
}
