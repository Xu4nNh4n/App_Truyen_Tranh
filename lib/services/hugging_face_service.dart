import 'dart:convert';
import 'package:http/http.dart' as http;

// Service lấy URL ảnh từ Hugging Face Datasets
class HuggingFaceService {
  static const _base = 'https://huggingface.co'; // Base URL của HuggingFace

  // Lấy danh sách URL ảnh từ một thư mục dataset HuggingFace
  // folderPath: "xu4nnh4n/manga-images/momogusa-san/c001"
  static Future<List<String>> fetchImageUrls(String folderPath) async {
    try {
      // Tách các phần: user, repo, đường dẫn thư mục
      final parts = folderPath.trim().split('/');
      if (parts.length < 3) return [];

      final user = parts[0];
      final repo = parts[1];
      final path = parts.sublist(2).join('/');

      // Xây dựng URL API để lấy danh sách file trong thư mục
      final apiUrl = '$_base/api/datasets/$user/$repo/tree/main/$path';

      final res = await http.get(Uri.parse(apiUrl));
      if (res.statusCode != 200) return []; // Lỗi HTTP thì trả rỗng

      final decoded = jsonDecode(res.body);
      if (decoded is! List) return [];

      // Các đuôi file ảnh được hỗ trợ
      final imageExts = {'.jpg', '.jpeg', '.png', '.webp', '.gif'};

      // Lọc chỉ lấy file ảnh và tạo URL đầy đủ
      final urls = (decoded as List<dynamic>)
          .where((item) {
            if (item is! Map) return false;
            final p = ((item['path'] ?? '') as String).toLowerCase();
            return item['type'] == 'file' &&
                imageExts.any((ext) => p.endsWith(ext));
          })
          .map((item) {
            final filePath = item['path'] as String;
            return '$_base/datasets/$user/$repo/resolve/main/$filePath';
          })
          .toList();

      // Sắp xếp ảnh theo thứ tự tự nhiên (1, 2, 10 thay vì 1, 10, 2)
      urls.sort((a, b) {
        final nameA = a.split('/').last.toLowerCase();
        final nameB = b.split('/').last.toLowerCase();
        return _naturalCompare(nameA, nameB);
      });

      return urls;
    } catch (_) {
      return []; // Bất kỳ lỗi nào cũng trả danh sách rỗng
    }
  }

  // So sánh tự nhiên: tách phần số trong tên file để so sánh đúng thứ tự
  static int _naturalCompare(String a, String b) {
    final numReg = RegExp(r'\d+'); // Regex tìm chuỗi số
    final aMatches = numReg.allMatches(a).toList();
    final bMatches = numReg.allMatches(b).toList();
    if (aMatches.isNotEmpty && bMatches.isNotEmpty) {
      final aNum = int.tryParse(aMatches.first.group(0)!) ?? 0;
      final bNum = int.tryParse(bMatches.first.group(0)!) ?? 0;
      if (aNum != bNum) return aNum.compareTo(bNum); // So sánh theo số
    }
    return a.compareTo(b); // Fallback: so sánh chuỗi thông thường
  }
}
