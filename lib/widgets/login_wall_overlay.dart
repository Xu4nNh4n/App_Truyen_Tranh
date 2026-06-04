import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';

// === WIDGET CHẶN NỘI DUNG - LOGIN WALL ===
// Overlay mờ có hiệu ứng Blur, yêu cầu đăng nhập khi đọc chương VIP
class LoginWallOverlay extends StatefulWidget {
  const LoginWallOverlay({super.key});

  @override
  State<LoginWallOverlay> createState() => _LoginWallOverlayState();
}

class _LoginWallOverlayState extends State<LoginWallOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
          ),
        );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // === NỀN MỜ (Blur) ===
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.7)
                    : Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),

          // === CARD CHÍNH ===
          Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  decoration: BoxDecoration(
                    // Glassmorphism effect
                    color: isDark
                        ? AppColors.cardDark.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color: isDark
                          ? AppColors.gradientStart.withValues(alpha: 0.3)
                          : AppColors.gradientStart.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gradientStart.withValues(alpha: 0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon khóa với gradient
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gradientStart.withValues(alpha: 0.15),
                              AppColors.gradientEnd.withValues(alpha: 0.15),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.gradientStart.withValues(
                              alpha: 0.3,
                            ),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.lock,
                          size: 32,
                          color: AppColors.gradientStart,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Tiêu đề
                      Text(
                        AppStrings.vipContent,
                        style: TextStyle(
                          fontSize: AppFontSizes.heading,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Mô tả
                      Text(
                        AppStrings.unlockContent,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppFontSizes.body,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Badge miễn phí
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Đăng ký hoàn toàn miễn phí!',
                              style: TextStyle(
                                fontSize: AppFontSizes.small,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Nút Đăng nhập (gradient)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop(); // Đóng dialog
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.login, size: 20),
                          label: Text(
                            AppStrings.login,
                            style: const TextStyle(
                              fontSize: AppFontSizes.medium,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gradientStart,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: AppColors.gradientStart.withValues(
                              alpha: 0.4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Nút Đăng ký (outlined)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop(); // Đóng dialog
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.person_add,
                            size: 20,
                            color: AppColors.gradientEnd,
                          ),
                          label: Text(
                            AppStrings.register,
                            style: TextStyle(
                              fontSize: AppFontSizes.medium,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gradientEnd,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppColors.gradientEnd,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // === NÚT ĐÓNG ===
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.3),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

// === HELPER: Hiển thị Login Wall Dialog ===
void showLoginWallDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.transparent, // Dùng backdrop filter riêng
    builder: (context) => const LoginWallOverlay(),
  );
}
