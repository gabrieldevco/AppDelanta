import 'package:flutter/material.dart';

enum NotificationType { success, warning, info }

class NotificationData {
  final String id;
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  bool isRead;

  NotificationData({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.isRead,
  });

  NotificationData copyWith({
    String? id,
    String? title,
    String? message,
    String? time,
    NotificationType? type,
    bool? isRead,
  }) {
    return NotificationData(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}

// Provider global simple para notificaciones
class NotificationProvider extends ChangeNotifier {
  static final NotificationProvider _instance = NotificationProvider._internal();
  factory NotificationProvider() => _instance;
  NotificationProvider._internal();

  List<NotificationData> _notifications = [
    NotificationData(
      id: '1',
      title: 'Adelanto aprobado',
      message: 'Tu solicitud de adelanto de \$500.000 ha sido aprobada por tu empleador.',
      time: 'Hace 5 minutos',
      type: NotificationType.success,
      isRead: false,
    ),
    NotificationData(
      id: '2',
      title: 'Pago recibido',
      message: 'El dinero ha sido transferido a tu cuenta bancaria.',
      time: 'Hace 2 horas',
      type: NotificationType.success,
      isRead: false,
    ),
    NotificationData(
      id: '3',
      title: 'Recordatorio de pago',
      message: 'Tu adelanto vence en 3 días. Asegúrate de tener fondos disponibles.',
      time: 'Hace 1 día',
      type: NotificationType.warning,
      isRead: true,
    ),
    NotificationData(
      id: '4',
      title: 'Nueva función disponible',
      message: 'Ahora puedes ver tu historial de adelantos en la app.',
      time: 'Hace 3 días',
      type: NotificationType.info,
      isRead: true,
    ),
  ];

  List<NotificationData> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void resetToDefault() {
    _notifications = [
      NotificationData(
        id: '1',
        title: 'Adelanto aprobado',
        message: 'Tu solicitud de adelanto de \$500.000 ha sido aprobada por tu empleador.',
        time: 'Hace 5 minutos',
        type: NotificationType.success,
        isRead: false,
      ),
      NotificationData(
        id: '2',
        title: 'Pago recibido',
        message: 'El dinero ha sido transferido a tu cuenta bancaria.',
        time: 'Hace 2 horas',
        type: NotificationType.success,
        isRead: false,
      ),
      NotificationData(
        id: '3',
        title: 'Recordatorio de pago',
        message: 'Tu adelanto vence en 3 días. Asegúrate de tener fondos disponibles.',
        time: 'Hace 1 día',
        type: NotificationType.warning,
        isRead: true,
      ),
      NotificationData(
        id: '4',
        title: 'Nueva función disponible',
        message: 'Ahora puedes ver tu historial de adelantos en la app.',
        time: 'Hace 3 días',
        type: NotificationType.info,
        isRead: true,
      ),
    ];
    notifyListeners();
  }
}

// Instancia global
final notificationProvider = NotificationProvider();
