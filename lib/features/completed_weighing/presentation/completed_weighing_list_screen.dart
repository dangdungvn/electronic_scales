import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_display_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../data/completed_weighing_provider.dart';
import '../domain/completed_weighing.dart';
import 'completed_weighing_detail_dialog.dart';

class CompletedWeighingListScreen extends HookConsumerWidget {
  const CompletedWeighingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(completedWeighingListProvider);
    final filter = ref.watch(completedWeighingFilterStateProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Xe Đã Cân Xong'),
            Text(
              '${dateFormat.format(filter.fromDate)} - ${dateFormat.format(filter.toDate)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.calendar_1_copy),
            onPressed: () => _showDateRangePicker(context, ref, filter),
          ),
        ],
      ),
      body: listAsync.when(
        data: (list) => list.isEmpty
            ? const EmptyStateWidget(
                icon: Iconsax.clipboard_text,
                title: 'Không có dữ liệu',
                message:
                    'Không tìm thấy phiếu cân nào trong khoảng thời gian này',
              )
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(completedWeighingListProvider);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _CompletedWeighingCard(item: item);
                  },
                ),
              ),
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorDisplayWidget(
          error: error,
          onRetry: () => ref.invalidate(completedWeighingListProvider),
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(
    BuildContext context,
    WidgetRef ref,
    CompletedWeighingFilter filter,
  ) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: filter.fromDate,
        end: filter.toDate,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final start = DateTime(
        picked.start.year,
        picked.start.month,
        picked.start.day,
        0,
        0,
        0,
      );
      final end = DateTime(
        picked.end.year,
        picked.end.month,
        picked.end.day,
        23,
        59,
        59,
      );
      ref
          .read(completedWeighingFilterStateProvider.notifier)
          .setDateRange(start, end);
    }
  }
}

class _CompletedWeighingCard extends StatelessWidget {
  const _CompletedWeighingCard({required this.item});

  final CompletedWeighing item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () => CompletedWeighingDetailDialog.show(context, item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Ticket Number & License Plate
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${item.ticketNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  Text(
                    item.licensePlate1 ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFEEEEEE)),

              // Content
              _InfoRow(
                icon: Iconsax.user,
                label: 'Khách hàng',
                value: item.customerName ?? '-',
                iconColor: Colors.blue,
              ),
              const SizedBox(height: 10),
              _InfoRow(
                icon: Iconsax.box,
                label: 'Hàng hóa',
                value: item.productName ?? '-',
                iconColor: Colors.blue,
              ),
              const SizedBox(height: 10),
              _InfoRow(
                icon: Iconsax.weight_1,
                label: 'KL Hàng',
                value: '${item.netWeight} kg',
                valueColor: Colors.blue[700],
                isBold: true,
                iconColor: Colors.blue,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _InfoRow(
                      icon: Iconsax.clock,
                      label: 'Lần 1',
                      value: '${item.time1} ${item.date1}',
                      fontSize: 12,
                      iconColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoRow(
                      icon: Iconsax.clock,
                      label: 'Lần 2',
                      value: '${item.time2} ${item.date2}',
                      fontSize: 12,
                      iconColor: Colors.blue,
                    ),
                  ),
                ],
              ),

              if (item.warehouseName?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Iconsax.building,
                  label: 'Kho',
                  value: item.warehouseName!,
                  iconColor: Colors.blue,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
    this.fontSize = 14,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;
  final double fontSize;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor ?? Colors.grey[500]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: fontSize, color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
