import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/pending_weighing.dart';
import '../../home/data/permissions_provider.dart';
import '../../scales/data/scale_station_provider.dart';

part 'pending_weighing_provider.g.dart';

/// Provider để quản lý danh sách xe chờ cân lần 2
@riverpod
class PendingWeighingList extends _$PendingWeighingList {
  @override
  Future<List<PendingWeighing>> build() async {
    return await _fetchPendingWeighings(const PendingWeighingFilter());
  }

  /// Refresh danh sách
  Future<void> refresh([PendingWeighingFilter? filter]) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _fetchPendingWeighings(filter ?? const PendingWeighingFilter()),
    );
  }

  /// Xóa xe chờ cân theo syncID
  Future<bool> deletePendingWeighing(String syncID) async {
    try {
      // Lấy trạm cân
      final stations = await ref.read(scaleStationListProvider.future);
      if (stations.isEmpty) {
        throw Exception('Chưa có trạm cân nào');
      }
      final station = stations.first;

      // Lấy token từ permissions
      final permissions = ref.read(userPermissionsProvider);
      if (permissions == null) {
        throw Exception('Chưa đăng nhập');
      }

      final dio = Dio();
      final baseUrl = 'http://${station.ip}:${station.port}';

      print('🗑️ Delete Request URL: $baseUrl/scm/XoaThongTinXeChoCanLan2');
      print('🗑️ Delete Request Body: ${{'syncID': syncID}}');

      final response = await dio.post(
        '$baseUrl/scm/XoaThongTinXeChoCanLan2',
        options: Options(headers: {'Authorization': permissions.token}),
        data: {'syncID': syncID},
      );

      print('✅ Delete Response Status: ${response.statusCode}');
      print('✅ Delete Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        // API trả về Error: false có nghĩa là thành công
        if (data['Error'] == false) {
          print('✅ Delete successful, refreshing list...');
          // Refresh lại danh sách
          await refresh();
          return true;
        }
      }

      print('❌ Delete failed');
      return false;
    } catch (e) {
      print('❌ Delete error: $e');
      return false;
    }
  }

  /// Fetch danh sách xe chờ cân với filter
  Future<List<PendingWeighing>> _fetchPendingWeighings(
    PendingWeighingFilter filter,
  ) async {
    // Lấy trạm cân
    final stations = await ref.read(scaleStationListProvider.future);
    if (stations.isEmpty) {
      throw Exception('Chưa có trạm cân nào');
    }
    final station = stations.first;

    // Lấy token từ permissions
    final permissions = ref.read(userPermissionsProvider);
    if (permissions == null) {
      throw Exception('Chưa đăng nhập');
    }

    try {
      final dio = Dio();
      final baseUrl = 'http://${station.ip}:${station.port}';

      // Debug: In ra request
      print('🚀 Request URL: $baseUrl/scm/BaoCaoDanhSachXeChoCanLan2');
      print('🚀 Request Headers: ${{'Authorization': permissions.token}}');
      print('🚀 Request Body: ${filter.toJson()}');

      final response = await dio.post(
        '$baseUrl/scm/BaoCaoDanhSachXeChoCanLan2',
        options: Options(headers: {'Authorization': permissions.token}),
        data: filter.toJson(),
      );

      // Debug: In ra response
      print('✅ Response Status Code: ${response.statusCode}');
      print('✅ Response Data: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data;

        // API trả về Error: false có nghĩa là thành công
        if (data['Error'] == false && data['data'] != null) {
          final List<dynamic> items = data['data'];
          print('📦 Found ${items.length} items');

          // Map data từ API format sang model format
          return items.map((item) {
            return PendingWeighing(
              syncID: item['syncID'] ?? '',
              soPhieu: int.tryParse(item['soPhieu']?.toString() ?? '0') ?? 0,
              plateNumber: item['bienSo11'] ?? '',
              plateNumber2: item['bienSo12']?.isNotEmpty == true
                  ? item['bienSo12']
                  : null,
              khachHang: item['khachHang'] ?? '',
              loaiHang: item['loaiHang'] ?? '',
              khoHang: item['khoHang'] ?? '',
              kieuCan: item['kieuCan'] ?? '',
              ngayCan: _parseDate(item['ngayCan1'], item['gioCan1']),
              khoiLuongLan1: _parseDouble(item['khoiLuongCan1']),
              nguonGoc: item['nguonGoc'],
              chatLuong: item['chatLuongHangHoa'],
              ghiChu: item['ghiChu'],
              nguoiCan1: item['nguoiCan1'],
              // Thông tin lái xe
              tenLaiXe: item['tenLaiXe'],
              cmndLaiXe: item['cmndLaiXe'],
              // Thông tin phiếu cân
              kyHieuPhieuCan: item['kyHieuPhieuCan'],
              soChungTu: item['soChungTu'],
              // Thông tin hàng hóa
              quyCach: item['quyCach'],
              // Thông tin vận chuyển
              nhaXe: item['nhaXe'],
              maChuyen: item['maChuyen'],
              // Hình ảnh cân lần 1
              vehicleImagePath11: item['VehicleImagePath11'],
              panoramaImagePath11: item['PanoramaImagePath11'],
              vehicleImagePath12: item['VehicleImagePath12'],
              panoramaImagePath12: item['PanoramaImagePath12'],
            );
          }).toList();
        } else {
          print('⚠️ API returned Error=true or data=null');
          print('⚠️ Message: ${data['Message']}');
        }
      }

      throw Exception('Không thể tải danh sách xe chờ cân');
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      throw Exception('Lỗi kết nối: ${e.message}');
    } catch (e, stackTrace) {
      print('❌ Unknown Error: $e');
      print('❌ Stack Trace: $stackTrace');
      rethrow;
    }
  }

  /// Parse date từ string format dd/MM/yyyy và HH:mm:ss
  DateTime _parseDate(String? dateStr, String? timeStr) {
    try {
      if (dateStr == null || dateStr.isEmpty) {
        return DateTime.now();
      }

      // Parse ngày: 03/11/2025
      final dateParts = dateStr.split('/');
      if (dateParts.length != 3) return DateTime.now();

      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);

      // Parse giờ: 17:33:18 (optional)
      int hour = 0, minute = 0, second = 0;
      if (timeStr != null && timeStr.isNotEmpty) {
        final timeParts = timeStr.split(':');
        if (timeParts.length >= 2) {
          hour = int.parse(timeParts[0]);
          minute = int.parse(timeParts[1]);
          if (timeParts.length >= 3) {
            second = int.parse(timeParts[2]);
          }
        }
      }

      return DateTime(year, month, day, hour, minute, second);
    } catch (e) {
      print('⚠️ Error parsing date: $dateStr $timeStr - $e');
      return DateTime.now();
    }
  }

  /// Parse double từ string có dấu phấy (ví dụ: "2,002")
  double? _parseDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      // Thay dấu phẩy bằng dấu chấm
      final cleanValue = value.replaceAll(',', '.');
      return double.parse(cleanValue);
    } catch (e) {
      print('⚠️ Error parsing double: $value - $e');
      return null;
    }
  }
}

/// Provider để lấy số lượng xe chờ cân (dùng cho badge)
@riverpod
Future<int> pendingWeighingCount(Ref ref) async {
  final list = await ref.watch(pendingWeighingListProvider.future);
  return list.length;
}
