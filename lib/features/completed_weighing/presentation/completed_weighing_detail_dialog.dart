import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../domain/completed_weighing.dart';

/// Dialog hiển thị chi tiết xe đã cân xong
class CompletedWeighingDetailDialog extends StatelessWidget {
  const CompletedWeighingDetailDialog({super.key, required this.vehicle});

  final CompletedWeighing vehicle;

  // Flat colors theme
  static const Color primaryColor = Color(0xFF2196F3); // Blue
  static const Color headerBgColor = Color(0xFF1976D2); // Darker Blue
  static const Color sectionIconBgColor = Color(0xFFE3F2FD); // Light Blue
  static const Color sectionTitleColor = Color(0xFF1565C0); // Deep Blue

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      width: screenSize.width - 48,
      height: screenSize.height - 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(context),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Thông tin xe & Phiếu
                  _DetailSection(
                    title: 'Thông tin xe & Phiếu',
                    icon: Iconsax.car,
                    color: sectionTitleColor,
                    bgColor: sectionIconBgColor,
                    children: [
                      _DetailItem(
                        label: 'Biển số xe',
                        value: vehicle.licensePlate1 ?? 'N/A',
                        icon: Iconsax.car,
                      ),
                      if (vehicle.licensePlate2?.isNotEmpty == true)
                        _DetailItem(
                          label: 'Biển số rơ-moóc',
                          value: vehicle.licensePlate2!,
                          icon: Iconsax.car,
                        ),
                      if (vehicle.ticketNumber?.isNotEmpty == true)
                        _DetailItem(
                          label: 'Số phiếu',
                          value: vehicle.ticketNumber!,
                          icon: Iconsax.document,
                        ),
                      if (vehicle.ticketSymbol?.isNotEmpty == true)
                        _DetailItem(
                          label: 'Ký hiệu phiếu',
                          value: vehicle.ticketSymbol!,
                          icon: Iconsax.document_text,
                        ),
                      if (vehicle.documentNumber?.isNotEmpty == true)
                        _DetailItem(
                          label: 'Số chứng từ',
                          value: vehicle.documentNumber!,
                          icon: Iconsax.receipt,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. Thông tin khách hàng & Lái xe
                  _DetailSection(
                    title: 'Khách hàng & Lái xe',
                    icon: Iconsax.user,
                    color: sectionTitleColor,
                    bgColor: sectionIconBgColor,
                    children: [
                      if (vehicle.customerName?.isNotEmpty == true)
                        _DetailItem(
                          label: 'Khách hàng',
                          value: vehicle.customerName!,
                          icon: Iconsax.user,
                        ),
                      if (vehicle.customerCode?.isNotEmpty == true)
                        _DetailItem(
                          label: 'Mã khách hàng',
                          value: vehicle.customerCode!,
                          icon: Iconsax.code,
                        ),
                      if (vehicle.driverName?.isNotEmpty == true)
                        _DetailItem(
                          label: 'Tên lái xe',
                          value: vehicle.driverName!,
                          icon: Iconsax.driver,
                        ),
                      if (vehicle.driverIdCard?.isNotEmpty == true)
                        _DetailItem(
                          label: 'CMND/CCCD',
                          value: vehicle.driverIdCard!,
                          icon: Iconsax.card,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3. Thông tin hàng hóa
                  _DetailSection(
                    title: 'Thông tin hàng hóa',
                    icon: Iconsax.box,
                    color: sectionTitleColor,
                    bgColor: sectionIconBgColor,
                    children: [
                      if (vehicle.productName?.isNotEmpty == true)
                        _DetailItem(
                          label: 'Tên hàng',
                          value: vehicle.productName!,
                          icon: Iconsax.box,
                        ),
                      if (vehicle.warehouseName?.isNotEmpty == true)
                        _DetailItem(
                          label: 'Kho hàng',
                          value: vehicle.warehouseName!,
                          icon: Iconsax.shop,
                        ),
                      if (vehicle.origin?.isNotEmpty == true)
                        _DetailItem(
                          label: 'Nguồn gốc',
                          value: vehicle.origin!,
                          icon: Iconsax.location,
                        ),
                      if (vehicle.goodsQuality?.isNotEmpty == true)
                        _DetailItem(
                          label: 'Chất lượng',
                          value: vehicle.goodsQuality!,
                          icon: Iconsax.star,
                        ),
                      if (vehicle.specification?.isNotEmpty == true)
                        _DetailItem(
                          label: 'Quy cách',
                          value: vehicle.specification!,
                          icon: Iconsax.document_text,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 4. Thông tin cân (Quan trọng)
                  _DetailSection(
                    title: 'Kết quả cân',
                    icon: Iconsax.weight,
                    color: sectionTitleColor,
                    bgColor: sectionIconBgColor,
                    children: [
                      _DetailItem(
                        label: 'Kiểu cân',
                        value: vehicle.weighingType ?? 'N/A',
                        icon: Iconsax.weight_1,
                      ),
                      if (vehicle.weight1 != null)
                        _DetailItem(
                          label: 'Khối lượng lần 1',
                          value: '${vehicle.weight1} kg',
                          icon: Iconsax.weight_1,
                          valueColor: Colors.blue[800],
                        ),
                      if (vehicle.date1 != null && vehicle.time1 != null)
                        _DetailItem(
                          label: 'Thời gian lần 1',
                          value: '${vehicle.time1} - ${vehicle.date1}',
                          icon: Iconsax.clock,
                        ),
                      if (vehicle.weight2 != null)
                        _DetailItem(
                          label: 'Khối lượng lần 2',
                          value: '${vehicle.weight2} kg',
                          icon: Iconsax.weight_1,
                          valueColor: Colors.blue[800],
                        ),
                      if (vehicle.date2 != null && vehicle.time2 != null)
                        _DetailItem(
                          label: 'Thời gian lần 2',
                          value: '${vehicle.time2} - ${vehicle.date2}',
                          icon: Iconsax.clock,
                        ),
                      if (vehicle.netWeight != null)
                        _DetailItem(
                          label: 'Khối lượng hàng (Net)',
                          value: '${vehicle.netWeight} kg',
                          icon: FontAwesomeIcons.scaleBalanced,
                          valueColor: Colors.red[700],
                          isBold: true,
                          fontSize: 18,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 5. Thông tin thanh toán & Khác
                  if (vehicle.price != null ||
                      vehicle.totalPrice != null ||
                      vehicle.note?.isNotEmpty == true)
                    _DetailSection(
                      title: 'Thanh toán & Ghi chú',
                      icon: Iconsax.money,
                      color: sectionTitleColor,
                      bgColor: sectionIconBgColor,
                      children: [
                        if (vehicle.price != null)
                          _DetailItem(
                            label: 'Đơn giá',
                            value: _formatCurrency(vehicle.price),
                            icon: Iconsax.money_2,
                          ),
                        if (vehicle.totalPrice != null)
                          _DetailItem(
                            label: 'Thành tiền',
                            value: _formatCurrency(vehicle.totalPrice),
                            icon: Iconsax.wallet,
                            valueColor: Colors.green[700],
                            isBold: true,
                          ),
                        if (vehicle.note?.isNotEmpty == true)
                          _DetailItem(
                            label: 'Ghi chú',
                            value: vehicle.note!,
                            icon: Iconsax.note,
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(String? value) {
    if (value == null || value.isEmpty) return '0 đ';
    try {
      // Remove commas if present (assuming US format input like "2,000.00")
      final cleanValue = value.replaceAll(',', '');
      final number = double.parse(cleanValue);
      return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(number);
    } catch (e) {
      return '$value đ';
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: headerBgColor, // Flat color
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const FaIcon(
              FontAwesomeIcons.check,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.licensePlate1 ?? 'Không có biển số',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (vehicle.ticketNumber != null)
                  Text(
                    'Phiếu: ${vehicle.ticketNumber}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
            tooltip: 'Đóng',
          ),
        ],
      ),
    );
  }

  /// Show detail dialog as popup
  static void show(BuildContext context, CompletedWeighing vehicle) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: CompletedWeighingDetailDialog(vehicle: vehicle),
      ),
    );
  }
}

/// Widget hiển thị một section thông tin
class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.children,
  });

  final String title;
  final dynamic icon;
  final Color color;
  final Color bgColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: icon is IconData
                  ? Icon(icon as IconData, color: color, size: 20)
                  : FaIcon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) ...[
                  const SizedBox(height: 8),
                  Divider(height: 1, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget hiển thị một dòng thông tin
class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
    this.isBold = false,
    this.fontSize = 15,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final bool isBold;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
