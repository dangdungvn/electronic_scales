import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

/// Model Khách hàng - theo API LayDanhSachKhachHang
@freezed
abstract class Customer with _$Customer {
  const factory Customer({
    @JsonKey(name: 'ID') String? id,
    @JsonKey(name: 'Ma') required String code,
    @JsonKey(name: 'Ten') required String name,
    @JsonKey(name: 'DienThoai') String? phone,
    @JsonKey(name: 'DiaChi') String? address,
    @JsonKey(name: 'GhiChu') String? note,
    @JsonKey(name: 'CMND') String? idCard,
    @JsonKey(name: 'NgayCap') String? issueDate,
    @JsonKey(name: 'NoiCap') String? issuePlace,
    @JsonKey(name: 'Mst') String? taxCode,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
}

/// Request model cho thêm/sửa khách hàng - theo API CapNhatKhachHang
@freezed
abstract class CustomerRequest with _$CustomerRequest {
  const factory CustomerRequest({
    @JsonKey(name: 'ID') @Default('') String id, // Trống = thêm mới
    @JsonKey(name: 'Ma') required String code,
    @JsonKey(name: 'Ten') required String name,
    @JsonKey(name: 'DienThoai') @Default('') String phone,
    @JsonKey(name: 'DiaChi') @Default('') String address,
    @JsonKey(name: 'GhiChu') @Default('') String note,
    @JsonKey(name: 'CMND') @Default('') String idCard,
    @JsonKey(name: 'NgayCap') @Default('') String issueDate,
    @JsonKey(name: 'NoiCap') @Default('') String issuePlace,
    @JsonKey(name: 'Mst') @Default('') String taxCode,
  }) = _CustomerRequest;

  factory CustomerRequest.fromJson(Map<String, dynamic> json) =>
      _$CustomerRequestFromJson(json);
}
