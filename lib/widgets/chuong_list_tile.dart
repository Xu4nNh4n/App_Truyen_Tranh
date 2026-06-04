import 'package:flutter/material.dart';
import '../models/Chuong.dart';
import '../utils/constants.dart';

// === WIDGET HIỂN THỊ MỘT CHƯƠNG TRONG DANH SÁCH ===
// Hiển thị số chương, tiêu đề, ngày đăng, badge VIP nếu bị khóa
class ChapterListTile extends StatelessWidget {
  final Chuong chuong;
  final VoidCallback onTap;
  final bool isCurrentChapter; // Danh dau chuong dang doc
  final bool isLocked; // Chuong bi khoa (can dang nhap)
  final bool isRead; // Chuong da doc (co the them sau)

  const ChapterListTile({
    super.key,
    required this.chuong,
    required this.onTap,
    this.isCurrentChapter = false,
    this.isLocked = false,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isCurrentChapter
              ? AppColors.gradientStart.withValues(alpha: isDark ? 0.15 : 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: isCurrentChapter
              ? Border.all(
                  color: AppColors.gradientStart.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Opacity(
          opacity: isRead ? 0.45 : 1.0,
          child: Row(
            children: [
              // So chuong (hinh tron)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isCurrentChapter
                      ? const LinearGradient(
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd,
                          ],
                        )
                      : null,
                  color: isCurrentChapter
                      ? null
                      : (isDark ? AppColors.cardDark : Colors.grey.shade100),
                ),
                child: Center(
                  child: Text(
                    '${chuong.soChuongText}',
                    style: TextStyle(
                      fontSize: AppFontSizes.small,
                      fontWeight: FontWeight.w700,
                      color: isCurrentChapter
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.grey.shade700),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Ten chuong + ngay dang
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chuong.tieuDe,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: AppFontSizes.body,
                              fontWeight: isCurrentChapter
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isCurrentChapter
                                  ? AppColors.gradientStart
                                  : (isDark
                                        ? Colors.white
                                        : AppColors.primaryDark),
                            ),
                          ),
                        ),
                        // Badge VIP
                        if (isLocked) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.gradientStart,
                                  AppColors.gradientEnd,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                            ),
                            child: const Text(
                              'VIP',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${chuong.trang.length} trang • ${_formatDate(chuong.ngayDang)}',
                      style: TextStyle(
                        fontSize: AppFontSizes.small,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              // Icon: khoa hoac mui ten
              Icon(
                isLocked
                    ? Icons.lock
                    : (isCurrentChapter
                          ? Icons.play_circle_filled
                          : Icons.chevron_right),
                color: isLocked
                    ? AppColors.gradientStart.withValues(alpha: 0.6)
                    : (isCurrentChapter
                          ? AppColors.gradientStart
                          : (isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade400)),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Format ngay thang
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
