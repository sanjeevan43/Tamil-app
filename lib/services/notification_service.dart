import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final List<Map<String, dynamic>> _notifications = [];

  List<Map<String, dynamic>> get notifications => _notifications;

  void addNotification({
    required String title,
    required String message,
    required String type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'message': message,
      'type': type,
      'timestamp': DateTime.now(),
    };

    _notifications.add(notification);

    Future.delayed(duration, () {
      _notifications.removeWhere((n) => n['id'] == notification['id']);
    });
  }

  void showSuccess(String title, String message) {
    addNotification(
      title: title,
      message: message,
      type: 'success',
    );
  }

  void showError(String title, String message) {
    addNotification(
      title: title,
      message: message,
      type: 'error',
    );
  }

  void showInfo(String title, String message) {
    addNotification(
      title: title,
      message: message,
      type: 'info',
    );
  }

  void showWarning(String title, String message) {
    addNotification(
      title: title,
      message: message,
      type: 'warning',
    );
  }

  void clearAll() {
    _notifications.clear();
  }

  void removeNotification(int id) {
    _notifications.removeWhere((n) => n['id'] == id);
  }
}
