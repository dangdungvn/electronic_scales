import 'dart:async';
import 'package:dio/dio.dart';
import '../domain/scale_station.dart';

class ConnectionService {
  /// Test kết nối đến trạm cân bằng cách gọi API token_auth
  /// Trả về Map với thông tin kết quả
  static Future<Map<String, dynamic>> testConnection(
    ScaleStation station,
  ) async {
    // Tạo Dio instance với config
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    try {
      // Tạo URL từ IP và Port
      final url = 'http://${station.ip}:${station.port}/scm/token_auth';

      // Body request với username và password
      final body = {'username': station.username, 'password': station.password};

      // Gọi API
      final response = await dio.post(url, data: body);

      // Kiểm tra status code
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Kết nối thành công!',
          'data': response.data,
          'permissions': response.data, // Thêm permissions để lưu vào provider
        };
      } else {
        return {
          'success': false,
          'message': 'Lỗi: ${response.statusCode} - ${response.statusMessage}',
          'statusCode': response.statusCode,
        };
      }
    } on DioException catch (e) {
      // Xử lý các loại lỗi Dio
      return _handleDioError(e, station);
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi không xác định',
        'error': e.toString(),
      };
    } finally {
      dio.close();
    }
  }

  static Map<String, dynamic> _handleDioError(
    DioException error,
    ScaleStation station,
  ) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return {
          'success': false,
          'message':
              'Timeout: Không thể kết nối đến ${station.ip}:${station.port}',
          'error': 'Connection timeout',
        };

      case DioExceptionType.badResponse:
        return {
          'success': false,
          'message':
              'Lỗi server: ${error.response?.statusCode} - ${error.response?.statusMessage}',
          'statusCode': error.response?.statusCode,
        };

      case DioExceptionType.cancel:
        return {
          'success': false,
          'message': 'Yêu cầu đã bị hủy',
          'error': 'Request cancelled',
        };

      case DioExceptionType.connectionError:
        return {
          'success': false,
          'message':
              'Không thể kết nối đến ${station.ip}:${station.port}\nKiểm tra địa chỉ IP và cổng',
          'error': 'Connection error',
        };

      case DioExceptionType.badCertificate:
        return {
          'success': false,
          'message': 'Lỗi chứng chỉ SSL',
          'error': 'Bad SSL certificate',
        };

      case DioExceptionType.unknown:
        return {
          'success': false,
          'message':
              'Lỗi kết nối: Không thể truy cập ${station.ip}:${station.port}',
          'error': error.message ?? 'Unknown error',
        };
    }
  }
}
