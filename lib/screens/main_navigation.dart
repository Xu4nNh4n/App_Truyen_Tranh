import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'thu_vien_screen.dart';
import 'profile_screen.dart';

// === MÀN HÌNH CHÍNH VỚI BOTTOM NAVIGATION BAR ===
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0; // Tab đang chọn

  // Lazy screens: chỉ khởi tạo tab khi người dùng truy cập lần đầu.
  late final List<Widget?> _screens = List<Widget?>.filled(3, null);

  @override
  void initState() {
    super.initState();
    _screens[_selectedIndex] = _buildScreen(_selectedIndex);
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const LibraryScreen();
      case 2:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: List<Widget>.generate(
          _screens.length,
          (index) => _screens[index] ?? const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              _screens[index] ??= _buildScreen(index);
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: _buildActiveIcon(Icons.home),
              label: AppStrings.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.library_books_outlined),
              activeIcon: _buildActiveIcon(Icons.library_books),
              label: AppStrings.library,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_circle_outlined),
              activeIcon: _buildActiveIcon(Icons.account_circle),
              label: AppStrings.profile,
            ),
          ],
        ),
      ),
    );
  }

  // Icon active với gradient container
  Widget _buildActiveIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gradientStart.withValues(alpha: 0.15),
            AppColors.gradientEnd.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, color: AppColors.gradientStart),
    );
  }
}
