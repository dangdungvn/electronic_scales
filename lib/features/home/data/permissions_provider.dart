import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/user_permissions.dart';

part 'permissions_provider.g.dart';

/// Notifier để quản lý quyền hạn người dùng
/// Sử dụng keepAlive để giữ state sau khi chuyển screen
@Riverpod(keepAlive: true)
class UserPermissionsNotifier extends _$UserPermissionsNotifier {
  @override
  UserPermissions? build() {
    return null;
  }

  /// Cập nhật quyền hạn
  void setPermissions(UserPermissions permissions) {
    state = permissions;
  }

  /// Xóa quyền hạn
  void clearPermissions() {
    state = null;
  }
}

/// Provider lấy quyền hạn chi tiết cho quản lý dữ liệu
@riverpod
DetailedPermission dataManagementPermission(Ref ref) {
  final permissions = ref.watch(userPermissionsProvider);
  if (permissions == null) {
    return const DetailedPermission();
  }
  return UserPermissionsExtension.parsePermissionString(
    permissions.quanLyDuLieu,
  );
}

/// Provider lấy quyền hạn chi tiết cho báo cáo tổng hợp
@riverpod
DetailedPermission summaryReportPermission(Ref ref) {
  final permissions = ref.watch(userPermissionsProvider);
  if (permissions == null) {
    return const DetailedPermission();
  }
  return UserPermissionsExtension.parsePermissionString(
    permissions.baoCaoTongHop,
  );
}

/// Provider lấy quyền hạn chi tiết cho báo cáo cân lần 2
@riverpod
DetailedPermission secondWeighingReportPermission(Ref ref) {
  final permissions = ref.watch(userPermissionsProvider);
  if (permissions == null) {
    return const DetailedPermission();
  }
  return UserPermissionsExtension.parsePermissionString(
    permissions.baoCaoChoCanLan2,
  );
}
