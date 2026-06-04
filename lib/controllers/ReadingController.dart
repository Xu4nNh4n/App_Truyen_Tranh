import 'package:flutter/material.dart';
import '../models/Truyen.dart';
import '../models/Chuong.dart';
import '../services/AuthService.dart';
import '../services/CoinService.dart';
import '../services/FirestoreService.dart';
import 'ChapterAccess.dart';
import 'ThuVienController.dart';

// Controller quản lý trạng thái và logic màn hình đọc truyện
class ReadingController {
  ReadingController({
    required this.truyen,
    required int chiSoChuongBanDau,
    AuthService? authService,
    CoinService? coinService,
    FirestoreService? firestoreService,
    ThuVienController? thuVienController,
  }) : chiSoChuongHienTai = chiSoChuongBanDau,
       _authService = authService ?? AuthService(),
       _coinService = coinService ?? CoinService(),
       _firestoreService = firestoreService ?? FirestoreService(),
       _thuVienController = thuVienController ?? ThuVienController();

  final Truyen truyen; // Truyện đang đọc (có kèm danh sách chương)
  final AuthService _authService;
  final CoinService _coinService;
  final FirestoreService _firestoreService;
  final ThuVienController _thuVienController;
  final Set<String> _chuongDaXem =
      {}; // Theo dõi chương đã xem để tránh tăng lượt xem nhiều lần

  // ==== STATE DOC TRUYEN ====
  int chiSoChuongHienTai; // Chỉ số chương đang đọc
  bool hienThanhDieuKhien = true; // Hiện/ẩn thanh AppBar và BottomBar
  double tienDoDoc = 0.0; // Tiến trình đọc từ 0.0 đến 1.0
  Color mauNen = Colors.black; // Màu nền trang đọc
  bool fitWidth = true; // Ảnh khớp chiều rộng màn hình hay không
  int trangHienTai = 1; // Số trang hiện tại đang hiển thị

  // ==== GETTER ====
  Chuong get chuongHienTai =>
      truyen.danhSachChuong[chiSoChuongHienTai]; // Chương đang đọc
  bool get coChuongTruoc => chiSoChuongHienTai > 0; // Có chương trước không
  bool get coChuongSau =>
      chiSoChuongHienTai <
      truyen.danhSachChuong.length - 1; // Có chương sau không

  // Cap nhat tien do doc (UI tu tinh scroll)
  void capNhatTienDo(double progress, int tongTrang) {
    if (tongTrang == 0) return;
    tienDoDoc = progress.clamp(0.0, 1.0); // Giới hạn trong khoảng [0, 1]
    trangHienTai = (progress * tongTrang).ceil().clamp(
      1,
      tongTrang,
    ); // Tính trang hiện tại
  }

  // Chuyển đổi trạng thái hiện/ẩn thanh điều khiển
  void doiTrangThaiHienThanh() {
    hienThanhDieuKhien = !hienThanhDieuKhien;
  }

  // Kiểm tra quyền đọc chương: có thể đọc, cần đăng nhập, hay cần mở khóa
  ChapterAccessAction kiemTraQuyenDoc(int chiSoChuong) {
    if (chiSoChuong < 0 || chiSoChuong >= truyen.danhSachChuong.length) {
      return ChapterAccessAction.moKhoa; // Chỉ số không hợp lệ
    }

    final chuong = truyen.danhSachChuong[chiSoChuong];
    final coTheDoc = _authService.coTheDocChuong(
      chiSoChuong,
      chuongMienPhi: truyen.chuongMienPhi,
      truyenID: truyen.truyenID,
      chuongID: chuong.id,
    );

    if (coTheDoc) return ChapterAccessAction.doc; // Được phép đọc
    // Chưa đăng nhập thì yêu cầu đăng nhập, đã đăng nhập thì yêu cầu mở khóa
    return _authService.daDangNhap
        ? ChapterAccessAction.moKhoa
        : ChapterAccessAction.dangNhap;
  }

  // Kiểm tra nhanh chương có bị khóa không
  bool laChuongBiKhoa(int chiSoChuong) {
    return kiemTraQuyenDoc(chiSoChuong) != ChapterAccessAction.doc;
  }

  // Chuyển sang chương mới và reset tiến trình đọc
  void chuyenChuong(int chiSoChuong) {
    chiSoChuongHienTai = chiSoChuong;
    tienDoDoc = 0.0; // Reset tiến trình
    trangHienTai = 1;
    ghiNhanXemChuong(chiSoChuong); // Ghi nhận lượt xem
  }

  // Ghi nhận lượt xem chương (chỉ tính 1 lần mỗi chương trong phiên đọc)
  void ghiNhanXemChuong(int chiSoChuong) {
    if (chiSoChuong < 0 || chiSoChuong >= truyen.danhSachChuong.length) return;
    final chuongID = truyen.danhSachChuong[chiSoChuong].id;
    if (_chuongDaXem.contains(chuongID)) return; // Đã xem rồi, bỏ qua
    _chuongDaXem.add(chuongID); // Đánh dấu đã xem
    _firestoreService.tangLuotXem(truyen.truyenID); // Tăng lượt xem truyện
    _thuVienController.ghiNhanDocTruyen(truyen); // Ghi vào thư viện "đang đọc"
    _authService.danhDauDaDoc(
      truyen.truyenID,
      chuongID,
    ); // Ghi nhận đã đọc chương này
  }

  // Đổi màu nền trang đọc
  void doiMauNen(Color color) {
    mauNen = color;
  }

  // Bật/tắt chế độ ảnh khớp chiều rộng màn hình
  void doiFitWidth(bool value) {
    fitWidth = value;
  }

  // Dùng xu để mở khóa chương đang cố đọc
  Future<CoinResult> moKhoaChuong(int chiSoChuong) async {
    final chuong = truyen.danhSachChuong[chiSoChuong];
    final result = await _coinService.moKhoaChuong(
      truyenID: truyen.truyenID,
      chuongID: chuong.id,
      xuCan: truyen.xuMoiChuong,
    );

    if (result.thanhCong) {
      await _authService.taiLaiUser(); // Cập nhật cache sau khi mua
    }

    return result;
  }
}
