import '../models/Truyen.dart';
import '../models/Chuong.dart';
import '../models/TheLoai.dart';
import '../processors/TruyenProcessor.dart';
import '../services/FirestoreService.dart';

// Controller quản lý nội dung cho Admin (truyện, chương, thể loại)
class AdminController {
  AdminController({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService; // Kết nối Firestore

  // ==== TRUYEN ====
  // Lắng nghe danh sách truyện real-time
  Stream<List<Truyen>> xemDanhSachTruyen() {
    return _firestoreService.layDanhSachTruyen();
  }

  // Thêm truyện mới từ form nhập liệu
  Future<void> themTruyen(TruyenMoiForm form) async {
    await _firestoreService.themTruyen(form.toTruyenMoi());
  }

  // Cập nhật thông tin truyện từ form
  Future<void> capNhatTruyen(Truyen truyen, TruyenMoiForm form) async {
    await _firestoreService.capNhatTruyen(form.toTruyenCapNhat(truyen));
  }

  // Xóa truyện khỏi Firestore
  Future<void> xoaTruyen(Truyen truyen) async {
    await _firestoreService.xoaTruyen(truyen.truyenID);
  }

  // ==== CHUONG ====
  // Lấy danh sách chương của một truyện
  Future<List<Chuong>> layChuong(String truyenID) async {
    return _firestoreService.layDanhSachChuong(truyenID);
  }

  // Cập nhật thông tin chương (chỉ các field được truyền vào)
  Future<void> capNhatChuong(
    String truyenID,
    String chuongID, {
    double? soChuong,
    String? tieuDe,
    List<String>? trang,
  }) async {
    await _firestoreService.capNhatChuong(
      truyenID,
      chuongID,
      soChuong: soChuong,
      tieuDe: tieuDe,
      trang: trang,
    );
  }

  // Xóa chương khỏi Firestore
  Future<void> xoaChuong(String truyenID, String chuongID) async {
    await _firestoreService.xoaChuong(truyenID, chuongID);
  }

  // Thêm chương mới, tự động gán số chương tiếp theo
  Future<void> themChuong(Truyen truyen, ChuongMoiForm form) async {
    await _firestoreService.themChuong(
      truyen.truyenID,
      form.toChuong(defaultSoChuong: (truyen.soChuong + 1).toDouble()),
    );
  }

  // ==== THE LOAI ====
  // Lắng nghe danh sách thể loại real-time
  Stream<List<TheLoai>> xemDanhSachTheLoai() {
    return _firestoreService.layDanhSachTheLoai();
  }

  // Thêm thể loại mới (tự trim khoảng trắng)
  Future<void> themTheLoai(String ten) async {
    await _firestoreService.themTheLoai(ten.trim());
  }

  // Cập nhật tên thể loại
  Future<void> capNhatTheLoai(TheLoai theLoai, String ten) async {
    await _firestoreService.capNhatTheLoai(theLoai.id, ten.trim());
  }

  // Xóa thể loại
  Future<void> xoaTheLoai(TheLoai theLoai) async {
    await _firestoreService.xoaTheLoai(theLoai.id);
  }
}

// ===== FORM DATA TRUYEN =====
// Dữ liệu nhập từ form để tạo hoặc cập nhật truyện
class TruyenMoiForm {
  const TruyenMoiForm({
    required this.tenTruyen,
    required this.tacGia,
    required this.moTa,
    required this.anhBia,
    required this.theLoai,
    required this.chuongMienPhi,
    required this.xuMoiChuong,
  });

  final String tenTruyen; // Tên truyện
  final String tacGia; // Tên tác giả
  final String moTa; // Mô tả nội dung
  final String anhBia; // URL ảnh bìa
  final List<String> theLoai; // Danh sách thể loại
  final int chuongMienPhi; // Số chương miễn phí
  final int xuMoiChuong; // Xu cần để mở mỗi chương

  // Kiểm tra form có hợp lệ không (tên truyện không rỗng)
  bool get isValid => tenTruyen.trim().isNotEmpty;

  // Tạo TruyenMoiForm từ các chuỗi văn bản nhập tay
  factory TruyenMoiForm.fromText({
    required String tenTruyen,
    required String tacGia,
    required String moTa,
    required String anhBia,
    required String theLoai,
    required String chuongMienPhi,
    required String xuMoiChuong,
  }) {
    final trimmedTacGia = tacGia.trim();
    return TruyenMoiForm(
      tenTruyen: tenTruyen.trim(),
      tacGia: trimmedTacGia.isEmpty
          ? 'Chua ro'
          : trimmedTacGia, // Mặc định nếu bỏ trống
      moTa: moTa.trim(),
      anhBia: anhBia.trim(),
      theLoai: TruyenProcessor.tachTheLoai(theLoai), // Tách từ chuỗi "a, b, c"
      chuongMienPhi:
          int.tryParse(chuongMienPhi) ?? 3, // Mặc định 3 chương miễn phí
      xuMoiChuong: int.tryParse(xuMoiChuong) ?? 5, // Mặc định 5 xu mỗi chương
    );
  }

  // Chuyển form thành đối tượng Truyen mới để thêm vào Firestore
  Truyen toTruyenMoi() {
    final now = DateTime.now();
    return Truyen(
      truyenID: '', // Firestore tự tạo ID
      tenTruyen: tenTruyen,
      tacGia: tacGia,
      theLoai: theLoai,
      anhBia: anhBia,
      moTa: moTa,
      soChuong: 0,
      danhGia: 0.0,
      ratingCount: 0,
      trangThai: 'Dang ra',
      luotXem: 0,
      chuongMienPhi: chuongMienPhi,
      xuMoiChuong: xuMoiChuong,
      taoLuc: now,
      capNhatLuc: now,
    );
  }

  // Chuyển form thành đối tượng Truyen cập nhật (giữ nguyên các field không đổi)
  Truyen toTruyenCapNhat(Truyen current) {
    return Truyen(
      truyenID: current.truyenID,
      tenTruyen: tenTruyen,
      tacGia: tacGia,
      theLoai: theLoai,
      anhBia: anhBia,
      moTa: moTa,
      soChuong: current.soChuong, // Giữ nguyên số chương
      danhGia: current.danhGia,
      ratingCount: current.ratingCount,
      trangThai: current.trangThai,
      luotXem: current.luotXem,
      chuongMienPhi: chuongMienPhi,
      xuMoiChuong: xuMoiChuong,
      taoLuc: current.taoLuc,
      capNhatLuc: DateTime.now(), // Cập nhật thời gian chỉnh sửa
      danhSachChuong: current.danhSachChuong,
    );
  }
}

// ===== FORM DATA CHUONG =====
// Dữ liệu nhập từ form để tạo chương mới
class ChuongMoiForm {
  const ChuongMoiForm({
    required this.soChuong,
    required this.tieuDe,
    required this.trang,
  });

  final double? soChuong; // Số chương (null nếu dùng mặc định)
  final String tieuDe; // Tiêu đề chương
  final List<String> trang; // Danh sách URL ảnh từng trang

  // Tạo form từ văn bản nhập tay (danh sách URL mỗi dòng một URL)
  factory ChuongMoiForm.fromText({
    required String soChuong,
    required String tieuDe,
    required String trang,
  }) {
    return ChuongMoiForm(
      soChuong: double.tryParse(soChuong),
      tieuDe: tieuDe.trim(),
      trang: TruyenProcessor.tachDong(trang), // Tách URL theo từng dòng
    );
  }

  // Tạo form từ URL GitHub (tự sinh URL từng trang theo pattern)
  factory ChuongMoiForm.fromGitHub({
    required String soChuong,
    required String tieuDe,
    required String baseUrl,
    required String soTrang,
    String extension = 'jpg',
  }) {
    final base = baseUrl.trim().replaceAll(RegExp(r'/+$'), ''); // Bỏ dấu / cuối
    final n = int.tryParse(soTrang.trim()) ?? 0; // Số trang
    // Sinh URL: base/1.jpg, base/2.jpg, ...
    final trang = List.generate(n, (i) => '$base/${i + 1}.$extension');
    return ChuongMoiForm(
      soChuong: double.tryParse(soChuong),
      tieuDe: tieuDe.trim(),
      trang: trang,
    );
  }

  // Chuyển form thành đối tượng Chuong để lưu vào Firestore
  Chuong toChuong({required double defaultSoChuong}) {
    return Chuong(
      id: '', // Firestore tự tạo ID
      soChuong: soChuong ?? defaultSoChuong, // Dùng mặc định nếu không nhập
      tieuDe: tieuDe,
      trang: trang,
      ngayDang: DateTime.now(),
    );
  }
}
