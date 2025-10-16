import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'home_tab.dart';
import 'weighing_tab.dart';
import 'settings_tab.dart';

/// HomeScreen với 3 tabs: Home, Cân hàng, Cài đặt
class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(0);
    final pageController = usePageController();

    // Danh sách các tabs
    final tabs = [const HomeTab(), const WeighingTab(), const SettingsTab()];

    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          selectedIndex.value = index;
        },
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: GNav(
              rippleColor: const Color(0xFF2196F3).withOpacity(0.1),
              hoverColor: const Color(0xFF2196F3).withOpacity(0.05),
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: const Color(0xFF2196F3),
              color: Colors.grey[600],
              tabs: const [
                GButton(icon: Iconsax.home, text: 'Trang chủ'),
                GButton(icon: Iconsax.weight_1, text: 'Cân hàng'),
                GButton(icon: Iconsax.setting_2, text: 'Cài đặt'),
              ],
              selectedIndex: selectedIndex.value,
              onTabChange: (index) {
                selectedIndex.value = index;
                pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
