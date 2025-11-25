import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/api_response.dart';
import '../domain/goods_origin.dart';
import '../../home/data/permissions_provider.dart';
import '../../scales/data/scale_station_provider.dart';

part 'goods_origin_provider.g.dart';

@riverpod
class GoodsOriginList extends _$GoodsOriginList {
  @override
  Future<List<GoodsOrigin>> build() async {
    return await _fetchGoodsOrigins();
  }

  Future<List<GoodsOrigin>> _fetchGoodsOrigins() async {
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
        '$baseUrl/scm/LayDanhSachNguonGocHangHoa',
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
              .map((json) => GoodsOrigin.fromJson(json as Map<String, dynamic>))
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
              .map((json) => GoodsOrigin.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        return [];
      }

      throw Exception('Failed to load goods origins');
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách nguồn gốc: ${e.toString()}');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGoodsOrigins());
  }

  Future<void> addGoodsOrigin(GoodsOrigin goodsOrigin) async {
    await _updateGoodsOrigin(goodsOrigin);
  }

  Future<void> updateGoodsOrigin(GoodsOrigin goodsOrigin) async {
    await _updateGoodsOrigin(goodsOrigin);
  }

  Future<void> _updateGoodsOrigin(GoodsOrigin goodsOrigin) async {
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

      final jsonData = goodsOrigin.toJson();

      // API expects ID to be empty string for new items, not null
      if (jsonData['ID'] == null) {
        jsonData['ID'] = '';
      }

      final response = await dio.post(
        '$baseUrl/scm/CapNhatNguonGocHangHoa',
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

        // Refresh list after successful update
        await refresh();
      } else {
        throw Exception('Failed to update goods origin');
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

  Future<void> deleteGoodsOrigin(String id) async {
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
        '$baseUrl/scm/XoaNguonGocHangHoa',
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
        throw Exception('Failed to delete goods origin');
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
