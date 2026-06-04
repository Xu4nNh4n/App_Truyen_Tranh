import '../models/Truyen.dart';
import '../services/FirestoreService.dart';
import '../processors/TruyenProcessor.dart';

// Controller cung cấp dữ liệu cho màn hình trang chủ
class HomeController {
  //Kết nối đến FirestoreService để lấy dữ liệu truyện
  HomeController({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();
  final FirestoreService _firestoreService;

  //Giao diện gọi để lấy truyện real-time(Thời gian thực)
  Stream<List<Truyen>> xemDanhSachTruyen() {
    return _firestoreService.layDanhSachTruyen();
  }

  //Format thời gian (Giao diện chỉ gọi, không tự tính toán)
  String dinhDangThoiGian(DateTime date) {
    return TruyenProcessor.dinhDangThoiGian(date);
  }
}
