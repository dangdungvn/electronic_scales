import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/widgets/connection_test_dialog.dart';
import '../../../shared/widgets/connection_result_snackbar.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_display_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../data/scale_station_provider.dart';
import '../widgets/station_card.dart';
import 'add_edit_station_screen.dart';

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
              return StationCard(
                station: station,
                index: index,
                onTest: () => _testConnection(context, station),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _testConnection(BuildContext context, dynamic station) async {
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
