import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database_helper.dart';
import '../domain/scale_station.dart';

part 'scale_station_provider.g.dart';

@riverpod
class ScaleStationList extends _$ScaleStationList {
  @override
  Future<List<ScaleStation>> build() async {
    return await DatabaseHelper.instance.getAllStations();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await DatabaseHelper.instance.getAllStations();
    });
  }

  Future<void> addStation(ScaleStation station) async {
    await DatabaseHelper.instance.createStation(station);
    await refresh();
  }

  Future<void> updateStation(ScaleStation station) async {
    await DatabaseHelper.instance.updateStation(station);
    await refresh();
  }

  Future<void> deleteStation(int id) async {
    await DatabaseHelper.instance.deleteStation(id);
    await refresh();
  }
}

/// Provider để watch một station cụ thể theo ID
@riverpod
Future<ScaleStation?> scaleStation(Ref ref, int stationId) async {
  // Watch list để tự động update khi list thay đổi
  final stationList = await ref.watch(scaleStationListProvider.future);

  // Tìm station theo ID
  try {
    return stationList.firstWhere((station) => station.id == stationId);
  } catch (e) {
    return null;
  }
}
