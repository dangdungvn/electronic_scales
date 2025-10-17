import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_display_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../data/user_group_provider.dart';
import '../widgets/user_group_card.dart';

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
                gradient: const LinearGradient(
                  colors: [Color(0xFF673AB7), Color(0xFF9575CD)],
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
          // TODO: Navigate to add user group screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chức năng thêm nhóm đang được phát triển'),
            ),
          );
        },
        icon: const Icon(Iconsax.add),
        label: const Text('Nhóm'),
        backgroundColor: const Color(0xFF673AB7),
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
                UserGroupCard(group: group, onTap: () {}),
                if (index == groups.length - 1) const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}
