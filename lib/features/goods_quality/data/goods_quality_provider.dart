import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/api_response.dart';
import '../domain/goods_quality.dart';
import '../../home/data/permissions_provider.dart';
import '../../scales/data/scale_station_provider.dart';

part 'goods_quality_provider.g.dart';

@riverpod
class GoodsQualityList extends _$GoodsQualityList {
  @override
  Future<List<GoodsQuality>> build() async {
    return await _fetchGoodsQualities();
  }

  Future<List<GoodsQuality>> _fetchGoodsQualities() async {
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
        '$baseUrl/scm/LayDanhSachChatLuongHangHoa',
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
                (json) => GoodsQuality.fromJson(json as Map<String, dynamic>),
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
                (json) => GoodsQuality.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        }

        return [];
      }

      throw Exception('Failed to load goods qualities');
    } catch (e) {
      throw Exception(
        'Lỗi khi tải danh sách chất lượng hàng hóa: ${e.toString()}',
      );
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGoodsQualities());
  }

  Future<void> addGoodsQuality(GoodsQuality goodsQuality) async {
    await _updateGoodsQuality(goodsQuality);
  }

  Future<void> updateGoodsQuality(GoodsQuality goodsQuality) async {
    await _updateGoodsQuality(goodsQuality);
  }

  Future<void> _updateGoodsQuality(GoodsQuality goodsQuality) async {
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

      final jsonData = goodsQuality.toJson();

      // API expects ID to be empty string for new items, not null
      if (jsonData['ID'] == null) {
        jsonData['ID'] = '';
      }

      final response = await dio.post(
        '$baseUrl/scm/CapNhatChatLuongHangHoa',
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
        throw Exception('Failed to update goods quality');
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

  Future<void> deleteGoodsQuality(String id) async {
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
      print('Deleting goods quality with ID: $id');
      final response = await dio.post(
        '$baseUrl/scm/XoaChatLuongHangHoa',
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
        throw Exception('Failed to delete goods quality');
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
