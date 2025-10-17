import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/api_service.dart';
import '../domain/user.dart';

part 'user_repository.g.dart';

/// Repository để quản lý API người dùng
@riverpod
UserRepository userRepository(Ref ref) {
  return UserRepository(ref.watch(dioProvider));
}

class UserRepository {
  final Dio _dio;

  UserRepository(this._dio);

  /// Lấy danh sách người dùng
  /// [baseUrl]: URL của trạm cân (http://ip:port)
  /// [token]: Token xác thực
  Future<UserListResponse> getUserList({
    required String baseUrl,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/scm/GetUserList',
        options: Options(headers: {'Authorization': token}),
      );

      return UserListResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['Message'] ?? 'Lỗi không xác định');
      }
      throw Exception('Không thể kết nối đến server');
    }
  }
}
