import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/models/api_response.dart';
import '../../../shared/widgets/connection_result_snackbar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../data/weighing_type_provider.dart';
import '../domain/weighing_type.dart';

/// Hiển thị bottom sheet để thêm/sửa kiểu cân
Future<void> showAddEditWeighingTypeSheet({
  required BuildContext context,
  WeighingType? weighingType,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) =>
        AddEditWeighingTypeSheet(weighingType: weighingType),
  );
}

/// Bottom sheet thêm/sửa kiểu cân
class AddEditWeighingTypeSheet extends HookConsumerWidget {
  const AddEditWeighingTypeSheet({super.key, this.weighingType});

  final WeighingType? weighingType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = weighingType != null;

    // Text controllers
    final nameController = useTextEditingController(
      text: weighingType?.name ?? '',
    );
    final weighingCountController = useTextEditingController(
      text: weighingType?.weighingCount.toString() ?? '2',
    );
    final noteController = useTextEditingController(
      text: weighingType?.note ?? '',
    );

    final isLoading = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.93,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                        Iconsax.weight_1,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isEditing ? 'Sửa Kiểu Cân' : 'Thêm Kiểu Cân',
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
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  children: [
                    // Basic Information Section
                    _SectionHeader(
                      icon: Iconsax.info_circle,
                      title: 'Thông Tin Cơ Bản',
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      title: 'TÊN KIỂU CÂN *',
                      placeholder: 'Nhập tên kiểu cân',
                      controller: nameController,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên kiểu cân';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      title: 'SỐ LẦN CÂN *',
                      placeholder: 'Nhập số lần cân',
                      controller: weighingCountController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập số lần cân';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Số lần cân phải là số nguyên';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Note Section
                    _SectionHeader(icon: Iconsax.note_1, title: 'Ghi Chú'),
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
              decoration: const BoxDecoration(color: Colors.transparent),
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
                          nameController,
                          weighingCountController,
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
                          isEditing ? 'Cập nhật' : 'Thêm kiểu cân',
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
  }

  Future<void> _handleSave(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    bool isEditing,
    ValueNotifier<bool> isLoading,
    TextEditingController nameController,
    TextEditingController weighingCountController,
    TextEditingController noteController,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final request = WeighingType(
        id: isEditing ? (weighingType!.id) : 0,
        name: nameController.text.trim(),
        weighingCount: int.parse(weighingCountController.text.trim()),
        note: noteController.text.trim(),
      );

      if (isEditing) {
        await ref
            .read(weighingTypeListProvider.notifier)
            .updateWeighingType(request);
      } else {
        await ref
            .read(weighingTypeListProvider.notifier)
            .addWeighingType(request);
      }

      if (context.mounted) {
        Navigator.of(context).pop();
        ConnectionResultSnackbar.showSimple(
          context,
          message: isEditing
              ? 'Cập nhật kiểu cân thành công'
              : 'Thêm kiểu cân thành công',
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
