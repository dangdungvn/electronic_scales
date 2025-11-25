import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    @JsonKey(name: 'ID') String? id,
    @JsonKey(name: 'Ma') required String code,
    @JsonKey(name: 'Ten') required String name,
    @JsonKey(name: 'GhiChu') @Default('') String note,
    @JsonKey(name: 'DonGia') @Default(0.0) double price,
    @JsonKey(name: 'TyLeQuyDoi') @Default(1.0) double conversionRate,
    @JsonKey(name: 'TyLeQuyDoi2') @Default(1.0) double conversionRate2,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
