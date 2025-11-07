import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/api_response.dart';
import '../domain/customer.dart';
import '../../home/data/permissions_provider.dart';
import '../../scales/data/scale_station_provider.dart';

part 'customer_provider.g.dart';

/// Provider quản lý danh sách khách hàng theo chuẩn Agents.md
@riverpod
class CustomerList extends _$CustomerList {
  @override
  Future<List<Customer>> build() async {
    return await _fetchCustomers();
  }

  /// Lấy danh sách khách hàng từ API
  Future<List<Customer>> _fetchCustomers() async {
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
        '$baseUrl/scm/LayDanhSachKhachHang',
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
              .map((json) => Customer.fromJson(json as Map<String, dynamic>))
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
              .map((json) => Customer.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        return [];
      }

      throw Exception('Failed to load customers');
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách khách hàng: ${e.toString()}');
    }
  }

  /// Refresh danh sách
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchCustomers());
  }

  /// Thêm khách hàng mới
  Future<void> addCustomer(CustomerRequest request) async {
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

      final response = await dio.post(
        '$baseUrl/scm/CapNhatKhachHang',
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
        throw Exception('Failed to add customer');
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

  /// Cập nhật khách hàng
  Future<void> updateCustomer(CustomerRequest request) async {
    try {
      if (request.id.isEmpty) {
        throw Exception('Không tìm thấy ID khách hàng để cập nhật');
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
        '$baseUrl/scm/CapNhatKhachHang',
        options: Options(
          headers: {
            'Authorization': permissions.token,
            'Content-Type': 'application/json; charset=utf-8',
          },
        ),
        data: request.toJson(),
      );
      print(request.toJson());

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
        throw Exception('Failed to update customer');
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

  /// Xóa khách hàng
  Future<void> deleteCustomer(String id) async {
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
        '$baseUrl/scm/XoaKhachHang',
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
        throw Exception('Failed to delete customer');
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
