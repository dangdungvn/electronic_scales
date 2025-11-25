import 'package:freezed_annotation/freezed_annotation.dart';

part 'goods_quality.freezed.dart';
part 'goods_quality.g.dart';

@freezed
abstract class GoodsQuality with _$GoodsQuality {
  const factory GoodsQuality({
    @JsonKey(name: 'ID') String? id,
    @JsonKey(name: 'Ma') required String code,
    @JsonKey(name: 'Ten') required String name,
    @JsonKey(name: 'GhiChu') @Default('') String note,
  }) = _GoodsQuality;

  factory GoodsQuality.fromJson(Map<String, dynamic> json) =>
      _$GoodsQualityFromJson(json);
}
