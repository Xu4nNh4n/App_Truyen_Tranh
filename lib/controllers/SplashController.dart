import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../services/AuthService.dart';

// Controller xử lý logic khởi động app (Splash Screen)
class SplashController {
  SplashController({AuthService? authService}) : _authService = authService; // ignore: prefer_initializing_formals

  AuthService? _authService; // Nullable: khởi tạo lazy nếu chưa có

  // Khởi tạo AuthService và tải thông tin user (nếu đã đăng nhập trước đó)
  Future<void> init() async {
    try {
      await (_authService ??= AuthService()).init(); // Lazy init AuthService
    } on FirebaseException catch (error) {
      if (error.code != 'no-app') rethrow; // Chỉ bỏ qua lỗi 'no-app'
      debugPrint('[SplashController] Firebase chua init.');
    }
  }
}
