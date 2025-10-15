import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/widgets/connection_result_snackbar.dart';
import '../data/scale_station_provider.dart';
import '../domain/scale_station.dart';

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
          icon: const Icon(Iconsax.arrow_left_1_copy),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.weight_1,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station == null ? 'Trạm Cân Mới' : 'Cập Nhật',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          station == null
                              ? 'Điền thông tin bên dưới'
                              : 'Chỉnh sửa thông tin trạm cân',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Form section title
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Thông Tin Kết Nối',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            _buildTextField(
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
            _buildTextField(
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
            _buildTextField(
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
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Row(
                children: [
                  Icon(Iconsax.shield_tick, size: 18, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Thông Tin Xác Thực',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            _buildTextField(
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
            _buildPasswordField(
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
                              Navigator.pop(context);
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: .5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: .5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: .5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: .5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: .5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      textCapitalization: TextCapitalization.none,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required ValueNotifier<bool> isPasswordVisible,
    String? Function(String?)? validator,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: isPasswordVisible,
      builder: (context, visible, _) {
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Mật khẩu',
            hintText: '••••••••',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: const Icon(Iconsax.lock, color: Color(0xFF2196F3)),
            suffixIcon: IconButton(
              icon: Icon(
                visible ? Iconsax.eye : Iconsax.eye_slash,
                color: Colors.grey[600],
              ),
              onPressed: () {
                isPasswordVisible.value = !isPasswordVisible.value;
              },
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: .5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: .5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: .5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: .5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: .5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          obscureText: !visible,
          validator: validator,
          style: const TextStyle(fontSize: 16),
        );
      },
    );
  }
}
