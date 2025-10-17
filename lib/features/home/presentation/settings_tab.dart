import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Tab Cài đặt - Cấu hình và thiết lập ứng dụng
class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Iconsax.setting_2,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Cài Đặt'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9C27B0).withOpacity(0.3),
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
                    Iconsax.user,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Người dùng',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Quản trị viên',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Permissions section
          _SectionTitle(title: 'Quyền Hạn'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Iconsax.shield_tick,
            title: 'Xem quyền hạn chi tiết',
            subtitle: 'Xem danh sách quyền hạn của bạn',
            color: const Color(0xFFFF6F00),
            onTap: () {
              // Chuyển sang tab Quyền hạn
              // Có thể sử dụng GNav để chuyển tab
              // Tạm thời để trống
            },
          ),
          const SizedBox(height: 24),
          // General settings
          _SectionTitle(title: 'Chung'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Iconsax.weight,
            title: 'Quản lý trạm cân',
            subtitle: 'Cấu hình các trạm cân',
            color: const Color(0xFF2196F3),
            onTap: () {
              Navigator.of(context).pop();
              // Will return to scale station list
            },
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Iconsax.document_text,
            title: 'Mẫu phiếu cân',
            subtitle: 'Thiết lập mẫu in phiếu',
            color: const Color(0xFF4CAF50),
            onTap: () {
              // TODO: Navigate to template settings
            },
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Iconsax.printer,
            title: 'Cài đặt in ấn',
            subtitle: 'Cấu hình máy in',
            color: const Color(0xFFFF9800),
            onTap: () {
              // TODO: Navigate to printer settings
            },
          ),
          const SizedBox(height: 24),
          // Data settings
          _SectionTitle(title: 'Dữ Liệu'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Iconsax.export,
            title: 'Sao lưu dữ liệu',
            subtitle: 'Xuất dữ liệu ra file',
            color: const Color(0xFF00BCD4),
            onTap: () {
              // TODO: Implement backup
            },
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Iconsax.import,
            title: 'Khôi phục dữ liệu',
            subtitle: 'Nhập dữ liệu từ file',
            color: const Color(0xFF009688),
            onTap: () {
              // TODO: Implement restore
            },
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Iconsax.trash,
            title: 'Xóa dữ liệu',
            subtitle: 'Xóa tất cả dữ liệu',
            color: const Color(0xFFF44336),
            onTap: () {
              // TODO: Show delete confirmation dialog
            },
          ),
          const SizedBox(height: 24),
          // App info
          _SectionTitle(title: 'Thông Tin'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Iconsax.info_circle,
            title: 'Về ứng dụng',
            subtitle: 'Phiên bản 1.0.0',
            color: const Color(0xFF607D8B),
            onTap: () {
              // TODO: Show about dialog
            },
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Iconsax.arrow_right_3, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
