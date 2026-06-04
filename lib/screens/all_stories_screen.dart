import 'package:flutter/material.dart';
import '../services/FirestoreService.dart';
import '../models/Truyen.dart';
import '../utils/constants.dart';
import 'truyen_detail_screen.dart';

class AllStoriesScreen extends StatefulWidget {
  const AllStoriesScreen({super.key});

  @override
  State<AllStoriesScreen> createState() => _AllStoriesScreenState();
}

class _AllStoriesScreenState extends State<AllStoriesScreen> {
  final _service = FirestoreService();
  final ScrollController _scrollCtrl = ScrollController();
  List<Truyen> _stories = [];
  bool _loading = true;
  int _pageSize = 20;
  int _displayCount = 20;

  @override
  void initState() {
    super.initState();
    _loadStories();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final threshold = 200.0;
    if (_scrollCtrl.position.pixels + threshold >=
        _scrollCtrl.position.maxScrollExtent) {
      // load more
      setState(() {
        _displayCount = (_displayCount + _pageSize).clamp(0, _stories.length);
      });
    }
  }

  Future<void> _loadStories() async {
    setState(() => _loading = true);
    try {
      final s = await _service.layDanhSachTruyen().first;
      setState(() {
        _stories = s;
        _displayCount = _pageSize.clamp(0, _stories.length);
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  int _cacheWidthFor(double logicalWidth) {
    final devicePixelRatio = MediaQuery.of(
      context,
    ).devicePixelRatio.clamp(1.0, 3.0);
    return (logicalWidth * devicePixelRatio).round();
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  void _navigateToDetail(Truyen truyen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => StoryDetailScreen(truyen: truyen)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả truyện'),
        backgroundColor: AppColors.gradientStart,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStories,
              child: GridView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(AppSpacing.lg),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.58,
                ),
                itemCount: (_displayCount >= _stories.length)
                    ? _stories.length
                    : _displayCount + 1,
                itemBuilder: (context, index) {
                  if (index == _displayCount &&
                      _displayCount < _stories.length) {
                    return Center(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _displayCount = (_displayCount + _pageSize).clamp(
                              0,
                              _stories.length,
                            );
                          });
                        },
                        child: const Text('Xem thêm'),
                      ),
                    );
                  }

                  final truyen = _stories[index];
                  final latestChapters = truyen.danhSachChuong.reversed
                      .take(2)
                      .toList();
                  final gridImageWidth =
                      (MediaQuery.of(context).size.width -
                          (AppSpacing.lg * 2) -
                          12) /
                      2;

                  return GestureDetector(
                    onTap: () => _navigateToDetail(truyen),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? Colors.black : Colors.grey)
                                .withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppRadius.md),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  truyen.anhBia.isNotEmpty
                                      ? (truyen.anhBia.startsWith('http')
                                            ? Image.network(
                                                truyen.anhBia,
                                                fit: BoxFit.cover,
                                                cacheWidth: _cacheWidthFor(
                                                  gridImageWidth,
                                                ),
                                              )
                                            : Image.network(
                                                truyen.anhBia,
                                                fit: BoxFit.cover,
                                                cacheWidth: _cacheWidthFor(
                                                  gridImageWidth,
                                                ),
                                              ))
                                      : Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AppColors.gradientStart
                                                    .withValues(alpha: 0.6),
                                                AppColors.gradientEnd
                                                    .withValues(alpha: 0.6),
                                              ],
                                            ),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.book,
                                              size: 40,
                                              color: Colors.white54,
                                            ),
                                          ),
                                        ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 50,
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
                                  ),
                                  Positioned(
                                    bottom: 6,
                                    left: 6,
                                    right: 6,
                                    child: Row(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 12,
                                              color: AppColors.starGold,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              truyen.danhGia.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.menu_book,
                                              size: 12,
                                              color: Colors.white70,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              '${truyen.soChuong}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: truyen.trangThai == 'Hoàn thành'
                                                ? AppColors.success.withValues(
                                                    alpha: 0.85,
                                                  )
                                                : AppColors.accent.withValues(
                                                    alpha: 0.85,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.full,
                                            ),
                                          ),
                                          child: Text(
                                            truyen.trangThai == 'Hoàn thành'
                                                ? 'Hoàn thành'
                                                : 'Đang ra',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    truyen.tenTruyen,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: AppFontSizes.body,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.primaryDark,
                                      height: 1.2,
                                    ),
                                  ),
                                  const Spacer(),
                                  ...latestChapters.map((ch) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 3),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.local_fire_department,
                                            size: 13,
                                            color: AppColors.accent,
                                          ),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              'Ch.${ch.soChuongText}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.grey.shade700,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            _formatTimeAgo(ch.ngayDang),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isDark
                                                  ? Colors.grey.shade500
                                                  : Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
