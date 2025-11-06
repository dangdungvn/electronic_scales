import 'package:electronic_scales/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/scale_station_provider.dart';
import '../domain/scale_station.dart';
import '../widgets/station_header_card.dart';
import '../widgets/detail_info_item.dart';
import '../widgets/section_title.dart';
import 'add_edit_station_screen.dart';

class StationDetailScreen extends ConsumerWidget {
  const StationDetailScreen({super.key, required this.stationId});

  final int stationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationAsync = ref.watch(scaleStationProvider(stationId));

    return stationAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Chi Tiết Trạm Cân'),
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left_1),
            onPressed: () => context.pop(),
          ),
        ),
        body: const LoadingWidget(),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Chi Tiết Trạm Cân'),
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left_1),
            onPressed: () => context.pop(),
          ),
        ),
        body: ErrorDisplayWidget(
          error: error,
          onRetry: () => ref.invalidate(scaleStationProvider(stationId)),
        ),
      ),
      data: (station) {
        if (station == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Chi Tiết Trạm Cân'),
              leading: IconButton(
                icon: const Icon(Iconsax.arrow_left_1),
                onPressed: () => context.pop(),
              ),
            ),
            body: const EmptyStateWidget(
              icon: Iconsax.search_status_1,
              title: 'Không tìm thấy trạm cân',
              message: 'Trạm cân này có thể đã bị xóa',
            ),
          );
        }

        return _StationDetailContent(station: station);
      },
    );
  }
}

class _StationDetailContent extends ConsumerWidget {
  const _StationDetailContent({required this.station});

  final ScaleStation station;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Trạm Cân'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_1),
          onPressed: () => context.pop(),
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
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header card
              StationHeaderCard(
                stationId: station.id,
                stationName: station.name,
              ),
              const SizedBox(height: 24),
              // Info section
              SectionTitle(
                icon: Iconsax.information,
                title: 'Thông Tin Kết Nối',
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    DetailInfoItem(
                      icon: Iconsax.global,
                      label: 'Địa chỉ IP',
                      value: station.ip,
                      iconColor: const Color(0xFF2196F3),
                    ),
                    const Divider(height: 1),
                    DetailInfoItem(
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
              SectionTitle(icon: Iconsax.shield_tick, title: 'Xác Thực'),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    DetailInfoItem(
                      icon: Iconsax.user,
                      label: 'Tên đăng nhập',
                      value: station.username,
                      iconColor: const Color(0xFF4CAF50),
                    ),
                    const Divider(height: 1),
                    DetailInfoItem(
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
              SectionTitle(icon: Iconsax.calendar, title: 'Thông Tin Khác'),
              const SizedBox(height: 12),
              Card(
                child: DetailInfoItem(
                  icon: Iconsax.clock,
                  label: 'Ngày tạo',
                  value: _formatDate(station.createdAt),
                  iconColor: const Color(0xFFFF5722),
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              const SizedBox(height: 20),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 12.0),
                child: Row(
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
              ),
            ),
          ),
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
          TextButton(onPressed: () => context.pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(scaleStationListProvider.notifier)
                    .deleteStation(station.id!);
                if (context.mounted) {
                  context.pop(); // Close dialog
                  context.pop(); // Close detail screen
                  ConnectionResultSnackbar.showSimple(
                    context,
                    message: 'Xóa trạm cân thành công',
                    backgroundColor: const Color(0xFF4CAF50),
                    icon: Iconsax.tick_circle,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  context.pop();
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
