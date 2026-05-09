import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/widgets/logout_confirmation_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../pages/admin_help_page.dart';
import '../pages/admin_profile_page.dart';

class AdminHeader extends StatefulWidget {
  final int currentIndex;

  const AdminHeader({super.key, this.currentIndex = 0});

  @override
  State<AdminHeader> createState() => _AdminHeaderState();
}

class _AdminHeaderState extends State<AdminHeader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().refreshUnreadCount();
    });
  }

  static const List<List<Color>> _headerGradientColors = [
    [Color(0xFF8B5CF6), Color(0xFFA78BFA)], // Inicio - Morado
    [Color(0xFFEC4899), Color(0xFFF472B6)], // Usuarios - Fucsia/Rosa
    [Color(0xFF10B981), Color(0xFF34D399)], // Desembolsos - Verde
    [Color(0xFFF97316), Color(0xFFFB923C)], // Reportes - Naranja
    [Color(0xFF64748B), Color(0xFF94A3B8)], // Config - Gris
  ];

  static const List<Color> _headerShadowColors = [
    Color(0xFF8B5CF6), // Inicio - Morado
    Color(0xFFEC4899), // Usuarios - Fucsia
    Color(0xFF10B981), // Desembolsos - Verde
    Color(0xFFF97316), // Reportes - Naranja
    Color(0xFF64748B), // Config - Gris
  ];

  List<Color> _getGradientColors() {
    final index = widget.currentIndex.clamp(
      0,
      _headerGradientColors.length - 1,
    );
    return _headerGradientColors[index];
  }

  Color _getShadowColor() {
    final index = widget.currentIndex.clamp(0, _headerShadowColors.length - 1);
    return _headerShadowColors[index];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final fullName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
    final displayName = fullName.isNotEmpty
        ? fullName
        : (user?.username.isNotEmpty == true
              ? user!.username
              : 'Administrador');

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
          colors: [Color(0xFFFFFFFF), Color(0xFFF7F1FF)],
        ),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE9D5FF), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.12),
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
                  color: shadowColor.withValues(alpha: 0.28),
                  blurRadius: 14,
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
                Text(
                  'Appdelanta',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '$displayName - Admin',
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
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              return _buildNotificationIcon(context, notificationProvider);
            },
          ),
          _HeaderActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminHelpPage()),
              );
            },
            icon: const Icon(Icons.help_outline, size: 20),
          ),
          _HeaderActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminProfilePage()),
              );
            },
            icon: const Icon(Icons.person_outline, size: 20),
          ),
          _HeaderActionButton(
            onPressed: () {
              _showLogoutConfirmation(context);
            },
            icon: const Icon(Icons.logout, size: 20),
            color: const Color(0xFFDC2626),
            backgroundColor: const Color(0xFFFFE4E6),
          ),
        ],
      ),
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
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
            notificationProvider.loadNotifications();
          },
          icon: const Icon(Icons.notifications_outlined, size: 20),
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

  void _showLogoutConfirmation(BuildContext context) {
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
    this.color = const Color(0xFF312E81),
    this.backgroundColor = const Color(0xFFF5F3FF),
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
