import 'package:flutter/material.dart';
import '../pages/admin_main_page.dart';
import '../pages/admin_user_management_page.dart';
import '../pages/admin_disbursements_page.dart';
import '../pages/admin_reports_page.dart';
import '../pages/admin_settings_page.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNav({super.key, required this.currentIndex});

  final List<NavItemData> _navItems = const [
    NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Inicio',
      color: Color(0xFF6366F1),
      endColor: Color(0xFF8B5CF6),
    ),
    NavItemData(
      icon: Icons.people_outlined,
      activeIcon: Icons.people,
      label: 'Usuarios',
      color: Color(0xFF8B5CF6),
      endColor: Color(0xFFA78BFA),
    ),
    NavItemData(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet,
      label: 'Desembolsos',
      color: Color(0xFF0D9488),
      endColor: Color(0xFF14B8A6),
    ),
    NavItemData(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      label: 'Reportes',
      color: Color(0xFFF97316),
      endColor: Color(0xFFFB923C),
    ),
    NavItemData(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Config',
      color: Color(0xFF64748B),
      endColor: Color(0xFF94A3B8),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final navHeight = isSmallScreen ? 68.0 : 76.0;
    final iconSize = isSmallScreen ? 22.0 : 24.0;
    final activeIconSize = isSmallScreen ? 24.0 : 26.0;
    final fontSize = isSmallScreen ? 11.0 : 12.0;
    final activeFontSize = isSmallScreen ? 12.0 : 13.0;

    return BottomAppBar(
      elevation: 0,
      height: navHeight,
      color: Colors.transparent,
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFFAF7FF)],
          ),
          border: const Border(top: BorderSide(color: Color(0xFFE9D5FF))),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
              blurRadius: 22,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_navItems.length, (index) {
            final isSelected = index == currentIndex;
            final item = _navItems[index];

            return Expanded(
              child: InkWell(
                onTap: () {
                  if (!isSelected) {
                    if (index == 0) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminMainPage(),
                        ),
                      );
                    } else if (index == 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminUserManagementPage(),
                        ),
                      );
                    } else if (index == 2) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminDisbursementsPage(),
                        ),
                      );
                    } else if (index == 3) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminReportsPage(),
                        ),
                      );
                    } else if (index == 4) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminSettingsPage(),
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  height: navHeight,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        width: isSelected ? activeIconSize + 18 : iconSize + 12,
                        height: isSelected
                            ? activeIconSize + 12
                            : iconSize + 10,
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [item.color, item.endColor],
                                )
                              : null,
                          color: isSelected ? null : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: item.color.withValues(alpha: 0.22),
                                    blurRadius: 16,
                                    offset: const Offset(0, 7),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF94A3B8),
                          size: isSelected ? activeIconSize - 2 : iconSize - 3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          color: isSelected
                              ? item.color
                              : const Color(0xFF94A3B8),
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          fontSize: isSelected ? activeFontSize : fontSize,
                          letterSpacing: 0,
                        ),
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;
  final Color endColor;

  const NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
    required this.endColor,
  });
}
