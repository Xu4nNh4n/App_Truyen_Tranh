import 'package:flutter/foundation.dart';
import '../models/Truyen.dart';
import '../processors/TruyenProcessor.dart';
import '../services/FirestoreService.dart';

// Controller quản lý trạng thái và logic màn hình tìm kiếm
class TimKiemController extends ChangeNotifier {
  TimKiemController({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();
  final FirestoreService _firestoreService;

  //==== STATE(Trạng thái) cho giao diện ====
  bool isMoNangCao = false; // Trạng thái của bộ lọc nâng cao
  bool daTimKiem = false; // Đã thực hiện tìm kiếm hay chưa
  final Set<String> theLoaiDaChon =
      {}; // Các thể loại đã chọn trong bộ lọc nâng cao
  List<String> tatCaTheLoai = []; // Danh sách tất cả thể loại có trong dữ liệu
  List<Truyen> goiY = []; // Kết quả gợi ý khi người dùng nhập từ khóa
  List<Truyen> _tatCaTruyen = []; // danh sách truyện load 1 lần để tìm kiếm

  //==== Load data ban đầu ====
  Future<void> loadDuLieuBanDau() async {
    await _taiTruyen();    // load truyện trước
    await _taiTheLoai();   // rồi mới gom thể loại từ truyện đã load
    notifyListeners();
  }

  // Tìm kiếm truyện theo từ khóa và bộ lọc thể loại
  void timKiem(String query) {
    final q = query.trim();
    daTimKiem =
        q.isNotEmpty ||
        theLoaiDaChon.isNotEmpty; // Cập nhật trạng thái đã tìm kiếm

    // Gọi processor để lọc danh sách truyện
    goiY = TruyenProcessor.timKiemTruyen(
      _tatCaTruyen,
      query: q,
      theLoaiDaChon: theLoaiDaChon,
    );
    notifyListeners(); // Thông báo giao diện cập nhật sau khi tìm kiếm xong
  }

  // === Các hàm hỗ trợ ===
  // Mở/đóng panel bộ lọc nâng cao
  void moDongNangCao() {
    isMoNangCao = !isMoNangCao;
    notifyListeners();
  }

  // Chọn hoặc bỏ chọn một thể loại rồi tìm kiếm lại
  void chonTheLoai(String theLoai, String query) {
    if (theLoaiDaChon.contains(theLoai)) {
      theLoaiDaChon.remove(theLoai); // Bỏ chọn nếu đã chọn
    } else {
      theLoaiDaChon.add(theLoai); // Thêm vào nếu chưa chọn
    }
    timKiem(query); // Cập nhật kết quả tìm kiếm sau khi chọn thể loại
  }

  // Xóa tất cả bộ lọc thể loại và tìm kiếm lại
  void xoaBoLoc(String query) {
    theLoaiDaChon.clear();
    timKiem(query); // Cập nhật kết quả tìm kiếm sau khi xóa bộ lọc
  }

  // Tải toàn bộ truyện một lần để tìm kiếm local
  Future<void> _taiTruyen() async {
    try {
      _tatCaTruyen = await _firestoreService.layDanhSachTruyenMotLan();
    } catch (_) {
      _tatCaTruyen = []; // Lỗi thì để rỗng
    }
  }

  // Gom tất cả thể loại từ danh sách truyện đã tải
  Future<void> _taiTheLoai() async {
    //Nếu chưa có collection theLoai, thì lấy từ truyện
    final set = <String>{};
    for (final t in _tatCaTruyen) {
      set.addAll(t.theLoai); // Gom thể loại từ từng truyện
    }
    tatCaTheLoai = set.toList()..sort(); // Sắp xếp theo bảng chữ cái
  }
}
