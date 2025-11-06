import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/scales/domain/scale_station.dart';
import '../../features/scales/data/connection_service.dart';

/// Widget hiển thị dialog test connection và trả về kết quả
class ConnectionTestDialog {
  /// Show loading dialog và test connection
  /// Trả về Map với kết quả test
  static Future<Map<String, dynamic>?> show(
    BuildContext context,
    ScaleStation station,
  ) async {
    // Hiển thị loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _LoadingDialog(station: station),
    );

    Map<String, dynamic>? result;

    try {
      // Gọi API test connection
      result = await ConnectionService.testConnection(station);

      if (context.mounted) {
        // Đóng loading dialog
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        context.pop(); // Đóng loading
        result = {'success': false, 'message': 'Lỗi: ${e.toString()}'};
      }
    }

    return result;
  }
}

class _LoadingDialog extends StatelessWidget {
  const _LoadingDialog({required this.station});

  final ScaleStation station;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Đang kiểm tra kết nối...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${station.ip}:${station.port}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
