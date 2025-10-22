import 'package:electronic_scales/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../domain/user.dart';
import 'card_widgets.dart';

/// Card hiển thị thông tin người dùng
class UserCard extends HookWidget {
  const UserCard({
    super.key,
    required this.user,
    required this.index,
    this.onTap,
    this.onDelete,
  });

  final User user;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);

    return Slidable(
      key: ValueKey('user-${user.id}-$index'),
      endActionPane: onDelete == null
          ? null
          : ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.22,
              children: [
                CustomSlidableAction(
                  onPressed: (_) => onDelete?.call(),
                  padding: const EdgeInsets.all(12),
                  backgroundColor: Colors.red,
                  borderRadius: BorderRadius.circular(16),
                  child: const Icon(
                    Iconsax.trash,
                    color: Colors.white,
                    size: 22,
                  ),
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
                // Header với STT, tên và nút xóa
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (user.description?.isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text(
                              user.description!,
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
                    if (_hasExpandableContent(user))
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
                    // Nút xóa đã chuyển sang Slidable action
                  ],
                ),

                // Thông tin đăng nhập

                // Nội dung có thể expand/collapse
                if (isExpanded.value) ...[
                  // Quyền hạn boolean
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Iconsax.user,
                    label: 'Tên đăng nhập',
                    value: user.login,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      PermissionChip(
                        label: 'Quản lý người dùng',
                        icon: Iconsax.people,
                        enabled: user.quanLyNguoiDung,
                      ),
                      PermissionChip(
                        label: 'Cấu hình hệ thống',
                        icon: Iconsax.setting_2,
                        enabled: user.cauHinhHeThong,
                      ),
                      PermissionChip(
                        label: 'Báo cáo Log',
                        icon: Iconsax.document_text,
                        enabled: user.baoCaoLog,
                      ),
                      PermissionChip(
                        label: 'Báo cáo thống kê',
                        icon: Iconsax.chart,
                        enabled: user.baoCaoThongKe,
                      ),
                      PermissionChip(
                        label: 'Báo cáo Web',
                        icon: Iconsax.global,
                        enabled: user.baoCaoWeb,
                      ),
                    ],
                  ),

                  // Quyền hạn chi tiết
                  if (_hasDetailedPermissions(user)) ...[
                    const SizedBox(height: 12),
                    _DetailedPermissionsSection(user: user),
                  ],

                  // Quyền chỉnh sửa (luôn hiển thị tất cả, đổi màu theo enabled)
                  const SizedBox(height: 12),
                  Text(
                    'Quyền chỉnh sửa:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      EditChip(label: 'Mã phiếu', enabled: user.suaMaPhieu),
                      EditChip(label: 'Biển số', enabled: user.suaBienSo),
                      EditChip(label: 'Khách hàng', enabled: user.suaKhachHang),
                      EditChip(label: 'Loại hàng', enabled: user.suaLoaiHang),
                      EditChip(label: 'Kho hàng', enabled: user.suaKhoHang),
                      EditChip(label: 'Kiểu cân', enabled: user.suaKieuCan),
                      EditChip(label: 'Người cân', enabled: user.suaNguoiCan),
                      EditChip(label: 'Thời gian', enabled: user.suaThoiGian),
                      EditChip(label: 'Khối lượng', enabled: user.suaKhoiLuong),
                      EditChip(label: 'Đơn giá', enabled: user.suaDonGia),
                    ],
                  ),

                  // Quyền khác (luôn hiển thị tất cả, đổi màu theo enabled)
                  const SizedBox(height: 12),
                  Text(
                    'Quyền khác:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      OtherChip(
                        label: 'Giảm trừ KL',
                        icon: Iconsax.minus_cirlce,
                        enabled: user.choPhepGiamTruKL,
                      ),
                      OtherChip(
                        label: 'Xuất Excel',
                        icon: Iconsax.document_download,
                        enabled: user.xuatExcel,
                      ),
                      OtherChip(
                        label: 'Xuất PDF',
                        icon: Iconsax.document_download,
                        enabled: user.xuatPDF,
                      ),
                      OtherChip(
                        label: 'Cho phép demo',
                        icon: Iconsax.play,
                        enabled: user.choPhepDeMo,
                      ),
                    ],
                  ),

                  // Thông tin bổ sung
                  if (_hasAdditionalInfo(user)) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Thông tin bổ sung:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          if (user.soLanIn > 0)
                            _InfoRow(
                              icon: Iconsax.printer,
                              label: 'Số lần in',
                              value: '${user.soLanIn}',
                            ),
                          if (user.gioiHanThoiGian?.isNotEmpty == true) ...[
                            if (user.soLanIn > 0) const SizedBox(height: 8),
                            _InfoRow(
                              icon: Iconsax.calendar,
                              label: 'Giới hạn thời gian',
                              value: user.gioiHanThoiGian!,
                            ),
                          ],
                        ],
                      ),
                    ),
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
bool _hasExpandableContent(User user) {
  // Luôn có thể expand vì luôn hiển thị các quyền hạn
  return true;
}

/// Helper để kiểm tra có quyền hạn chi tiết không
bool _hasDetailedPermissions(User user) {
  return hasAnyPermission(user.quanLyDuLieu) ||
      hasAnyPermission(user.baoCaoTongHop) ||
      hasAnyPermission(user.baoCaoChoCanLan2);
}

/// Helper để kiểm tra có thông tin bổ sung không
bool _hasAdditionalInfo(User user) {
  return user.soLanIn > 0 || (user.gioiHanThoiGian?.isNotEmpty == true);
}

/// Widget hiển thị thông tin cơ bản
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryBlue),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

/// Section hiển thị quyền hạn chi tiết
class _DetailedPermissionsSection extends StatelessWidget {
  const _DetailedPermissionsSection({required this.user});

  final User user;

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
        if (hasAnyPermission(user.quanLyDuLieu))
          DetailedPermissionItem(
            title: 'Quản lý dữ liệu',
            permissionString: user.quanLyDuLieu,
            icon: Iconsax.folder_2,
          ),
        if (hasAnyPermission(user.baoCaoTongHop))
          DetailedPermissionItem(
            title: 'Báo cáo tổng hợp',
            permissionString: user.baoCaoTongHop,
            icon: Iconsax.document,
          ),
        if (hasAnyPermission(user.baoCaoChoCanLan2))
          DetailedPermissionItem(
            title: 'Báo cáo cân lần 2',
            permissionString: user.baoCaoChoCanLan2,
            icon: Iconsax.clipboard_text,
          ),
      ],
    );
  }
}
