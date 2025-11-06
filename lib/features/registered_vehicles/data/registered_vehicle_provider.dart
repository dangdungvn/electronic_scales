import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/api_response.dart';
import '../domain/registered_vehicle.dart';
import '../../home/data/permissions_provider.dart';
import '../../scales/data/scale_station_provider.dart';

part 'registered_vehicle_provider.g.dart';

@riverpod
class RegisteredVehicleList extends _$RegisteredVehicleList {
  @override
  Future<List<RegisteredVehicle>> build() async {
    return await _fetchVehicles();
  }

  Future<List<RegisteredVehicle>> _fetchVehicles() async {
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
        '$baseUrl/scm/LayDanhSachXeDangKy',
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
                (json) =>
                    RegisteredVehicle.fromJson(json as Map<String, dynamic>),
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
                (json) =>
                    RegisteredVehicle.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }

        return [];
      }

      throw Exception('Failed to load vehicles');
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách xe: ${e.toString()}');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchVehicles());
  }

  Future<void> addVehicle(RegisteredVehicleRequest request) async {
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
      print('🚀 Request Data: $jsonData');

      final response = await dio.post(
        '$baseUrl/scm/CapNhatXeDangKy',
        options: Options(
          headers: {
            'Authorization': permissions.token,
            'Content-Type': 'application/json; charset=utf-8',
          },
        ),
        data: jsonData,
      );

      print('✅ Response Status: ${response.statusCode}');
      print('✅ Response Data Type: ${response.data.runtimeType}');
      print('✅ Response Data: ${response.data}');

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
        throw Exception('Failed to add vehicle');
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('❌ Response Data Type: ${e.response?.data.runtimeType}');
      print('❌ Response Data: ${e.response?.data}');

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

  Future<void> updateVehicle(RegisteredVehicleRequest request) async {
    try {
      if (request.syncId.isEmpty) {
        throw Exception('Không tìm thấy ID xe để cập nhật');
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
        '$baseUrl/scm/CapNhatXeDangKy',
        options: Options(
          headers: {
            'Authorization': permissions.token,
            'Content-Type': 'application/json; charset=utf-8',
          },
        ),
        data: request.toJson(),
      );
      print(request.toJson());
      print(response.data);
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
        throw Exception('Failed to update vehicle');
      }
    } on DioException catch (e) {
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

  Future<void> deleteVehicle(String syncId) async {
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
        '$baseUrl/scm/XoaXeDangKy',
        options: Options(
          headers: {
            'Authorization': permissions.token,
            'Content-Type': 'application/json; charset=utf-8',
          },
        ),
        data: {'ID': syncId},
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
        throw Exception('Failed to delete vehicle');
      }
    } on DioException catch (e) {
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
}
