import 'package:flutter/material.dart';
import '../controllers/TimKiemController.dart';
import '../models/Truyen.dart';
import '../utils/constants.dart';
import 'truyen_detail_screen.dart';

// === MÀN HÌNH TÌM KIẾM NÂNG CAO ===
// Cho phép tìm theo tên/tác giả và lọc theo thể loại với animation panel
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  // === STATE ===
  late final TimKiemController _searchState;
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Animation cho advanced panel
  late AnimationController _panelAnimController;
  late Animation<double> _panelAnimation;

  @override
  void initState() {
    super.initState();
    _searchState = TimKiemController()
      ..addListener(_onSearchStateChanged)
      ..loadDuLieuBanDau();

    // Animation controller cho panel nâng cao
    _panelAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _panelAnimation = CurvedAnimation(
      parent: _panelAnimController,
      curve: Curves.easeOutCubic,
    );

    // Lắng nghe thay đổi input
    _queryController.addListener(_onSearchChanged);
  }

  void _onSearchStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchState.removeListener(_onSearchStateChanged);
    _searchState.dispose();
    _queryController.removeListener(_onSearchChanged);
    _queryController.dispose();
    _searchFocusNode.dispose();
    _panelAnimController.dispose();
    super.dispose();
  }

  // === LOGIC TÌM KIẾM ===
  void _onSearchChanged() {
    _searchState.timKiem(_queryController.text);
  }

  // Toggle panel nâng cao
  void _toggleAdvancedPanel() {
    _searchState.moDongNangCao();
    if (_searchState.isMoNangCao) {
      _panelAnimController.forward();
    } else {
      _panelAnimController.reverse();
    }
  }

  // Chọn/bỏ chọn thể loại
  void _toggleGenre(String genre) {
    _searchState.chonTheLoai(genre, _queryController.text);
  }

  // Xóa tất cả bộ lọc
  void _clearFilters() {
    _searchState.xoaBoLoc(_queryController.text);
  }

  // Áp dụng và đóng panel
  void _applyAndClose() {
    _toggleAdvancedPanel();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Tìm Kiếm'), elevation: 0),
      body: Column(
        children: [
          // --- THANH TÌM KIẾM + NÚT NÂNG CAO ---
          _buildSearchBar(isDark),

          // --- BADGE THỂ LOẠI ĐÃ CHỌN (hiện khi panel đóng) ---
          if (!_searchState.isMoNangCao &&
              _searchState.theLoaiDaChon.isNotEmpty)
            _buildSelectedGenresBadges(isDark),

          // --- PANEL NÂNG CAO (animated) ---
          _buildAdvancedPanel(isDark),

          // --- KẾT QUẢ TÌM KIẾM ---
          Expanded(child: _buildSearchResults(isDark)),
        ],
      ),
    );
  }

  // =========================================
  // === THANH TÌM KIẾM + NÚT NÂNG CAO ===
  // =========================================
  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          // TextField tìm kiếm
          Expanded(
            child: TextField(
              controller: _queryController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: AppStrings.search,
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.gradientStart),
                suffixIcon: _queryController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          size: 20,
                        ),
                        onPressed: () {
                          _queryController.clear();
                          // _onSearchChanged sẽ tự gọi qua listener
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.cardDark : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  borderSide: BorderSide(
                    color: AppColors.gradientStart.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Nút Nâng cao (có badge)
          _buildAdvancedButton(isDark),
        ],
      ),
    );
  }

  // === NÚT NÂNG CAO ===
  Widget _buildAdvancedButton(bool isDark) {
    final hasFilters = _searchState.theLoaiDaChon.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleAdvancedPanel,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _searchState.isMoNangCao
                ? AppColors.gradientStart
                : (hasFilters
                      ? AppColors.gradientStart.withValues(alpha: 0.15)
                      : (isDark ? AppColors.cardDark : Colors.grey.shade100)),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: hasFilters && !_searchState.isMoNangCao
                ? Border.all(
                    color: AppColors.gradientStart.withValues(alpha: 0.4),
                    width: 1.5,
                  )
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                _searchState.isMoNangCao ? Icons.tune_outlined : Icons.tune,
                color: _searchState.isMoNangCao
                    ? Colors.white
                    : (hasFilters
                          ? AppColors.gradientStart
                          : (isDark ? Colors.white70 : Colors.grey.shade700)),
                size: 22,
              ),
              // Badge số lượng
              if (hasFilters && !_searchState.isMoNangCao)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${_searchState.theLoaiDaChon.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // === BADGES THỂ LOẠI ĐÃ CHỌN (compact) ===
  // ==========================================
  Widget _buildSelectedGenresBadges(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Label
            Text(
              'Lọc: ',
              style: TextStyle(
                fontSize: AppFontSizes.small,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            // Genre chips
            ..._searchState.theLoaiDaChon.map((genre) {
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: GestureDetector(
                  onTap: () => _toggleGenre(genre),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          genre,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.close,
                          size: 12,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            // Nút xóa tất cả
            GestureDetector(
              onTap: _clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.clear_all, size: 14, color: AppColors.accent),
                    const SizedBox(width: 2),
                    Text(
                      'Xóa lọc',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // === PANEL NÂNG CAO (ANIMATED) ===
  // ==========================================
  Widget _buildAdvancedPanel(bool isDark) {
    return SizeTransition(
      sizeFactor: _panelAnimation,
      axisAlignment: -1.0,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withValues(alpha: 0.95)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isDark
                ? AppColors.gradientStart.withValues(alpha: 0.2)
                : AppColors.gradientStart.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gradientStart.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      color: AppColors.gradientStart,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tìm kiếm nâng cao',
                      style: TextStyle(
                        fontSize: AppFontSizes.medium,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                // Nút đóng
                GestureDetector(
                  onTap: _toggleAdvancedPanel,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Label thể loại
            Text(
              'Thể loại (chọn nhiều):',
              style: TextStyle(
                fontSize: AppFontSizes.small,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Wrap of genre chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _searchState.tatCaTheLoai.map((genre) {
                final isSelected = _searchState.theLoaiDaChon.contains(genre);
                return GestureDetector(
                  onTap: () => _toggleGenre(genre),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [
                                AppColors.gradientStart,
                                AppColors.gradientEnd,
                              ],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : Colors.grey.shade300,
                            ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          genre,
                          style: TextStyle(
                            fontSize: AppFontSizes.body,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? Colors.white70
                                      : Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Action buttons
            Row(
              children: [
                // Xóa bộ lọc
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _searchState.theLoaiDaChon.isNotEmpty
                        ? _clearFilters
                        : null,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Xóa bộ lọc'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: BorderSide(
                        color: _searchState.theLoaiDaChon.isNotEmpty
                            ? AppColors.accent
                            : (isDark ? Colors.white12 : Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Áp dụng
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _applyAndClose,
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(
                      _searchState.theLoaiDaChon.isEmpty
                          ? 'Đóng'
                          : 'Áp dụng (${_searchState.theLoaiDaChon.length})',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gradientStart,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
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
      ),
    );
  }

  // ==========================================
  // === KẾT QUẢ TÌM KIẾM ===
  // ==========================================
  Widget _buildSearchResults(bool isDark) {
    // Trạng thái 1: Empty state — chưa gõ và chưa lọc
    if (!_searchState.daTimKiem) {
      return _buildEmptyState(isDark);
    }

    // Trạng thái 2: Không tìm thấy
    if (_searchState.goiY.isEmpty) {
      return _buildNoResults(isDark);
    }

    // Trạng thái 3: Hiển thị kết quả gợi ý
    return _buildSuggestionList(isDark);
  }

  // === EMPTY STATE ===
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon tìm kiếm lớn
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.gradientStart.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search,
              size: 40,
              color: AppColors.gradientStart.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Tìm kiếm truyện',
            style: TextStyle(
              fontSize: AppFontSizes.title,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: Text(
              'Nhập tên truyện hoặc tác giả.\nDùng bộ lọc nâng cao để tìm theo thể loại.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFontSizes.body,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === KHÔNG TÌM THẤY ===
  Widget _buildNoResults(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Không tìm thấy truyện nào',
            style: TextStyle(
              fontSize: AppFontSizes.medium,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_searchState.theLoaiDaChon.isNotEmpty)
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.filter_list_off, size: 18),
              label: const Text('Xóa bộ lọc thể loại'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.gradientStart,
              ),
            ),
        ],
      ),
    );
  }

  // === DANH SÁCH GỢI Ý ===
  Widget _buildSuggestionList(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header kết quả
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 16,
                color: AppColors.gradientStart,
              ),
              const SizedBox(width: 4),
              Text(
                'Tìm thấy ${_searchState.goiY.length} kết quả',
                style: TextStyle(
                  fontSize: AppFontSizes.small,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        // Danh sách
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: _searchState.goiY.length,
            itemBuilder: (context, index) {
              final truyen = _searchState.goiY[index];
              return _buildSuggestionItem(truyen, isDark);
            },
          ),
        ),
      ],
    );
  }

  // === MỘT ITEM GỢI Ý ===
  Widget _buildSuggestionItem(Truyen truyen, bool isDark) {
    final query = _queryController.text.trim().toLowerCase();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StoryDetailScreen(truyen: truyen),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withValues(
                alpha: 0.12,
              ),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ảnh bìa nhỏ
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Image.network(
                truyen.anhBia,
                width: 55,
                height: 75,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 55,
                    height: 75,
                    color: AppColors.gradientStart.withValues(alpha: 0.3),
                    child: const Icon(
                      Icons.book,
                      color: Colors.white70,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên truyện (highlight keyword)
                  _buildHighlightedText(
                    truyen.tenTruyen,
                    query,
                    TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: AppFontSizes.body + 1,
                      color: isDark ? Colors.white : AppColors.primaryDark,
                    ),
                    isDark,
                  ),
                  const SizedBox(height: 3),
                  // Tác giả (highlight keyword)
                  _buildHighlightedText(
                    truyen.tacGia,
                    query,
                    TextStyle(
                      fontSize: AppFontSizes.small,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    isDark,
                  ),
                  const SizedBox(height: 6),
                  // Thể loại chips
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: truyen.theLoai.map((genre) {
                      final isSelected = _searchState.theLoaiDaChon.contains(
                        genre,
                      );
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.gradientStart.withValues(
                                  alpha: isDark ? 0.3 : 0.15,
                                )
                              : AppColors.gradientStart.withValues(
                                  alpha: isDark ? 0.12 : 0.08,
                                ),
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.gradientStart.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: AppColors.gradientStart,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Rating + Arrow
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: AppColors.starGold, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      truyen.danhGia.toString(),
                      style: TextStyle(
                        fontSize: AppFontSizes.small,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // === HIGHLIGHT KEYWORD TRONG TEXT ===
  Widget _buildHighlightedText(
    String text,
    String query,
    TextStyle baseStyle,
    bool isDark,
  ) {
    if (query.isEmpty) {
      return Text(
        text,
        style: baseStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchIndex = lowerText.indexOf(lowerQuery);

    if (matchIndex == -1) {
      return Text(
        text,
        style: baseStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          // Phần trước keyword
          TextSpan(text: text.substring(0, matchIndex), style: baseStyle),
          // Keyword (highlight)
          TextSpan(
            text: text.substring(matchIndex, matchIndex + query.length),
            style: baseStyle.copyWith(
              color: AppColors.gradientStart,
              backgroundColor: AppColors.gradientStart.withValues(
                alpha: isDark ? 0.2 : 0.1,
              ),
              fontWeight: FontWeight.w800,
            ),
          ),
          // Phần sau keyword
          TextSpan(
            text: text.substring(matchIndex + query.length),
            style: baseStyle,
          ),
        ],
      ),
    );
  }
}
