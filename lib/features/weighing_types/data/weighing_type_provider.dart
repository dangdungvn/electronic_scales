import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/api_response.dart';
import '../domain/weighing_type.dart';
import '../../home/data/permissions_provider.dart';
import '../../scales/data/scale_station_provider.dart';

part 'weighing_type_provider.g.dart';

/// Provider quản lý danh sách kiểu cân
@riverpod
class WeighingTypeList extends _$WeighingTypeList {
  @override
  Future<List<WeighingType>> build() async {
    return await _fetchWeighingTypes();
  }

  /// Lấy danh sách kiểu cân từ API
  Future<List<WeighingType>> _fetchWeighingTypes() async {
    try {
      // Lấy trạm cân
      final stations = await ref.read(scaleStationListProvider.future);
      if (stations.isEmpty) {
        throw Exception('Chưa có trạm cân nào');
      }
      final station = stations.first;

      // Lấy token từ permissions
      final permissions = ref.read(userPermissionsProvider);
      if (permissions == null) {
        throw Exception('Chưa đăng nhập');
      }

      final dio = Dio();
      final baseUrl = 'http://${station.ip}:${station.port}';

      final response = await dio.post(
        '$baseUrl/scm/LayDanhSachKieuCan',
        options: Options(
          headers: {
            'Authorization': permissions.token,
            'Content-Type': 'application/json; charset=utf-8',
          },
        ),
        data: {},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle both direct list and ApiResponse wrapped list
        if (data is List) {
          return data
              .map(
                (json) => WeighingType.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        } else if (data is Map<String, dynamic>) {
          final apiResponse = ApiResponse<List<dynamic>>.fromJson(
            data,
            (json) => json as List<dynamic>,
          );

          if (apiResponse.error) {
            throw ApiException(apiResponse.errorMessage);
          }

          final listData = apiResponse.data ?? [];
          return listData
              .map(
                (json) => WeighingType.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }

        return [];
      }

      throw Exception('Failed to load weighing types');
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách kiểu cân: ${e.toString()}');
    }
  }

  /// Refresh danh sách
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchWeighingTypes());
  }

  /// Thêm kiểu cân mới
  Future<void> addWeighingType(WeighingType request) async {
    try {
      // Lấy trạm cân
      final stations = await ref.read(scaleStationListProvider.future);
      if (stations.isEmpty) {
        throw Exception('Chưa có trạm cân nào');
      }
      final station = stations.first;

      // Lấy token từ permissions
      final permissions = ref.read(userPermissionsProvider);
      if (permissions == null) {
        throw Exception('Chưa đăng nhập');
      }

      final dio = Dio();
      final baseUrl = 'http://${station.ip}:${station.port}';

      final jsonData = request.toJson();
      // Ensure ID is 0 for new items
      jsonData['ID'] = 0;

      final response = await dio.post(
        '$baseUrl/scm/CapNhatKieuCan',
        options: Options(
          headers: {
            'Authorization': permissions.token,
            'Content-Type': 'application/json; charset=utf-8',
          },
        ),
        data: jsonData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle string response
        Map<String, dynamic> data;
        if (responseData is String) {
          data = {'Error': false, 'Message': responseData};
        } else if (responseData is Map<String, dynamic>) {
          data = responseData;
        } else {
          throw Exception('Invalid response format');
        }

        final apiResponse = ApiResponse<dynamic>.fromJson(data, (json) => json);

        if (apiResponse.error) {
          throw ApiException(apiResponse.errorMessage);
        }

        // Refresh list after successful add
        await refresh();
      } else {
        throw Exception('Failed to add weighing type');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Cập nhật kiểu cân
  Future<void> updateWeighingType(WeighingType request) async {
    try {
      if (request.id == 0) {
        throw Exception('Không tìm thấy ID kiểu cân để cập nhật');
      }

      // Lấy trạm cân
      final stations = await ref.read(scaleStationListProvider.future);
      if (stations.isEmpty) {
        throw Exception('Chưa có trạm cân nào');
      }
      final station = stations.first;

      // Lấy token từ permissions
      final permissions = ref.read(userPermissionsProvider);
      if (permissions == null) {
        throw Exception('Chưa đăng nhập');
      }

      final dio = Dio();
      final baseUrl = 'http://${station.ip}:${station.port}';

      final response = await dio.post(
        '$baseUrl/scm/CapNhatKieuCan',
        options: Options(
          headers: {
            'Authorization': permissions.token,
            'Content-Type': 'application/json; charset=utf-8',
          },
        ),
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle string response
        Map<String, dynamic> data;
        if (responseData is String) {
          data = {'Error': false, 'Message': responseData};
        } else if (responseData is Map<String, dynamic>) {
          data = responseData;
        } else {
          throw Exception('Invalid response format');
        }

        final apiResponse = ApiResponse<dynamic>.fromJson(data, (json) => json);

        if (apiResponse.error) {
          throw ApiException(apiResponse.errorMessage);
        }

        // Refresh list after successful update
        await refresh();
      } else {
        throw Exception('Failed to update weighing type');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Xóa kiểu cân
  Future<void> deleteWeighingType(int id) async {
    try {
      // Lấy trạm cân
      final stations = await ref.read(scaleStationListProvider.future);
      if (stations.isEmpty) {
        throw Exception('Chưa có trạm cân nào');
      }
      final station = stations.first;

      // Lấy token từ permissions
      final permissions = ref.read(userPermissionsProvider);
      if (permissions == null) {
        throw Exception('Chưa đăng nhập');
      }

      final dio = Dio();
      final baseUrl = 'http://${station.ip}:${station.port}';

      final response = await dio.post(
        '$baseUrl/scm/XoaKieuCan',
        options: Options(
          headers: {
            'Authorization': permissions.token,
            'Content-Type': 'application/json; charset=utf-8',
          },
        ),
        data: {'ID': id},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle string response
        Map<String, dynamic> data;
        if (responseData is String) {
          data = {'Error': false, 'Message': responseData};
        } else if (responseData is Map<String, dynamic>) {
          data = responseData;
        } else {
          throw Exception('Invalid response format');
        }

        final apiResponse = ApiResponse<dynamic>.fromJson(data, (json) => json);

        if (apiResponse.error) {
          throw ApiException(apiResponse.errorMessage);
        }

        // Refresh list after successful delete
        await refresh();
      } else {
        throw Exception('Failed to delete weighing type');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  void _handleDioError(DioException e) {
    if (e.response?.data != null) {
      final responseData = e.response!.data;

      Map<String, dynamic> data;
      if (responseData is String) {
        data = {'Error': true, 'Message': responseData};
      } else if (responseData is Map<String, dynamic>) {
        data = responseData;
      } else {
        throw Exception('Lỗi kết nối: ${e.message}');
      }

      final apiResponse = ApiResponse<dynamic>.fromJson(data, (json) => json);
      throw ApiException(apiResponse.errorMessage);
    }
    throw Exception('Lỗi kết nối: ${e.message}');
  }
}
