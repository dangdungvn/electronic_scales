import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../data/pending_weighing_provider.dart';
import '../domain/pending_weighing.dart';
import 'pending_weighing_detail_dialog.dart';
import '../../../shared/widgets/widgets.dart';

/// Screen hiển thị danh sách xe chờ cân lần 2
class PendingWeighingListScreen extends HookConsumerWidget {
  const PendingWeighingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingListAsync = ref.watch(pendingWeighingListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const FaIcon(
                FontAwesomeIcons.clockRotateLeft,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Xe Chờ Cân Lần 2'),
          ],
        ),
        // leading: IconButton(
        //   icon: const Icon(Iconsax.arrow_left_1),
        //   onPressed: () => context.pop(),
        // ),
      ),
      body: pendingListAsync.when(
        data: (vehicles) => vehicles.isEmpty
            ? const EmptyStateWidget(
                icon: Iconsax.clock,
                title: 'Không có xe chờ cân',
                message: 'Chưa có xe nào chờ cân lần 2',
              )
            : _PendingList(vehicles: vehicles),
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorDisplayWidget(
          error: error,
          onRetry: () => ref.invalidate(pendingWeighingListProvider),
        ),
      ),
    );
  }
}

class _PendingList extends ConsumerWidget {
  const _PendingList({required this.vehicles});

  final List<PendingWeighing> vehicles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(pendingWeighingListProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PendingVehicleCard(vehicle: vehicle, index: index),
          );
        },
      ),
    );
  }
}

class _PendingVehicleCard extends ConsumerWidget {
  const _PendingVehicleCard({required this.vehicle, required this.index});

  final PendingWeighing vehicle;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradients = [
      [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
      [const Color(0xFF2196F3), const Color(0xFF64B5F6)],
      [const Color(0xFF9C27B0), const Color(0xFFBA68C8)],
      [const Color(0xFF4CAF50), const Color(0xFF81C784)],
      [const Color(0xFFFF5722), const Color(0xFFFF8A65)],
    ];

    final gradient = gradients[index % gradients.length];

    return Card(
      elevation: 6,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          PendingWeighingDetailDialog.show(context, vehicle, gradient);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                gradient[0].withOpacity(0.1),
                gradient[1].withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Biển số + Số phiếu
              Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: gradient[0].withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.truckFast,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Biển số
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.plateNumber,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Phiếu #${vehicle.soPhieu}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  // Delete button
                  IconButton(
                    onPressed: () => _showDeleteDialog(context, ref),
                    icon: Icon(Iconsax.trash, color: Colors.red[400], size: 20),
                    tooltip: 'Xóa',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Info rows
              _InfoRow(
                icon: Iconsax.user,
                label: 'Khách hàng',
                value: vehicle.khachHang,
                color: gradient[0],
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Iconsax.box,
                label: 'Loại hàng',
                value: vehicle.loaiHang,
                color: gradient[0],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _InfoRow(
                      icon: Iconsax.shop,
                      label: 'Kho',
                      value: vehicle.khoHang,
                      color: gradient[0],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoRow(
                      icon: Iconsax.weight_1,
                      label: 'Kiểu cân',
                      value: vehicle.kieuCan,
                      color: gradient[0],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Iconsax.trash, color: Colors.red[400], size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Xóa xe chờ cân'),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa xe ${vehicle.plateNumber} khỏi danh sách chờ cân?',
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red[400]),
            onPressed: () async {
              context.pop();

              final success = await ref
                  .read(pendingWeighingListProvider.notifier)
                  .deletePendingWeighing(vehicle.syncID);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Đã xóa xe ${vehicle.plateNumber}'
                          : 'Không thể xóa xe',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color.withOpacity(0.7)),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
