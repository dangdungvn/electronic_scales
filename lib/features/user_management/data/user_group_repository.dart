import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/user_group.dart';
import '../../../core/services/api_service.dart';

part 'user_group_repository.g.dart';

/// Repository để quản lý API nhóm người dùng
@riverpod
UserGroupRepository userGroupRepository(Ref ref) {
  return UserGroupRepository(ref.watch(dioProvider));
}

class UserGroupRepository {
  final Dio _dio;

  UserGroupRepository(this._dio);

  /// Lấy danh sách nhóm người dùng
  /// [baseUrl]: URL của trạm cân (http://ip:port)
  /// [token]: Token xác thực
  Future<UserGroupListResponse> getUserGroupList({
    required String baseUrl,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/scm/GetUserGroupList',
        options: Options(headers: {'Authorization': token}),
      );

      return UserGroupListResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['Message'] ?? 'Lỗi không xác định');
      }
      throw Exception('Không thể kết nối đến server');
    }
  }
}
