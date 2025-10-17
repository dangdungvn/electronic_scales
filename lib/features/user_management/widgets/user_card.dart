import 'package:electronic_scales/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../domain/user.dart';

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
                    const _PermissionChip(
                      label: 'Quản lý người dùng',
                      icon: Iconsax.people,
                    ),
                  if (user.cauHinhHeThong)
                    const _PermissionChip(
                      label: 'Cấu hình hệ thống',
                      icon: Iconsax.setting_2,
                    ),
                  if (user.baoCaoLog)
                    const _PermissionChip(
                      label: 'Báo cáo Log',
                      icon: Iconsax.document_text,
                    ),
                  if (user.baoCaoThongKe)
                    const _PermissionChip(
                      label: 'Báo cáo thống kê',
                      icon: Iconsax.chart,
                    ),
                  if (user.baoCaoWeb)
                    const _PermissionChip(
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
                    if (user.suaMaPhieu) const _EditChip(label: 'Mã phiếu'),
                    if (user.suaBienSo) const _EditChip(label: 'Biển số'),
                    if (user.suaKhachHang) const _EditChip(label: 'Khách hàng'),
                    if (user.suaLoaiHang) const _EditChip(label: 'Loại hàng'),
                    if (user.suaKhoHang) const _EditChip(label: 'Kho hàng'),
                    if (user.suaKieuCan) const _EditChip(label: 'Kiểu cân'),
                    if (user.suaNguoiCan) const _EditChip(label: 'Người cân'),
                    if (user.suaThoiGian) const _EditChip(label: 'Thời gian'),
                    if (user.suaKhoiLuong) const _EditChip(label: 'Khối lượng'),
                    if (user.suaDonGia) const _EditChip(label: 'Đơn giá'),
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
                      const _OtherChip(
                        label: 'Giảm trừ KL',
                        icon: Iconsax.minus_cirlce,
                      ),
                    if (user.xuatExcel)
                      const _OtherChip(
                        label: 'Xuất Excel',
                        icon: Iconsax.document_download,
                      ),
                    if (user.xuatPDF)
                      const _OtherChip(
                        label: 'Xuất PDF',
                        icon: Iconsax.document_download,
                      ),
                    if (user.choPhepDeMo)
                      const _OtherChip(
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
  return _hasAnyPermission(user.quanLyDuLieu) ||
      _hasAnyPermission(user.baoCaoTongHop) ||
      _hasAnyPermission(user.baoCaoChoCanLan2);
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

/// Chip hiển thị quyền hệ thống
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

/// Chip hiển thị quyền chỉnh sửa
class _EditChip extends StatelessWidget {
  const _EditChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Colors.orange[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Chip hiển thị quyền khác
class _OtherChip extends StatelessWidget {
  const _OtherChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.purple[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.purple[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
        if (_hasAnyPermission(user.quanLyDuLieu))
          _DetailedPermissionItem(
            title: 'Quản lý dữ liệu',
            permissionString: user.quanLyDuLieu,
            icon: Iconsax.folder_2,
          ),
        if (_hasAnyPermission(user.baoCaoTongHop))
          _DetailedPermissionItem(
            title: 'Báo cáo tổng hợp',
            permissionString: user.baoCaoTongHop,
            icon: Iconsax.document,
          ),
        if (_hasAnyPermission(user.baoCaoChoCanLan2))
          _DetailedPermissionItem(
            title: 'Báo cáo cân lần 2',
            permissionString: user.baoCaoChoCanLan2,
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
