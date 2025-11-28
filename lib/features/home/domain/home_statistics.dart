import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_statistics.freezed.dart';

@freezed
abstract class HomeStatistics with _$HomeStatistics {
  const factory HomeStatistics({
    @Default(0) int pendingCount,
    @Default(0) int completedCountToday,
    @Default(0.0) double totalWeightToday,
    @Default(0) int customerCount,
    @Default(0) int driverCount,
  }) = _HomeStatistics;
}
