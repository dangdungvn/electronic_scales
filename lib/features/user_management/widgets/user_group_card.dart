import 'package:electronic_scales/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../domain/user_group.dart';

/// Card hiển thị thông tin nhóm người dùng
class UserGroupCard extends StatelessWidget {
  const UserGroupCard({
    super.key,
    required this.group,
    required this.onTap,
    required this.onDelete,
  });

  final UserGroup group;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với STT và tên nhóm
              Row(
                children: [
                  Text(
                    '${group.stt}. ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.secondaryBlue,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.tenNhom,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (group.ghiChu?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            group.ghiChu!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Iconsax.trash, color: Colors.red[400], size: 24),
                    onPressed: onDelete,
                    tooltip: 'Xóa nhóm',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Quyền hạn boolean
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (group.mauQuanLyNguoiDung)
                    const _PermissionChip(
                      label: 'Quản lý người dùng',
                      icon: Iconsax.people,
                    ),
                  if (group.mauCauHinhHeThong)
                    const _PermissionChip(
                      label: 'Cấu hình hệ thống',
                      icon: Iconsax.setting_2,
                    ),
                  if (group.mauBaoCaoLog)
                    const _PermissionChip(
                      label: 'Báo cáo Log',
                      icon: Iconsax.document_text,
                    ),
                  if (group.mauBaoCaoThongKe)
                    const _PermissionChip(
                      label: 'Báo cáo thống kê',
                      icon: Iconsax.chart,
                    ),
                  if (group.mauBaoCaoWeb)
                    const _PermissionChip(
                      label: 'Báo cáo Web',
                      icon: Iconsax.global,
                    ),
                ],
              ),
              // Quyền hạn chi tiết
              if (_hasDetailedPermissions(group)) ...[
                // const SizedBox(height: 16),
                // const Divider(height: 1),
                const SizedBox(height: 12),
                _DetailedPermissionsSection(group: group),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionChip extends StatelessWidget {
  const _PermissionChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryBlue),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.secondaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper để kiểm tra có quyền hạn chi tiết không
bool _hasDetailedPermissions(UserGroup group) {
  return _hasAnyPermission(group.mauQuanLyDuLieu) ||
      _hasAnyPermission(group.mauBaoCaoTongHop) ||
      _hasAnyPermission(group.mauBaoCaoChoCanLan2);
}

/// Kiểm tra chuỗi permission có ít nhất 1 quyền = True
bool _hasAnyPermission(String? permString) {
  if (permString == null || permString.isEmpty) return false;
  return permString.toLowerCase().contains('true');
}

/// Parse permission string thành Map
Map<String, bool> _parsePermissionString(String? permString) {
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

/// Section hiển thị quyền hạn chi tiết
class _DetailedPermissionsSection extends StatelessWidget {
  const _DetailedPermissionsSection({required this.group});

  final UserGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quyền hạn chi tiết:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        if (_hasAnyPermission(group.mauQuanLyDuLieu))
          _DetailedPermissionItem(
            title: 'Quản lý dữ liệu',
            permissionString: group.mauQuanLyDuLieu,
            icon: Iconsax.folder_2,
          ),
        if (_hasAnyPermission(group.mauBaoCaoTongHop))
          _DetailedPermissionItem(
            title: 'Báo cáo tổng hợp',
            permissionString: group.mauBaoCaoTongHop,
            icon: Iconsax.document,
          ),
        if (_hasAnyPermission(group.mauBaoCaoChoCanLan2))
          _DetailedPermissionItem(
            title: 'Báo cáo cân lần 2',
            permissionString: group.mauBaoCaoChoCanLan2,
            icon: Iconsax.clipboard_text,
          ),
      ],
    );
  }
}

/// Item hiển thị một quyền hạn chi tiết
class _DetailedPermissionItem extends StatelessWidget {
  const _DetailedPermissionItem({
    required this.title,
    required this.permissionString,
    required this.icon,
  });

  final String title;
  final String? permissionString;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final perms = _parsePermissionString(permissionString);
    final hasXem = perms['Xem'] ?? false;
    final hasThem = perms['Them'] ?? false;
    final hasSua = perms['Sua'] ?? false;
    final hasXoa = perms['Xoa'] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _PermissionBadge(label: 'Xem', enabled: hasXem),
                _PermissionBadge(label: 'Thêm', enabled: hasThem),
                _PermissionBadge(label: 'Sửa', enabled: hasSua),
                _PermissionBadge(label: 'Xóa', enabled: hasXoa),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge nhỏ hiển thị từng quyền
class _PermissionBadge extends StatelessWidget {
  const _PermissionBadge({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: enabled
            ? AppTheme.primaryGreen.withOpacity(0.1)
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: enabled
              ? AppTheme.primaryGreen.withOpacity(0.5)
              : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled ? Iconsax.tick_circle : Iconsax.close_circle,
            size: 12,
            color: enabled ? AppTheme.primaryGreen : Colors.grey[500],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: enabled ? AppTheme.primaryGreen : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
