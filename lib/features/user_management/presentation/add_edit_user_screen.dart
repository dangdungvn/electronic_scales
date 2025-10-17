import 'package:electronic_scales/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../domain/user.dart';
import '../data/user_repository.dart';
import '../data/user_provider.dart';
import '../data/user_group_provider.dart';
import '../widgets/permission_widgets.dart';
import '../../scales/data/scale_station_provider.dart';
import '../../home/data/permissions_provider.dart';

/// Screen để thêm/sửa người dùng
class AddEditUserScreen extends HookConsumerWidget {
  const AddEditUserScreen({super.key, this.user});

  /// Người dùng cần sửa (null = thêm mới)
  final User? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = user != null;
    final nameController = useTextEditingController(text: user?.name ?? '');
    final loginController = useTextEditingController(text: user?.login ?? '');
    final passwordController = useTextEditingController(
      text: user?.password ?? '',
    );
    final descriptionController = useTextEditingController(
      text: user?.description ?? '',
    );
    final isLoading = useState(false);

    // Helper để parse permission string
    Map<String, bool> parsePermString(String? permString) {
      final result = <String, bool>{};
      if (permString == null || permString.isEmpty) return result;

      final pairs = permString.split(';');
      for (var pair in pairs) {
        final parts = pair.trim().split('=');
        if (parts.length == 2) {
          result[parts[0].trim()] = parts[1].trim().toLowerCase() == 'true';
        }
      }
      return result;
    }

    // Parse permissions từ user nếu đang edit
    final qlDuLieuPerms = parsePermString(user?.quanLyDuLieu);
    final bcTongHopPerms = parsePermString(user?.baoCaoTongHop);
    final bcCanLan2Perms = parsePermString(user?.baoCaoChoCanLan2);

    // Selected user group
    final selectedUserGroupId = useState<String?>(user?.idNhomUser);

    // Boolean permissions
    final quanLyNguoiDung = useState(user?.quanLyNguoiDung ?? false);
    final cauHinhHeThong = useState(user?.cauHinhHeThong ?? false);
    final baoCaoLog = useState(user?.baoCaoLog ?? false);
    final baoCaoThongKe = useState(user?.baoCaoThongKe ?? false);

    // Detailed permissions - Quản lý dữ liệu
    final qlDuLieuXem = useState(qlDuLieuPerms['Xem'] ?? false);
    final qlDuLieuThem = useState(qlDuLieuPerms['Them'] ?? false);
    final qlDuLieuSua = useState(qlDuLieuPerms['Sua'] ?? false);
    final qlDuLieuXoa = useState(qlDuLieuPerms['Xoa'] ?? false);

    // Detailed permissions - Báo cáo tổng hợp
    final bcTongHopXem = useState(bcTongHopPerms['Xem'] ?? false);
    final bcTongHopSua = useState(bcTongHopPerms['Sua'] ?? false);
    final bcTongHopXoa = useState(bcTongHopPerms['Xoa'] ?? false);

    // Detailed permissions - Báo cáo cân lần 2
    final bcCanLan2Xem = useState(bcCanLan2Perms['Xem'] ?? false);
    final bcCanLan2Sua = useState(bcCanLan2Perms['Sua'] ?? false);
    final bcCanLan2Xoa = useState(bcCanLan2Perms['Xoa'] ?? false);

    // Export permissions
    final xuatExcel = useState(user?.xuatExcel ?? false);
    final xuatPDF = useState(user?.xuatPDF ?? false);

    Future<void> handleSubmit() async {
      // Validate
      if (nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập tên người dùng')),
        );
        return;
      }

      if (loginController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập tên đăng nhập')),
        );
        return;
      }

      if (passwordController.text.trim().isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập mật khẩu')));
        return;
      }

      if (selectedUserGroupId.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn nhóm người dùng')),
        );
        return;
      }

      isLoading.value = true;

      try {
        // Lấy thông tin trạm cân và token
        final stations = await ref.read(scaleStationListProvider.future);
        if (stations.isEmpty) {
          throw Exception('Chưa có trạm cân nào');
        }

        final station = stations.first;
        final permissions = ref.read(userPermissionsProvider);
        if (permissions == null) {
          throw Exception('Chưa đăng nhập');
        }

        final baseUrl = 'http://${station.ip}:${station.port}';

        // Tạo permission strings
        final qlDuLieuStr =
            'Xem=${qlDuLieuXem.value};Them=${qlDuLieuThem.value};Sua=${qlDuLieuSua.value};Xoa=${qlDuLieuXoa.value}';
        final bcTongHopStr =
            'Xem=${bcTongHopXem.value};Them=False;Sua=${bcTongHopSua.value};Xoa=${bcTongHopXoa.value}';
        final bcCanLan2Str =
            'Xem=${bcCanLan2Xem.value};Them=False;Sua=${bcCanLan2Sua.value};Xoa=${bcCanLan2Xoa.value}';

        // Tạo request
        final request = AddUserRequest(
          id: user?.id, // Thêm ID nếu đang edit
          name: nameController.text.trim(),
          login: loginController.text.trim(),
          password: passwordController.text.trim(),
          idNhomUser: selectedUserGroupId.value!,
          description: descriptionController.text.trim(),
          quanLyNguoiDung: quanLyNguoiDung.value,
          cauHinhHeThong: cauHinhHeThong.value,
          baoCaoLog: baoCaoLog.value,
          baoCaoThongKe: baoCaoThongKe.value,
          quanLyDuLieu: qlDuLieuStr,
          baoCaoTongHop: bcTongHopStr,
          baoCaoChoCanLan2: bcCanLan2Str,
          xuatExcel: xuatExcel.value,
          xuatPDF: xuatPDF.value,
        );

        // Call API
        final response = await ref
            .read(userRepositoryProvider)
            .addUser(
              baseUrl: baseUrl,
              token: permissions.token,
              request: request,
            );

        if (!context.mounted) return;

        if (response.error) {
          throw Exception(response.message);
        }

        // Refresh danh sách
        ref.invalidate(userListProvider);

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Cập nhật người dùng thành công!'
                  : 'Thêm người dùng thành công!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Quay lại
        Navigator.of(context).pop();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Sửa Người Dùng' : 'Thêm Người Dùng'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin cơ bản
            SectionTitle(title: 'Thông Tin Cơ Bản'),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Tên người dùng *',
                hintText: 'Nhập tên người dùng',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Iconsax.user),
              ),
              textCapitalization: TextCapitalization.words,
              enabled: !isLoading.value,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: loginController,
              decoration: InputDecoration(
                labelText: 'Tên đăng nhập *',
                hintText: 'Nhập tên đăng nhập',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Iconsax.login),
              ),
              enabled: !isLoading.value,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Mật khẩu *',
                hintText: 'Nhập mật khẩu',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Iconsax.lock),
              ),
              obscureText: true,
              enabled: !isLoading.value,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Mô tả',
                hintText: 'Nhập mô tả (tùy chọn)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Iconsax.note_text),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              enabled: !isLoading.value,
            ),
            const SizedBox(height: 12),

            // Nhóm người dùng dropdown
            _UserGroupDropdown(
              selectedId: selectedUserGroupId.value,
              onChanged: isLoading.value
                  ? null
                  : (value) => selectedUserGroupId.value = value,
            ),
            const SizedBox(height: 24),

            // Quyền hạn boolean
            SectionTitle(title: 'Quyền Hạn Cơ Bản'),
            const SizedBox(height: 12),
            PermissionSwitch(
              title: 'Quản lý người dùng',
              value: quanLyNguoiDung.value,
              onChanged: isLoading.value
                  ? null
                  : (val) => quanLyNguoiDung.value = val,
              icon: Iconsax.people,
            ),
            PermissionSwitch(
              title: 'Cấu hình hệ thống',
              value: cauHinhHeThong.value,
              onChanged: isLoading.value
                  ? null
                  : (val) => cauHinhHeThong.value = val,
              icon: Iconsax.setting_2,
            ),
            PermissionSwitch(
              title: 'Báo cáo Log',
              value: baoCaoLog.value,
              onChanged: isLoading.value
                  ? null
                  : (val) => baoCaoLog.value = val,
              icon: Iconsax.document_text,
            ),
            PermissionSwitch(
              title: 'Báo cáo thống kê',
              value: baoCaoThongKe.value,
              onChanged: isLoading.value
                  ? null
                  : (val) => baoCaoThongKe.value = val,
              icon: Iconsax.chart,
            ),
            const SizedBox(height: 12),

            // Quản lý dữ liệu
            SectionTitle(title: 'Quản Lý Dữ Liệu'),
            DetailedPermissionGroup(
              permissions: [
                PermissionCheckbox(
                  label: 'Xem',
                  value: qlDuLieuXem.value,
                  onChanged: isLoading.value
                      ? null
                      : (val) => qlDuLieuXem.value = val ?? false,
                ),
                PermissionCheckbox(
                  label: 'Thêm',
                  value: qlDuLieuThem.value,
                  onChanged: isLoading.value
                      ? null
                      : (val) => qlDuLieuThem.value = val ?? false,
                ),
                PermissionCheckbox(
                  label: 'Sửa',
                  value: qlDuLieuSua.value,
                  onChanged: isLoading.value
                      ? null
                      : (val) => qlDuLieuSua.value = val ?? false,
                ),
                PermissionCheckbox(
                  label: 'Xóa',
                  value: qlDuLieuXoa.value,
                  onChanged: isLoading.value
                      ? null
                      : (val) => qlDuLieuXoa.value = val ?? false,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Báo cáo tổng hợp
            SectionTitle(title: 'Báo Cáo Tổng Hợp'),
            DetailedPermissionGroup(
              permissions: [
                PermissionCheckbox(
                  label: 'Xem',
                  value: bcTongHopXem.value,
                  onChanged: isLoading.value
                      ? null
                      : (val) => bcTongHopXem.value = val ?? false,
                ),
                PermissionCheckbox(
                  label: 'Sửa',
                  value: bcTongHopSua.value,
                  onChanged: isLoading.value
                      ? null
                      : (val) => bcTongHopSua.value = val ?? false,
                ),
                PermissionCheckbox(
                  label: 'Xóa',
                  value: bcTongHopXoa.value,
                  onChanged: isLoading.value
                      ? null
                      : (val) => bcTongHopXoa.value = val ?? false,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Báo cáo cân lần 2
            SectionTitle(title: 'Báo Cáo Cân Lần 2'),
            DetailedPermissionGroup(
              permissions: [
                PermissionCheckbox(
                  label: 'Xem',
                  value: bcCanLan2Xem.value,
                  onChanged: isLoading.value
                      ? null
                      : (val) => bcCanLan2Xem.value = val ?? false,
                ),
                PermissionCheckbox(
                  label: 'Sửa',
                  value: bcCanLan2Sua.value,
                  onChanged: isLoading.value
                      ? null
                      : (val) => bcCanLan2Sua.value = val ?? false,
                ),
                PermissionCheckbox(
                  label: 'Xóa',
                  value: bcCanLan2Xoa.value,
                  onChanged: isLoading.value
                      ? null
                      : (val) => bcCanLan2Xoa.value = val ?? false,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quyền xuất file
            SectionTitle(title: 'Quyền Xuất File'),
            const SizedBox(height: 12),
            PermissionSwitch(
              title: 'Xuất Excel',
              value: xuatExcel.value,
              onChanged: isLoading.value
                  ? null
                  : (val) => xuatExcel.value = val,
              icon: Iconsax.document_download,
            ),
            PermissionSwitch(
              title: 'Xuất PDF',
              value: xuatPDF.value,
              onChanged: isLoading.value ? null : (val) => xuatPDF.value = val,
              icon: Iconsax.document_download,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isLoading.value ? null : handleSubmit,
        icon: const Icon(Iconsax.add_circle),
        label: const Text('Lưu'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        heroTag: null,
      ),
    );
  }
}

// Widget dropdown cho nhóm người dùng
class _UserGroupDropdown extends ConsumerWidget {
  const _UserGroupDropdown({required this.selectedId, required this.onChanged});

  final String? selectedId;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userGroupsAsync = ref.watch(userGroupListProvider);

    return userGroupsAsync.when(
      data: (userGroups) {
        if (userGroups.isEmpty) {
          return Card(
            child: ListTile(
              leading: Icon(Iconsax.people, color: Colors.orange),
              title: const Text('Chưa có nhóm người dùng'),
              subtitle: const Text('Vui lòng tạo nhóm người dùng trước'),
            ),
          );
        }

        return DropdownButtonFormField<String>(
          value: selectedId,
          decoration: InputDecoration(
            labelText: 'Nhóm người dùng *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Iconsax.people),
          ),
          items: userGroups.map((group) {
            return DropdownMenuItem(
              value: group.id,
              child: Text(group.tenNhom),
            );
          }).toList(),
          onChanged: onChanged,
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => Card(
        color: Colors.red.shade50,
        child: ListTile(
          leading: Icon(Iconsax.warning_2, color: Colors.red),
          title: const Text('Lỗi tải danh sách nhóm'),
          subtitle: Text(error.toString()),
        ),
      ),
    );
  }
}
