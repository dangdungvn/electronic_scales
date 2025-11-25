import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/models/api_response.dart';
import '../../../shared/widgets/connection_result_snackbar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../data/warehouse_provider.dart';
import '../domain/warehouse.dart';

/// Hiển thị bottom sheet để thêm/sửa kho hàng
Future<void> showAddEditWarehouseSheet({
  required BuildContext context,
  Warehouse? warehouse,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => AddEditWarehouseSheet(warehouse: warehouse),
  );
}

/// Bottom sheet thêm/sửa kho hàng
class AddEditWarehouseSheet extends HookConsumerWidget {
  const AddEditWarehouseSheet({super.key, this.warehouse});

  final Warehouse? warehouse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = warehouse != null;

    // Text controllers
    final nameController = useTextEditingController(
      text: warehouse?.name ?? '',
    );
    final addressController = useTextEditingController(
      text: warehouse?.address ?? '',
    );
    final noteController = useTextEditingController(
      text: warehouse?.note ?? '',
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
                            Iconsax.building,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isEditing ? 'Sửa Kho Hàng' : 'Thêm Kho Hàng',
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
                          title: 'TÊN KHO HÀNG *',
                          placeholder: 'Nhập tên kho hàng',
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập tên kho hàng';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          title: 'ĐỊA CHỈ',
                          placeholder: 'Nhập địa chỉ',
                          controller: addressController,
                          textCapitalization: TextCapitalization.words,
                          maxLines: 2,
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
                              nameController,
                              addressController,
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
                              isEditing ? 'Cập nhật' : 'Thêm kho hàng',
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
    TextEditingController nameController,
    TextEditingController addressController,
    TextEditingController noteController,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final request = Warehouse(
        id: isEditing ? (warehouse!.id ?? '') : '',
        name: nameController.text.trim(),
        address: addressController.text.trim(),
        note: noteController.text.trim(),
      );

      if (isEditing) {
        await ref.read(warehouseListProvider.notifier).updateWarehouse(request);
      } else {
        await ref.read(warehouseListProvider.notifier).addWarehouse(request);
      }

      if (context.mounted) {
        Navigator.of(context).pop();
        ConnectionResultSnackbar.showSimple(
          context,
          message: isEditing
              ? 'Cập nhật kho hàng thành công'
              : 'Thêm kho hàng thành công',
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
