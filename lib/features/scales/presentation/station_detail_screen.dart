import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/widgets/connection_test_dialog.dart';
import '../../../shared/widgets/connection_result_snackbar.dart';
import '../data/scale_station_provider.dart';
import '../domain/scale_station.dart';
import 'add_edit_station_screen.dart';

class StationDetailScreen extends ConsumerWidget {
  const StationDetailScreen({super.key, required this.station});

  final ScaleStation station;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Trạm Cân'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_1_copy),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit),
            onPressed: () => _navigateToEdit(context),
            tooltip: 'Chỉnh sửa',
          ),
          IconButton(
            icon: const Icon(Iconsax.trash),
            onPressed: () => _showDeleteDialog(context, ref),
            tooltip: 'Xóa',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2196F3).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hero only wraps the icon
                Hero(
                  tag: 'station_${station.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.weight_1,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  station.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconsax.status, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Hoạt động',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Info section
          _SectionTitle(icon: Iconsax.information, title: 'Thông Tin Kết Nối'),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _DetailItem(
                  icon: Iconsax.global,
                  label: 'Địa chỉ IP',
                  value: station.ip,
                  iconColor: const Color(0xFF2196F3),
                ),
                const Divider(height: 1),
                _DetailItem(
                  icon: Iconsax.setting_2,
                  label: 'Cổng',
                  value: station.port.toString(),
                  iconColor: const Color(0xFF9C27B0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Auth section
          _SectionTitle(icon: Iconsax.shield_tick, title: 'Xác Thực'),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _DetailItem(
                  icon: Iconsax.user,
                  label: 'Tên đăng nhập',
                  value: station.username,
                  iconColor: const Color(0xFF4CAF50),
                ),
                const Divider(height: 1),
                _DetailItem(
                  icon: Iconsax.lock,
                  label: 'Mật khẩu',
                  value: '•' * station.password.length,
                  iconColor: const Color(0xFFFF9800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Metadata section
          _SectionTitle(icon: Iconsax.calendar, title: 'Thông Tin Khác'),
          const SizedBox(height: 12),
          Card(
            child: _DetailItem(
              icon: Iconsax.clock,
              label: 'Ngày tạo',
              value: _formatDate(station.createdAt),
              iconColor: const Color(0xFFFF5722),
            ),
          ),
          const SizedBox(height: 32),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _testConnection(context),
                    icon: const Icon(Iconsax.link),
                    label: const Text('Kiểm Tra'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF2196F3),
                        width: 2,
                      ),
                      foregroundColor: const Color(0xFF2196F3),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToEdit(context),
                    icon: const Icon(Iconsax.edit),
                    label: const Text('Chỉnh Sửa'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditStationScreen(station: station),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Iconsax.trash, color: Colors.red, size: 32),
        ),
        title: const Text(
          'Xóa trạm cân',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa "${station.name}"?\nHành động này không thể hoàn tác.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(scaleStationListProvider.notifier)
                    .deleteStation(station.id!);
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close detail screen
                  ConnectionResultSnackbar.showSimple(
                    context,
                    message: 'Xóa trạm cân thành công',
                    backgroundColor: const Color(0xFF4CAF50),
                    icon: Iconsax.tick_circle,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ConnectionResultSnackbar.showSimple(
                    context,
                    message: 'Lỗi: ${e.toString()}',
                    backgroundColor: Colors.red,
                    icon: Iconsax.close_circle,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _testConnection(BuildContext context) async {
    // Hiển thị loading dialog và test connection
    final result = await ConnectionTestDialog.show(context, station);

    if (result != null && context.mounted) {
      // Hiển thị kết quả
      if (result['success'] == true) {
        ConnectionResultSnackbar.showSuccess(
          context,
          title: 'Kết nối thành công!',
          message: '${station.name} đang hoạt động',
        );
      } else {
        ConnectionResultSnackbar.showError(
          context,
          title: 'Kết nối thất bại!',
          message: result['message'] ?? 'Lỗi không xác định',
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? const Color(0xFF2196F3)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? const Color(0xFF2196F3),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Section title widget
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
