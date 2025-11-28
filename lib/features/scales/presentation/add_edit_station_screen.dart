import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/widgets/connection_result_snackbar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../data/scale_station_provider.dart';
import '../domain/scale_station.dart';

/// Hiển thị bottom sheet để thêm/sửa trạm cân
Future<void> showAddEditStationSheet({
  required BuildContext context,
  ScaleStation? station,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => AddEditStationSheet(station: station),
  );
}

class AddEditStationSheet extends HookConsumerWidget {
  const AddEditStationSheet({super.key, this.station});

  final ScaleStation? station;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = station != null;
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // Controllers
    final nameController = useTextEditingController(text: station?.name ?? '');
    final ipController = useTextEditingController(text: station?.ip ?? '');
    final portController = useTextEditingController(
      text: station?.port.toString() ?? '',
    );
    final imagePortController = useTextEditingController(
      text: station?.imagePort.toString() ?? '85',
    );
    final usernameController = useTextEditingController(
      text: station?.username ?? '',
    );
    final passwordController = useTextEditingController(
      text: station?.password ?? '',
    );

    final isPasswordVisible = useState(false);
    final isLoading = useState(false);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Iconsax.weight_1,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isEditing ? 'Sửa Trạm Cân' : 'Thêm Trạm Cân',
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

            // Content
            Expanded(
              child: Form(
                key: formKey,
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _SectionHeader(
                      icon: Iconsax.info_circle,
                      title: 'Thông Tin Kết Nối',
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      title: 'TÊN TRẠM CÂN *',
                      placeholder: 'Ví dụ: Trạm cân số 1',
                      controller: nameController,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên trạm cân';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      title: 'ĐỊA CHỈ IP *',
                      placeholder: '192.168.1.100',
                      controller: ipController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập địa chỉ IP';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            title: 'CỔNG (PORT) *',
                            placeholder: '8080',
                            controller: portController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nhập cổng';
                              }
                              final port = int.tryParse(value);
                              if (port == null || port < 1 || port > 65535) {
                                return 'Sai cổng';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            title: 'CỔNG HÌNH ẢNH',
                            placeholder: '85',
                            controller: imagePortController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final port = int.tryParse(value);
                                if (port == null || port < 1 || port > 65535) {
                                  return 'Sai cổng';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SectionHeader(
                      icon: Iconsax.shield_tick,
                      title: 'Thông Tin Xác Thực',
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      title: 'TÊN ĐĂNG NHẬP *',
                      placeholder: 'admin',
                      controller: usernameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên đăng nhập';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      title: 'MẬT KHẨU *',
                      placeholder: '••••••••',
                      controller: passwordController,
                      obscureText: !isPasswordVisible.value,
                      showIcon: true,
                      icon: EyeIcon(isVisible: isPasswordVisible.value),
                      onIconTap: () {
                        isPasswordVisible.value = !isPasswordVisible.value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                          ipController,
                          portController,
                          imagePortController,
                          usernameController,
                          passwordController,
                        ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                          isEditing ? 'Cập Nhật' : 'Thêm Trạm Cân',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
    TextEditingController ipController,
    TextEditingController portController,
    TextEditingController imagePortController,
    TextEditingController usernameController,
    TextEditingController passwordController,
  ) async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final newStation = ScaleStation(
        id: station?.id,
        name: nameController.text.trim(),
        ip: ipController.text.trim(),
        port: int.parse(portController.text.trim()),
        imagePort: int.tryParse(imagePortController.text.trim()) ?? 85,
        username: usernameController.text.trim(),
        password: passwordController.text,
        createdAt: station?.createdAt ?? DateTime.now(),
      );

      if (isEditing) {
        await ref
            .read(scaleStationListProvider.notifier)
            .updateStation(newStation);
      } else {
        await ref
            .read(scaleStationListProvider.notifier)
            .addStation(newStation);
      }

      if (context.mounted) {
        Navigator.of(context).pop();
        ConnectionResultSnackbar.showSimple(
          context,
          message: isEditing
              ? 'Cập nhật trạm cân thành công'
              : 'Thêm trạm cân thành công',
          backgroundColor: const Color(0xFF4CAF50),
          icon: Iconsax.tick_circle,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ConnectionResultSnackbar.showSimple(
          context,
          message: 'Lỗi: ${e.toString()}',
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
