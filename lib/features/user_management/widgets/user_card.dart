import 'package:electronic_scales/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../domain/user.dart';
import 'card_widgets.dart';

/// Card hiển thị thông tin người dùng
class UserCard extends StatelessWidget {
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
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(
                        Iconsax.trash,
                        color: Colors.red[400],
                        size: 24,
                      ),
                      onPressed: onDelete,
                      tooltip: 'Xóa người dùng',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),

              // Thông tin đăng nhập
              const SizedBox(height: 12),
              _InfoRow(
                icon: Iconsax.user,
                label: 'Tên đăng nhập',
                value: user.login,
              ),

              // Quyền hạn boolean
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (user.quanLyNguoiDung)
                    const PermissionChip(
                      label: 'Quản lý người dùng',
                      icon: Iconsax.people,
                    ),
                  if (user.cauHinhHeThong)
                    const PermissionChip(
                      label: 'Cấu hình hệ thống',
                      icon: Iconsax.setting_2,
                    ),
                  if (user.baoCaoLog)
                    const PermissionChip(
                      label: 'Báo cáo Log',
                      icon: Iconsax.document_text,
                    ),
                  if (user.baoCaoThongKe)
                    const PermissionChip(
                      label: 'Báo cáo thống kê',
                      icon: Iconsax.chart,
                    ),
                  if (user.baoCaoWeb)
                    const PermissionChip(
                      label: 'Báo cáo Web',
                      icon: Iconsax.global,
                    ),
                ],
              ),

              // Quyền hạn chi tiết
              if (_hasDetailedPermissions(user)) ...[
                const SizedBox(height: 12),
                _DetailedPermissionsSection(user: user),
              ],

              // Quyền chỉnh sửa
              if (_hasEditPermissions(user)) ...[
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
                    if (user.suaMaPhieu) const EditChip(label: 'Mã phiếu'),
                    if (user.suaBienSo) const EditChip(label: 'Biển số'),
                    if (user.suaKhachHang) const EditChip(label: 'Khách hàng'),
                    if (user.suaLoaiHang) const EditChip(label: 'Loại hàng'),
                    if (user.suaKhoHang) const EditChip(label: 'Kho hàng'),
                    if (user.suaKieuCan) const EditChip(label: 'Kiểu cân'),
                    if (user.suaNguoiCan) const EditChip(label: 'Người cân'),
                    if (user.suaThoiGian) const EditChip(label: 'Thời gian'),
                    if (user.suaKhoiLuong) const EditChip(label: 'Khối lượng'),
                    if (user.suaDonGia) const EditChip(label: 'Đơn giá'),
                  ],
                ),
              ],

              // Quyền khác
              if (_hasOtherPermissions(user)) ...[
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
                    if (user.choPhepGiamTruKL)
                      const OtherChip(
                        label: 'Giảm trừ KL',
                        icon: Iconsax.minus_cirlce,
                      ),
                    if (user.xuatExcel)
                      const OtherChip(
                        label: 'Xuất Excel',
                        icon: Iconsax.document_download,
                      ),
                    if (user.xuatPDF)
                      const OtherChip(
                        label: 'Xuất PDF',
                        icon: Iconsax.document_download,
                      ),
                    if (user.choPhepDeMo)
                      const OtherChip(
                        label: 'Cho phép demo',
                        icon: Iconsax.play,
                      ),
                  ],
                ),
              ],

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
          ),
        ),
      ),
    );
  }
}

/// Helper để kiểm tra có quyền hạn chi tiết không
bool _hasDetailedPermissions(User user) {
  return hasAnyPermission(user.quanLyDuLieu) ||
      hasAnyPermission(user.baoCaoTongHop) ||
      hasAnyPermission(user.baoCaoChoCanLan2);
}

/// Helper để kiểm tra có quyền chỉnh sửa không
bool _hasEditPermissions(User user) {
  return user.suaMaPhieu ||
      user.suaBienSo ||
      user.suaKhachHang ||
      user.suaLoaiHang ||
      user.suaKhoHang ||
      user.suaKieuCan ||
      user.suaNguoiCan ||
      user.suaThoiGian ||
      user.suaKhoiLuong ||
      user.suaDonGia;
}

/// Helper để kiểm tra có quyền khác không
bool _hasOtherPermissions(User user) {
  return user.choPhepGiamTruKL ||
      user.xuatExcel ||
      user.xuatPDF ||
      user.choPhepDeMo;
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
