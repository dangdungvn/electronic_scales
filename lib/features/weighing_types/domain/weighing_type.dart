import 'package:freezed_annotation/freezed_annotation.dart';

part 'weighing_type.freezed.dart';
part 'weighing_type.g.dart';

@freezed
abstract class WeighingType with _$WeighingType {
  const factory WeighingType({
    @JsonKey(name: 'ID') required int id,
    @JsonKey(name: 'Ten') required String name,
    @JsonKey(name: 'SoLanCan') required int weighingCount,
    @JsonKey(name: 'GhiChu') String? note,
  }) = _WeighingType;

  factory WeighingType.fromJson(Map<String, dynamic> json) =>
      _$WeighingTypeFromJson(json);
}
