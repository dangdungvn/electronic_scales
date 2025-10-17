import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/user_group.dart';
import 'user_group_repository.dart';
import '../../scales/data/scale_station_provider.dart';
import '../../home/data/permissions_provider.dart';

part 'user_group_provider.g.dart';

/// Provider để lấy danh sách nhóm người dùng
@riverpod
class UserGroupList extends _$UserGroupList {
  @override
  Future<List<UserGroup>> build() async {
    // Lấy trạm cân đang được chọn
    final stations = await ref.watch(scaleStationListProvider.future);

    if (stations.isEmpty) {
      throw Exception('Chưa có trạm cân nào');
    }

    // Lấy trạm cân đầu tiên (có thể cải thiện sau)
    final station = stations.first;

    // Lấy token từ permissions
    final permissions = ref.watch(userPermissionsProvider);

    if (permissions == null) {
      throw Exception('Chưa đăng nhập');
    }

    final baseUrl = 'http://${station.ip}:${station.port}';

    final response = await ref
        .read(userGroupRepositoryProvider)
        .getUserGroupList(baseUrl: baseUrl, token: permissions.token);

    if (response.error) {
      throw Exception(response.message);
    }

    return response.data;
  }

  /// Làm mới danh sách
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
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

      final response = await ref
          .read(userGroupRepositoryProvider)
          .getUserGroupList(baseUrl: baseUrl, token: permissions.token);

      if (response.error) {
        throw Exception(response.message);
      }

      return response.data;
    });
  }
}
