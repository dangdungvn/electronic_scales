import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/models/api_response.dart';
import '../../../shared/widgets/connection_result_snackbar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../data/driver_provider.dart';
import '../domain/driver.dart';

/// Hiển thị bottom sheet để thêm/sửa tài xế
Future<void> showAddEditDriverSheet({
  required BuildContext context,
  Driver? driver,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => AddEditDriverSheet(driver: driver),
  );
}

/// Bottom sheet thêm/sửa tài xế
class AddEditDriverSheet extends HookConsumerWidget {
  const AddEditDriverSheet({super.key, this.driver});

  final Driver? driver;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = driver != null;

    // Text controllers
    final codeController = useTextEditingController(text: driver?.code ?? '');
    final nameController = useTextEditingController(text: driver?.name ?? '');
    final phoneController = useTextEditingController(text: driver?.phone ?? '');
    final idCardController = useTextEditingController(
      text: driver?.idCard ?? '',
    );
    final licenseNumberController = useTextEditingController(
      text: driver?.licenseNumber ?? '',
    );
    final addressController = useTextEditingController(
      text: driver?.address ?? '',
    );
    final issueDateController = useTextEditingController(
      text: driver?.issueDate ?? '',
    );
    final issuePlaceController = useTextEditingController(
      text: driver?.issuePlace ?? '',
    );
    final safetyPermitController = useTextEditingController(
      text: driver?.safetyPermit ?? '',
    );
    final expiryDateController = useTextEditingController(
      text: driver?.expiryDate ?? '',
    );
    final noteController = useTextEditingController(text: driver?.note ?? '');

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
                        Iconsax.driver,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isEditing ? 'Sửa Tài Xế' : 'Thêm Tài Xế',
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
                      icon: Iconsax.user,
                      title: 'Thông Tin Cơ Bản',
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      title: 'MÃ TÀI XẾ *',
                      placeholder: 'Nhập mã tài xế',
                      controller: codeController,
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập mã tài xế';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      title: 'TÊN TÀI XẾ *',
                      placeholder: 'Nhập tên tài xế',
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên tài xế';
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

                    // License Information Section
                    _SectionHeader(
                      icon: Iconsax.card,
                      title: 'Thông Tin Giấy Tờ',
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
                      title: 'BẰNG LÁI',
                      placeholder: 'Nhập số bằng lái',
                      controller: licenseNumberController,
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      title: 'NGÀY CẤP',
                      placeholder: 'Nhập ngày cấp',
                      controller: issueDateController,
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      title: 'NƠI CẤP',
                      placeholder: 'Nhập nơi cấp',
                      controller: issuePlaceController,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      title: 'GIẤY PHÉP AN TOÀN',
                      placeholder: 'Nhập giấy phép an toàn',
                      controller: safetyPermitController,
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      title: 'NGÀY HẾT HẠN',
                      placeholder: 'Nhập ngày hết hạn',
                      controller: expiryDateController,
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
                          phoneController,
                          idCardController,
                          licenseNumberController,
                          addressController,
                          issueDateController,
                          issuePlaceController,
                          safetyPermitController,
                          expiryDateController,
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
                          isEditing ? 'Cập nhật' : 'Thêm tài xế',
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
    TextEditingController idCardController,
    TextEditingController licenseNumberController,
    TextEditingController addressController,
    TextEditingController issueDateController,
    TextEditingController issuePlaceController,
    TextEditingController safetyPermitController,
    TextEditingController expiryDateController,
    TextEditingController noteController,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final request = Driver(
        id: isEditing ? (driver!.id ?? '') : '',
        code: codeController.text.trim(),
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        idCard: idCardController.text.trim(),
        licenseNumber: licenseNumberController.text.trim(),
        address: addressController.text.trim(),
        issueDate: issueDateController.text.trim(),
        issuePlace: issuePlaceController.text.trim(),
        safetyPermit: safetyPermitController.text.trim(),
        expiryDate: expiryDateController.text.trim(),
        note: noteController.text.trim(),
      );

      if (isEditing) {
        await ref.read(driverListProvider.notifier).updateDriver(request);
      } else {
        await ref.read(driverListProvider.notifier).addDriver(request);
      }

      if (context.mounted) {
        Navigator.of(context).pop();
        ConnectionResultSnackbar.showSimple(
          context,
          message: isEditing
              ? 'Cập nhật tài xế thành công'
              : 'Thêm tài xế thành công',
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
