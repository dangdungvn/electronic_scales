import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Model dữ liệu người dùng
@freezed
abstract class User with _$User {
  const factory User({
    @JsonKey(name: 'IDMayCan') required int idMayCan,
    @JsonKey(name: 'ID') required String id,
    @JsonKey(name: 'Ma') String? ma,
    @JsonKey(name: 'Name') required String name,
    @JsonKey(name: 'Login') required String login,
    @JsonKey(name: 'Password') required String password,
    @JsonKey(name: 'IdNhomUser') required String idNhomUser,
    @JsonKey(name: 'Description') String? description,
    @JsonKey(name: 'AvatarImagePath') String? avatarImagePath,
    @JsonKey(name: 'QuanLyNguoiDung') @Default(false) bool quanLyNguoiDung,
    @JsonKey(name: 'CauHinhHeThong') @Default(false) bool cauHinhHeThong,
    @JsonKey(name: 'BaoCaoLog') @Default(false) bool baoCaoLog,
    @JsonKey(name: 'BaoCaoThongKe') @Default(false) bool baoCaoThongKe,
    @JsonKey(name: 'BaoCaoWeb') @Default(false) bool baoCaoWeb,
    @JsonKey(name: 'QuanLyDuLieu') String? quanLyDuLieu,
    @JsonKey(name: 'BaoCaoTongHop') String? baoCaoTongHop,
    @JsonKey(name: 'BaoCaoChoCanLan2') String? baoCaoChoCanLan2,
    @JsonKey(name: 'IDKhachHangs') @Default([]) List<dynamic> idKhachHangs,
    @JsonKey(name: 'SuaMaPhieu') @Default(false) bool suaMaPhieu,
    @JsonKey(name: 'SuaBienSo') @Default(false) bool suaBienSo,
    @JsonKey(name: 'SuaKhachHang') @Default(false) bool suaKhachHang,
    @JsonKey(name: 'SuaLoaiHang') @Default(false) bool suaLoaiHang,
    @JsonKey(name: 'SuaKhoHang') @Default(false) bool suaKhoHang,
    @JsonKey(name: 'SuaKieuCan') @Default(false) bool suaKieuCan,
    @JsonKey(name: 'SuaNguoiCan') @Default(false) bool suaNguoiCan,
    @JsonKey(name: 'SuaThoiGian') @Default(false) bool suaThoiGian,
    @JsonKey(name: 'SuaKhoiLuong') @Default(false) bool suaKhoiLuong,
    @JsonKey(name: 'SuaDonGia') @Default(false) bool suaDonGia,
    @JsonKey(name: 'ChoPhepGiamTruKL') @Default(false) bool choPhepGiamTruKL,
    @JsonKey(name: 'XuatExcel') @Default(false) bool xuatExcel,
    @JsonKey(name: 'XuatPDF') @Default(false) bool xuatPDF,
    @JsonKey(name: 'ChoPhepDeMo') @Default(false) bool choPhepDeMo,
    @JsonKey(name: 'SoLanIn') @Default(0) int soLanIn,
    @JsonKey(name: 'GioiHanThoiGian') String? gioiHanThoiGian,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// Response từ API GetUserList
@freezed
abstract class UserListResponse with _$UserListResponse {
  const factory UserListResponse({
    @JsonKey(name: 'Error') required bool error,
    @JsonKey(name: 'Message') required String message,
    @JsonKey(name: 'pageNo') required int pageNo,
    @JsonKey(name: 'pageSize') required int pageSize,
    @JsonKey(name: 'lastPage') required bool lastPage,
    @JsonKey(name: 'total') required int total,
    @JsonKey(name: 'data') required List<User> data,
  }) = _UserListResponse;

  factory UserListResponse.fromJson(Map<String, dynamic> json) =>
      _$UserListResponseFromJson(json);
}
