import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/connection_result_snackbar.dart';
import '../data/scale_station_provider.dart';
import '../domain/scale_station.dart';
import '../widgets/form_header_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/password_text_field.dart';
import '../widgets/form_section_title.dart';

class AddEditStationScreen extends HookConsumerWidget {
  const AddEditStationScreen({super.key, this.station});

  final ScaleStation? station;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController(text: station?.name ?? '');
    final ipController = useTextEditingController(text: station?.ip ?? '');
    final portController = useTextEditingController(
      text: station?.port.toString() ?? '',
    );
    final usernameController = useTextEditingController(
      text: station?.username ?? '',
    );
    final passwordController = useTextEditingController(
      text: station?.password ?? '',
    );
    final isPasswordVisible = useState(false);
    final isSaving = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: Text(station == null ? 'Thêm Trạm Cân' : 'Sửa Trạm Cân'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_1),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header card
            FormHeaderCard(isEditMode: station != null),
            const SizedBox(height: 32),
            // Form section title
            const FormSectionTitle(title: 'Thông Tin Kết Nối'),
            CustomTextField(
              controller: nameController,
              label: 'Tên trạm cân',
              icon: Iconsax.edit,
              hint: 'Ví dụ: Trạm cân số 1',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên trạm cân';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: ipController,
              label: 'Địa chỉ IP',
              icon: Iconsax.global,
              hint: '192.168.1.100',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập địa chỉ IP';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: portController,
              label: 'Cổng (Port)',
              icon: Iconsax.setting_2,
              hint: '8080',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập cổng';
                }
                final port = int.tryParse(value);
                if (port == null || port < 1 || port > 65535) {
                  return 'Cổng phải từ 1 đến 65535';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            // Authentication section
            const FormSectionTitle(
              title: 'Thông Tin Xác Thực',
              icon: Iconsax.shield_tick,
            ),
            CustomTextField(
              controller: usernameController,
              label: 'Tên đăng nhập',
              icon: Iconsax.user,
              hint: 'admin',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên đăng nhập';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            PasswordTextField(
              controller: passwordController,
              isPasswordVisible: isPasswordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),
            // Save button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: isSaving.value
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          isSaving.value = true;
                          try {
                            final newStation = ScaleStation(
                              id: station?.id,
                              name: nameController.text.trim(),
                              ip: ipController.text.trim(),
                              port: int.parse(portController.text.trim()),
                              username: usernameController.text.trim(),
                              password: passwordController.text,
                              createdAt: station?.createdAt ?? DateTime.now(),
                            );

                            if (station == null) {
                              await ref
                                  .read(scaleStationListProvider.notifier)
                                  .addStation(newStation);
                            } else {
                              await ref
                                  .read(scaleStationListProvider.notifier)
                                  .updateStation(newStation);
                            }

                            if (context.mounted) {
                              context.pop();
                              ConnectionResultSnackbar.showSimple(
                                context,
                                message: station == null
                                    ? 'Thêm trạm cân thành công'
                                    : 'Cập nhật trạm cân thành công',
                                backgroundColor: const Color(0xFF4CAF50),
                                icon: Iconsax.tick_circle,
                              );
                            }
                          } catch (e) {
                            isSaving.value = false;
                            if (context.mounted) {
                              ConnectionResultSnackbar.showSimple(
                                context,
                                message: 'Lỗi: ${e.toString()}',
                                backgroundColor: Colors.red,
                                icon: Iconsax.close_circle,
                              );
                            }
                          }
                        }
                      },
                child: isSaving.value
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Đang lưu...'),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.tick_circle),
                          const SizedBox(width: 12),
                          Text(
                            station == null ? 'Thêm Trạm Cân' : 'Cập Nhật',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
