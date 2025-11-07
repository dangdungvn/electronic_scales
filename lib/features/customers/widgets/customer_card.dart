import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../domain/customer.dart';

/// Widget hiển thị thông tin khách hàng dạng card
class CustomerCard extends StatelessWidget {
  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
    required this.onDelete,
  });

  final Customer customer;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Tên và action buttons
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Mã: ${customer.code}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.trash, size: 20),
                    color: Colors.red,
                    onPressed: onDelete,
                    tooltip: 'Xóa',
                  ),
                ],
              ),

              // const SizedBox(height: 12),
              // const Divider(height: 1),
              // const SizedBox(height: 12),

              // Thông tin chi tiết
              if (customer.phone?.isNotEmpty == true)
                _InfoRow(
                  icon: Iconsax.call,
                  label: 'Điện thoại',
                  value: customer.phone!,
                ),
              if (customer.phone?.isNotEmpty == true) const SizedBox(height: 8),

              if (customer.address?.isNotEmpty == true)
                _InfoRow(
                  icon: Iconsax.location,
                  label: 'Địa chỉ',
                  value: customer.address!,
                ),
              if (customer.address?.isNotEmpty == true)
                const SizedBox(height: 8),

              if (customer.taxCode?.isNotEmpty == true)
                _InfoRow(
                  icon: Iconsax.document_text,
                  label: 'MST',
                  value: customer.taxCode!,
                ),
              if (customer.taxCode?.isNotEmpty == true)
                const SizedBox(height: 8),

              if (customer.idCard?.isNotEmpty == true)
                _InfoRow(
                  icon: Iconsax.card,
                  label: 'CMND/CCCD',
                  value: customer.idCard!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget hiển thị một dòng thông tin
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
