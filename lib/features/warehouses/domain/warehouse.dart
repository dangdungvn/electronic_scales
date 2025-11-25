import 'package:freezed_annotation/freezed_annotation.dart';

part 'warehouse.freezed.dart';
part 'warehouse.g.dart';

@freezed
abstract class Warehouse with _$Warehouse {
  const factory Warehouse({
    @JsonKey(name: 'ID') String? id,
    @JsonKey(name: 'Ten') required String name,
    @JsonKey(name: 'DiaChi') @Default('') String address,
    @JsonKey(name: 'GhiChu') @Default('') String note,
  }) = _Warehouse;

  factory Warehouse.fromJson(Map<String, dynamic> json) =>
      _$WarehouseFromJson(json);
}
