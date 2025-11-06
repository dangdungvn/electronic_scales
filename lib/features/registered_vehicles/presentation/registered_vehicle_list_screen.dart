import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/models/api_response.dart';
import '../../../shared/widgets/connection_result_snackbar.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_display_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../data/registered_vehicle_provider.dart';
import '../domain/registered_vehicle.dart';
import 'add_edit_vehicle_screen.dart';

class RegisteredVehicleListScreen extends HookConsumerWidget {
  const RegisteredVehicleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(registeredVehicleListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xe Đăng Ký'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add_circle_copy),
            onPressed: () => showAddEditVehicleSheet(context: context),
            tooltip: 'Thêm mới',
          ),
        ],
      ),
      body: vehiclesAsync.when(
        data: (vehicles) => vehicles.isEmpty
            ? const EmptyStateWidget(
                icon: Iconsax.car,
                title: 'Chưa có xe đăng ký',
                message: 'Thêm xe đăng ký đầu tiên của bạn',
              )
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(registeredVehicleListProvider);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vehicles.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return _VehicleCard(vehicle: vehicle);
                  },
                ),
              ),
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorDisplayWidget(
          error: error,
          onRetry: () => ref.invalidate(registeredVehicleListProvider),
        ),
      ),
    );
  }
}

class _VehicleCard extends ConsumerWidget {
  const _VehicleCard({required this.vehicle});

  final RegisteredVehicle vehicle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            showAddEditVehicleSheet(context: context, vehicle: vehicle),
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
                          Iconsax.car,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          vehicle.frontPlateNumber,
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
                  if (vehicle.isBlackList)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.danger,
                            size: 14,
                            color: Colors.red[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Blacklist',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (vehicle.isSpecialList)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.star_1,
                            size: 14,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Đặc biệt',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Iconsax.trash, size: 20),
                    color: Colors.red,
                    onPressed: () => _showDeleteDialog(context, ref),
                    tooltip: 'Xóa',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Iconsax.user,
                label: 'Khách hàng',
                value: vehicle.customerName,
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Iconsax.driver,
                label: 'Tài xế',
                value: vehicle.driverName,
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Iconsax.box,
                label: 'Loại hàng',
                value: vehicle.productName,
              ),
              if (vehicle.warehouseName != null &&
                  vehicle.warehouseName!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Iconsax.building,
                  label: 'Kho hàng',
                  value: vehicle.warehouseName!,
                ),
              ],
              if (vehicle.capacity > 0) ...[
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Iconsax.weight,
                  label: 'Trọng tải',
                  value: '${vehicle.capacity} kg',
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
        title: const Text('Xóa xe đăng ký'),
        content: Text(
          'Bạn có chắc chắn muốn xóa xe "${vehicle.frontPlateNumber}"?\nHành động này không thể hoàn tác.',
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
                    .read(registeredVehicleListProvider.notifier)
                    .deleteVehicle(vehicle.syncId!);
                if (context.mounted) {
                  context.pop();
                  ConnectionResultSnackbar.showSimple(
                    context,
                    message: 'Xóa xe thành công',
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
