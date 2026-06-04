import '../controllers/HomeController.dart';

void testLogHome() {
  final controller = HomeController();
  controller.xemDanhSachTruyen().listen(
    (list) {
      for (final truyen in list) {
        print('[TRUYEN] ${truyen.tenTruyen} - ${truyen.tacGia}');
      }
    },
    onError: (e) {
      print('[ERROR] Lỗi khi lấy danh sách truyện: $e');
    },
  );
}
