import 'package:flutter/material.dart';
import '../utils/constants.dart';

// === BOTTOM SHEET CÀI ĐẶT ĐỌC TRUYỆN ===
// Cho phép chọn màu nền trang đọc (đen, tối, xám, trắng)
class MangaReadingSettingsSheet extends StatefulWidget {
  final Color backgroundColor;
  final bool isFitWidth;
  final ValueChanged<Color> onBackgroundChanged;
  final ValueChanged<bool> onFitWidthChanged;

  const MangaReadingSettingsSheet({
    super.key,
    required this.backgroundColor,
    required this.isFitWidth,
    required this.onBackgroundChanged,
    required this.onFitWidthChanged,
  });

  @override
  State<MangaReadingSettingsSheet> createState() =>
      _MangaReadingSettingsSheetState();
}

class _MangaReadingSettingsSheetState extends State<MangaReadingSettingsSheet> {
  late Color _selectedColor;

  static const _colors = [
    (color: Colors.black, label: 'Đen'),
    (color: Color(0xFF1A1A2E), label: 'Tối'),
    (color: Color(0xFF2D2D2D), label: 'Xám'),
    (color: Colors.white, label: 'Trắng'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.backgroundColor;
  }

  void _selectColor(Color color) {
    setState(() => _selectedColor = color);
    widget.onBackgroundChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primaryMid : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Text(
            '⚙️ Cài Đặt Đọc Truyện',
            style: TextStyle(
              fontSize: AppFontSizes.title,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Text(
            'Màu nền',
            style: TextStyle(
              fontSize: AppFontSizes.body,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _colors
                .map((c) => _buildColorOption(
                      color: c.color,
                      label: c.label,
                      isSelected: _selectedColor == c.color,
                      isDark: isDark,
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xl),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildColorOption({
    required Color color,
    required String label,
    required bool isSelected,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => _selectColor(color),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppColors.gradientStart
                    : Colors.grey.shade400,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.gradientStart.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: color == Colors.white
                        ? AppColors.gradientStart
                        : Colors.white,
                    size: 20,
                  )
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: AppFontSizes.small,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// ReadingSettingsSheet: giữ lại để tương thích ngược, không dùng trực tiếp
class ReadingSettingsSheet extends StatelessWidget {
  final double fontSize;
  final Color backgroundColor;
  final Color textColor;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<int> onThemeChanged;

  const ReadingSettingsSheet({
    super.key,
    required this.fontSize,
    required this.backgroundColor,
    required this.textColor,
    required this.onFontSizeChanged,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
