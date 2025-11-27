import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/models/api_response.dart';
import '../../../shared/widgets/connection_result_snackbar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../data/product_provider.dart';
import '../domain/product.dart';

/// Hiển thị bottom sheet để thêm/sửa hàng hóa
Future<void> showAddEditProductSheet({
  required BuildContext context,
  Product? product,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => AddEditProductSheet(product: product),
  );
}

/// Bottom sheet thêm/sửa hàng hóa
class AddEditProductSheet extends HookConsumerWidget {
  const AddEditProductSheet({super.key, this.product});

  final Product? product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = product != null;

    // Text controllers
    final codeController = useTextEditingController(text: product?.code ?? '');
    final nameController = useTextEditingController(text: product?.name ?? '');
    final priceController = useTextEditingController(
      text: product?.price.toString() ?? '0.0',
    );
    final conversionRateController = useTextEditingController(
      text: product?.conversionRate.toString() ?? '1.0',
    );
    final conversionRate2Controller = useTextEditingController(
      text: product?.conversionRate2.toString() ?? '1.0',
    );
    final noteController = useTextEditingController(text: product?.note ?? '');

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
                      Icon(Iconsax.box, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isEditing ? 'Sửa Hàng Hóa' : 'Thêm Hàng Hóa',
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
                      title: 'MÃ HÀNG HÓA *',
                      placeholder: 'Nhập mã hàng hóa',
                      controller: codeController,
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập mã hàng hóa';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      title: 'TÊN HÀNG HÓA *',
                      placeholder: 'Nhập tên hàng hóa',
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên hàng hóa';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Pricing and Conversion Section
                    _SectionHeader(icon: Iconsax.money, title: 'Giá & Quy Đổi'),
                    const SizedBox(height: 8),
                    CustomTextField(
                      title: 'ĐƠN GIÁ',
                      placeholder: '0.0',
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            title: 'TỶ LỆ QUY ĐỔI',
                            placeholder: '1.0',
                            controller: conversionRateController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            title: 'TỶ LỆ QUY ĐỔI 2',
                            placeholder: '1.0',
                            controller: conversionRate2Controller,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Additional Information Section
                    _SectionHeader(icon: Iconsax.note, title: 'Thông Tin Khác'),
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
                          priceController,
                          conversionRateController,
                          conversionRate2Controller,
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
                          isEditing ? 'Cập nhật' : 'Thêm hàng hóa',
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
    TextEditingController codeController,
    TextEditingController nameController,
    TextEditingController priceController,
    TextEditingController conversionRateController,
    TextEditingController conversionRate2Controller,
    TextEditingController noteController,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final request = Product(
        id: isEditing ? (product!.id ?? '') : '',
        code: codeController.text.trim(),
        name: nameController.text.trim(),
        price: double.tryParse(priceController.text.trim()) ?? 0.0,
        conversionRate:
            double.tryParse(conversionRateController.text.trim()) ?? 1.0,
        conversionRate2:
            double.tryParse(conversionRate2Controller.text.trim()) ?? 1.0,
        note: noteController.text.trim(),
      );

      if (isEditing) {
        await ref.read(productListProvider.notifier).updateProduct(request);
      } else {
        await ref.read(productListProvider.notifier).addProduct(request);
      }

      if (context.mounted) {
        Navigator.of(context).pop();
        ConnectionResultSnackbar.showSimple(
          context,
          message: isEditing
              ? 'Cập nhật hàng hóa thành công'
              : 'Thêm hàng hóa thành công',
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
