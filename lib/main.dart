import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'utils/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
// === ENTRY POINT ===
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khoi tao Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Giam dung luong ImageCache
  final imageCache = PaintingBinding.instance.imageCache;
  imageCache.maximumSize = 80;
  imageCache.maximumSizeBytes = 40 << 20;

  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('themeMode') ?? 'system';
  themeNotifier.value = saved == 'dark'
      ? ThemeMode.dark
      : saved == 'light'
      ? ThemeMode.light
      : ThemeMode.system;
  // Cai dat thanh trang thai trong suot
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const TruyenHayApp());
}

// Widget gốc của ứng dụng, cấu hình theme và màn hình khởi đầu
class TruyenHayApp extends StatelessWidget {
  const TruyenHayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, ___) => MaterialApp(
        title: 'MangaHay',
        debugShowCheckedModeBanner: false, // Ẩn banner debug
        theme: AppThemes.lightTheme, // Theme sáng
        darkTheme: AppThemes.darkTheme, // Theme tối
        themeMode: mode, // Tự động theo hệ thống
        home: const SplashScreen(), // Màn hình khởi động
      ),
    );
  }
}
