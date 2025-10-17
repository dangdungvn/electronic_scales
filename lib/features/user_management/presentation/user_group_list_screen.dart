import 'package:electronic_scales/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_display_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../data/user_group_provider.dart';
import '../data/user_group_repository.dart';
import '../widgets/user_group_card.dart';
import 'add_edit_user_group_screen.dart';
import '../../scales/data/scale_station_provider.dart';
import '../../home/data/permissions_provider.dart';

/// Screen hiển thị danh sách nhóm người dùng
class UserGroupListScreen extends HookConsumerWidget {
  const UserGroupListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userGroupsAsync = ref.watch(userGroupListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.secondaryBlue, AppTheme.primaryBlue],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Iconsax.profile_2user,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('QLNND'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: () => ref.invalidate(userGroupListProvider),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: userGroupsAsync.when(
        data: (groups) => groups.isEmpty
            ? const EmptyStateWidget(
                icon: Iconsax.profile_2user,
                title: 'Chưa có nhóm người dùng',
                message: 'Danh sách nhóm người dùng trống',
              )
            : _UserGroupList(groups: groups),
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorDisplayWidget(
          error: error,
          onRetry: () => ref.invalidate(userGroupListProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditUserGroupScreen(),
            ),
          );
        },
        icon: const Icon(Iconsax.add),
        label: const Text('Nhóm'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        heroTag: null,
      ),
    );
  }
}

class _UserGroupList extends ConsumerWidget {
  const _UserGroupList({required this.groups});

  final List groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(userGroupListProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                UserGroupCard(
                  group: group,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            AddEditUserGroupScreen(userGroup: group),
                      ),
                    );
                  },
                  onDelete: () => _showDeleteConfirmDialog(context, ref, group),
                ),
                if (index == groups.length - 1) const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic group,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa nhóm "${group.tenNhom}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _deleteUserGroup(context, ref, group);
    }
  }

  Future<void> _deleteUserGroup(
    BuildContext context,
    WidgetRef ref,
    dynamic group,
  ) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Lấy thông tin trạm cân và token
      final stations = await ref.read(scaleStationListProvider.future);
      if (stations.isEmpty) {
        throw Exception('Chưa có trạm cân nào');
      }

      final station = stations.first;
      final permissions = ref.read(userPermissionsProvider);
      if (permissions == null) {
        throw Exception('Chưa đăng nhập');
      }

      final baseUrl = 'http://${station.ip}:${station.port}';

      // Call API delete
      final response = await ref
          .read(userGroupRepositoryProvider)
          .deleteUserGroup(
            baseUrl: baseUrl,
            token: permissions.token,
            groupId: group.id,
          );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (response.error) {
        throw Exception(response.message);
      }

      // Refresh danh sách
      ref.invalidate(userGroupListProvider);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa nhóm người dùng thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
