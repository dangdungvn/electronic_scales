import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/models/api_response.dart';
import '../../../shared/widgets/connection_result_snackbar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_toggle.dart';
import '../data/registered_vehicle_provider.dart';
import '../domain/registered_vehicle.dart';

/// Hiển thị bottom sheet để thêm/sửa xe đăng ký
Future<void> showAddEditVehicleSheet({
  required BuildContext context,
  RegisteredVehicle? vehicle,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => AddEditVehicleSheet(vehicle: vehicle),
  );
}

/// Bottom sheet thêm/sửa xe đăng ký
class AddEditVehicleSheet extends HookConsumerWidget {
  const AddEditVehicleSheet({super.key, this.vehicle});

  final RegisteredVehicle? vehicle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = vehicle != null;

    // Text controllers
    final customerNameController = useTextEditingController(
      text: vehicle?.customerName ?? '',
    );
    final customerIdCardController = useTextEditingController(
      text: vehicle?.customerIdCard ?? '',
    );
    final customerPhoneController = useTextEditingController(
      text: vehicle?.customerPhone ?? '',
    );
    final customerAddressController = useTextEditingController(
      text: vehicle?.customerAddress ?? '',
    );
    final customerTaxCodeController = useTextEditingController(
      text: vehicle?.customerTaxCode ?? '',
    );
    final frontPlateController = useTextEditingController(
      text: vehicle?.frontPlateNumber ?? '',
    );
    final rearPlateController = useTextEditingController(
      text: vehicle?.rearPlateNumber ?? '',
    );
    final driverNameController = useTextEditingController(
      text: vehicle?.driverName ?? '',
    );
    final driverPhoneController = useTextEditingController(
      text: vehicle?.driverPhone ?? '',
    );
    final driverIdCardController = useTextEditingController(
      text: vehicle?.driverIdCard ?? '',
    );
    final productNameController = useTextEditingController(
      text: vehicle?.productName ?? '',
    );
    final warehouseNameController = useTextEditingController(
      text: vehicle?.warehouseName ?? '',
    );
    final capacityController = useTextEditingController(
      text: vehicle?.capacity.toString() ?? '0',
    );
    final noteController = useTextEditingController(text: vehicle?.note ?? '');

    final isBlackList = useState(vehicle?.isBlackList ?? false);
    final isSpecialList = useState(vehicle?.isSpecialList ?? false);
    final singleWeighing = useState(vehicle?.singleWeighing ?? false);
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
                            Iconsax.car,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isEditing ? 'Sửa Xe Đăng Ký' : 'Thêm Xe Đăng Ký',
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
                        // Customer Information Section
                        _SectionHeader(
                          icon: Iconsax.user,
                          title: 'Thông Tin Khách Hàng',
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          title: 'TÊN KHÁCH HÀNG *',
                          placeholder: 'Nhập tên khách hàng',
                          controller: customerNameController,
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
                          title: 'CMND/CCCD',
                          placeholder: 'Nhập số CMND/CCCD',
                          controller: customerIdCardController,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          title: 'SỐ ĐIỆN THOẠI',
                          placeholder: 'Nhập số điện thoại',
                          controller: customerPhoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          title: 'ĐỊA CHỈ',
                          placeholder: 'Nhập địa chỉ',
                          controller: customerAddressController,
                          textCapitalization: TextCapitalization.words,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          title: 'MÃ SỐ THUẾ',
                          placeholder: 'Nhập mã số thuế',
                          controller: customerTaxCodeController,
                        ),
                        const SizedBox(height: 12),

                        // Vehicle Information Section
                        _SectionHeader(
                          icon: Iconsax.car,
                          title: 'Thông Tin Xe',
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          title: 'BIỂN SỐ ĐẦU XE *',
                          placeholder: 'VD: 30A-12345',
                          controller: frontPlateController,
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập biển số đầu xe';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          title: 'BIỂN SỐ ĐUÔI XE',
                          placeholder: 'VD: 30A-67890',
                          controller: rearPlateController,
                          textCapitalization: TextCapitalization.characters,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          title: 'TRỌNG TẢI (KG)',
                          placeholder: 'Nhập trọng tải',
                          controller: capacityController,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),

                        // Driver Information Section
                        _SectionHeader(
                          icon: Iconsax.driver,
                          title: 'Thông Tin Tài Xế',
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          title: 'TÊN LÁI XE *',
                          placeholder: 'Nhập tên lái xe',
                          controller: driverNameController,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập tên lái xe';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          title: 'SỐ ĐIỆN THOẠI TÀI XẾ',
                          placeholder: 'Nhập số điện thoại',
                          controller: driverPhoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          title: 'CMND/CCCD TÀI XẾ',
                          placeholder: 'Nhập số CMND/CCCD',
                          controller: driverIdCardController,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),

                        // Product Information Section
                        _SectionHeader(
                          icon: Iconsax.box,
                          title: 'Thông Tin Hàng Hóa',
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          title: 'TÊN LOẠI HÀNG *',
                          placeholder: 'Nhập tên loại hàng',
                          controller: productNameController,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập tên loại hàng';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          title: 'TÊN KHO HÀNG',
                          placeholder: 'Nhập tên kho hàng',
                          controller: warehouseNameController,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 12),

                        // Additional Options Section
                        _SectionHeader(
                          icon: Iconsax.setting_2,
                          title: 'Tùy Chọn',
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FE),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFC5C6CC),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              CustomToggle(
                                isOn: isBlackList.value,
                                onChanged: (value) => isBlackList.value = value,
                                label: 'Blacklist',
                              ),
                              const SizedBox(height: 12),
                              CustomToggle(
                                isOn: isSpecialList.value,
                                onChanged: (value) =>
                                    isSpecialList.value = value,
                                label: 'Danh sách đặc biệt',
                              ),
                              const SizedBox(height: 12),
                              CustomToggle(
                                isOn: singleWeighing.value,
                                onChanged: (value) =>
                                    singleWeighing.value = value,
                                label: 'Xe cân 1 lần',
                              ),
                            ],
                          ),
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
                              customerNameController,
                              customerIdCardController,
                              customerPhoneController,
                              customerAddressController,
                              customerTaxCodeController,
                              frontPlateController,
                              rearPlateController,
                              driverNameController,
                              driverPhoneController,
                              driverIdCardController,
                              productNameController,
                              warehouseNameController,
                              capacityController,
                              noteController,
                              isBlackList.value,
                              isSpecialList.value,
                              singleWeighing.value,
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
                              isEditing ? 'Cập nhật' : 'Thêm xe',
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
    TextEditingController customerNameController,
    TextEditingController customerIdCardController,
    TextEditingController customerPhoneController,
    TextEditingController customerAddressController,
    TextEditingController customerTaxCodeController,
    TextEditingController frontPlateController,
    TextEditingController rearPlateController,
    TextEditingController driverNameController,
    TextEditingController driverPhoneController,
    TextEditingController driverIdCardController,
    TextEditingController productNameController,
    TextEditingController warehouseNameController,
    TextEditingController capacityController,
    TextEditingController noteController,
    bool isBlackListValue,
    bool isSpecialListValue,
    bool singleWeighingValue,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final now = DateTime.now();
      final request = RegisteredVehicleRequest(
        syncId: isEditing ? (vehicle!.syncId ?? '') : '',
        customerName: customerNameController.text.trim(),
        customerIdCard: customerIdCardController.text.trim(),
        customerPhone: customerPhoneController.text.trim(),
        customerAddress: customerAddressController.text.trim(),
        customerTaxCode: customerTaxCodeController.text.trim(),
        customerNote: noteController.text.trim(),
        frontPlateNumber: frontPlateController.text.trim(),
        rearPlateNumber: rearPlateController.text.trim(),
        driverName: driverNameController.text.trim(),
        driverPhone: driverPhoneController.text.trim(),
        driverIdCard: driverIdCardController.text.trim(),
        productName: productNameController.text.trim(),
        warehouseName: warehouseNameController.text.trim(),
        capacity: int.tryParse(capacityController.text) ?? 0,
        note: noteController.text.trim(),
        isBlackList: isBlackListValue,
        isSpecialList: isSpecialListValue,
        singleWeighing: singleWeighingValue,
        registrationDate: now,
        weighingDate: now, // NgayCanBi giống NgayDangKy
      );

      if (isEditing) {
        await ref
            .read(registeredVehicleListProvider.notifier)
            .updateVehicle(request);
      } else {
        await ref
            .read(registeredVehicleListProvider.notifier)
            .addVehicle(request);
      }

      if (context.mounted) {
        Navigator.of(context).pop();
        ConnectionResultSnackbar.showSimple(
          context,
          message: isEditing ? 'Cập nhật xe thành công' : 'Thêm xe thành công',
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
