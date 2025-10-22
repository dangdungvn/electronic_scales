import 'package:electronic_scales/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../domain/user_group.dart';
import 'card_widgets.dart';

/// Card hiển thị thông tin nhóm người dùng
class UserGroupCard extends HookWidget {
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
    final isExpanded = useState(false);

    return Slidable(
      key: ValueKey('user-group-${group.id}-${group.stt}'),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.22,
        children: [
          CustomSlidableAction(
            onPressed: (_) => onDelete.call(),
            padding: const EdgeInsets.all(12),
            backgroundColor: Colors.red,
            borderRadius: BorderRadius.circular(16),
            child: const Icon(Iconsax.trash, color: Colors.white, size: 22),
          ),
        ],
      ),
      child: Card(
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
                    // Modern expand/collapse button
                    if (_hasExpandableContent(group))
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Material(
                          color: AppTheme.primaryBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => isExpanded.value = !isExpanded.value,
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: Icon(
                                isExpanded.value
                                    ? Iconsax.arrow_up_2
                                    : Iconsax.arrow_down_1,
                                color: AppTheme.primaryBlue,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                // const SizedBox(height: 8),

                // Nội dung có thể expand/collapse
                if (isExpanded.value) ...[
                  // Quyền hạn boolean
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (group.mauQuanLyNguoiDung)
                        const PermissionChip(
                          label: 'Quản lý người dùng',
                          icon: Iconsax.people,
                        ),
                      if (group.mauCauHinhHeThong)
                        const PermissionChip(
                          label: 'Cấu hình hệ thống',
                          icon: Iconsax.setting_2,
                        ),
                      if (group.mauBaoCaoLog)
                        const PermissionChip(
                          label: 'Báo cáo Log',
                          icon: Iconsax.document_text,
                        ),
                      if (group.mauBaoCaoThongKe)
                        const PermissionChip(
                          label: 'Báo cáo thống kê',
                          icon: Iconsax.chart,
                        ),
                      if (group.mauBaoCaoWeb)
                        const PermissionChip(
                          label: 'Báo cáo Web',
                          icon: Iconsax.global,
                        ),
                    ],
                  ),

                  // Quyền hạn chi tiết
                  if (_hasDetailedPermissions(group)) ...[
                    const SizedBox(height: 12),
                    _DetailedPermissionsSection(group: group),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper để kiểm tra có nội dung có thể expand không
bool _hasExpandableContent(UserGroup group) {
  return group.mauQuanLyNguoiDung ||
      group.mauCauHinhHeThong ||
      group.mauBaoCaoLog ||
      group.mauBaoCaoThongKe ||
      group.mauBaoCaoWeb ||
      _hasDetailedPermissions(group);
}

/// Helper để kiểm tra có quyền hạn chi tiết không
bool _hasDetailedPermissions(UserGroup group) {
  return hasAnyPermission(group.mauQuanLyDuLieu) ||
      hasAnyPermission(group.mauBaoCaoTongHop) ||
      hasAnyPermission(group.mauBaoCaoChoCanLan2);
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
        if (hasAnyPermission(group.mauQuanLyDuLieu))
          DetailedPermissionItem(
            title: 'Quản lý dữ liệu',
            permissionString: group.mauQuanLyDuLieu,
            icon: Iconsax.folder_2,
          ),
        if (hasAnyPermission(group.mauBaoCaoTongHop))
          DetailedPermissionItem(
            title: 'Báo cáo tổng hợp',
            permissionString: group.mauBaoCaoTongHop,
            icon: Iconsax.document,
          ),
        if (hasAnyPermission(group.mauBaoCaoChoCanLan2))
          DetailedPermissionItem(
            title: 'Báo cáo cân lần 2',
            permissionString: group.mauBaoCaoChoCanLan2,
            icon: Iconsax.clipboard_text,
          ),
      ],
    );
  }
}
