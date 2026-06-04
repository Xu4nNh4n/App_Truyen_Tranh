import 'package:flutter/foundation.dart';

// Controller quản lý tab đang chọn trong thanh điều hướng chính
class MainNavigationController extends ChangeNotifier {
  int chiSoTab = 0; // Chỉ số tab hiện tại (0 = Trang chủ, 1 = Tìm kiếm, ...)

  // Chuyển sang tab mới, bỏ qua nếu đã ở tab đó rồi
  void doiTab(int index) {
    if (index == chiSoTab) return; // Không làm gì nếu không thay đổi
    chiSoTab = index;
    notifyListeners(); // Thông báo UI rebuild
  }
}
