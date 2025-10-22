import 'package:electronic_scales/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Chip hiển thị quyền hệ thống (màu xanh lục nếu enabled, đỏ nếu disabled)
class PermissionChip extends StatelessWidget {
  const PermissionChip({
    super.key,
    required this.label,
    required this.icon,
    required this.enabled,
  });

  final String label;
  final IconData icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final chipColor = enabled ? AppTheme.primaryGreen : Colors.red;
    final statusIcon = enabled ? Iconsax.tick_circle : Iconsax.close_circle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip hiển thị quyền chỉnh sửa: xanh lục (✓) nếu bật, đỏ (✗) nếu tắt
class EditChip extends StatelessWidget {
  const EditChip({super.key, required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final chipColor = enabled ? AppTheme.primaryGreen : AppTheme.errorRed;
    final statusIcon = enabled ? Iconsax.tick_circle : Iconsax.close_circle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: chipColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip hiển thị quyền khác: xanh lục (✓) nếu bật, đỏ (✗) nếu tắt
class OtherChip extends StatelessWidget {
  const OtherChip({
    super.key,
    required this.label,
    required this.icon,
    required this.enabled,
  });

  final String label;
  // icon giữ lại để tương thích API cũ, hiện không dùng để hiển thị
  final IconData icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final chipColor = enabled ? AppTheme.primaryGreen : AppTheme.errorRed;
    final statusIcon = enabled ? Iconsax.tick_circle : Iconsax.close_circle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: chipColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Item hiển thị một quyền hạn chi tiết với CRUD badges
class DetailedPermissionItem extends StatelessWidget {
  const DetailedPermissionItem({
    super.key,
    required this.title,
    required this.permissionString,
    required this.icon,
  });

  final String title;
  final String? permissionString;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final perms = parsePermissionString(permissionString);
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
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                PermissionBadge(label: 'Xem', enabled: hasXem),
                PermissionBadge(label: 'Thêm', enabled: hasThem),
                PermissionBadge(label: 'Sửa', enabled: hasSua),
                PermissionBadge(label: 'Xóa', enabled: hasXoa),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge nhỏ hiển thị từng quyền CRUD
class PermissionBadge extends StatelessWidget {
  const PermissionBadge({
    super.key,
    required this.label,
    required this.enabled,
  });

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: enabled
            ? AppTheme.primaryGreen.withOpacity(0.1)
            : AppTheme.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: enabled
              ? AppTheme.primaryGreen.withOpacity(0.5)
              : AppTheme.errorRed.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled ? Iconsax.tick_circle : Iconsax.close_circle,
            size: 12,
            color: enabled ? AppTheme.primaryGreen : AppTheme.errorRed,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: enabled ? AppTheme.primaryGreen : AppTheme.errorRed,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper functions

/// Kiểm tra chuỗi permission có ít nhất 1 quyền = True
bool hasAnyPermission(String? permString) {
  if (permString == null || permString.isEmpty) return false;
  return permString.toLowerCase().contains('true');
}

/// Parse permission string thành Map
Map<String, bool> parsePermissionString(String? permString) {
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
