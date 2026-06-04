import '../services/AuthService.dart';
import '../services/CoinService.dart';
import '../controllers/ThuVienController.dart';

// Controller cung cấp dữ liệu cho màn hình Cá Nhân
class ProfileController {
  ProfileController({AuthService? authService, CoinService? coinService})
    : _authService = authService ?? AuthService(),
      _coinService = coinService ?? CoinService();

  final AuthService _authService;
  final CoinService _coinService;
  final ThuVienController _thuVienController = ThuVienController();

  bool get daDangNhap => _authService.daDangNhap;
  String get tenHienThi => _authService.tenHienThi;
  String get vaiTro => _authService.vaiTro;
  int get xuHienTai => _authService.xu;

  // Lắng nghe số xu real-time
  Stream<int> layXu() => _coinService.layXu();

  // Đếm số truyện đang đọc
  Stream<int> laySoTruyenDaDoc() =>
      _thuVienController.layDangDoc().map((list) => list.length);

  // Nạp xu thẳng vào tài khoản
  Future<bool> napXu(CoinPackage goi) => _coinService.napXu(goi);

  Future<void> dangXuat() => _authService.dangXuat();
}
