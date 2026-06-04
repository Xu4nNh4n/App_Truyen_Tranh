import '../services/AuthService.dart';

// Controller xử lý đăng nhập và đăng ký từ màn hình UI
class AuthController {
  AuthController({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService; // Service xác thực Firebase Auth

  // Chuyển tiếp yêu cầu đăng nhập đến AuthService
  Future<AuthResult> dangNhap({
    required String email,
    required String matKhau,
  }) {
    return _authService.dangNhap(email, matKhau);
  }

  // Chuyển tiếp yêu cầu đăng ký đến AuthService
  Future<AuthResult> dangKy({
    required String email,
    required String matKhau,
    String? ten,
  }) {
    return _authService.dangKy(email, matKhau, ten: ten);
  }
}
