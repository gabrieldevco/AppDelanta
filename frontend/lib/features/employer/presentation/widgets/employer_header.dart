import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/logout_confirmation_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../pages/employer_help_page.dart';
import '../pages/employer_profile_page.dart';

class EmployerHeader extends StatefulWidget {
  const EmployerHeader({super.key});

  @override
  State<EmployerHeader> createState() => _EmployerHeaderState();
}

class _EmployerHeaderState extends State<EmployerHeader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().refreshUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final companyName = user?.company?.name ?? 'Mi Empresa';

        return Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFE0F2FE)],
            ),
            border: const Border(
              bottom: BorderSide(color: Color(0xFFBAE6FD), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.13),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1D4ED8), Color(0xFF06B6D4)],
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.28),
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
                    const Text(
                      'Appdelanta',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      companyName,
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
                icon: const Icon(Icons.help_outline, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmployerHelpPage()),
                  );
                },
              ),
              _HeaderActionButton(
                icon: const Icon(Icons.person_outline, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmployerProfilePage(),
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
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
            notificationProvider.loadNotifications();
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
    this.color = const Color(0xFF0F172A),
    this.backgroundColor = const Color(0xFFEFF6FF),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: IconButton(
        icon: IconTheme(
          data: IconThemeData(color: color),
          child: icon,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
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
