import 'package:freezed_annotation/freezed_annotation.dart';

// Đảm bảo tên file này viết đúng 100%
part 'scale_station.freezed.dart';
part 'scale_station.g.dart';

@freezed
// Sử dụng 'abstract class' là cách làm chuẩn mực
abstract class ScaleStation with _$ScaleStation {
  // Constructor factory nên để là 'const'
  const factory ScaleStation({
    int? id,
    required String name,
    required String ip,
    required int port,
    required String username,
    required String password,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ScaleStation;

  // Constructor này không cần 'const'
  factory ScaleStation.fromJson(Map<String, dynamic> json) =>
      _$ScaleStationFromJson(json);
}
