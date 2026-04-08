import 'package:flutter/material.dart';
import 'employee_home_page.dart';
import 'employee_request_page.dart';
import 'employee_history_page.dart';

class EmployeeMainPage extends StatefulWidget {
  const EmployeeMainPage({super.key});

  @override
  State<EmployeeMainPage> createState() => _EmployeeMainPageState();
}

class _EmployeeMainPageState extends State<EmployeeMainPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const EmployeeHomePage(),
    const EmployeeRequestPage(),
    const EmployeeHistoryPage(),
  ];

  final List<NavItem> _navItems = [
    NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Inicio',
      color: const Color(0xFF2563EB),
    ),
    NavItem(
      icon: Icons.attach_money,
      activeIcon: Icons.attach_money,
      label: 'Solicitar',
      color: const Color(0xFF059669),
    ),
    NavItem(
      icon: Icons.description_outlined,
      activeIcon: Icons.description,
      label: 'Historial',
      color: const Color(0xFF7C3AED),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        height: 100,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            final isSelected = _currentIndex == index;
            final item = _navItems[index];

            return GestureDetector(
              onTap: () => setState(() => _currentIndex = index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          width: isSelected ? 44 : 36,
                          height: isSelected ? 44 : 36,
                          decoration: BoxDecoration(
                            color: isSelected ? item.color : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: item.color.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        AnimatedScale(
                          scale: isSelected ? 1.0 : 0.85,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                            size: isSelected ? 24 : 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: isSelected ? item.color : const Color(0xFF94A3B8),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: isSelected ? 13 : 12,
                        letterSpacing: isSelected ? 0.3 : 0,
                      ),
                      child: Text(item.label),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}
