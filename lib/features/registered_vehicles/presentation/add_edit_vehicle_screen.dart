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
import '../../customers/data/customer_provider.dart';
import '../../customers/domain/customer.dart';
import '../../drivers/data/driver_provider.dart';
import '../../drivers/domain/driver.dart';
import '../../products/data/product_provider.dart';
import '../../products/domain/product.dart';
import '../../warehouses/data/warehouse_provider.dart';
import '../../warehouses/domain/warehouse.dart';

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

    // Fetch data for selections
    final customersAsync = ref.watch(customerListProvider);
    final driversAsync = ref.watch(driverListProvider);
    final productsAsync = ref.watch(productListProvider);
    final warehousesAsync = ref.watch(warehouseListProvider);

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

    // State for selected entities
    final selectedCustomer = useState<Customer?>(null);
    final selectedDriver = useState<Driver?>(null);

    // Initialize selected entities if editing
    useEffect(() {
      if (vehicle != null) {
        // Note: We don't have full objects in vehicle, so we rely on text fields initially.
        // If we wanted to pre-select the object, we'd need to find it in the list.
        // For now, we just let the text fields hold the values.
      }
      return null;
    }, []);

    // Listeners to clear selection if text changes
    useEffect(() {
      void listener() {
        if (selectedCustomer.value != null &&
            customerNameController.text != selectedCustomer.value!.name) {
          selectedCustomer.value = null;
        }
      }

      customerNameController.addListener(listener);
      return () => customerNameController.removeListener(listener);
    }, [selectedCustomer.value]);

    useEffect(() {
      void listener() {
        if (selectedDriver.value != null &&
            driverNameController.text != selectedDriver.value!.name) {
          selectedDriver.value = null;
        }
      }

      driverNameController.addListener(listener);
      return () => driverNameController.removeListener(listener);
    }, [selectedDriver.value]);

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
                      Icon(Iconsax.car, color: Theme.of(context).primaryColor),
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
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  children: [
                    // Customer Information Section
                    _SectionHeader(
                      icon: Iconsax.user,
                      title: 'Thông Tin Khách Hàng',
                    ),
                    const SizedBox(height: 8),
                    _InlineSearchField<Customer>(
                      label: 'TÊN KHÁCH HÀNG *',
                      placeholder: 'Nhập tên khách hàng để tìm kiếm',
                      controller: customerNameController,
                      items: customersAsync.asData?.value ?? [],
                      itemLabelBuilder: (item) => item.name,
                      itemSubtitleBuilder: (item) => item.phone ?? '',
                      onSelected: (customer) {
                        customerNameController.text = customer.name;
                        selectedCustomer.value = customer;

                        // Update other fields
                        customerIdCardController.text = customer.idCard ?? '';
                        customerPhoneController.text = customer.phone ?? '';
                        customerAddressController.text = customer.address ?? '';
                        customerTaxCodeController.text = customer.taxCode ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên khách hàng';
                        }
                        return null;
                      },
                    ),

                    if (selectedCustomer.value != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            _InfoDisplayRow(
                              label: 'CMND/CCCD',
                              value: selectedCustomer.value!.idCard,
                            ),
                            const SizedBox(height: 8),
                            _InfoDisplayRow(
                              label: 'SỐ ĐIỆN THOẠI',
                              value: selectedCustomer.value!.phone,
                            ),
                            const SizedBox(height: 8),
                            _InfoDisplayRow(
                              label: 'ĐỊA CHỈ',
                              value: selectedCustomer.value!.address,
                            ),
                            const SizedBox(height: 8),
                            _InfoDisplayRow(
                              label: 'MÃ SỐ THUẾ',
                              value: selectedCustomer.value!.taxCode,
                            ),
                          ],
                        ),
                      ),
                    ] else
                      ...[],
                    const SizedBox(height: 12),

                    // Vehicle Information Section
                    _SectionHeader(icon: Iconsax.car, title: 'Thông Tin Xe'),
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
                    _InlineSearchField<Driver>(
                      label: 'TÊN LÁI XE *',
                      placeholder: 'Nhập tên lái xe để tìm kiếm',
                      controller: driverNameController,
                      items: driversAsync.asData?.value ?? [],
                      itemLabelBuilder: (item) => item.name,
                      itemSubtitleBuilder: (item) => item.phone,
                      onSelected: (driver) {
                        driverNameController.text = driver.name;
                        selectedDriver.value = driver;

                        // Update other fields
                        driverPhoneController.text = driver.phone;
                        driverIdCardController.text = driver.idCard;
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên lái xe';
                        }
                        return null;
                      },
                    ),

                    if (selectedDriver.value != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            _InfoDisplayRow(
                              label: 'SỐ ĐIỆN THOẠI',
                              value: selectedDriver.value!.phone,
                            ),
                            const SizedBox(height: 8),
                            _InfoDisplayRow(
                              label: 'CMND/CCCD',
                              value: selectedDriver.value!.idCard,
                            ),
                          ],
                        ),
                      ),
                    ] else
                      ...[],
                    const SizedBox(height: 12),

                    // Product Information Section
                    _SectionHeader(
                      icon: Iconsax.box,
                      title: 'Thông Tin Hàng Hóa',
                    ),
                    const SizedBox(height: 8),
                    _InlineSearchField<Product>(
                      label: 'TÊN LOẠI HÀNG *',
                      placeholder: 'Nhập tên loại hàng để tìm kiếm',
                      controller: productNameController,
                      items: productsAsync.asData?.value ?? [],
                      itemLabelBuilder: (item) => item.name,
                      itemSubtitleBuilder: (item) => item.code,
                      onSelected: (product) {
                        productNameController.text = product.name;
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên loại hàng';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    _InlineSearchField<Warehouse>(
                      label: 'TÊN KHO HÀNG',
                      placeholder: 'Nhập tên kho hàng để tìm kiếm',
                      controller: warehouseNameController,
                      items: warehousesAsync.asData?.value ?? [],
                      itemLabelBuilder: (item) => item.name,
                      itemSubtitleBuilder: (item) => item.address,
                      onSelected: (warehouse) {
                        warehouseNameController.text = warehouse.name;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Additional Options Section
                    _SectionHeader(icon: Iconsax.setting_2, title: 'Tùy Chọn'),
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
                            onChanged: (value) => isSpecialList.value = value,
                            label: 'Danh sách đặc biệt',
                          ),
                          const SizedBox(height: 12),
                          CustomToggle(
                            isOn: singleWeighing.value,
                            onChanged: (value) => singleWeighing.value = value,
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

class _InlineSearchField<T extends Object> extends StatelessWidget {
  const _InlineSearchField({
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.items,
    required this.itemLabelBuilder,
    required this.itemSubtitleBuilder,
    required this.onSelected,
    this.validator,
  });

  final String label;
  final String placeholder;
  final TextEditingController controller;
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final String Function(T) itemSubtitleBuilder;
  final Function(T) onSelected;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8F9098),
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Autocomplete<T>(
              initialValue: TextEditingValue(text: controller.text),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return items;
                }
                return items.where((T option) {
                  return itemLabelBuilder(
                    option,
                  ).toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              displayStringForOption: itemLabelBuilder,
              onSelected: onSelected,
              fieldViewBuilder:
                  (
                    BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    return _AutocompleteFieldView(
                      fieldTextEditingController: fieldTextEditingController,
                      fieldFocusNode: fieldFocusNode,
                      parentController: controller,
                      placeholder: placeholder,
                      validator: validator,
                    );
                  },
              optionsViewBuilder:
                  (
                    BuildContext context,
                    AutocompleteOnSelected<T> onSelected,
                    Iterable<T> options,
                  ) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: constraints.maxWidth,
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final T option = options.elementAt(index);
                              return InkWell(
                                onTap: () => onSelected(option),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        itemLabelBuilder(option),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (itemSubtitleBuilder(
                                        option,
                                      ).isNotEmpty)
                                        Text(
                                          itemSubtitleBuilder(option),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
            );
          },
        ),
      ],
    );
  }
}

class _AutocompleteFieldView extends HookWidget {
  const _AutocompleteFieldView({
    required this.fieldTextEditingController,
    required this.fieldFocusNode,
    required this.parentController,
    required this.placeholder,
    this.validator,
  });

  final TextEditingController fieldTextEditingController;
  final FocusNode fieldFocusNode;
  final TextEditingController parentController;
  final String placeholder;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    // Sync the internal controller with the external one if needed
    // But here we want the external one to control the text

    // We need to listen to changes to update the parent controller
    useEffect(() {
      void listener() {
        parentController.text = fieldTextEditingController.text;
      }

      fieldTextEditingController.addListener(listener);
      return () => fieldTextEditingController.removeListener(listener);
    }, [fieldTextEditingController]);

    // If the parent controller changes (e.g. initial value), update this one
    useEffect(() {
      if (fieldTextEditingController.text != parentController.text) {
        fieldTextEditingController.text = parentController.text;
      }
      return null;
    }, [parentController.text]);

    return TextFormField(
      controller: fieldTextEditingController,
      focusNode: fieldFocusNode,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: const TextStyle(color: Color(0xFFC5C6CC)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC5C6CC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC5C6CC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        suffixIcon: const Icon(Iconsax.search_normal, size: 20),
      ),
      validator: validator,
    );
  }
}

class _InfoDisplayRow extends StatelessWidget {
  const _InfoDisplayRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value ?? '-',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
