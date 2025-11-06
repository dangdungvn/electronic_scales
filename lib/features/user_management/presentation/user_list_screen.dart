import 'package:electronic_scales/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_display_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../data/user_provider.dart';
import '../data/user_repository.dart';
import '../widgets/user_card.dart';
import 'add_edit_user_screen.dart';
import '../../scales/data/scale_station_provider.dart';
import '../../home/data/permissions_provider.dart';

/// Screen hiển thị danh sách người dùng
class UserListScreen extends HookConsumerWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(userListProvider);

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
              child: const Icon(Iconsax.user, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('QLND'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add),
            onPressed: () => showAddEditUserSheet(context: context),
          ),
        ],
      ),
      body: usersAsync.when(
        data: (users) => users.isEmpty
            ? const EmptyStateWidget(
                icon: Iconsax.user,
                title: 'Chưa có người dùng',
                message: 'Danh sách người dùng trống',
              )
            : _UserList(users: users),
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorDisplayWidget(
          error: error,
          onRetry: () => ref.invalidate(userListProvider),
        ),
      ),
    );
  }
}

class _UserList extends ConsumerWidget {
  const _UserList({required this.users});

  final List users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(userListProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                UserCard(
                  user: user,
                  index: index,
                  onTap: () =>
                      showAddEditUserSheet(context: context, user: user),
                  onDelete: () => _showDeleteConfirmDialog(context, ref, user),
                ),
                if (index == users.length - 1) const SizedBox(height: 100),
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
    dynamic user,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa người dùng "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _deleteUser(context, ref, user);
    }
  }

  Future<void> _deleteUser(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
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
          .read(userRepositoryProvider)
          .deleteUser(
            baseUrl: baseUrl,
            token: permissions.token,
            userId: user.id,
          );

      if (!context.mounted) return;

      // Dismiss loading
      context.pop();

      if (!response.error) {
        // Refresh danh sách
        ref.invalidate(userListProvider);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Xóa người dùng '${user.name}' thành công!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      if (!context.mounted) return;

      // Dismiss loading
      context.pop();

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
