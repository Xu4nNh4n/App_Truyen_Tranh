import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../controllers/ThuVienController.dart';
import '../models/ThuVien.dart';
import '../services/FirestoreService.dart';
import '../utils/constants.dart';
import 'truyen_detail_screen.dart';

// === MÀN HÌNH THƯ VIỆN ===
// Hiển thị 2 tab: Đang đọc và Yêu thích, mỗi tab là danh sách truyện của user
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _controller = ThuVienController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.library),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gradientStart,
          indicatorWeight: 3,
          labelColor: AppColors.gradientStart,
          unselectedLabelColor:
              isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: AppFontSizes.body,
          ),
          tabs: const [
            Tab(text: AppStrings.reading),
            Tab(text: AppStrings.favorites),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(
            stream: _controller.layDangDoc(),
            emptyMessage: 'Chưa có truyện đang đọc',
            emptyIcon: Icons.menu_book_outlined,
            isDark: isDark,
          ),
          _buildList(
            stream: _controller.layYeuThich(),
            emptyMessage: 'Chưa có truyện yêu thích',
            emptyIcon: Icons.favorite_border,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildList({
    required Stream<List<ThuVienItem>> stream,
    required String emptyMessage,
    required IconData emptyIcon,
    required bool isDark,
  }) {
    return StreamBuilder<List<ThuVienItem>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return _buildEmptyState(emptyMessage, emptyIcon, isDark);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: items.length,
          itemBuilder: (_, i) => _buildItem(items[i], isDark),
        );
      },
    );
  }

  Future<void> _moChiTietTruyen(ThuVienItem item) async {
    try {
      final truyen = await FirestoreService().layTruyenTheoID(item.truyenID).first;
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StoryDetailScreen(truyen: truyen)),
      );
    } catch (_) {}
  }

  Widget _buildItem(ThuVienItem item, bool isDark) {
    return GestureDetector(
      onTap: () => _moChiTietTruyen(item),
      child: Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.md),
              bottomLeft: Radius.circular(AppRadius.md),
            ),
            child: item.anhBia.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: item.anhBia,
                    width: 70,
                    height: 100,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _coverPlaceholder(),
                  )
                : _coverPlaceholder(),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.tenTruyen,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: AppFontSizes.body,
                      color: isDark ? Colors.white : AppColors.primaryDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (item.dangDoc)
                        _badge('Đang đọc', AppColors.gradientStart),
                      if (item.dangDoc && item.yeuThich)
                        const SizedBox(width: 4),
                      if (item.yeuThich)
                        _badge('Yêu thích', AppColors.accent),
                    ],
                  ),
                  if (item.coViTriDoc && item.tieuDeChuongCuoi.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.bookmark,
                          size: 14,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Đọc tiếp: ${item.tieuDeChuongCuoi}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      width: 70,
      height: 100,
      color: AppColors.gradientStart.withValues(alpha: 0.1),
      child: const Icon(Icons.book, color: AppColors.gradientStart),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: TextStyle(
              fontSize: AppFontSizes.medium,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
