import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../data/permissions_provider.dart';
import '../../../shared/widgets/permission_widgets.dart';
import '../../../shared/models/user_permissions.dart';

/// Tab hiển thị quyền hạn người dùng
class PermissionsTab extends ConsumerWidget {
  const PermissionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(userPermissionsProvider);

    if (permissions == null) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6F00), Color(0xFFFFB74D)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Iconsax.shield_tick,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Quyền Hạn'),
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.shield_cross, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Chưa kết nối với trạm cân',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Vui lòng kết nối trạm cân để xem quyền hạn',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6F00), Color(0xFFFFB74D)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Iconsax.shield_tick,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Quyền Hạn'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            _InfoCard(permissions: permissions),
            const SizedBox(height: 24),

            // Quyền hạn Boolean
            _SectionTitle(title: 'Quyền Hạn Chính'),
            const SizedBox(height: 12),
            ..._buildBooleanPermissions(permissions),
            const SizedBox(height: 24),

            // Quyền hạn chi tiết
            _SectionTitle(title: 'Quyền Hạn Chi Tiết'),
            const SizedBox(height: 12),
            _buildDetailedPermissions(ref),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBooleanPermissions(UserPermissions permissions) {
    return permissions.allBooleanPermissions.map((item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: PermissionBooleanTile(item: item),
      );
    }).toList();
  }

  Widget _buildDetailedPermissions(WidgetRef ref) {
    return Column(
      children: [
        DetailedPermissionTile(
          title: 'Quản lý dữ liệu',
          permission: ref.watch(dataManagementPermissionProvider),
        ),
        const SizedBox(height: 8),
        DetailedPermissionTile(
          title: 'Báo cáo tổng hợp',
          permission: ref.watch(summaryReportPermissionProvider),
        ),
        const SizedBox(height: 8),
        DetailedPermissionTile(
          title: 'Báo cáo cân lần 2',
          permission: ref.watch(secondWeighingReportPermissionProvider),
        ),
      ],
    );
  }
}

/// Card hiển thị thông tin quyền hạn
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.permissions});

  final UserPermissions permissions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6F00), Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6F00).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Iconsax.shield_tick,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trạng thái quyền hạn',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Đã được cấp quyền',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Token: ${permissions.token.substring(0, 8)}...',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tiêu đề section
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
      ),
    );
  }
}
