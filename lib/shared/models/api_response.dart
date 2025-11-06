import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

@Freezed(genericArgumentFactories: true)
abstract class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    @JsonKey(name: 'Error') @Default(false) bool error,
    @JsonKey(name: 'Message') String? message,
    @JsonKey(name: 'pageNo') @Default(0) int pageNo,
    @JsonKey(name: 'pageSize') @Default(0) int pageSize,
    @JsonKey(name: 'lastPage') @Default(false) bool lastPage,
    @JsonKey(name: 'total') @Default(0) int total,
    @JsonKey(name: 'data') T? data,
  }) = _ApiResponse<T>;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);
}

// Helper extension for easier error handling
extension ApiResponseX<T> on ApiResponse<T> {
  bool get isSuccess => !error;

  String get errorMessage => message ?? 'Đã có lỗi xảy ra';

  T? get dataOrNull => error ? null : data;

  T getDataOrThrow() {
    if (error || data == null) {
      throw ApiException(errorMessage);
    }
    return data as T;
  }
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}
