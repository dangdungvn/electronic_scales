import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../domain/pending_weighing.dart';

/// Dialog hiển thị chi tiết xe chờ cân lần 2
class PendingWeighingDetailDialog extends StatelessWidget {
  const PendingWeighingDetailDialog({
    super.key,
    required this.vehicle,
    required this.gradient,
  });

  final PendingWeighing vehicle;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      width: screenSize.width - 48, // Trừ đi padding horizontal (24*2)
      height: screenSize.height - 80, // Trừ đi padding vertical (40*2)
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
                  _DetailSection(
                    title: 'Thông tin xe',
                    icon: Iconsax.car,
                    color: gradient[0],
                    children: [
                      _DetailItem(
                        label: 'Biển số 1',
                        value: vehicle.plateNumber,
                        icon: Iconsax.car,
                      ),
                      if (vehicle.plateNumber2?.isNotEmpty == true)
                        _DetailItem(
                          label: 'Biển số 2',
                          value: vehicle.plateNumber2!,
                          icon: Iconsax.car,
                        ),
                      _DetailItem(
                        label: 'Số phiếu',
                        value: vehicle.soPhieu.toString(),
                        icon: Iconsax.document,
                      ),
                      if (vehicle.kyHieuPhieuCan?.isNotEmpty == true)
                        _DetailItem(
                          label: 'Ký hiệu phiếu cân',
                          value: vehicle.kyHieuPhieuCan!,
                          icon: Iconsax.document_text,
                        ),
                      if (vehicle.soChungTu?.isNotEmpty == true)
                        _DetailItem(
                          label: 'Số chứng từ',
                          value: vehicle.soChungTu!,
                          icon: Iconsax.receipt,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _DetailSection(
                    title: 'Thông tin khách hàng',
                    icon: Iconsax.user,
                    color: gradient[0],
                    children: [
                      _DetailItem(
                        label: 'Tên khách hàng',
                        value: vehicle.khachHang,
                        icon: Iconsax.user,
                      ),
                    ],
                  ),
                  if (vehicle.tenLaiXe?.isNotEmpty == true ||
                      vehicle.cmndLaiXe?.isNotEmpty == true) ...[
                    const SizedBox(height: 20),
                    _DetailSection(
                      title: 'Thông tin lái xe',
                      icon: Iconsax.driver,
                      color: gradient[0],
                      children: [
                        if (vehicle.tenLaiXe?.isNotEmpty == true)
                          _DetailItem(
                            label: 'Tên lái xe',
                            value: vehicle.tenLaiXe!,
                            icon: Iconsax.user,
                          ),
                        if (vehicle.cmndLaiXe?.isNotEmpty == true)
                          _DetailItem(
                            label: 'CMND/CCCD',
                            value: vehicle.cmndLaiXe!,
                            icon: Iconsax.card,
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  _DetailSection(
                    title: 'Thông tin hàng hóa',
                    icon: Iconsax.box,
                    color: gradient[0],
                    children: [
                      _DetailItem(
                        label: 'Loại hàng',
                        value: vehicle.loaiHang,
                        icon: Iconsax.box,
                      ),
                      _DetailItem(
                        label: 'Kho hàng',
                        value: vehicle.khoHang,
                        icon: Iconsax.shop,
                      ),
                      if (vehicle.quyCach?.isNotEmpty == true)
                        _DetailItem(
                          label: 'Quy cách',
                          value: vehicle.quyCach!,
                          icon: Iconsax.document_text,
                        ),
                      if (vehicle.nguonGoc?.isNotEmpty == true)
                        _DetailItem(
                          label: 'Nguồn gốc',
                          value: vehicle.nguonGoc!,
                          icon: Iconsax.location,
                        ),
                      if (vehicle.chatLuong?.isNotEmpty == true)
                        _DetailItem(
                          label: 'Chất lượng',
                          value: vehicle.chatLuong!,
                          icon: Iconsax.star,
                        ),
                    ],
                  ),
                  if (vehicle.nhaXe?.isNotEmpty == true ||
                      vehicle.maChuyen?.isNotEmpty == true) ...[
                    const SizedBox(height: 20),
                    _DetailSection(
                      title: 'Thông tin vận chuyển',
                      icon: FontAwesomeIcons.truck,
                      color: gradient[0],
                      children: [
                        if (vehicle.nhaXe?.isNotEmpty == true)
                          _DetailItem(
                            label: 'Nhà xe',
                            value: vehicle.nhaXe!,
                            icon: FontAwesomeIcons.building,
                          ),
                        if (vehicle.maChuyen?.isNotEmpty == true)
                          _DetailItem(
                            label: 'Mã chuyến',
                            value: vehicle.maChuyen!,
                            icon: Iconsax.hashtag,
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  _DetailSection(
                    title: 'Thông tin cân',
                    icon: Iconsax.weight,
                    color: gradient[0],
                    children: [
                      _DetailItem(
                        label: 'Kiểu cân',
                        value: vehicle.kieuCan,
                        icon: Iconsax.weight_1,
                      ),
                      _DetailItem(
                        label: 'Ngày giờ cân lần 1',
                        value: _formatDateTime(vehicle.ngayCan),
                        icon: Iconsax.calendar,
                      ),
                      if (vehicle.khoiLuongLan1 != null)
                        _DetailItem(
                          label: 'Khối lượng lần 1',
                          value:
                              '${vehicle.khoiLuongLan1!.toStringAsFixed(3)} kg',
                          icon: Iconsax.weight_1,
                        ),
                      if (vehicle.nguoiCan1?.isNotEmpty == true)
                        _DetailItem(
                          label: 'Người cân',
                          value: vehicle.nguoiCan1!,
                          icon: Iconsax.user,
                        ),
                    ],
                  ),
                  // if (vehicle.vehicleImagePath11?.isNotEmpty == true ||
                  //     vehicle.vehicleImagePath12?.isNotEmpty == true ||
                  //     vehicle.panoramaImagePath11?.isNotEmpty == true ||
                  //     vehicle.panoramaImagePath12?.isNotEmpty == true) ...[
                  //   const SizedBox(height: 20),
                  //   _DetailSection(
                  //     title: 'Hình ảnh cân lần 1',
                  //     icon: Iconsax.camera,
                  //     color: gradient[0],
                  //     children: [
                  //       if (vehicle.vehicleImagePath11?.isNotEmpty == true)
                  //         _ImageItem(
                  //           label: 'Ảnh biển số 1',
                  //           imagePath: vehicle.vehicleImagePath11!,
                  //         ),
                  //       if (vehicle.panoramaImagePath11?.isNotEmpty == true)
                  //         _ImageItem(
                  //           label: 'Ảnh toàn cảnh 1',
                  //           imagePath: vehicle.panoramaImagePath11!,
                  //         ),
                  //       if (vehicle.vehicleImagePath12?.isNotEmpty == true)
                  //         _ImageItem(
                  //           label: 'Ảnh biển số 2',
                  //           imagePath: vehicle.vehicleImagePath12!,
                  //         ),
                  //       if (vehicle.panoramaImagePath12?.isNotEmpty == true)
                  //         _ImageItem(
                  //           label: 'Ảnh toàn cảnh 2',
                  //           imagePath: vehicle.panoramaImagePath12!,
                  //         ),
                  //     ],
                  //   ),
                  // ],
                  if (vehicle.ghiChu?.isNotEmpty == true) ...[
                    const SizedBox(height: 20),
                    _DetailSection(
                      title: 'Ghi chú',
                      icon: Iconsax.note,
                      color: gradient[0],
                      children: [
                        _DetailItem(
                          label: 'Ghi chú',
                          value: vehicle.ghiChu!,
                          icon: Iconsax.note,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
              FontAwesomeIcons.truckFast,
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
                  vehicle.plateNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Show detail dialog as popup
  static void show(
    BuildContext context,
    PendingWeighing vehicle,
    List<Color> gradient,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: PendingWeighingDetailDialog(
          vehicle: vehicle,
          gradient: gradient,
        ),
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
    required this.children,
  });

  final String title;
  final dynamic icon; // Có thể là IconData hoặc FaIcon
  final Color color;
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
                color: color.withOpacity(0.1),
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
  });

  final String label;
  final String value;
  final IconData icon;

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
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget hiển thị hình ảnh
// class _ImageItem extends StatelessWidget {
//   const _ImageItem({required this.label, required this.imagePath});

//   final String label;
//   final String imagePath;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(Iconsax.image, size: 20, color: Colors.grey[600]),
//             const SizedBox(width: 12),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 13,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Container(
//           width: double.infinity,
//           height: 200,
//           decoration: BoxDecoration(
//             color: Colors.grey[100],
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 // Placeholder
//                 Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Iconsax.image, size: 48, color: Colors.grey[400]),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Ảnh từ máy cân',
//                         style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         imagePath.split('\\').last,
//                         style: TextStyle(fontSize: 10, color: Colors.grey[400]),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),
//                 // TODO: Load image from network or local path
//                 // Image.network hoặc Image.file khi có API endpoint
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
