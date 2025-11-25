import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/models/api_response.dart';
import '../../../shared/widgets/connection_result_snackbar.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_display_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../data/driver_provider.dart';
import '../domain/driver.dart';
import 'add_edit_driver_screen.dart';

class DriverListScreen extends HookConsumerWidget {
  const DriverListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driversAsync = ref.watch(driverListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách tài xế'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add_circle_copy),
            onPressed: () => showAddEditDriverSheet(context: context),
            tooltip: 'Thêm mới',
          ),
        ],
      ),
      body: driversAsync.when(
        data: (drivers) => drivers.isEmpty
            ? const EmptyStateWidget(
                icon: Iconsax.driver,
                title: 'Chưa có tài xế',
                message: 'Thêm tài xế đầu tiên của bạn',
              )
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(driverListProvider);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: drivers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final driver = drivers[index];
                    return _DriverCard(driver: driver);
                  },
                ),
              ),
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorDisplayWidget(
          error: error,
          onRetry: () => ref.invalidate(driverListProvider),
        ),
      ),
    );
  }
}

class _DriverCard extends ConsumerWidget {
  const _DriverCard({required this.driver});

  final Driver driver;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showAddEditDriverSheet(context: context, driver: driver),
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
                          Iconsax.driver,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          driver.name,
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
              _InfoRow(icon: Iconsax.code, label: 'Mã', value: driver.code),
              if (driver.phone.isNotEmpty) ...[
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Iconsax.call,
                  label: 'Điện thoại',
                  value: driver.phone,
                ),
              ],
              if (driver.idCard.isNotEmpty) ...[
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Iconsax.card,
                  label: 'CMND/CCCD',
                  value: driver.idCard,
                ),
              ],
              if (driver.licenseNumber.isNotEmpty) ...[
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Iconsax.driver,
                  label: 'Bằng lái',
                  value: driver.licenseNumber,
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
        title: const Text('Xóa tài xế'),
        content: Text(
          'Bạn có chắc chắn muốn xóa tài xế "${driver.name}"?\nHành động này không thể hoàn tác.',
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
                    .read(driverListProvider.notifier)
                    .deleteDriver(driver.id ?? '');
                if (context.mounted) {
                  context.pop();
                  ConnectionResultSnackbar.showSimple(
                    context,
                    message: 'Xóa tài xế thành công',
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
