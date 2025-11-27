import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/api_response.dart';
import '../../home/data/permissions_provider.dart';
import '../../scales/data/scale_station_provider.dart';
import '../domain/completed_weighing.dart';

part 'completed_weighing_provider.g.dart';

class CompletedWeighingFilter {
  final DateTime fromDate;
  final DateTime toDate;

  CompletedWeighingFilter({required this.fromDate, required this.toDate});

  CompletedWeighingFilter copyWith({DateTime? fromDate, DateTime? toDate}) {
    return CompletedWeighingFilter(
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}

@riverpod
class CompletedWeighingFilterState extends _$CompletedWeighingFilterState {
  @override
  CompletedWeighingFilter build() {
    final now = DateTime.now();
    // Mặc định từ đầu ngày đến cuối ngày hiện tại
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return CompletedWeighingFilter(fromDate: startOfDay, toDate: endOfDay);
  }

  void setDateRange(DateTime from, DateTime to) {
    state = state.copyWith(fromDate: from, toDate: to);
  }
}

@riverpod
class CompletedWeighingList extends _$CompletedWeighingList {
  @override
  Future<List<CompletedWeighing>> build() async {
    final filter = ref.watch(completedWeighingFilterStateProvider);
    return await _fetchData(filter);
  }

  Future<List<CompletedWeighing>> _fetchData(
    CompletedWeighingFilter filter,
  ) async {
    try {
      final stations = await ref.read(scaleStationListProvider.future);
      if (stations.isEmpty) {
        throw Exception('Chưa có trạm cân nào');
      }
      final station = stations.first;

      final permissions = ref.read(userPermissionsProvider);
      if (permissions == null) {
        throw Exception('Chưa đăng nhập');
      }

      final dio = Dio();
      final baseUrl = 'http://${station.ip}:${station.port}';

      // Format date for API: yyyy-MM-dd HH:mm:ss.fff
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');

      final response = await dio.get(
        '$baseUrl/scm/BaoCaoDanhSachXeDaCanXong',
        options: Options(
          headers: {
            'Authorization': permissions.token,
            'Content-Type': 'application/json; charset=utf-8',
          },
        ),
        data: {
          "dateFrom": dateFormat.format(filter.fromDate),
          "dateTo": dateFormat.format(filter.toDate),
          "keyword": "",
          "plateNumber": "",
          "soPhieu": -1,
          "khachHang": "",
          "loaiHang": "",
          "khoHang": "",
          "kieuCan": "",
          "maxRecord": 10000,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle ApiResponse wrapper
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
                  CompletedWeighing.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }

      throw Exception('Failed to load data');
    } catch (e) {
      throw Exception('Lỗi khi tải dữ liệu: ${e.toString()}');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final filter = ref.read(completedWeighingFilterStateProvider);
    state = await AsyncValue.guard(() => _fetchData(filter));
  }
}
