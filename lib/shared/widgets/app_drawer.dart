import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/data/permissions_provider.dart';
import '../../features/scales/data/scale_station_provider.dart';
import '../../features/pending_weighing/data/pending_weighing_provider.dart';
import '../../core/router/app_router.dart';

/// App Drawer - Menu chung cho toàn bộ app (trừ feature scales)
class AppDrawer extends HookConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(userPermissionsProvider);
    final stationsAsync = ref.watch(scaleStationListProvider);

    return Drawer(
      backgroundColor: Colors.grey[50],
      child: Column(
        children: [
          _DrawerHeader(permissions: permissions, stationsAsync: stationsAsync),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              children: [
                // Dashboard
                // _DrawerItem(
                //   icon: FontAwesomeIcons.house,
                //   title: 'Trang chủ',
                //   route: '/',
                //   currentRoute: ModalRoute.of(context)?.settings.name,
                //   color: const Color(0xFF2196F3),
                // ),

                // const SizedBox(height: 8),
                // Divider(
                //   height: 1,
                //   color: Colors.grey[300],
                //   indent: 16,
                //   endIndent: 16,
                // ),
                // const SizedBox(height: 8),
                _SectionHeader('BÁO CÁO & GIÁM SÁT'),

                _DrawerItemWithBadge(
                  icon: FontAwesomeIcons.clockRotateLeft,
                  title: 'Xe chờ cân lần 2',
                  route: '/pending-weighing',
                  currentRoute: ModalRoute.of(context)?.settings.name,
                  color: const Color(0xFFFF9800),
                  badgeProvider: pendingWeighingCountProvider,
                ),

                _DrawerItem(
                  icon: FontAwesomeIcons.circleCheck,
                  title: 'Xe đã cân xong',
                  route: '/completed-weighing',
                  currentRoute: ModalRoute.of(context)?.settings.name,
                  color: const Color(0xFF4CAF50),
                ),

                const SizedBox(height: 8),
                Divider(
                  height: 1,
                  color: Colors.grey[300],
                  indent: 16,
                  endIndent: 16,
                ),
                const SizedBox(height: 8),

                _SectionHeader('QUẢN LÝ VẬN HÀNH'),

                _DrawerItem(
                  icon: FontAwesomeIcons.truckFast,
                  title: 'Xe đăng ký',
                  route: '/registered-vehicles',
                  currentRoute: ModalRoute.of(context)?.settings.name,
                  color: const Color(0xFF9C27B0),
                ),

                _DrawerItem(
                  icon: FontAwesomeIcons.userTie,
                  title: 'Tài xế',
                  route: '/drivers',
                  currentRoute: ModalRoute.of(context)?.settings.name,
                  color: const Color(0xFF00BCD4),
                ),

                _DrawerItem(
                  icon: FontAwesomeIcons.building,
                  title: 'Khách hàng',
                  route: '/customers',
                  currentRoute: ModalRoute.of(context)?.settings.name,
                  color: const Color(0xFF673AB7),
                ),

                const SizedBox(height: 8),
                Divider(
                  height: 1,
                  color: Colors.grey[300],
                  indent: 16,
                  endIndent: 16,
                ),
                const SizedBox(height: 8),

                _SectionHeader('DANH MỤC HÀNG HÓA'),

                _DrawerItem(
                  icon: FontAwesomeIcons.boxes,
                  title: 'Loại hàng',
                  route: '/products',
                  currentRoute: ModalRoute.of(context)?.settings.name,
                  color: const Color(0xFFFF5722),
                ),

                _DrawerItem(
                  icon: FontAwesomeIcons.locationDot,
                  title: 'Nguồn gốc',
                  route: '/product-origins',
                  currentRoute: ModalRoute.of(context)?.settings.name,
                  color: const Color(0xFF009688),
                ),

                _DrawerItem(
                  icon: FontAwesomeIcons.solidStar,
                  title: 'Chất lượng',
                  route: '/goods-quality',
                  currentRoute: ModalRoute.of(context)?.settings.name,
                  color: const Color(0xFFFFC107),
                ),

                _DrawerItem(
                  icon: FontAwesomeIcons.warehouse,
                  title: 'Kho hàng',
                  route: '/warehouses',
                  currentRoute: ModalRoute.of(context)?.settings.name,
                  color: const Color(0xFF795548),
                ),

                _DrawerItem(
                  icon: FontAwesomeIcons.scaleBalanced,
                  title: 'Kiểu cân',
                  route: '/weighing-types',
                  currentRoute: ModalRoute.of(context)?.settings.name,
                  color: const Color(0xFF607D8B),
                ),

                // Chỉ hiển thị nếu có quyền
                // if (permissions?.quanLyNguoiDung == true ||
                //     permissions?.cauHinhHeThong == true) ...[
                //   const SizedBox(height: 8),
                //   Divider(
                //     height: 1,
                //     color: Colors.grey[300],
                //     indent: 16,
                //     endIndent: 16,
                //   ),
                // const SizedBox(height: 8),

                // _SectionHeader('HỆ THỐNG'),

                // _DrawerItem(
                //   icon: FontAwesomeIcons.industry,
                //   title: 'Quản lý trạm cân',
                //   route: '/stations',
                //   currentRoute: ModalRoute.of(context)?.settings.name,
                //   color: const Color(0xFF3F51B5),
                // ),

                // if (permissions?.quanLyNguoiDung == true) ...[
                //   _DrawerItem(
                //     icon: FontAwesomeIcons.userGear,
                //     title: 'Người dùng',
                //     route: '/users',
                //     currentRoute: ModalRoute.of(context)?.settings.name,
                //     color: const Color(0xFF2196F3),
                //   ),

                //   _DrawerItem(
                //     icon: FontAwesomeIcons.userGroup,
                //     title: 'Nhóm người dùng',
                //     route: '/user-groups',
                //     currentRoute: ModalRoute.of(context)?.settings.name,
                //     color: const Color(0xFF9C27B0),
                //   ),
                // ],
                // ],
              ],
            ),
          ),

          // Footer
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey[50]!, Colors.white],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 4),
                _FooterItem(
                  icon: FontAwesomeIcons.gear,
                  title: 'Cài đặt',
                  color: const Color(0xFF607D8B),
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: Navigate to settings tab
                  },
                ),
                _FooterItem(
                  icon: FontAwesomeIcons.circleQuestion,
                  title: 'Trợ giúp',
                  color: const Color(0xFF607D8B),
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: Show help dialog
                  },
                ),
                _FooterItem(
                  icon: FontAwesomeIcons.rightFromBracket,
                  title: 'Đăng xuất',
                  color: const Color(0xFFF44336),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showLogoutDialog(context, ref);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    // Lưu notifier và router trước khi show dialog để tránh lỗi unmounted
    final permissionsNotifier = ref.read(userPermissionsProvider.notifier);
    final router = ref.read(goRouterProvider);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: FaIcon(
                FontAwesomeIcons.rightFromBracket,
                color: Colors.red[400],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Đăng xuất'),
          ],
        ),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red[400]),
            onPressed: () async {
              // Clear permissions sử dụng notifier đã lưu
              permissionsNotifier.clearPermissions();

              // Close dialog
              Navigator.of(dialogContext).pop();

              // Đợi một chút để dialog đóng hoàn toàn
              await Future.delayed(const Duration(milliseconds: 100));

              // Navigate to scale stations list - dùng router đã lưu
              router.go('/scales');
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

/// Drawer Header với thông tin user và trạm cân
class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.permissions, required this.stationsAsync});

  final dynamic permissions;
  final AsyncValue<List<dynamic>> stationsAsync;

  @override
  Widget build(BuildContext context) {
    final station = stationsAsync.when(
      data: (stations) => stations.firstOrNull,
      loading: () => null,
      error: (_, __) => null,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF2196F3), const Color(0xFF1976D2)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const FaIcon(
                  FontAwesomeIcons.solidUser,
                  color: Color(0xFF2196F3),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      permissions?.token != null
                          ? 'Người dùng'
                          : 'Chưa đăng nhập',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quản trị viên',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (station != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.industry,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      station.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Section Header trong Drawer
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Drawer Item với active state và badge
class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.currentRoute,
    required this.color,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String route;
  final String? currentRoute;
  final Color color;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final isActive = currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Material(
        elevation: isActive ? 3 : 0,
        borderRadius: BorderRadius.circular(14),
        shadowColor: isActive ? color.withOpacity(0.3) : Colors.transparent,
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop(); // Close drawer

            if (!isActive) {
              context.push(route);
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              gradient: isActive
                  ? LinearGradient(
                      colors: [
                        color.withOpacity(0.15),
                        color.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                // Icon với gradient background
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? LinearGradient(
                            colors: [color, color.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isActive ? null : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: FaIcon(
                    icon,
                    size: 18,
                    color: isActive ? Colors.white : color.withOpacity(0.85),
                  ),
                ),
                const SizedBox(width: 14),
                // Title và badge
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? color : Colors.grey[800],
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                if (badge != null && badge! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      badge! > 99 ? '99+' : '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Drawer Item with badge from provider
class _DrawerItemWithBadge extends ConsumerWidget {
  const _DrawerItemWithBadge({
    required this.icon,
    required this.title,
    required this.route,
    required this.currentRoute,
    required this.color,
    required this.badgeProvider,
  });

  final IconData icon;
  final String title;
  final String route;
  final String? currentRoute;
  final Color color;
  final dynamic badgeProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeAsync = ref.watch(badgeProvider);

    // Kiểm tra nếu badgeAsync là AsyncValue thì dùng when
    final int? badge;
    if (badgeAsync is AsyncValue) {
      badge = badgeAsync.when(
        data: (count) => count > 0 ? count as int : null,
        loading: () => null,
        error: (_, __) => null,
      );
    } else {
      // Nếu không phải AsyncValue thì coi như giá trị trực tiếp
      badge = badgeAsync is int && badgeAsync > 0 ? badgeAsync : null;
    }

    return _DrawerItem(
      icon: icon,
      title: title,
      route: route,
      currentRoute: currentRoute,
      color: color,
      badge: badge,
    );
  }
}

/// Footer Item cho drawer
class _FooterItem extends StatelessWidget {
  const _FooterItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FaIcon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: color == const Color(0xFFF44336)
                        ? color
                        : Colors.grey[700],
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
