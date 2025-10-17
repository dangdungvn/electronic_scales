import 'package:electronic_scales/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../domain/user_group.dart';
import '../data/user_group_repository.dart';
import '../data/user_group_provider.dart';
import '../../scales/data/scale_station_provider.dart';
import '../../home/data/permissions_provider.dart';

/// Screen để thêm/sửa nhóm người dùng
class AddEditUserGroupScreen extends HookConsumerWidget {
  const AddEditUserGroupScreen({super.key, this.userGroup});

  /// Nhóm người dùng cần sửa (null = thêm mới)
  final UserGroup? userGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = userGroup != null;
    final nameController = useTextEditingController(
      text: userGroup?.tenNhom ?? '',
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

    // Parse permissions từ userGroup nếu đang edit
    final qlDuLieuPerms = parsePermString(userGroup?.mauQuanLyDuLieu);
    final bcTongHopPerms = parsePermString(userGroup?.mauBaoCaoTongHop);
    final bcCanLan2Perms = parsePermString(userGroup?.mauBaoCaoChoCanLan2);

    // Boolean permissions
    final quanLyNguoiDung = useState(userGroup?.mauQuanLyNguoiDung ?? false);
    final cauHinhHeThong = useState(userGroup?.mauCauHinhHeThong ?? false);
    final baoCaoLog = useState(userGroup?.mauBaoCaoLog ?? false);
    final baoCaoThongKe = useState(userGroup?.mauBaoCaoThongKe ?? false);

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

    Future<void> handleSubmit() async {
      if (nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên nhóm')));
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
        final request = AddUserGroupRequest(
          id: userGroup?.id, // Thêm ID nếu đang edit
          tenNhom: nameController.text.trim(),
          mauQuanLyNguoiDung: quanLyNguoiDung.value,
          mauCauHinhHeThong: cauHinhHeThong.value,
          mauBaoCaoLog: baoCaoLog.value,
          mauBaoCaoThongKe: baoCaoThongKe.value,
          mauQuanLyDuLieu: qlDuLieuStr,
          mauBaoCaoTongHop: bcTongHopStr,
          mauBaoCaoChoCanLan2: bcCanLan2Str,
        );

        // Call API
        final response = await ref
            .read(userGroupRepositoryProvider)
            .addUserGroup(
              baseUrl: baseUrl,
              token: permissions.token,
              request: request,
            );

        if (!context.mounted) return;

        if (response.error) {
          throw Exception(response.message);
        }

        // Refresh danh sách
        ref.invalidate(userGroupListProvider);

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Cập nhật nhóm người dùng thành công!'
                  : 'Thêm nhóm người dùng thành công!',
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
        title: Text(
          isEditMode ? 'Sửa Nhóm Người Dùng' : 'Thêm Nhóm Người Dùng',
        ),
        actions: [
          if (isLoading.value)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Iconsax.tick_circle),
              onPressed: handleSubmit,
              tooltip: 'Lưu',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tên nhóm
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Tên nhóm *',
                hintText: 'Nhập tên nhóm người dùng',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Iconsax.edit),
              ),
              textCapitalization: TextCapitalization.words,
              enabled: !isLoading.value,
            ),
            const SizedBox(height: 24),

            // Quyền hạn boolean
            _SectionTitle(title: 'Quyền Hạn Cơ Bản'),
            const SizedBox(height: 12),
            _PermissionSwitch(
              title: 'Quản lý người dùng',
              value: quanLyNguoiDung.value,
              onChanged: isLoading.value
                  ? null
                  : (val) => quanLyNguoiDung.value = val,
              icon: Iconsax.people,
            ),
            _PermissionSwitch(
              title: 'Cấu hình hệ thống',
              value: cauHinhHeThong.value,
              onChanged: isLoading.value
                  ? null
                  : (val) => cauHinhHeThong.value = val,
              icon: Iconsax.setting_2,
            ),
            _PermissionSwitch(
              title: 'Báo cáo Log',
              value: baoCaoLog.value,
              onChanged: isLoading.value
                  ? null
                  : (val) => baoCaoLog.value = val,
              icon: Iconsax.document_text,
            ),
            _PermissionSwitch(
              title: 'Báo cáo thống kê',
              value: baoCaoThongKe.value,
              onChanged: isLoading.value
                  ? null
                  : (val) => baoCaoThongKe.value = val,
              icon: Iconsax.chart,
            ),
            const SizedBox(height: 12),

            // Quản lý dữ liệu
            _SectionTitle(title: 'Quản Lý Dữ Liệu'),
            _DetailedPermissionGroup(
              permissions: [
                _PermissionCheckbox(
                  label: 'Xem',
                  value: qlDuLieuXem.value,
                  onChanged: isLoading.value
                      ? null
                      : (val) => qlDuLieuXem.value = val ?? false,
                ),
                _PermissionCheckbox(
                  label: 'Thêm',
                  value: qlDuLieuThem.value,
                  onChanged: isLoading.value
                      ? null
                      : (val) => qlDuLieuThem.value = val ?? false,
                ),
                _PermissionCheckbox(
                  label: 'Sửa',
                  value: qlDuLieuSua.value,
                  onChanged: isLoading.value
                      ? null
                      : (val) => qlDuLieuSua.value = val ?? false,
                ),
                _PermissionCheckbox(
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
            _SectionTitle(title: 'Báo Cáo Tổng Hợp'),
            _DetailedPermissionGroup(
              permissions: [
                _PermissionCheckbox(
                  label: 'Xem',
                  value: bcTongHopXem.value,
                  onChanged: isLoading.value
                      ? null
                      : (val) => bcTongHopXem.value = val ?? false,
                ),
                _PermissionCheckbox(
                  label: 'Sửa',
                  value: bcTongHopSua.value,
                  onChanged: isLoading.value
                      ? null
                      : (val) => bcTongHopSua.value = val ?? false,
                ),
                _PermissionCheckbox(
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
            _SectionTitle(title: 'Báo Cáo Cân Lần 2'),
            _DetailedPermissionGroup(
              permissions: [
                _PermissionCheckbox(
                  label: 'Xem',
                  value: bcCanLan2Xem.value,
                  onChanged: isLoading.value
                      ? null
                      : (val) => bcCanLan2Xem.value = val ?? false,
                ),
                _PermissionCheckbox(
                  label: 'Sửa',
                  value: bcCanLan2Sua.value,
                  onChanged: isLoading.value
                      ? null
                      : (val) => bcCanLan2Sua.value = val ?? false,
                ),
                _PermissionCheckbox(
                  label: 'Xóa',
                  value: bcCanLan2Xoa.value,
                  onChanged: isLoading.value
                      ? null
                      : (val) => bcCanLan2Xoa.value = val ?? false,
                ),
              ],
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
      ),
    );
  }
}

class _PermissionSwitch extends StatelessWidget {
  const _PermissionSwitch({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: AppTheme.primaryBlue),
      ),
    );
  }
}

class _DetailedPermissionGroup extends StatelessWidget {
  const _DetailedPermissionGroup({required this.permissions});

  final List<Widget> permissions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(spacing: 16, runSpacing: 8, children: permissions),
      ),
    );
  }
}

class _PermissionCheckbox extends StatelessWidget {
  const _PermissionCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged?.call(!value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: value
              ? AppTheme.primaryGreen.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value ? AppTheme.primaryGreen : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value ? Iconsax.tick_circle : Iconsax.close_circle,
              size: 16,
              color: value ? AppTheme.primaryGreen : Colors.grey[500],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: value ? AppTheme.primaryGreen : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
