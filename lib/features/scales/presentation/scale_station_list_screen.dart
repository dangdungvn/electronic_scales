import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/widgets/connection_test_dialog.dart';
import '../../../shared/widgets/connection_result_snackbar.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_display_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../data/scale_station_provider.dart';
import 'add_edit_station_screen.dart';
import 'station_detail_screen.dart';

class ScaleStationListScreen extends HookConsumerWidget {
  const ScaleStationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationsAsync = ref.watch(scaleStationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Iconsax.weight_1,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Quản Lý Trạm Cân'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: () => ref.invalidate(scaleStationListProvider),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: stationsAsync.when(
        data: (stations) => stations.isEmpty
            ? const EmptyStateWidget(
                icon: Iconsax.weight_1,
                title: 'Chưa có trạm cân nào',
                message: 'Nhấn nút "Thêm Trạm" để thêm trạm cân mới',
                actionText: 'Bắt đầu ngay',
              )
            : _StationList(stations: stations),
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorDisplayWidget(
          error: error,
          onRetry: () => ref.invalidate(scaleStationListProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddStation(context),
        icon: const Icon(Iconsax.add),
        label: const Text('Thêm Trạm'),
        elevation: 4,
      ),
    );
  }

  void _navigateToAddStation(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddEditStationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}

class _StationList extends ConsumerWidget {
  const _StationList({required this.stations});

  final List stations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(scaleStationListProvider.notifier).refresh();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive grid: 1 column on mobile, 2 on tablet, 3 on desktop
          final crossAxisCount = constraints.maxWidth > 1200
              ? 3
              : constraints.maxWidth > 600
              ? 2
              : 1;

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 2.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: stations.length,
            itemBuilder: (context, index) {
              final station = stations[index];
              return _StationCard(station: station, index: index);
            },
          );
        },
      ),
    );
  }
}

class _StationCard extends StatelessWidget {
  const _StationCard({required this.station, required this.index});

  final dynamic station;
  final int index;

  @override
  Widget build(BuildContext context) {
    // Gradient colors cho mỗi card
    final gradients = [
      [const Color(0xFF2196F3), const Color(0xFF64B5F6)],
      [const Color(0xFF9C27B0), const Color(0xFFBA68C8)],
      [const Color(0xFFFF5722), const Color(0xFFFF8A65)],
      [const Color(0xFF4CAF50), const Color(0xFF81C784)],
      [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
    ];

    final gradient = gradients[index % gradients.length];

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _testConnection(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                gradient[0].withOpacity(0.05),
                gradient[1].withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon với gradient
              Hero(
                tag: 'station_${station.id}',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: gradient[0].withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Iconsax.weight_1,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Thông tin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      station.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Iconsax.global, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${station.ip}:${station.port}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Detail button
              IconButton(
                onPressed: () => _navigateToDetail(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: gradient[0].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Iconsax.arrow_right_3,
                    color: gradient[0],
                    size: 18,
                  ),
                ),
                tooltip: 'Xem chi tiết',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigate to detail screen
  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            StationDetailScreen(station: station),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  // Test kết nối đến trạm cân
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
}
