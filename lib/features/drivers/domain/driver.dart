import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver.freezed.dart';
part 'driver.g.dart';

@freezed
abstract class Driver with _$Driver {
  const factory Driver({
    @JsonKey(name: 'ID') String? id,
    @JsonKey(name: 'Ma') required String code,
    @JsonKey(name: 'LaiXe') required String name,
    @JsonKey(name: 'DienThoai') @Default('') String phone,
    @JsonKey(name: 'CMND') @Default('') String idCard,
    @JsonKey(name: 'Banglai') @Default('') String licenseNumber,
    @JsonKey(name: 'DiaChi') @Default('') String address,
    @JsonKey(name: 'NgayCap') @Default('') String issueDate,
    @JsonKey(name: 'NoiCap') @Default('') String issuePlace,
    @JsonKey(name: 'GiayPhepAnToan') @Default('') String safetyPermit,
    @JsonKey(name: 'NgayHetHan') @Default('') String expiryDate,
    @JsonKey(name: 'GhiChu') @Default('') String note,
  }) = _Driver;

  factory Driver.fromJson(Map<String, dynamic> json) => _$DriverFromJson(json);
}
