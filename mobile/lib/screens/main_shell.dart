import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import '../services/sync_engine.dart';
import 'home_dashboard.dart';
import 'my_lots_screen.dart';
import 'price_board_screen.dart';
import 'earnings_dashboard_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  final int initialTabIndex;
  const MainShell({super.key, this.initialTabIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();
    final sync = Provider.of<SyncEngine>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final navBg = isDark ? const Color(0xFF0B132B) : const Color(0xFFFFFFFF);
    final navBorder = isDark ? const Color(0xFF1E3A8A).withOpacity(0.3) : const Color(0xFF061E18).withOpacity(0.1);

    final List<Widget> screens = [
      const HomeDashboard(),
      const MyLotsScreen(),
      const PriceBoardScreen(),
      const EarningsDashboardScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(
            top: BorderSide(color: navBorder, width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  icon: Icons.home_rounded,
                  label: loc.tr('tab_home'),
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  icon: Icons.inventory_2_rounded,
                  label: loc.tr('tab_lots'),
                  badgeCount: sync.offlineCount > 0 ? sync.offlineCount : null,
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  icon: Icons.bar_chart_rounded,
                  label: loc.tr('tab_price'),
                ),
                _buildNavItem(
                  context,
                  index: 3,
                  icon: Icons.account_balance_wallet_rounded,
                  label: loc.tr('tab_earnings'),
                ),
                _buildNavItem(
                  context,
                  index: 4,
                  icon: Icons.person_rounded,
                  label: loc.tr('tab_profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    int? badgeCount,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _currentIndex == index;

    final activeColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF061E18);
    final inactiveColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? activeColor : inactiveColor,
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: activeColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
