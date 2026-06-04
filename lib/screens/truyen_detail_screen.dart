import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../controllers/ChiTietTruyenController.dart';
import '../models/Truyen.dart';
import '../models/Chuong.dart';
import '../models/binh_luan.dart';
import '../services/FirestoreService.dart';
import '../utils/constants.dart';
import '../widgets/chuong_list_tile.dart';
import '../widgets/login_wall_overlay.dart';
import 'doc_truyen_screen.dart';

// === MÀN HÌNH CHI TIẾT TRUYỆN ===
// Hiển thị thông tin truyện, danh sách chương, đánh giá và bình luận
class StoryDetailScreen extends StatefulWidget {
  final Truyen truyen;

  const StoryDetailScreen({super.key, required this.truyen});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  late final StoryDetailController _controller;
  final _firestoreService = FirestoreService();
  final _commentController = TextEditingController();
  bool _dangGuiBinhLuan = false;

  @override
  void initState() {
    super.initState();
    _controller = StoryDetailController(truyen: widget.truyen)
      ..addListener(_onControllerChanged)
      ..taiDanhSachChuong();
    // Load rating if logged in
    final uid = _controller.authService.firebaseUser?.uid;
    if (uid != null) _controller.taiDanhGiaUser(uid);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  // Xử lý khi bấm vào chương
  Future<void> _onChapterTap(int chapterIndex) async {
    final locked = _controller.laChuongBiKhoa(chapterIndex);
    if (!mounted) return;

    if (!locked) {
      _openReading(chapterIndex);
    } else if (!_controller.authService.daDangNhap) {
      showLoginWallDialog(context);
    } else {
      _showUnlockDialog(chapterIndex, _controller.danhSachChuong[chapterIndex]);
    }
  }

  void _openReading(int chapterIndex) {
    final truyenVoiChuong = _controller.truyen.withDanhSachChuong(
      _controller.danhSachChuong,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReadingScreen(
          truyen: truyenVoiChuong,
          initialChapterIndex: chapterIndex,
        ),
      ),
    );
  }

  void _showUnlockDialog(int chapterIndex, Chuong chapter) {
    final truyen = widget.truyen;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            const Text('🪙', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Mở khóa chương',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chương ${chapter.soChuongText}: ${chapter.tieuDe}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cần ${truyen.xuMoiChuong} xu để mở khóa chương này.',
              style: TextStyle(
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final result = await _controller.unlockChuong(chapterIndex);

              if (!mounted) return;

              if (result.thanhCong) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('✅ ${result.loi ?? 'Thanh cong'}'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                _openReading(chapterIndex);
              } else {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('❌ ${result.loi ?? 'Thanh cong'}'),
                    backgroundColor: AppColors.accent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Text('🪙', style: TextStyle(fontSize: 16)),
            label: Text('Mở khóa (${truyen.xuMoiChuong} xu)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final truyen = widget.truyen;
    final chapters = _controller.danhSachChuong;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- SliverAppBar với ảnh bìa ---
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: isDark
                ? AppColors.primaryDark
                : AppColors.gradientStart,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Ảnh bìa
                  Hero(
                    tag: 'cover_${truyen.truyenID}',
                    child: truyen.anhBia.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: truyen.anhBia,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: AppColors.shimmerBase),
                            errorWidget: (context, url, error) => Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.gradientStart,
                                    AppColors.gradientEnd,
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Image.network(
                            truyen.anhBia,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.gradientStart,
                                      AppColors.gradientEnd,
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                  // Thông tin truyện ở dưới
                  Positioned(
                    bottom: AppSpacing.xl,
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên truyện
                        Text(
                          truyen.tenTruyen,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: AppFontSizes.heading + 4,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Tác giả
                        Text(
                          'Tác giả: ${truyen.tacGia}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: AppFontSizes.medium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Nút yêu thích
            actions: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    _controller.yeuThich
                        ? Icons.favorite
                        : Icons.favorite_border,
                    key: ValueKey(_controller.yeuThich),
                    color: _controller.yeuThich
                        ? AppColors.accent
                        : Colors.white,
                    size: 28,
                  ),
                ),
                onPressed: () async {
                  if (!_controller.authService.daDangNhap) {
                    showLoginWallDialog(context);
                    return;
                  }

                  await _controller.doiYeuThich();

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _controller.yeuThich
                            ? 'Đã thêm vào Thư Viện ❤️'
                            : 'Đã xóa khỏi Thư Viện',
                      ),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // --- Nội dung chi tiết ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Thống kê nhanh ---
                  _buildQuickStats(truyen, isDark),
                  const SizedBox(height: AppSpacing.md),
                  _buildRatingSection(truyen, isDark),
                  const SizedBox(height: AppSpacing.xl),

                  // --- Thể loại (Chips) ---
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: truyen.theLoai.map((genre) {
                      return Chip(
                        label: Text(genre),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // --- Nút "Đọc Ngay" ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (chapters.isNotEmpty) {
                          _openReading(0);
                        }
                      },
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
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow, size: 24),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            AppStrings.readNow,
                            style: TextStyle(
                              fontSize: AppFontSizes.medium,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // --- Mô tả (có nút Xem thêm) ---
                  Text(
                    'Giới Thiệu',
                    style: TextStyle(
                      fontSize: AppFontSizes.title,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AnimatedCrossFade(
                    firstChild: Text(
                      truyen.moTa,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppFontSizes.body,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                        height: 1.6,
                      ),
                    ),
                    secondChild: Text(
                      truyen.moTa,
                      style: TextStyle(
                        fontSize: AppFontSizes.body,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                        height: 1.6,
                      ),
                    ),
                    crossFadeState: _controller.moMoTa
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                  GestureDetector(
                    onTap: () {
                      _controller.doiTrangThaiMoTa();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Text(
                        _controller.moMoTa ? 'Thu gọn ▲' : 'Xem thêm ▼',
                        style: const TextStyle(
                          color: AppColors.gradientStart,
                          fontWeight: FontWeight.w600,
                          fontSize: AppFontSizes.body,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // --- Danh sách chương ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.chapters,
                        style: TextStyle(
                          fontSize: AppFontSizes.title,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      Row(
                        children: [
                          // Chỉ báo chương miễn phí
                          if (!_controller.authService.daDangNhap)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                              ),
                              child: Text(
                                '${truyen.chuongMienPhi} chương miễn phí',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          Text(
                            '${chapters.length} chương',
                            style: TextStyle(
                              fontSize: AppFontSizes.body,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),

          // --- Danh sách chương (SliverList) ---
          if (_controller.dangTaiChuong)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final chapter = chapters[index];
                  // Lôgic khóa: nếu chưa đăng nhập và >= freeChapters
                  final isLocked = _controller.laChuongBiKhoa(index);
                  return ChapterListTile(
                    chuong: chapter,
                    isLocked: isLocked,
                    isRead: _controller.authService.daDocChuong(
                      widget.truyen.truyenID,
                      chapter.id,
                    ),
                    onTap: () => _onChapterTap(index),
                  );
                }, childCount: chapters.length),
              ),
            ),

          // --- Bình luận ---
          SliverToBoxAdapter(child: _buildCommentSection(isDark)),
        ],
      ),
    );
  }

  // === BÌNH LUẬN ===
  Widget _buildCommentSection(bool isDark) {
    final truyenID = widget.truyen.truyenID;
    final auth = _controller.authService;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline, size: 20),
              const SizedBox(width: 8),
              Text(
                'Bình luận',
                style: TextStyle(
                  fontSize: AppFontSizes.medium,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Ô nhập bình luận
          if (auth.daDangNhap)
            Row(
              children: [
                _avatar(auth.tenHienThi, isDark),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    maxLines: null,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.primaryDark,
                      fontSize: AppFontSizes.body,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Viết bình luận...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _dangGuiBinhLuan
                    ? const SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send_rounded),
                        color: AppColors.gradientStart,
                        onPressed: () => _guiBinhLuan(truyenID),
                      ),
              ],
            )
          else
            GestureDetector(
              onTap: () => showLoginWallDialog(context),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Đăng nhập để bình luận',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.lg),

          // Danh sách bình luận
          StreamBuilder<List<BinhLuan>>(
            stream: _firestoreService.layBinhLuan(truyenID),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final comments = snapshot.data ?? [];
              if (comments.isEmpty) {
                return Center(
                  child: Text(
                    'Chưa có bình luận nào. Hãy là người đầu tiên!',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: AppFontSizes.body,
                    ),
                  ),
                );
              }
              return Column(
                children: comments
                    .map((c) => _buildCommentItem(c, isDark))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _guiBinhLuan(String truyenID) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    final auth = _controller.authService;
    if (!auth.daDangNhap) return;

    setState(() => _dangGuiBinhLuan = true);
    await _firestoreService.themBinhLuan(
      truyenID,
      auth.firebaseUser!.uid,
      auth.tenHienThi.isEmpty ? 'Người dùng' : auth.tenHienThi,
      text,
    );
    _commentController.clear();
    setState(() => _dangGuiBinhLuan = false);
  }

  Widget _buildCommentItem(BinhLuan comment, bool isDark) {
    final isOwner = comment.uid == _controller.authService.firebaseUser?.uid;
    final timeAgo = _thoiGianTruoc(comment.taoLuc);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(comment.tenHienThi, isDark),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.tenHienThi,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: AppFontSizes.body,
                          color: isDark ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: AppFontSizes.small,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      if (isOwner) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _firestoreService.xoaBinhLuan(
                            widget.truyen.truyenID,
                            comment.id,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.noiDung,
                    style: TextStyle(
                      fontSize: AppFontSizes.body,
                      color: isDark
                          ? Colors.grey.shade300
                          : Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(String name, bool isDark) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.gradientStart.withValues(alpha: 0.2),
      child: Text(
        letter,
        style: const TextStyle(
          color: AppColors.gradientStart,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  String _thoiGianTruoc(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${time.day}/${time.month}/${time.year}';
  }

  // === THỐNG KÊ NHANH ===
  Widget _buildQuickStats(Truyen truyen, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.star,
            iconColor: AppColors.starGold,
            value: truyen.danhGia == 0
                ? 'Chưa có'
                : truyen.danhGia.toStringAsFixed(1),
            label: 'Đánh giá',
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildStatItem(
            icon: Icons.menu_book,
            iconColor: AppColors.gradientStart,
            value: '${truyen.soChuong}',
            label: 'Chương',
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildStatItem(
            icon: Icons.visibility_outlined,
            iconColor: AppColors.gradientEnd,
            value: '${truyen.luotXem}',
            label: 'Lượt xem',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: AppFontSizes.body,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.primaryDark,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSizes.small,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 40,
      color: isDark ? Colors.white10 : Colors.grey.shade300,
    );
  }

  Widget _buildRatingSection(Truyen truyen, bool isDark) {
    final avg = truyen.danhGia;
    final count = truyen.ratingCount;
    final user = _controller.danhGiaCuaToi;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đánh giá',
            style: TextStyle(
              fontSize: AppFontSizes.title,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              // Stars (interactive)
              for (var i = 1; i <= 5; i++)
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    i <= (user?.round() ?? 0) ? Icons.star : Icons.star_border,
                    color: AppColors.starGold,
                    size: 28,
                  ),
                  onPressed: () async {
                    if (!_controller.authService.daDangNhap) {
                      showLoginWallDialog(context);
                      return;
                    }

                    // Submit rating
                    final uid = _controller.authService.firebaseUser!.uid;
                    await _controller.guiDanhGia(uid, i.toDouble());
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cám ơn bạn đã đánh giá $i sao'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              const SizedBox(width: AppSpacing.md),
              // Average and count
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    avg.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: AppFontSizes.body,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    '$count lượt đánh giá',
                    style: TextStyle(
                      fontSize: AppFontSizes.small,
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (_controller.dangGuiDanhGia)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
