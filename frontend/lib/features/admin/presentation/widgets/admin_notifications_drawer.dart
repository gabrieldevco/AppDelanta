import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';

class AdminNotificationsDrawer extends StatefulWidget {
  const AdminNotificationsDrawer({super.key});

  @override
  State<AdminNotificationsDrawer> createState() =>
      _AdminNotificationsDrawerState();
}

class _AdminNotificationsDrawerState extends State<AdminNotificationsDrawer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.88,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF5F3FF), Color(0xFFF8FAFC)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, provider),
                Expanded(
                  child: provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF7C3AED),
                          ),
                        )
                      : provider.notifications.isEmpty
                      ? _buildMessage(
                          Icons.notifications_off_outlined,
                          'No tienes notificaciones',
                        )
                      : RefreshIndicator(
                          onRefresh: () => provider.loadNotifications(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.notifications.length,
                            itemBuilder: (context, index) {
                              return _buildNotificationCard(
                                context,
                                provider.notifications[index],
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, NotificationProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 10, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFE9D5FF))),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notificaciones',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  provider.unreadCount > 0
                      ? '${provider.unreadCount} sin leer'
                      : 'Todo al dia',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (provider.unreadCount > 0)
            TextButton.icon(
              onPressed: provider.markAllAsRead,
              icon: const Icon(Icons.done_all, size: 17),
              label: const Text('Leidas'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7C3AED),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF64748B)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
  ) {
    final unread = !notification.isRead;
    final iconColor = switch (notification.type) {
      'success' => const Color(0xFF0D9488),
      'warning' => const Color(0xFFF59E0B),
      'error' => const Color(0xFFDC2626),
      _ => const Color(0xFF7C3AED),
    };
    final iconData = switch (notification.type) {
      'success' => Icons.check_circle,
      'warning' => Icons.warning,
      'error' => Icons.error,
      _ => Icons.info,
    };

    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Color(0xFFDC2626)),
      ),
      onDismissed: (_) {
        context.read<NotificationProvider>().deleteNotification(
          notification.id,
        );
      },
      child: InkWell(
        onTap: unread
            ? () => context.read<NotificationProvider>().markAsRead(
                notification.id,
              )
            : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: unread
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF5F3FF), Color(0xFFFFF1F2)],
                  )
                : null,
            color: unread ? null : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: unread ? const Color(0xFFE9D5FF) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (unread) ...[
                Container(
                  width: 4,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7C3AED),
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: unread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF7C3AED),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.timeAgo,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(IconData icon, String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, size: 38, color: const Color(0xFF7C3AED)),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
