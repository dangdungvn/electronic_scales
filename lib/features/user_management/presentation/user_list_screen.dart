import 'package:electronic_scales/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_display_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../data/user_provider.dart';
import '../widgets/user_card.dart';
import 'add_edit_user_screen.dart';

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
            icon: const Icon(Iconsax.refresh),
            onPressed: () => ref.invalidate(userListProvider),
            tooltip: 'Làm mới',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditUserScreen()),
          );
        },
        icon: const Icon(Iconsax.add),
        label: const Text('Người dùng'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        heroTag: null,
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
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddEditUserScreen(user: user),
                      ),
                    );
                  },
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
      // TODO: Implement delete user API
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chức năng xóa người dùng đang được phát triển'),
        ),
      );
    }
  }
}
