import 'package:flutter/material.dart';
import '../controllers/ProfileController.dart';
import '../utils/constants.dart';
import '../services/CoinService.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'admin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

// === MÀN HÌNH CÁ NHÂN ===
// Hiển thị thông tin user, ví xu, thống kê đọc, menu cài đặt và đăng xuất
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _controller = ProfileController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profile), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),

            // --- Avatar + Tên ---
            _controller.daDangNhap
                ? _buildLoggedInHeader(isDark)
                : _buildGuestHeader(isDark),
            const SizedBox(height: AppSpacing.xl),

            // --- Ví Xu (chỉ hiện khi đã đăng nhập) ---
            if (_controller.daDangNhap) ...[
              _buildCoinWallet(isDark),
              const SizedBox(height: AppSpacing.lg),
            ],

            // --- Thống kê ---
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: StreamBuilder<int>(
                stream: _controller.laySoTruyenDaDoc(),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return Center(
                    child: _buildStatColumn('$count', 'Truyện\nđã đọc', isDark),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- Menu cài đặt ---
            _buildMenuItem(
              context,
              icon: Icons.palette,
              iconColor: AppColors.gradientStart,
              title: 'Giao diện',
              subtitle: themeNotifier.value == ThemeMode.dark ? 'Tối' : 'Sáng',
              isDark: isDark,
              onTap: () async {
                final next = themeNotifier.value == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
                themeNotifier.value = next;
                final prefs = await SharedPreferences.getInstance();
                prefs.setString(
                  'themeMode',
                  next == ThemeMode.dark ? 'dark' : 'light',
                );
                setState(() {});
              },
            ),
            // --- Nạp xu (chỉ hiện khi đã đăng nhập) ---
            if (_controller.daDangNhap) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildMenuItem(
                context,
                icon: Icons.monetization_on,
                iconColor: Colors.amber,
                title: 'Nạp Xu',
                subtitle: 'Mua thêm xu để đọc truyện',
                isDark: isDark,
                onTap: () => _showCoinShop(context, isDark),
              ),
            ],

            // --- Admin Panel (chỉ hiện cho admin) ---
            if (_controller.daDangNhap && _controller.vaiTro == 'admin') ...[
              const SizedBox(height: AppSpacing.sm),
              _buildMenuItem(
                context,
                icon: Icons.admin_panel_settings,
                iconColor: Colors.deepPurple,
                title: 'Quản trị',
                subtitle: 'Quản lý truyện và nội dung',
                isDark: isDark,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminScreen(),
                    ),
                  );
                },
              ),
            ],

            // --- Đăng xuất (chỉ hiện khi đã đăng nhập) ---
            if (_controller.daDangNhap) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildMenuItem(
                context,
                icon: Icons.logout,
                iconColor: AppColors.accent,
                title: AppStrings.logout,
                subtitle: 'Đăng xuất khỏi tài khoản',
                isDark: isDark,
                onTap: () => _showLogoutConfirmation(context, isDark),
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  // === VÍ XU ===
  Widget _buildCoinWallet(bool isDark) {
    return StreamBuilder<int>(
      stream: _controller.layXu(),
      builder: (context, snapshot) {
        final coins = snapshot.data ?? 0;
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade700, Colors.orange.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: const Center(
                  child: Text('🪙', style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              // Thông tin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ví Xu',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: AppFontSizes.body,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$coins Xu',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppFontSizes.heading + 4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              // Nút nạp
              ElevatedButton.icon(
                onPressed: () => _showCoinShop(context, isDark),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nạp xu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.amber.shade700,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // === SHOP NẠP XU ===
  void _showCoinShop(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: isDark ? AppColors.primaryMid : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Tiêu đề
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      'Nạp Xu',
                      style: TextStyle(
                        fontSize: AppFontSizes.title,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  'Chọn gói xu để mua. Ấn vào sẽ nạp luôn! (Demo)',
                  style: TextStyle(
                    fontSize: AppFontSizes.body,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              // Danh sách gói
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: CoinService.packages.length,
                  itemBuilder: (context, index) {
                    final package = CoinService.packages[index];
                    return _buildCoinPackageCard(package, isDark);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Định dạng số tiền VND với dấu chấm phân cách hàng nghìn
  String _formatVnd(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  // Card gói xu
  Widget _buildCoinPackageCard(CoinPackage package, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: isDark ? AppColors.cardDark : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => _purchaseCoinPackage(package),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                // Icon coin
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade600, Colors.orange.shade500],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Center(
                    child: Text('🪙', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.ten,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: AppFontSizes.medium,
                          color: isDark ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        '${_formatVnd(package.giaVnd)} VNĐ',
                        style: TextStyle(
                          fontSize: AppFontSizes.small,
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Giá
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'Nạp ngay',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: AppFontSizes.body,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Xử lý mua gói xu
  Future<void> _purchaseCoinPackage(CoinPackage package) async {
    Navigator.pop(context);

    final ok = await _controller.napXu(package);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? '✅ Nạp thành công ${package.xu} xu!'
              : '❌ Nạp xu thất bại, thử lại sau',
        ),
        backgroundColor: ok ? AppColors.success : AppColors.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // === HEADER - ĐÃ ĐĂNG NHẬP ===
  Widget _buildLoggedInHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientStart.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              color: Colors.white24,
            ),
            child: Center(
              child: Text(
                _controller.tenHienThi[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Tên + Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _controller.tenHienThi,
                        style: const TextStyle(
                          fontSize: AppFontSizes.title,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Badge Admin
                    if (_controller.daDangNhap &&
                        _controller.vaiTro == 'admin') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 12, color: Colors.white),
                            SizedBox(width: 3),
                            Text(
                              'Admin',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _controller.vaiTro,
                  style: const TextStyle(
                    fontSize: AppFontSizes.body,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === HEADER - KHÁCH (CHƯA ĐĂNG NHẬP) ===
  Widget _buildGuestHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gradientStart.withValues(alpha: 0.8),
            AppColors.gradientEnd.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientStart.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              color: Colors.white24,
            ),
            child: const Icon(
              Icons.person_outline,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Chào mừng bạn đến MangaHay!',
            style: TextStyle(
              fontSize: AppFontSizes.title,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Đăng nhập để mở khóa toàn bộ nội dung',
            style: TextStyle(
              fontSize: AppFontSizes.body,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.login, size: 18),
                  label: Text(
                    AppStrings.login,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.gradientStart,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add, size: 18),
                  label: Text(
                    AppStrings.register,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Dialog xác nhận đăng xuất
  void _showLogoutConfirmation(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Xác nhận đăng xuất',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất?',
          style: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              await _controller.dangXuat();
              if (mounted) {
                setState(() {}); // Refresh UI
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('Đã đăng xuất thành công'),
                      ],
                    ),
                    backgroundColor: AppColors.gradientStart,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // Cột thống kê
  Widget _buildStatColumn(String value, String label, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: AppFontSizes.heading,
            fontWeight: FontWeight.w800,
            color: AppColors.gradientStart,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFontSizes.small,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  // Menu item
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: AppFontSizes.body,
            color: isDark ? Colors.white : AppColors.primaryDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: AppFontSizes.small,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
