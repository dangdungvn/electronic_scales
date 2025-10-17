import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/user.dart';
import 'user_repository.dart';
import '../../scales/data/scale_station_provider.dart';
import '../../home/data/permissions_provider.dart';

part 'user_provider.g.dart';

@Riverpod(keepAlive: true)
class UserList extends _$UserList {
  @override
  Future<List<User>> build() async {
    return await _fetchUsers();
  }

  Future<List<User>> _fetchUsers() async {
    try {
      // Lấy trạm cân đang được chọn
      final stations = await ref.read(scaleStationListProvider.future);

      if (stations.isEmpty) {
        throw Exception('Chưa có trạm cân nào');
      }

      // Lấy trạm cân đầu tiên (có thể cải thiện sau)
      final station = stations.first;

      // Lấy token từ permissions
      final permissions = ref.read(userPermissionsProvider);

      if (permissions == null) {
        throw Exception('Chưa đăng nhập');
      }

      final baseUrl = 'http://${station.ip}:${station.port}';

      final response = await ref
          .read(userRepositoryProvider)
          .getUserList(baseUrl: baseUrl, token: permissions.token);

      if (response.error) {
        throw Exception(response.message);
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchUsers());
  }
}
