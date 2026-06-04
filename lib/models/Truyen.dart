import 'Chuong.dart';

// Model đại diện cho một bộ truyện
class Truyen {
  Truyen({
    required this.truyenID,
    required this.tenTruyen,
    required this.tacGia,
    required this.theLoai,
    required this.anhBia,
    required this.moTa,
    required this.soChuong,
    required this.danhGia,
    required this.ratingCount,
    required this.trangThai,
    required this.luotXem,
    required this.chuongMienPhi,
    required this.xuMoiChuong,
    required this.taoLuc,
    required this.capNhatLuc,
    this.danhSachChuong = const [],
  });

  // Các trường dữ liệu của truyện
  final String truyenID; // ID duy nhất trên Firestore
  final String tenTruyen; // Tên bộ truyện
  final String tacGia; // Tên tác giả
  final List<String> theLoai; // Danh sách thể loại
  final String anhBia; // URL ảnh bìa
  final String moTa; // Mô tả nội dung truyện
  final int soChuong; // Tổng số chương hiện có
  final double danhGia; // Điểm đánh giá trung bình
  final int ratingCount; // Số lượt đánh giá
  final String trangThai; // "Đang ra" hoặc "Hoàn thành"
  final int luotXem; // Tổng số lượt xem
  final int chuongMienPhi; // Số chương đọc miễn phí
  final int xuMoiChuong; // Xu cần để mở mỗi chương trả phí
  final DateTime taoLuc; // Ngày tạo truyện
  final DateTime capNhatLuc; // Ngày cập nhật gần nhất
  final List<Chuong> danhSachChuong; // Danh sách chương (load riêng)

  // Chuyển đổi dữ liệu Firestore thành đối tượng Truyen
  factory Truyen.fromFirestore(Map<String, dynamic> data, String id) {
    return Truyen(
      truyenID: id,
      tenTruyen: (data['tenTruyen'] ?? '') as String,
      tacGia: (data['tacGia'] ?? '') as String,
      theLoai: List<String>.from(data['theLoai'] ?? []),
      anhBia: (data['anhBia'] ?? '') as String,
      moTa: (data['moTa'] ?? '') as String,
      soChuong: (data['soChuong'] ?? 0) as int,
      danhGia: (data['danhGia'] ?? 0.0).toDouble(),
      ratingCount: (data['ratingCount'] ?? 0) as int,
      trangThai: (data['trangThai'] ?? '') as String,
      luotXem: (data['luotXem'] ?? 0) as int,
      chuongMienPhi: (data['chuongMienPhi'] ?? 0) as int,
      xuMoiChuong: (data['xuMoiChuong'] ?? 0) as int,
      taoLuc: _toDateTime(data['taoLuc']),
      capNhatLuc: _toDateTime(data['capNhatLuc']),
      danhSachChuong: const [],
    );
  }

  // Tạo bản sao Truyen với danh sách chương được gán vào
  Truyen withDanhSachChuong(List<Chuong> chuong) => Truyen(
        truyenID: truyenID,
        tenTruyen: tenTruyen,
        tacGia: tacGia,
        theLoai: theLoai,
        anhBia: anhBia,
        moTa: moTa,
        soChuong: soChuong,
        danhGia: danhGia,
        ratingCount: ratingCount,
        trangThai: trangThai,
        luotXem: luotXem,
        chuongMienPhi: chuongMienPhi,
        xuMoiChuong: xuMoiChuong,
        taoLuc: taoLuc,
        capNhatLuc: capNhatLuc,
        danhSachChuong: chuong,
      );

  // Chuyển đổi đối tượng thành Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'tenTruyen': tenTruyen,
      'tacGia': tacGia,
      'theLoai': theLoai,
      'anhBia': anhBia,
      'moTa': moTa,
      'soChuong': soChuong,
      'danhGia': danhGia,
      'trangThai': trangThai,
      'luotXem': luotXem,
      'chuongMienPhi': chuongMienPhi,
      'xuMoiChuong': xuMoiChuong,
      'taoLuc': taoLuc,
      'capNhatLuc': capNhatLuc,
    };
  }

  // Hàm nội bộ: chuyển giá trị thô thành DateTime
  static DateTime _toDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }
}
