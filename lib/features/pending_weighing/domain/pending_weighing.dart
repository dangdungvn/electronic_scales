import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_weighing.freezed.dart';
part 'pending_weighing.g.dart';

/// Model xe chờ cân lần 2
@freezed
abstract class PendingWeighing with _$PendingWeighing {
  const factory PendingWeighing({
    required String syncID,
    required int soPhieu,
    required String plateNumber, // bienSo11
    String? plateNumber2, // bienSo12 - Biển số thứ 2 (nếu có)
    required String khachHang,
    required String loaiHang,
    required String khoHang,
    required String kieuCan,
    required DateTime ngayCan, // ngayCan1 + gioCan1
    double? khoiLuongLan1, // khoiLuongCan1
    String? nguonGoc,
    String? chatLuong, // chatLuongHangHoa
    String? ghiChu,
    String? nguoiCan1, // Người cân lần 1
    // Thông tin lái xe
    String? tenLaiXe,
    String? cmndLaiXe,
    // Thông tin phiếu cân
    String? kyHieuPhieuCan,
    String? soChungTu,
    // Thông tin hàng hóa
    String? quyCach,
    // Thông tin vận chuyển
    String? nhaXe,
    String? maChuyen,
    // Hình ảnh cân lần 1
    String? vehicleImagePath11, // Ảnh biển số 1
    String? panoramaImagePath11, // Ảnh toàn cảnh 1
    String? vehicleImagePath12, // Ảnh biển số 2
    String? panoramaImagePath12, // Ảnh toàn cảnh 2
  }) = _PendingWeighing;

  factory PendingWeighing.fromJson(Map<String, dynamic> json) =>
      _$PendingWeighingFromJson(json);
}

/// Model filter để search xe chờ cân
@freezed
abstract class PendingWeighingFilter with _$PendingWeighingFilter {
  const factory PendingWeighingFilter({
    @Default('') String keyword,
    @Default('') String plateNumber,
    @Default(-1) int soPhieu,
    @Default('') String khachHang,
    @Default('') String loaiHang,
    @Default('') String khoHang,
    @Default('') String kieuCan,
  }) = _PendingWeighingFilter;

  factory PendingWeighingFilter.fromJson(Map<String, dynamic> json) =>
      _$PendingWeighingFilterFromJson(json);
}
