import 'package:electronic_scales/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../domain/user_group.dart';
import '../data/user_group_repository.dart';
import '../data/user_group_provider.dart';
import '../widgets/permission_widgets.dart';
import '../../scales/data/scale_station_provider.dart';
import '../../home/data/permissions_provider.dart';

Future<void> showAddEditUserGroupSheet({
  required BuildContext context,
  UserGroup? userGroup,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => AddEditUserGroupSheet(userGroup: userGroup),
  );
}

/// Bottom sheet thêm/sửa nhóm người dùng
class AddEditUserGroupSheet extends HookConsumerWidget {
  const AddEditUserGroupSheet({super.key, this.userGroup});

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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sheetTitle = isEditMode ? 'Sửa Nhóm' : 'Thêm Nhóm';
    final actionIcon = isEditMode ? Iconsax.save_2 : Iconsax.add_circle;
    final actionLabel = isEditMode ? 'Lưu thay đổi' : 'Tạo nhóm';
    final hasDataPermissions =
        qlDuLieuXem.value ||
        qlDuLieuThem.value ||
        qlDuLieuSua.value ||
        qlDuLieuXoa.value;
    final hasSummaryPermissions =
        bcTongHopXem.value || bcTongHopSua.value || bcTongHopXoa.value;
    final hasSecondWeighPermissions =
        bcCanLan2Xem.value || bcCanLan2Sua.value || bcCanLan2Xoa.value;

    Future<void> handleSubmit() async {
      FocusScope.of(context).unfocus();
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
        context.pop();
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

    return SafeArea(
      top: false,
      bottom: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FractionallySizedBox(
          heightFactor: 0.95,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                const _SheetHandle(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              sheetTitle,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Đóng',
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Iconsax.close_circle,
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionTitle(title: 'Thông Tin Cơ Bản'),
                        const SizedBox(height: 4),
                        _SectionCard(
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'Tên nhóm *',
                                hintText: 'Nhập tên nhóm người dùng',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Iconsax.people),
                              ),
                              textCapitalization: TextCapitalization.words,
                              enabled: !isLoading.value,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SectionTitle(title: 'Quyền Hạn Cơ Bản'),
                        // const SizedBox(height: 12),
                        _SectionCard(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _PermissionChip(
                                    label: 'Quản lý người dùng',
                                    icon: Iconsax.people,
                                    value: quanLyNguoiDung.value,
                                    enabled: !isLoading.value,
                                    onChanged: (val) =>
                                        quanLyNguoiDung.value = val,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _PermissionChip(
                                    label: 'Cấu hình hệ thống',
                                    icon: Iconsax.setting_2,
                                    value: cauHinhHeThong.value,
                                    enabled: !isLoading.value,
                                    onChanged: (val) =>
                                        cauHinhHeThong.value = val,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _PermissionChip(
                                    label: 'Báo cáo Log',
                                    icon: Iconsax.document_text,
                                    value: baoCaoLog.value,
                                    enabled: !isLoading.value,
                                    onChanged: (val) => baoCaoLog.value = val,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _PermissionChip(
                                    label: 'Báo cáo thống kê',
                                    icon: Iconsax.chart,
                                    value: baoCaoThongKe.value,
                                    enabled: !isLoading.value,
                                    onChanged: (val) =>
                                        baoCaoThongKe.value = val,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SectionTitle(title: 'Quyền Chi Tiết'),
                        _CollapsibleSection(
                          title: 'Quản Lý Dữ Liệu',
                          description:
                              'Quyền truy cập và chỉnh sửa dữ liệu cân.',
                          icon: Icons.storage_rounded,
                          initiallyExpanded: isEditMode
                              ? hasDataPermissions
                              : false,
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
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
                                    : (val) =>
                                          qlDuLieuThem.value = val ?? false,
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
                        ),
                        const SizedBox(height: 12),
                        _CollapsibleSection(
                          title: 'Báo Cáo Tổng Hợp',
                          description: 'Quyền truy cập báo cáo tổng hợp.',
                          icon: Icons.bar_chart_rounded,
                          initiallyExpanded: isEditMode
                              ? hasSummaryPermissions
                              : false,
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              PermissionCheckbox(
                                label: 'Xem',
                                value: bcTongHopXem.value,
                                onChanged: isLoading.value
                                    ? null
                                    : (val) =>
                                          bcTongHopXem.value = val ?? false,
                              ),
                              PermissionCheckbox(
                                label: 'Sửa',
                                value: bcTongHopSua.value,
                                onChanged: isLoading.value
                                    ? null
                                    : (val) =>
                                          bcTongHopSua.value = val ?? false,
                              ),
                              PermissionCheckbox(
                                label: 'Xóa',
                                value: bcTongHopXoa.value,
                                onChanged: isLoading.value
                                    ? null
                                    : (val) =>
                                          bcTongHopXoa.value = val ?? false,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _CollapsibleSection(
                          title: 'Báo Cáo Cân Lần 2',
                          description:
                              'Quyền thao tác với báo cáo cân kiểm tra.',
                          icon: Icons.monitor_weight,
                          initiallyExpanded: isEditMode
                              ? hasSecondWeighPermissions
                              : false,
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              PermissionCheckbox(
                                label: 'Xem',
                                value: bcCanLan2Xem.value,
                                onChanged: isLoading.value
                                    ? null
                                    : (val) =>
                                          bcCanLan2Xem.value = val ?? false,
                              ),
                              PermissionCheckbox(
                                label: 'Sửa',
                                value: bcCanLan2Sua.value,
                                onChanged: isLoading.value
                                    ? null
                                    : (val) =>
                                          bcCanLan2Sua.value = val ?? false,
                              ),
                              PermissionCheckbox(
                                label: 'Xóa',
                                value: bcCanLan2Xoa.value,
                                onChanged: isLoading.value
                                    ? null
                                    : (val) =>
                                          bcCanLan2Xoa.value = val ?? false,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isLoading.value ? null : handleSubmit,
                      icon: isLoading.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color?>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Icon(actionIcon),
                      label: Text(
                        isLoading.value ? 'Đang lưu...' : actionLabel,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Bottom sheet helper widgets
class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 48,
      height: 5,
      decoration: BoxDecoration(
        color: colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i != 0) const SizedBox(height: 12),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _CollapsibleSection extends StatelessWidget {
  const _CollapsibleSection({
    required this.title,
    required this.icon,
    required this.child,
    this.description,
    this.initiallyExpanded = false,
  });

  final String title;
  final String? description;
  final IconData icon;
  final Widget child;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Icon(icon, color: AppTheme.primaryBlue),
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: description == null
              ? null
              : Text(
                  description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
          children: [child],
        ),
      ),
    );
  }
}

class _PermissionChip extends StatelessWidget {
  const _PermissionChip({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.enabled,
  });

  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = AppTheme.primaryBlue;
    final unselectedColor = theme.colorScheme.surfaceVariant;

    return FilterChip(
      avatar: Icon(
        icon,
        size: 18,
        color: value ? Colors.white : theme.colorScheme.onSurfaceVariant,
      ),
      label: Text(label),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: value ? Colors.white : theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      selected: value,
      onSelected: enabled ? onChanged : null,
      showCheckmark: false,
      backgroundColor: unselectedColor,
      disabledColor: unselectedColor.withOpacity(0.5),
      selectedColor: selectedColor,
      side: BorderSide(color: value ? selectedColor : unselectedColor),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
