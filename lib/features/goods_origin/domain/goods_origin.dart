import 'package:freezed_annotation/freezed_annotation.dart';

part 'goods_origin.freezed.dart';
part 'goods_origin.g.dart';

@freezed
abstract class GoodsOrigin with _$GoodsOrigin {
  const factory GoodsOrigin({
    @JsonKey(name: 'ID') String? id,
    @JsonKey(name: 'Ma') required String code,
    @JsonKey(name: 'Ten') required String name,
    @JsonKey(name: 'GhiChu') @Default('') String note,
  }) = _GoodsOrigin;

  factory GoodsOrigin.fromJson(Map<String, dynamic> json) =>
      _$GoodsOriginFromJson(json);
}
