import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/models/api_response.dart';
import '../../../shared/widgets/connection_result_snackbar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../data/customer_provider.dart';
import '../domain/customer.dart';

/// Hiển thị bottom sheet để thêm/sửa khách hàng
Future<void> showAddEditCustomerSheet({
  required BuildContext context,
  Customer? customer,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => AddEditCustomerSheet(customer: customer),
  );
}

/// Bottom sheet thêm/sửa khách hàng
class AddEditCustomerSheet extends HookConsumerWidget {
  const AddEditCustomerSheet({super.key, this.customer});

  final Customer? customer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = customer != null;

    // Text controllers
    final codeController = useTextEditingController(text: customer?.code ?? '');
    final nameController = useTextEditingController(text: customer?.name ?? '');
    final phoneController = useTextEditingController(
      text: customer?.phone ?? '',
    );
    final addressController = useTextEditingController(
      text: customer?.address ?? '',
    );
    final idCardController = useTextEditingController(
      text: customer?.idCard ?? '',
    );
    final issueDateController = useTextEditingController(
      text: customer?.issueDate ?? '',
    );
    final issuePlaceController = useTextEditingController(
      text: customer?.issuePlace ?? '',
    );
    final taxCodeController = useTextEditingController(
      text: customer?.taxCode ?? '',
    );
    final noteController = useTextEditingController(text: customer?.note ?? '');

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
                      Icon(Iconsax.user, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isEditing ? 'Sửa Khách Hàng' : 'Thêm Khách Hàng',
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
                      icon: Iconsax.profile_circle,
                      title: 'Thông Tin Cơ Bản',
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      title: 'MÃ KHÁCH HÀNG *',
                      placeholder: 'Nhập mã khách hàng',
                      controller: codeController,
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập mã khách hàng';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      title: 'TÊN KHÁCH HÀNG *',
                      placeholder: 'Nhập tên khách hàng',
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên khách hàng';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      title: 'SỐ ĐIỆN THOẠI',
                      placeholder: 'Nhập số điện thoại',
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
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

                    // Tax Information Section
                    _SectionHeader(
                      icon: Iconsax.document_text,
                      title: 'Thông Tin Thuế & Giấy Tờ',
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      title: 'MÃ SỐ THUẾ',
                      placeholder: 'Nhập mã số thuế',
                      controller: taxCodeController,
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      title: 'CMND/CCCD',
                      placeholder: 'Nhập số CMND/CCCD',
                      controller: idCardController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      title: 'NGÀY CẤP',
                      placeholder: 'dd/mm/yyyy',
                      controller: issueDateController,
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      title: 'NƠI CẤP',
                      placeholder: 'Nhập nơi cấp',
                      controller: issuePlaceController,
                      textCapitalization: TextCapitalization.words,
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
                          codeController,
                          nameController,
                          phoneController,
                          addressController,
                          idCardController,
                          issueDateController,
                          issuePlaceController,
                          taxCodeController,
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
                          isEditing ? 'Cập nhật' : 'Thêm khách hàng',
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
    TextEditingController phoneController,
    TextEditingController addressController,
    TextEditingController idCardController,
    TextEditingController issueDateController,
    TextEditingController issuePlaceController,
    TextEditingController taxCodeController,
    TextEditingController noteController,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final request = CustomerRequest(
        id: isEditing ? (customer?.id ?? '') : '',
        code: codeController.text.trim(),
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        idCard: idCardController.text.trim(),
        issueDate: issueDateController.text.trim(),
        issuePlace: issuePlaceController.text.trim(),
        taxCode: taxCodeController.text.trim(),
        note: noteController.text.trim(),
      );

      if (isEditing) {
        await ref.read(customerListProvider.notifier).updateCustomer(request);
      } else {
        await ref.read(customerListProvider.notifier).addCustomer(request);
      }

      if (context.mounted) {
        Navigator.of(context).pop();
        ConnectionResultSnackbar.showSimple(
          context,
          message: isEditing
              ? 'Cập nhật khách hàng thành công'
              : 'Thêm khách hàng thành công',
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
