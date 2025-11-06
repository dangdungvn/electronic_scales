import 'package:freezed_annotation/freezed_annotation.dart';

part 'registered_vehicle.freezed.dart';
part 'registered_vehicle.g.dart';

@freezed
abstract class RegisteredVehicle with _$RegisteredVehicle {
  const factory RegisteredVehicle({
    @JsonKey(name: 'SyncID') String? syncId,
    @JsonKey(name: 'TenKhachHang') required String customerName,
    @JsonKey(name: 'CMNDKhachHang') String? customerIdCard,
    @JsonKey(name: 'DienThoaiKH') String? customerPhone,
    @JsonKey(name: 'DiachiKH') String? customerAddress,
    @JsonKey(name: 'MstKH') String? customerTaxCode,
    @JsonKey(name: 'GhiChuKH') String? customerNote,
    @JsonKey(name: 'BienSoDauXe') required String frontPlateNumber,
    @JsonKey(name: 'BienSoDuoiXe') String? rearPlateNumber,
    @JsonKey(name: 'LaiXe') required String driverName,
    @JsonKey(name: 'TrongTai') @Default(0) int capacity,
    @JsonKey(name: 'KLTongChoPhep') @Default(0) int totalAllowedWeight,
    @JsonKey(name: 'DienThoai') String? driverPhone,
    @JsonKey(name: 'CMND') String? driverIdCard,
    @JsonKey(name: 'CardNumber') String? cardNumber,
    @JsonKey(name: 'IDLoaiHang') String? productId,
    @JsonKey(name: 'TenLoaiHang') required String productName,
    @JsonKey(name: 'IsBlackList') @Default(false) bool isBlackList,
    @JsonKey(name: 'IsSpecialList') @Default(false) bool isSpecialList,
    @JsonKey(name: 'XeCan1Lan') @Default(false) bool singleWeighing,
    @JsonKey(name: 'GhiChu') String? note,
    @JsonKey(name: 'TenKhoHang') String? warehouseName,
    @JsonKey(name: 'TenNguonGoc') String? originName,
    @JsonKey(name: 'NgayCanBi') DateTime? weighingDate,
    @JsonKey(name: 'NgayDangKy') DateTime? registrationDate,
    @JsonKey(name: 'AnhDauXe') String? frontImage,
    @JsonKey(name: 'AnhDuoiXe') String? rearImage,
    @JsonKey(name: 'AnhToanCanh') String? overviewImage,
    @JsonKey(name: 'AnhCMND') String? idCardImage,
    @JsonKey(name: 'GiayPhepAnToan') String? safetyPermit,
    @JsonKey(name: 'NgayHetHan') String? expiryDate,
    @JsonKey(name: 'DonGia') @Default(0.0) double unitPrice,
    @JsonKey(name: 'TyLeQuyDoi') @Default(1.0) double conversionRate,
    @JsonKey(name: 'TyLeQuyDoi2') @Default(1.0) double conversionRate2,
    @JsonKey(name: 'MaDonHangAPI') String? orderCode,
    @JsonKey(name: 'HeThongDangKy') String? registrationSystem,
    @JsonKey(name: 'MaKho') String? warehouseCode,
    @JsonKey(name: 'MaChuyen') String? tripCode,
    @JsonKey(name: 'NhaXe') String? transportCompany,
    @JsonKey(name: 'ExtraAttribute') String? extraAttribute,
    @JsonKey(name: 'TenChatLuong') String? qualityName,
    @JsonKey(name: 'TenKieuCan') String? weighingTypeName,
  }) = _RegisteredVehicle;

  factory RegisteredVehicle.fromJson(Map<String, dynamic> json) =>
      _$RegisteredVehicleFromJson(json);
}

@freezed
abstract class RegisteredVehicleRequest with _$RegisteredVehicleRequest {
  const factory RegisteredVehicleRequest({
    @JsonKey(name: 'SyncID') @Default('') String syncId,
    @JsonKey(name: 'TenKhachHang') required String customerName,
    @JsonKey(name: 'CMNDKhachHang') @Default('') String customerIdCard,
    @JsonKey(name: 'DienThoaiKH') @Default('') String customerPhone,
    @JsonKey(name: 'DiachiKH') @Default('') String customerAddress,
    @JsonKey(name: 'MstKH') @Default('') String customerTaxCode,
    @JsonKey(name: 'GhiChuKH') @Default('') String customerNote,
    @JsonKey(name: 'BienSoDauXe') required String frontPlateNumber,
    @JsonKey(name: 'BienSoDuoiXe') @Default('') String rearPlateNumber,
    @JsonKey(name: 'LaiXe') required String driverName,
    @JsonKey(name: 'TrongTai') @Default(0) int capacity,
    @JsonKey(name: 'KLTongChoPhep') @Default(0) int totalAllowedWeight,
    @JsonKey(name: 'DienThoai') @Default('') String driverPhone,
    @JsonKey(name: 'CMND') @Default('') String driverIdCard,
    @JsonKey(name: 'CardNumber') @Default('') String cardNumber,
    @JsonKey(name: 'IDLoaiHang') @Default('') String productId,
    @JsonKey(name: 'TenLoaiHang') required String productName,
    @JsonKey(name: 'IsBlackList') @Default(false) bool isBlackList,
    @JsonKey(name: 'IsSpecialList') @Default(false) bool isSpecialList,
    @JsonKey(name: 'XeCan1Lan') @Default(false) bool singleWeighing,
    @JsonKey(name: 'GhiChu') @Default('') String note,
    @JsonKey(name: 'TenKhoHang') @Default('') String warehouseName,
    @JsonKey(name: 'TenNguonGoc') @Default('') String originName,
    @JsonKey(name: 'NgayCanBi') DateTime? weighingDate,
    @JsonKey(name: 'NgayDangKy') DateTime? registrationDate,
    @JsonKey(name: 'AnhDauXe') @Default('') String frontImage,
    @JsonKey(name: 'AnhDuoiXe') @Default('') String rearImage,
    @JsonKey(name: 'AnhToanCanh') @Default('') String overviewImage,
    @JsonKey(name: 'AnhCMND') @Default('') String idCardImage,
    @JsonKey(name: 'GiayPhepAnToan') @Default('') String safetyPermit,
    @JsonKey(name: 'NgayHetHan') @Default('') String expiryDate,
    @JsonKey(name: 'DonGia') @Default(0.0) double unitPrice,
    @JsonKey(name: 'TyLeQuyDoi') @Default(1.0) double conversionRate,
    @JsonKey(name: 'TyLeQuyDoi2') @Default(1.0) double conversionRate2,
    @JsonKey(name: 'MaDonHangAPI') @Default('') String orderCode,
    @JsonKey(name: 'HeThongDangKy') @Default('') String registrationSystem,
    @JsonKey(name: 'MaKho') @Default('') String warehouseCode,
    @JsonKey(name: 'MaChuyen') @Default('') String tripCode,
    @JsonKey(name: 'NhaXe') @Default('') String transportCompany,
    @JsonKey(name: 'ExtraAttribute') @Default('') String extraAttribute,
    @JsonKey(name: 'TenChatLuong') @Default('') String qualityName,
    @JsonKey(name: 'TenKieuCan') @Default('') String weighingTypeName,
  }) = _RegisteredVehicleRequest;

  factory RegisteredVehicleRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisteredVehicleRequestFromJson(json);
}
