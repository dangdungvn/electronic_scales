import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../models/user_permissions.dart';

/// Widget hiển thị một quyền hạn boolean
class PermissionBooleanTile extends StatelessWidget {
  const PermissionBooleanTile({super.key, required this.item});

  final PermissionItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: item.value
              ? const Color(0xFF4CAF50).withOpacity(0.3)
              : Colors.grey[200]!,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.value
                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconData(item.icon),
                color: item.value ? const Color(0xFF4CAF50) : Colors.grey[400],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: item.value ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.value
                    ? const Color(0xFF4CAF50).withOpacity(0.2)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.value ? 'Có' : 'Không',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: item.value
                      ? const Color(0xFF4CAF50)
                      : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String icon) {
    switch (icon) {
      case 'star':
        return Iconsax.star_1;
      case 'refresh':
        return Iconsax.refresh;
      case 'trash':
        return Iconsax.trash;
      case 'people':
        return Iconsax.people;
      case 'settings':
        return Iconsax.setting_2;
      case 'log':
        return Iconsax.document;
      case 'chart':
        return Iconsax.chart_2;
      case 'download':
        return Iconsax.export;
      case 'document':
        return Iconsax.document_text;
      default:
        return Iconsax.info_circle;
    }
  }
}

/// Widget hiển thị quyền hạn chi tiết (Xem, Thêm, Sửa, Xóa)
class DetailedPermissionTile extends StatelessWidget {
  const DetailedPermissionTile({
    super.key,
    required this.title,
    required this.permission,
  });

  final String title;
  final DetailedPermission permission;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            // Grid 2x2 cho 4 loại quyền
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _PermissionCheckBox(label: 'Xem', value: permission.canView),
                _PermissionCheckBox(label: 'Thêm', value: permission.canCreate),
                _PermissionCheckBox(label: 'Sửa', value: permission.canEdit),
                _PermissionCheckBox(label: 'Xóa', value: permission.canDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget checkbox cho một quyền
class _PermissionCheckBox extends StatelessWidget {
  const _PermissionCheckBox({required this.label, required this.value});

  final String label;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: value
            ? const Color(0xFF4CAF50).withOpacity(0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value
              ? const Color(0xFF4CAF50).withOpacity(0.3)
              : Colors.grey[200]!,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            value ? Iconsax.tick_circle : Iconsax.close_circle,
            color: value ? const Color(0xFF4CAF50) : Colors.grey[400],
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: value ? const Color(0xFF4CAF50) : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
