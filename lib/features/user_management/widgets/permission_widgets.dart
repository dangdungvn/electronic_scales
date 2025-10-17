import 'package:electronic_scales/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Widget hiển thị tiêu đề section
class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }
}

/// Widget switch cho permission
class PermissionSwitch extends StatelessWidget {
  const PermissionSwitch({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: AppTheme.primaryBlue),
      ),
    );
  }
}

/// Widget nhóm checkbox cho detailed permissions
class DetailedPermissionGroup extends StatelessWidget {
  const DetailedPermissionGroup({super.key, required this.permissions});

  final List<Widget> permissions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(spacing: 16, runSpacing: 8, children: permissions),
      ),
    );
  }
}

/// Widget checkbox cho permission
class PermissionCheckbox extends StatelessWidget {
  const PermissionCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged?.call(!value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: value
              ? AppTheme.primaryGreen.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value ? AppTheme.primaryGreen : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value ? Iconsax.tick_circle : Iconsax.close_circle,
              size: 16,
              color: value ? AppTheme.primaryGreen : Colors.grey[500],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: value ? AppTheme.primaryGreen : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
