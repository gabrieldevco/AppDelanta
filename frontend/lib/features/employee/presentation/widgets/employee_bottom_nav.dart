import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../pages/employee_home_page.dart';
import '../pages/employee_request_page.dart';
import '../pages/employee_history_page.dart';

class EmployeeBottomNav extends StatelessWidget {
  final int currentIndex;

  const EmployeeBottomNav({super.key, required this.currentIndex});

  final List<NavItemData> _navItems = const [
    NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Inicio',
      color: Color(0xFFDC2626),
      endColor: Color(0xFFEF4444),
    ),
    NavItemData(
      icon: Icons.attach_money,
      activeIcon: Icons.attach_money,
      label: 'Solicitar',
      color: Color(0xFF059669),
      endColor: Color(0xFF10B981),
    ),
    NavItemData(
      icon: Icons.description_outlined,
      activeIcon: Icons.description,
      label: 'Historial',
      color: Color(0xFFF59E0B),
      endColor: Color(0xFFFBBF24),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = ResponsiveUtils.getScreenHeight(context);
    final screenWidth = ResponsiveUtils.getScreenWidth(context);
    final isLandscapePhone = ResponsiveUtils.isLandscapePhone(context);
    final isSmallScreen = screenHeight < 700;
    final isNarrow = screenWidth < 380;
    final navHeight = ResponsiveUtils.getBottomNavHeight(context);
    final iconSize = isLandscapePhone ? 19.0 : (isSmallScreen ? 20.0 : 21.0);
    final activeIconSize = isLandscapePhone
        ? 20.0
        : (isSmallScreen ? 21.0 : 22.0);
    final fontSize = isNarrow ? 10.0 : 11.0;
    final activeFontSize = isNarrow ? 10.5 : 11.5;

    return BottomAppBar(
      elevation: 0,
      height: navHeight,
      color: Colors.transparent,
      padding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.fromLTRB(10, isLandscapePhone ? 4 : 6, 10, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFBBF7D0))),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00A86B).withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Row(
          children: List.generate(_navItems.length, (index) {
            final isSelected = index == currentIndex;
            final item = _navItems[index];

            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  if (!isSelected) {
                    if (index == 0) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => EmployeeHomePage()),
                        (route) => false,
                      );
                    } else if (index == 1) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EmployeeRequestPage(),
                        ),
                        (route) => false,
                      );
                    } else if (index == 2) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EmployeeHistoryPage(),
                        ),
                        (route) => false,
                      );
                    }
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  height: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected && !isNarrow ? 8 : 4,
                    vertical: 2,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? item.color.withValues(alpha: 0.10)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? item.color.withValues(alpha: 0.18)
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        width: isSelected ? 34 : 30,
                        height: isSelected ? 34 : 30,
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [item.color, item.endColor],
                                )
                              : null,
                          color: isSelected ? null : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: item.color.withValues(alpha: 0.20),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
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
                      if (!isLandscapePhone) ...[
                        const SizedBox(height: 4),
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
                            height: 1,
                            letterSpacing: 0,
                          ),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
