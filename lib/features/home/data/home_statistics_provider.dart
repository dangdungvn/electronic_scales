import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/api_response.dart';
import '../../completed_weighing/domain/completed_weighing.dart';
import '../../customers/data/customer_provider.dart';
import '../../drivers/data/driver_provider.dart';
import '../../pending_weighing/data/pending_weighing_provider.dart';
import '../../scales/data/scale_station_provider.dart';
import '../domain/home_statistics.dart';
import 'permissions_provider.dart';

part 'home_statistics_provider.g.dart';

@riverpod
class HomeStatisticsData extends _$HomeStatisticsData {
  @override
  Future<HomeStatistics> build() async {
    return await _fetchStatistics();
  }

  Future<HomeStatistics> _fetchStatistics() async {
    // 1. Get Pending Count
    final pendingCount = await ref.watch(pendingWeighingCountProvider.future);

    // 2. Get Customer Count
    final customers = await ref.watch(customerListProvider.future);
    final customerCount = customers.length;

    // 3. Get Driver Count
    final drivers = await ref.watch(driverListProvider.future);
    final driverCount = drivers.length;

    // 4. Get Today's Completed Weighings
    final completedToday = await _fetchTodayCompletedWeighings();
    final completedCountToday = completedToday.length;

    double totalWeightToday = 0;
    for (var item in completedToday) {
      if (item.netWeight != null) {
        try {
          String cleanValue = item.netWeight!.replaceAll(',', '.');
          totalWeightToday += double.parse(cleanValue);
        } catch (e) {
          // Ignore parse error
        }
      }
    }

    return HomeStatistics(
      pendingCount: pendingCount,
      completedCountToday: completedCountToday,
      totalWeightToday: totalWeightToday,
      customerCount: customerCount,
      driverCount: driverCount,
    );
  }

  Future<List<CompletedWeighing>> _fetchTodayCompletedWeighings() async {
    try {
      final stations = await ref.read(scaleStationListProvider.future);
      if (stations.isEmpty) {
        return [];
      }
      final station = stations.first;

      final permissions = ref.read(userPermissionsProvider);
      if (permissions == null) {
        return [];
      }

      final dio = Dio();
      final baseUrl = 'http://${station.ip}:${station.port}';

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
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
          "dateFrom": dateFormat.format(startOfDay),
          "dateTo": dateFormat.format(endOfDay),
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
        final apiResponse = ApiResponse<List<dynamic>>.fromJson(
          data,
          (json) => json as List<dynamic>,
        );

        if (apiResponse.error) {
          return [];
        }

        final listData = apiResponse.data ?? [];
        return listData
            .map(
              (json) =>
                  CompletedWeighing.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching today stats: $e');
      return [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchStatistics());
  }
}
