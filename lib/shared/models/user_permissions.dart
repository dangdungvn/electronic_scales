import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_permissions.freezed.dart';
part 'user_permissions.g.dart';

/// Mô hình dữ liệu quyền hạn người dùng từ API
@freezed
abstract class UserPermissions with _$UserPermissions {
  const factory UserPermissions({
    required String token,
    required String anprAPIkey,
    @Default(false) bool choPhepDanhGia,
    @Default(false) bool choPhepDanhGiaLai,
    @Default(false) bool choPhepXoaLuotXeChoCanLan2,
    @Default(false) bool quanLyNguoiDung,
    @Default(false) bool cauHinhHeThong,
    @Default(false) bool baoCaoLog,
    @Default(false) bool baoCaoThongKe,
    @Default(false) bool xuatExcel,
    @Default(false) bool xuatPDF,
    String? quanLyDuLieu,
    String? baoCaoTongHop,
    String? baoCaoChoCanLan2,
    String? oemInfo,
    String? cusInfo,
  }) = _UserPermissions;

  factory UserPermissions.fromJson(Map<String, dynamic> json) =>
      _$UserPermissionsFromJson(json);
}

/// Chi tiết quyền hạn từ chuỗi định dạng "Xem=True;Them=True;Sua=True;Xoa=True"
@freezed
abstract class DetailedPermission with _$DetailedPermission {
  const factory DetailedPermission({
    @Default(false) bool canView,
    @Default(false) bool canCreate,
    @Default(false) bool canEdit,
    @Default(false) bool canDelete,
  }) = _DetailedPermission;

  factory DetailedPermission.fromJson(Map<String, dynamic> json) =>
      _$DetailedPermissionFromJson(json);
}

/// Mô hình quyền hạn người dùng với các tính năng chi tiết
extension UserPermissionsExtension on UserPermissions {
  /// Parse chuỗi quyền "Xem=True;Them=True;Sua=True;Xoa=True"
  static DetailedPermission parsePermissionString(String? permString) {
    if (permString == null || permString.isEmpty) {
      return const DetailedPermission();
    }

    final permissions = <String, bool>{};
    final pairs = permString.split(';');

    for (var pair in pairs) {
      final parts = pair.trim().split('=');
      if (parts.length == 2) {
        permissions[parts[0].trim().toLowerCase()] =
            parts[1].trim().toLowerCase() == 'true';
      }
    }

    return DetailedPermission(
      canView: permissions['xem'] ?? false,
      canCreate: permissions['them'] ?? false,
      canEdit: permissions['sua'] ?? false,
      canDelete: permissions['xoa'] ?? false,
    );
  }

  /// Lấy quyền chi tiết cho Quản lý dữ liệu
  DetailedPermission get dataManagementPermission =>
      parsePermissionString(quanLyDuLieu);

  /// Lấy quyền chi tiết cho Báo cáo tổng hợp
  DetailedPermission get summaryReportPermission =>
      parsePermissionString(baoCaoTongHop);

  /// Lấy quyền chi tiết cho Báo cáo cân lần 2
  DetailedPermission get secondWeighingReportPermission =>
      parsePermissionString(baoCaoChoCanLan2);

  /// Danh sách tất cả quyền hạn boolean
  List<PermissionItem> get allBooleanPermissions => [
    PermissionItem(
      name: 'Cho phép đánh giá',
      description: 'Cho phép người dùng đánh giá',
      value: choPhepDanhGia,
      icon: 'star',
    ),
    PermissionItem(
      name: 'Cho phép đánh giá lại',
      description: 'Cho phép cập nhật đánh giá',
      value: choPhepDanhGiaLai,
      icon: 'refresh',
    ),
    PermissionItem(
      name: 'Cho phép xóa lượt xe cân lần 2',
      description: 'Xóa các lượt xe đã cân lần 2',
      value: choPhepXoaLuotXeChoCanLan2,
      icon: 'trash',
    ),
    PermissionItem(
      name: 'Quản lý người dùng',
      description: 'Quản lý tài khoản người dùng',
      value: quanLyNguoiDung,
      icon: 'people',
    ),
    PermissionItem(
      name: 'Cấu hình hệ thống',
      description: 'Thay đổi cài đặt hệ thống',
      value: cauHinhHeThong,
      icon: 'settings',
    ),
    PermissionItem(
      name: 'Báo cáo Log',
      description: 'Xem nhật ký hoạt động',
      value: baoCaoLog,
      icon: 'log',
    ),
    PermissionItem(
      name: 'Báo cáo Thống kê',
      description: 'Xem báo cáo thống kê',
      value: baoCaoThongKe,
      icon: 'chart',
    ),
    PermissionItem(
      name: 'Xuất Excel',
      description: 'Xuất dữ liệu sang Excel',
      value: xuatExcel,
      icon: 'download',
    ),
    PermissionItem(
      name: 'Xuất PDF',
      description: 'Xuất dữ liệu sang PDF',
      value: xuatPDF,
      icon: 'document',
    ),
  ];
}

/// Model cho hiển thị quyền
class PermissionItem {
  final String name;
  final String description;
  final bool value;
  final String icon;

  PermissionItem({
    required this.name,
    required this.description,
    required this.value,
    required this.icon,
  });
}
