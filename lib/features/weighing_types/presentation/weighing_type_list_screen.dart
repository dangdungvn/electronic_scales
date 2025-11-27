import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/models/api_response.dart';
import '../../../shared/widgets/connection_result_snackbar.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_display_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../data/weighing_type_provider.dart';
import '../domain/weighing_type.dart';
import '../widgets/weighing_type_card.dart';
import 'add_edit_weighing_type_screen.dart';

/// Màn hình danh sách kiểu cân
class WeighingTypeListScreen extends HookConsumerWidget {
  const WeighingTypeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weighingTypesAsync = ref.watch(weighingTypeListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Kiểu cân'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_1),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add_circle_copy),
            onPressed: () => showAddEditWeighingTypeSheet(context: context),
            tooltip: 'Thêm kiểu cân',
          ),
        ],
      ),
      body: weighingTypesAsync.when(
        data: (weighingTypes) => weighingTypes.isEmpty
            ? const EmptyStateWidget(
                icon: Iconsax.weight_1,
                title: 'Chưa có kiểu cân',
                message: 'Thêm kiểu cân đầu tiên của bạn',
              )
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(weighingTypeListProvider);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: weighingTypes.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final weighingType = weighingTypes[index];
                    return WeighingTypeCard(
                      weighingType: weighingType,
                      onTap: () => showAddEditWeighingTypeSheet(
                        context: context,
                        weighingType: weighingType,
                      ),
                      onDelete: () =>
                          _showDeleteDialog(context, ref, weighingType),
                    );
                  },
                ),
              ),
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorDisplayWidget(
          error: error,
          onRetry: () => ref.invalidate(weighingTypeListProvider),
        ),
      ),
    );
  }

  /// Hiển thị dialog xác nhận xóa
  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    WeighingType weighingType,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa kiểu cân'),
        content: Text(
          'Bạn có chắc chắn muốn xóa kiểu cân "${weighingType.name}"?\nHành động này không thể hoàn tác.',
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
                    .read(weighingTypeListProvider.notifier)
                    .deleteWeighingType(weighingType.id);
                if (context.mounted) {
                  context.pop();
                  ConnectionResultSnackbar.showSimple(
                    context,
                    message: 'Xóa kiểu cân thành công',
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
