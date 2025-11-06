import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../pending_weighing/presentation/pending_weighing_list_screen.dart';
import 'home_tab.dart';
import 'settings_tab.dart';

/// HomeScreen với Bottom Navigation: Trang chủ, Chờ cân, Cài đặt
class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  // GlobalKey để truy cập Scaffold từ các tab
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(0);

    // Danh sách các tabs
    final tabs = [
      const HomeTab(),
      const _PendingWeighingTab(),
      const SettingsTab(),
    ];

    return Scaffold(
      key: scaffoldKey, // Thêm key
      drawer: const AppDrawer(), // Thêm drawer
      body: IndexedStack(index: selectedIndex.value, children: tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 16,
            left: 16,
            right: 16,
          ),
          child: GNav(
            rippleColor: const Color(0xFF2196F3).withOpacity(0.1),
            hoverColor: const Color(0xFF2196F3).withOpacity(0.05),
            gap: 8,
            haptic: true,
            curve: Curves.easeInOutCubic,
            activeColor: Colors.white,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: const Color(0xFF2196F3),
            color: Colors.grey[600],
            tabs: const [
              GButton(
                icon: Iconsax.home_1,
                text: 'Trang chủ',
                iconActiveColor: Colors.white,
                textColor: Colors.white,
              ),
              GButton(
                icon: Iconsax.clock,
                text: 'Chờ cân',
                iconActiveColor: Colors.white,
                textColor: Colors.white,
              ),
              GButton(
                icon: Iconsax.setting_2,
                text: 'Cài đặt',
                iconActiveColor: Colors.white,
                textColor: Colors.white,
              ),
            ],
            selectedIndex: selectedIndex.value,
            onTabChange: (index) {
              selectedIndex.value = index;
            },
          ),
        ),
      ),
    );
  }
}

/// Tab chờ cân lần 2 - sử dụng màn hình danh sách xe chờ cân
class _PendingWeighingTab extends StatelessWidget {
  const _PendingWeighingTab();

  @override
  Widget build(BuildContext context) {
    return PendingWeighingListScreen(
      onOpenDrawer: () {
        HomeScreen.scaffoldKey.currentState?.openDrawer();
      },
    );
  }
}
