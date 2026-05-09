import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/widgets/logout_confirmation_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../pages/employee_help_page.dart';
import '../pages/employee_profile_page.dart';

class EmployeeHeader extends StatefulWidget {
  final VoidCallback? onNotificationTap;
  final int currentIndex;

  const EmployeeHeader({
    super.key,
    this.onNotificationTap,
    this.currentIndex = 0,
  });

  @override
  State<EmployeeHeader> createState() => _EmployeeHeaderState();
}

class _EmployeeHeaderState extends State<EmployeeHeader> {
  // Colores para cada pestaña: Inicio (rojo), Solicitar (verde), Historial (amarillo)
  static const List<List<Color>> _iconGradientColors = [
    [Color(0xFFDC2626), Color(0xFFEF4444)], // Inicio - Rojo
    [Color(0xFF059669), Color(0xFF10B981)], // Solicitar - Verde
    [Color(0xFFF59E0B), Color(0xFFFBBF24)], // Historial - Amarillo
  ];

  static const List<Color> _iconShadowColors = [
    Color(0xFFDC2626), // Inicio - Rojo
    Color(0xFF059669), // Solicitar - Verde
    Color(0xFFF59E0B), // Historial - Amarillo
  ];

  List<Color> _getGradientColors() {
    final index = widget.currentIndex.clamp(0, _iconGradientColors.length - 1);
    return _iconGradientColors[index];
  }

  Color _getShadowColor() {
    final index = widget.currentIndex.clamp(0, _iconShadowColors.length - 1);
    return _iconShadowColors[index];
  }

  @override
  void initState() {
    super.initState();
    // Cargar conteo de notificaciones no leídas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().refreshUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final authProvider = context.watch<AuthProvider>();
        final user = authProvider.user;
        final userName = user?.firstName != null && user?.lastName != null
            ? '${user?.firstName} ${user?.lastName}'
            : user?.firstName ?? user?.username ?? 'Usuario';

        final gradientColors = _getGradientColors();
        final shadowColor = _getShadowColor();
        final isLandscapePhone = ResponsiveUtils.isLandscapePhone(context);

        return Container(
          padding: EdgeInsets.fromLTRB(
            14,
            isLandscapePhone ? 6 : 10,
            14,
            isLandscapePhone ? 8 : 12,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFF6F8FB)],
            ),
            border: const Border(
              bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.1),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: isLandscapePhone ? 34 : 40,
                height: isLandscapePhone ? 34 : 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Appdelanta',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              _buildNotificationIcon(context, notificationProvider),
              _HeaderActionButton(
                icon: const Icon(Icons.help_outline, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmployeeHelpPage()),
                  );
                },
              ),
              _HeaderActionButton(
                icon: const Icon(Icons.person_outline, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmployeeProfilePage(),
                    ),
                  );
                },
              ),
              _HeaderActionButton(
                icon: const Icon(Icons.logout, size: 20),
                color: const Color(0xFFDC2626),
                backgroundColor: const Color(0xFFFFE4E6),
                onPressed: () => _showLogoutDialog(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationIcon(
    BuildContext context,
    NotificationProvider notificationProvider,
  ) {
    final unreadCount = notificationProvider.unreadCount;

    return Stack(
      children: [
        _HeaderActionButton(
          icon: const Icon(Icons.notifications_outlined, size: 20),
          onPressed:
              widget.onNotificationTap ??
              () {
                Scaffold.of(context).openEndDrawer();
              },
        ),
        if (unreadCount > 0)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Color(0xFFDC2626),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Center(
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showLogoutConfirmationDialog(context);
  }
}

class _HeaderActionButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final Color color;
  final Color backgroundColor;

  const _HeaderActionButton({
    required this.icon,
    required this.onPressed,
    this.color = const Color(0xFF475569),
    this.backgroundColor = const Color(0xFFF1F5F9),
  });

  @override
  Widget build(BuildContext context) {
    final isLandscapePhone = ResponsiveUtils.isLandscapePhone(context);
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: IconButton(
        icon: IconTheme(
          data: IconThemeData(color: color),
          child: icon,
        ),
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          minWidth: isLandscapePhone ? 30 : 34,
          minHeight: isLandscapePhone ? 30 : 34,
        ),
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
