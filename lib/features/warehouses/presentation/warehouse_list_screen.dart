import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/models/api_response.dart';
import '../../../shared/widgets/connection_result_snackbar.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_display_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../data/warehouse_provider.dart';
import '../domain/warehouse.dart';
import 'add_edit_warehouse_screen.dart';

class WarehouseListScreen extends HookConsumerWidget {
  const WarehouseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehousesAsync = ref.watch(warehouseListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách kho hàng'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add_circle_copy),
            onPressed: () => showAddEditWarehouseSheet(context: context),
            tooltip: 'Thêm mới',
          ),
        ],
      ),
      body: warehousesAsync.when(
        data: (warehouses) => warehouses.isEmpty
            ? const EmptyStateWidget(
                icon: Iconsax.building,
                title: 'Chưa có kho hàng',
                message: 'Thêm kho hàng đầu tiên của bạn',
              )
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(warehouseListProvider);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: warehouses.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final warehouse = warehouses[index];
                    return _WarehouseCard(warehouse: warehouse);
                  },
                ),
              ),
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorDisplayWidget(
          error: error,
          onRetry: () => ref.invalidate(warehouseListProvider),
        ),
      ),
    );
  }
}

class _WarehouseCard extends ConsumerWidget {
  const _WarehouseCard({required this.warehouse});

  final Warehouse warehouse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            showAddEditWarehouseSheet(context: context, warehouse: warehouse),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.building,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          warehouse.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Iconsax.trash, size: 20),
                    color: Colors.red,
                    onPressed: () => _showDeleteDialog(context, ref),
                    tooltip: 'Xóa',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (warehouse.address.isNotEmpty) ...[
                _InfoRow(
                  icon: Iconsax.location,
                  label: 'Địa chỉ',
                  value: warehouse.address,
                ),
                const SizedBox(height: 8),
              ],
              if (warehouse.note.isNotEmpty) ...[
                _InfoRow(
                  icon: Iconsax.note,
                  label: 'Ghi chú',
                  value: warehouse.note,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa kho hàng'),
        content: Text(
          'Bạn có chắc chắn muốn xóa kho hàng "${warehouse.name}"?\nHành động này không thể hoàn tác.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                await ref
                    .read(warehouseListProvider.notifier)
                    .deleteWarehouse(warehouse.id ?? '');
                if (context.mounted) {
                  context.pop();
                  ConnectionResultSnackbar.showSimple(
                    context,
                    message: 'Xóa kho hàng thành công',
                    backgroundColor: const Color(0xFF4CAF50),
                    icon: Iconsax.tick_circle,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  context.pop();
                  String errorMessage = 'Lỗi: ${e.toString()}';
                  if (e is ApiException) {
                    errorMessage = e.message;
                  }
                  ConnectionResultSnackbar.showSimple(
                    context,
                    message: errorMessage,
                    backgroundColor: Colors.red,
                    icon: Iconsax.close_circle,
                  );
                }
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
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
