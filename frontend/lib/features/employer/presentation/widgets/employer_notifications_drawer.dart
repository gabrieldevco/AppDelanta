import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/widgets/app_popup.dart';
import 'package:provider/provider.dart';

import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';

class EmployerNotificationsDrawer extends StatefulWidget {
  const EmployerNotificationsDrawer({super.key});

  @override
  State<EmployerNotificationsDrawer> createState() =>
      _EmployerNotificationsDrawerState();
}

class _EmployerNotificationsDrawerState
    extends State<EmployerNotificationsDrawer> {
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
        final notifications = provider.notifications;

        return Container(
          width: MediaQuery.of(context).size.width * 0.88,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE0F2FE), Color(0xFFF6F8FB)],
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
                            color: Color(0xFF0284C7),
                          ),
                        )
                      : notifications.isEmpty
                      ? _buildMessage(
                          Icons.notifications_off_outlined,
                          'No tienes notificaciones',
                        )
                      : RefreshIndicator(
                          onRefresh: () => provider.loadNotifications(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              return _buildNotificationCard(
                                context,
                                notifications[index],
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFE0F2FE)],
        ),
        border: Border(bottom: BorderSide(color: Color(0xFFBAE6FD))),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF06B6D4)],
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
                foregroundColor: const Color(0xFF0284C7),
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
      'success' => const Color(0xFF0891B2),
      'warning' => const Color(0xFFF59E0B),
      'error' => const Color(0xFFDC2626),
      _ => const Color(0xFF0284C7),
    };
    final iconData = switch (notification.type) {
      'success' => Icons.check_circle,
      'warning' => Icons.warning,
      'error' => Icons.cancel,
      _ => Icons.info,
    };
    final employeeProfileId = _employeeApprovalProfileId(notification);

    return InkWell(
      onTap: unread
          ? () =>
                context.read<NotificationProvider>().markAsRead(notification.id)
          : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: unread
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEFF6FF), Color(0xFFECFEFF)],
                )
              : null,
          color: unread ? null : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: unread ? const Color(0xFF7DD3FC) : const Color(0xFFE2E8F0),
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
                  color: Color(0xFF0284C7),
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
                            color: Color(0xFF0284C7),
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
                  if (employeeProfileId != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _handleEmployeeApproval(
                              context,
                              notification.id,
                              employeeProfileId,
                              approve: false,
                            ),
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Denegar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFDC2626),
                              side: const BorderSide(color: Color(0xFFFCA5A5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _handleEmployeeApproval(
                              context,
                              notification.id,
                              employeeProfileId,
                              approve: true,
                            ),
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Aprobar'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9488),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
    );
  }

  int? _employeeApprovalProfileId(NotificationModel notification) {
    final link = notification.link;
    if (link == null) return null;
    final match = RegExp(r'^/employee-approvals/(\d+)$').firstMatch(link);
    if (match == null) return null;
    return int.tryParse(match.group(1) ?? '');
  }

  Future<void> _handleEmployeeApproval(
    BuildContext context,
    int notificationId,
    int profileId, {
    required bool approve,
  }) async {
    final confirmed = await AppPopup.confirm(
      context,
      title: approve ? 'Aprobar empleado' : 'Denegar empleado',
      message: approve
          ? 'Deseas aprobar la vinculacion de este empleado a tu empresa?'
          : 'Deseas denegar la vinculacion de este empleado a tu empresa?',
      type: approve ? AppPopupType.success : AppPopupType.error,
      primaryLabel: approve ? 'Aprobar' : 'Denegar',
    );
    if (!confirmed || !context.mounted) return;

    try {
      final action = approve ? 'approve' : 'reject';
      await apiService.post('/api/employee-profiles/$profileId/$action/');
      if (!context.mounted) return;
      context.read<NotificationProvider>().markEmployeeApprovalHandled(
        notificationId,
        approve: approve,
      );
      await _showResultDialog(
        context,
        title: approve ? 'Empleado aprobado' : 'Empleado denegado',
        message: approve
            ? 'El empleado fue aprobado correctamente.'
            : 'La vinculacion del empleado fue denegada.',
      );
      if (!context.mounted) return;
      await context.read<NotificationProvider>().loadNotifications();
    } catch (e) {
      if (!context.mounted) return;
      await _showResultDialog(
        context,
        title: 'No se pudo completar',
        message: e.toString(),
        isError: true,
      );
    }
  }

  Future<void> _showResultDialog(
    BuildContext context, {
    required String title,
    required String message,
    bool isError = false,
  }) {
    return AppPopup.show(
      context,
      title: title,
      message: message,
      type: isError ? AppPopupType.error : AppPopupType.success,
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
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, size: 38, color: const Color(0xFF0284C7)),
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
