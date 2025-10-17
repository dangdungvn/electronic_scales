import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_group.freezed.dart';
part 'user_group.g.dart';

/// Model dữ liệu nhóm người dùng
@freezed
abstract class UserGroup with _$UserGroup {
  const factory UserGroup({
    @JsonKey(name: 'IDMayCan') required int idMayCan,
    @JsonKey(name: 'ID') required String id,
    @JsonKey(name: 'STT') required int stt,
    @JsonKey(name: 'TenNhom') required String tenNhom,
    @JsonKey(name: 'GhiChu') String? ghiChu,
    @JsonKey(name: 'MauQuanLyNguoiDung')
    @Default(false)
    bool mauQuanLyNguoiDung,
    @JsonKey(name: 'MauCauHinhHeThong') @Default(false) bool mauCauHinhHeThong,
    @JsonKey(name: 'MauBaoCaoLog') @Default(false) bool mauBaoCaoLog,
    @JsonKey(name: 'MauBaoCaoThongKe') @Default(false) bool mauBaoCaoThongKe,
    @JsonKey(name: 'MauBaoCaoWeb') @Default(false) bool mauBaoCaoWeb,
    @JsonKey(name: 'MauQuanLyDuLieu') String? mauQuanLyDuLieu,
    @JsonKey(name: 'MauBaoCaoTongHop') String? mauBaoCaoTongHop,
    @JsonKey(name: 'MauBaoCaoChoCanLan2') String? mauBaoCaoChoCanLan2,
  }) = _UserGroup;

  factory UserGroup.fromJson(Map<String, dynamic> json) =>
      _$UserGroupFromJson(json);
}

/// Response từ API GetUserGroupList
@freezed
abstract class UserGroupListResponse with _$UserGroupListResponse {
  const factory UserGroupListResponse({
    @JsonKey(name: 'Error') required bool error,
    @JsonKey(name: 'Message') required String message,
    @JsonKey(name: 'pageNo') required int pageNo,
    @JsonKey(name: 'pageSize') required int pageSize,
    @JsonKey(name: 'lastPage') required bool lastPage,
    @JsonKey(name: 'total') required int total,
    @JsonKey(name: 'data') required List<UserGroup> data,
  }) = _UserGroupListResponse;

  factory UserGroupListResponse.fromJson(Map<String, dynamic> json) =>
      _$UserGroupListResponseFromJson(json);
}
