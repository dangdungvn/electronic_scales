import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/models/api_response.dart';
import '../../../shared/widgets/connection_result_snackbar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../data/goods_quality_provider.dart';
import '../domain/goods_quality.dart';

/// Hiển thị bottom sheet để thêm/sửa chất lượng hàng hóa
Future<void> showAddEditGoodsQualitySheet({
  required BuildContext context,
  GoodsQuality? goodsQuality,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) =>
        AddEditGoodsQualitySheet(goodsQuality: goodsQuality),
  );
}

/// Bottom sheet thêm/sửa chất lượng hàng hóa
class AddEditGoodsQualitySheet extends HookConsumerWidget {
  const AddEditGoodsQualitySheet({super.key, this.goodsQuality});

  final GoodsQuality? goodsQuality;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = goodsQuality != null;

    // Text controllers
    final codeController = useTextEditingController(
      text: goodsQuality?.code ?? '',
    );
    final nameController = useTextEditingController(
      text: goodsQuality?.name ?? '',
    );
    final noteController = useTextEditingController(
      text: goodsQuality?.note ?? '',
    );

    final isLoading = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    return DraggableScrollableSheet(
      initialChildSize: 0.93,
      minChildSize: 0.93,
      maxChildSize: 0.93,
      builder: (context, scrollController) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Title and close button
                      Row(
                        children: [
                          Icon(
                            Iconsax.verify,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isEditing
                                  ? 'Sửa Chất Lượng Hàng Hóa'
                                  : 'Thêm Chất Lượng Hàng Hóa',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Iconsax.close_circle),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Content - Scrollable form
                Expanded(
                  child: Form(
                    key: formKey,
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      children: [
                        // Basic Information Section
                        _SectionHeader(
                          icon: Iconsax.info_circle,
                          title: 'Thông Tin Cơ Bản',
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          title: 'MÃ CHẤT LƯỢNG *',
                          placeholder: 'Nhập mã chất lượng',
                          controller: codeController,
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập mã chất lượng';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          title: 'TÊN CHẤT LƯỢNG *',
                          placeholder: 'Nhập tên chất lượng',
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập tên chất lượng';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Additional Information Section
                        _SectionHeader(
                          icon: Iconsax.note,
                          title: 'Thông Tin Khác',
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          title: 'GHI CHÚ',
                          placeholder: 'Nhập ghi chú',
                          controller: noteController,
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // Fixed bottom button
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading.value
                          ? null
                          : () => _handleSave(
                              context,
                              ref,
                              formKey,
                              isEditing,
                              isLoading,
                              codeController,
                              nameController,
                              noteController,
                            ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEditing ? 'Cập nhật' : 'Thêm mới',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSave(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    bool isEditing,
    ValueNotifier<bool> isLoading,
    TextEditingController codeController,
    TextEditingController nameController,
    TextEditingController noteController,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final request = GoodsQuality(
        id: isEditing ? (goodsQuality!.id ?? '') : '',
        code: codeController.text.trim(),
        name: nameController.text.trim(),
        note: noteController.text.trim(),
      );

      if (isEditing) {
        await ref
            .read(goodsQualityListProvider.notifier)
            .updateGoodsQuality(request);
      } else {
        await ref
            .read(goodsQualityListProvider.notifier)
            .addGoodsQuality(request);
      }

      if (context.mounted) {
        Navigator.of(context).pop();
        ConnectionResultSnackbar.showSimple(
          context,
          message: isEditing
              ? 'Cập nhật chất lượng hàng hóa thành công'
              : 'Thêm chất lượng hàng hóa thành công',
          backgroundColor: const Color(0xFF4CAF50),
          icon: Iconsax.tick_circle,
        );
      }
    } catch (e) {
      String errorMessage = 'Lỗi: ${e.toString()}';
      if (e is ApiException) {
        errorMessage = e.message;
      }

      if (context.mounted) {
        ConnectionResultSnackbar.showSimple(
          context,
          message: errorMessage,
          backgroundColor: Colors.red,
          icon: Iconsax.close_circle,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}
