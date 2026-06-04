import 'package:flutter/material.dart';
import '../controllers/AdminController.dart';
import '../models/Chuong.dart';
import '../models/Truyen.dart';
import '../models/TheLoai.dart';
import '../services/hugging_face_service.dart';
import '../utils/constants.dart';

// === MÀN HÌNH ADMIN ===
// Quản lý truyện (thêm/sửa/xóa/chương) và thể loại qua 2 tab
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _controller = AdminController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản Trị'),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: AppColors.gradientStart,
            labelColor: AppColors.gradientStart,
            unselectedLabelColor: isDark
                ? Colors.grey.shade400
                : Colors.grey.shade600,
            tabs: const [
              Tab(icon: Icon(Icons.book), text: 'Truyện'),
              Tab(icon: Icon(Icons.category), text: 'Thể loại'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildStoriesTab(isDark), _buildCategoriesTab(isDark)],
        ),
      ),
    );
  }

  // === TAB 1: TRUYỆN ===
  Widget _buildStoriesTab(bool isDark) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStoryDialog(isDark),
        backgroundColor: AppColors.gradientStart,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Truyen>>(
        stream: _controller.xemDanhSachTruyen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final stories = snapshot.data ?? [];
          if (stories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có truyện nào',
                    style: TextStyle(
                      fontSize: AppFontSizes.medium,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final truyen = stories[index];
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  leading: Container(
                    width: 50,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      color: AppColors.gradientStart.withValues(alpha: 0.1),
                    ),
                    child: truyen.anhBia.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: truyen.anhBia.startsWith('http')
                                ? Image.network(
                                    truyen.anhBia,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    truyen.anhBia,
                                    fit: BoxFit.cover,
                                  ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.book,
                              color: AppColors.gradientStart,
                            ),
                          ),
                  ),
                  title: Text(
                    truyen.tenTruyen,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                  subtitle: Text(
                    '${truyen.soChuong} chương • ${truyen.luotXem} views • ⭐ ${truyen.danhGia}',
                    style: TextStyle(
                      fontSize: AppFontSizes.small,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _showEditStoryDialog(truyen, isDark);
                      if (v == 'add_chapter') _showAddChapterDialog(truyen, isDark);
                      if (v == 'manage_chapters') _showManageChaptersDialog(truyen, isDark);
                      if (v == 'delete') _confirmDeleteTruyen(truyen, isDark);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Sửa truyện')]),
                      ),
                      const PopupMenuItem(
                        value: 'add_chapter',
                        child: Row(children: [Icon(Icons.add_circle, size: 18), SizedBox(width: 8), Text('Thêm chương')]),
                      ),
                      const PopupMenuItem(
                        value: 'manage_chapters',
                        child: Row(children: [Icon(Icons.list, size: 18), SizedBox(width: 8), Text('Quản lý chương')]),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Xóa truyện', style: TextStyle(color: Colors.red))]),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // === TAB 2: THỂ LOẠI ===
  Widget _buildCategoriesTab(bool isDark) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(isDark),
        backgroundColor: AppColors.gradientEnd,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<TheLoai>>(
        stream: _controller.xemDanhSachTheLoai(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final cats = snapshot.data ?? [];
          if (cats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có thể loại nào',
                    style: TextStyle(
                      fontSize: AppFontSizes.medium,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhấn + để thêm',
                    style: TextStyle(
                      fontSize: AppFontSizes.body,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: cats.length,
            itemBuilder: (context, index) {
              final cat = cats[index];
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gradientStart.withValues(alpha: 0.15),
                          AppColors.gradientEnd.withValues(alpha: 0.15),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.label,
                        color: AppColors.gradientStart,
                        size: 20,
                      ),
                    ),
                  ),
                  title: Text(
                    cat.ten,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.blue.shade400,
                        ),
                        onPressed: () => _showEditCategoryDialog(cat, isDark),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.red.shade400,
                        ),
                        onPressed: () => _confirmDeleteCategory(cat, isDark),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // === DIALOG: THÊM TRUYỆN ===
  void _showAddStoryDialog(bool isDark) {
    final titleController = TextEditingController(),
        authorController = TextEditingController(),
        descriptionController = TextEditingController();
    final coverImageController = TextEditingController(),
        genresController = TextEditingController();
    final freeChaptersController = TextEditingController(text: '3'),
        coinPerChapterController = TextEditingController(text: '5');
    _showStoryForm(
      isDark,
      'Thêm Truyện Mới',
      titleController,
      authorController,
      descriptionController,
      coverImageController,
      genresController,
      freeChaptersController,
      coinPerChapterController,
      'Thêm',
      () async {
        final form = TruyenMoiForm.fromText(
          tenTruyen: titleController.text,
          tacGia: authorController.text,
          moTa: descriptionController.text,
          anhBia: coverImageController.text,
          theLoai: genresController.text,
          chuongMienPhi: freeChaptersController.text,
          xuMoiChuong: coinPerChapterController.text,
        );
        if (!form.isValid) return;
        Navigator.pop(context);
        await _controller.themTruyen(form);
        if (mounted) _snack('✅ Đã thêm truyện mới!', AppColors.success);
      },
    );
  }

  // === DIALOG: SỬA TRUYỆN ===
  void _showEditStoryDialog(Truyen s, bool isDark) {
    final titleController = TextEditingController(text: s.tenTruyen),
        authorController = TextEditingController(text: s.tacGia);
    final descriptionController = TextEditingController(text: s.moTa),
        coverImageController = TextEditingController(text: s.anhBia);
    final genresController = TextEditingController(text: s.theLoai.join(', '));
    final freeChaptersController = TextEditingController(
          text: '${s.chuongMienPhi}',
        ),
        coinPerChapterController = TextEditingController(
          text: '${s.xuMoiChuong}',
        );
    _showStoryForm(
      isDark,
      'Sửa Truyện',
      titleController, // Tên truyện
      authorController, // Tác giả
      descriptionController, // Mô tả
      coverImageController, // URL ảnh bìa
      genresController, //Thể loại
      freeChaptersController, // Số chương miễn phí
      coinPerChapterController, // Giá xu / chương
      'Lưu',
      () async {
        final form = TruyenMoiForm.fromText(
          tenTruyen: titleController.text,
          tacGia: authorController.text,
          moTa: descriptionController.text,
          anhBia: coverImageController.text,
          theLoai: genresController.text,
          chuongMienPhi: freeChaptersController.text,
          xuMoiChuong: coinPerChapterController.text,
        );
        if (!form.isValid) return;
        Navigator.pop(context);
        await _controller.capNhatTruyen(s, form);
        if (mounted) _snack('✅ Đã cập nhật truyện!', AppColors.success);
      },
    );
  }

  void _showStoryForm(
    bool isDark,
    String title,
    TextEditingController titleController,
    TextEditingController authorController,
    TextEditingController descriptionController,
    TextEditingController coverImageController,
    TextEditingController genresController,
    TextEditingController freeChaptersController,
    TextEditingController coinPerChapterController,
    String action,
    VoidCallback onSubmit,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(titleController, 'Tên truyện', isDark),
              _field(authorController, 'Tác giả', isDark),
              _field(descriptionController, 'Mô tả', isDark, maxLines: 3),
              _field(coverImageController, 'URL ảnh bìa', isDark),
              _field(
                genresController,
                'Thể loại (cách nhau bởi dấu ,)',
                isDark,
              ),
              _field(freeChaptersController, 'Số chương miễn phí', isDark),
              _field(coinPerChapterController, 'Giá xu / chương', isDark),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gradientStart,
              foregroundColor: Colors.white,
            ),
            child: Text(action),
          ),
        ],
      ),
    );
  }

  // === DIALOG: THÊM CHƯƠNG ===
  void _showAddChapterDialog(Truyen truyen, bool isDark) {
    final chapterNumberController = TextEditingController(
      text: '${truyen.soChuong + 1}',
    );
    final chapterTitleController = TextEditingController();
    final folderPathController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Text(
            'Thêm Chương - ${truyen.tenTruyen}',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.primaryDark,
              fontWeight: FontWeight.w700,
              fontSize: AppFontSizes.medium,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(chapterNumberController, 'Số chương', isDark),
                _field(chapterTitleController, 'Tiêu đề chương', isDark),
                _field(
                  folderPathController,
                  'Folder Hugging Face',
                  isDark,
                  hint: 'xu4nnh4n/manga-images/momogusa-san/c001',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setStateDialog(() => isLoading = true);

                      // Kiểm tra trùng số chương
                      final soChuongMoi = double.tryParse(chapterNumberController.text);
                      if (soChuongMoi != null) {
                        final existing = await _controller.layChuong(truyen.truyenID);
                        final trung = existing.any((c) => c.soChuong == soChuongMoi);
                        if (trung) {
                          setStateDialog(() => isLoading = false);
                          if (mounted) _snack('⚠️ Chương ${chapterNumberController.text} đã tồn tại!', Colors.orange);
                          return;
                        }
                      }

                      final urls = await HuggingFaceService.fetchImageUrls(
                        folderPathController.text.trim(),
                      );
                      if (urls.isEmpty) {
                        setStateDialog(() => isLoading = false);
                        if (mounted) {
                          _snack('❌ Không tìm thấy ảnh, kiểm tra lại đường dẫn!', AppColors.accent);
                        }
                        return;
                      }
                      final form = ChuongMoiForm(
                        soChuong: double.tryParse(chapterNumberController.text),
                        tieuDe: chapterTitleController.text.trim(),
                        trang: urls,
                      );
                      Navigator.pop(ctx);
                      await _controller.themChuong(truyen, form);
                      if (mounted) _snack('✅ Đã thêm chương mới! (${urls.length} trang)', AppColors.success);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gradientStart,
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  // === DIALOG: QUẢN LÝ CHƯƠNG ===
  void _showManageChaptersDialog(Truyen truyen, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text(
          'Chương - ${truyen.tenTruyen}',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryDark,
            fontWeight: FontWeight.w700,
            fontSize: AppFontSizes.medium,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<Chuong>>(
            future: _controller.layChuong(truyen.truyenID),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final chapters = snapshot.data ?? [];
              if (chapters.isEmpty) {
                return const Text('Chưa có chương nào');
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: chapters.length,
                itemBuilder: (_, i) {
                  final chuong = chapters[i];
                  return ListTile(
                    dense: true,
                    title: Text(
                      'Chương ${chuong.soChuongText}: ${chuong.tieuDe}',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.primaryDark,
                        fontSize: AppFontSizes.body,
                      ),
                    ),
                    subtitle: Text(
                      '${chuong.trang.length} trang',
                      style: TextStyle(
                        color: chuong.trang.isEmpty ? Colors.red : Colors.grey,
                        fontSize: AppFontSizes.small,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue.shade400, size: 20),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showEditChapterDialog(truyen, chuong, isDark);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await _controller.xoaChuong(truyen.truyenID, chuong.id);
                            if (mounted) _snack('🗑️ Đã xóa chương ${chuong.soChuongText}', AppColors.accent);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  // === DIALOG: SỬA CHƯƠNG ===
  void _showEditChapterDialog(Truyen truyen, Chuong chuong, bool isDark) {
    final soController = TextEditingController(text: chuong.soChuongText);
    final tieuDeController = TextEditingController(text: chuong.tieuDe);
    final folderController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: Text(
            'Sửa Chương ${chuong.soChuongText}',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.primaryDark,
              fontWeight: FontWeight.w700,
              fontSize: AppFontSizes.medium,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(soController, 'Số chương', isDark),
                _field(tieuDeController, 'Tiêu đề chương', isDark),
                _field(
                  folderController,
                  'Folder HuggingFace mới (để trống = giữ ảnh cũ)',
                  isDark,
                  hint: 'xu4nnh4n/manga-images/momogusa-san/c001',
                ),
                if (chuong.trang.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('⚠️ Chương này đang không có ảnh', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                setStateDialog(() => isLoading = true);
                List<String>? trangMoi;
                if (folderController.text.trim().isNotEmpty) {
                  trangMoi = await HuggingFaceService.fetchImageUrls(folderController.text.trim());
                  if (trangMoi.isEmpty) {
                    setStateDialog(() => isLoading = false);
                    if (mounted) _snack('❌ Không tìm thấy ảnh, kiểm tra lại đường dẫn!', AppColors.accent);
                    return;
                  }
                }
                Navigator.pop(ctx);
                await _controller.capNhatChuong(
                  truyen.truyenID,
                  chuong.id,
                  soChuong: double.tryParse(soController.text),
                  tieuDe: tieuDeController.text.trim(),
                  trang: trangMoi,
                );
                if (mounted) _snack('✅ Đã cập nhật chương!', AppColors.success);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gradientStart, foregroundColor: Colors.white),
              child: isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  // === DIALOG: XÁC NHẬN XÓA TRUYỆN ===
  void _confirmDeleteTruyen(Truyen truyen, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Xóa "${truyen.tenTruyen}"?',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Hành động này không thể hoàn tác!',
          style: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _controller.xoaTruyen(truyen);
              if (mounted) _snack('🗑️ Đã xóa truyện', AppColors.accent);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  // === DIALOGS: THỂ LOẠI ===
  void _showAddCategoryDialog(bool isDark) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Thêm Thể Loại',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: _field(ctrl, 'Tên thể loại', isDark),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await _controller.themTheLoai(ctrl.text);
              if (mounted) _snack('✅ Đã thêm thể loại!', AppColors.success);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gradientEnd,
              foregroundColor: Colors.white,
            ),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(TheLoai cat, bool isDark) {
    final ctrl = TextEditingController(text: cat.ten);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Sửa Thể Loại',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: _field(ctrl, 'Tên thể loại', isDark),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await _controller.capNhatTheLoai(cat, ctrl.text);
              if (mounted) _snack('✅ Đã cập nhật!', AppColors.success);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gradientEnd,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  // === DIALOG: XÁC NHẬN XÓA THỂ LOẠI ===
  void _confirmDeleteCategory(TheLoai cat, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Xóa "${cat.ten}"?',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Thể loại sẽ bị xóa vĩnh viễn.',
          style: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _controller.xoaTheLoai(cat);
              if (mounted) _snack('🗑️ Đã xóa thể loại', AppColors.accent);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  // === HELPERS ===
  // Hiển thị snackbar thông báo nhanh
  void _snack(String msg, Color c) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: c,
          behavior: SnackBarBehavior.floating,
        ),
      );

  Widget _field(
    TextEditingController ctrl,
    String label,
    bool isDark, {
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: TextStyle(color: isDark ? Colors.white : AppColors.primaryDark),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            fontSize: AppFontSizes.small,
          ),
          labelStyle: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontSize: AppFontSizes.body,
          ),
          filled: true,
          fillColor: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: BorderSide(
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: BorderSide(
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: const BorderSide(
              color: AppColors.gradientStart,
              width: 2,
            ),
          ),
          isDense: true,
        ),
      ),
    );
  }
}
