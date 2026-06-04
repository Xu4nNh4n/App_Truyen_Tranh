import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

// Service xử lý upload/xóa file trên Firebase Storage
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload ảnh bìa truyện
  Future<String> uploadAnhBia({
    required String truyenID,
    required File file,
  }) async {
    // Đường dẫn lưu trữ: truyen/{truyenID}/anh_bia.jpg
    final ref = _storage.ref('truyen/$truyenID/anh_bia.jpg');
    await ref.putFile(file); // Upload file lên Storage
    return ref.getDownloadURL(); // Trả về URL public để hiển thị
  }

  // Upload 1 trang truyện
  Future<String> uploadTrangTruyen({
    required String truyenID,
    required int soChuong,
    required int indexTrang,
    required File file,
  }) async {
    // Đường dẫn: truyen/{truyenID}/chuong_{n}/trang_{i}.jpg
    final ref = _storage.ref(
      'truyen/$truyenID/chuong_$soChuong/trang_$indexTrang.jpg',
    );
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  // Xoa file tren storage
  Future<void> xoaFile(String path) async {
    await _storage.ref(path).delete(); // Xóa file theo đường dẫn
  }
}
