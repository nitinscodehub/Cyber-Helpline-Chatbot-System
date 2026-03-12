import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  NotificationProvider() {
    loadNotifications();  // ← FIXED: _loadNotifications → loadNotifications
    _startAutoNotifications();
  }

  // ===== PUBLIC METHOD FOR SPLASH SCREEN =====
  Future<void> loadNotifications() async {  // ← FIXED: _loadNotifications → loadNotifications (public)
    _notifications = [
      {
        'id': '1',
        'title': '🚨 New UPI Scam Alert',
        'message': 'Fake customer care numbers: +91 98765... operating in your area',
        'time': DateTime.now().subtract(const Duration(minutes: 5)),
        'icon': Icons.warning,
        'color': Colors.red,
        'read': false,
        'type': 'alert',
      },
      {
        'id': '2',
        'title': '✅ Safety Tip',
        'message': 'Never share OTP with anyone, even if they claim to be bank officials',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'icon': Icons.tips_and_updates,
        'color': Colors.green,
        'read': false,
        'type': 'tip',
      },
      {
        'id': '3',
        'title': '📊 Weekly Report',
        'message': '523 cyber crimes reported this week in your region',
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'icon': Icons.analytics,
        'color': Colors.blue,
        'read': true,
        'type': 'report',
      },
      {
        'id': '4',
        'title': '🔐 Security Update',
        'message': 'Enable 2FA on all your social media accounts',
        'time': DateTime.now().subtract(const Duration(days: 2)),
        'icon': Icons.lock,
        'color': Colors.purple,
        'read': true,
        'type': 'update',
      },
    ];
    _updateUnreadCount();
  }

  void _startAutoNotifications() {
    Future.delayed(const Duration(seconds: 45), () {
      _addRandomNotification();
    });
  }

  void _addRandomNotification() {
    final alerts = [
      {
        'title': '⚠️ Phishing Alert',
        'msg': 'New phishing campaign targeting Gpay users in Delhi NCR',
        'icon': Icons.warning,
        'color': Colors.red,
      },
      {
        'title': '📢 Cyber Crime News',
        'msg': 'Fake FedEx courier scam on the rise - be careful',
        'icon': Icons.new_releases,
        'color': Colors.orange,
      },
      {
        'title': '🛡️ Safety Reminder',
        'msg': 'Update your passwords regularly - change this week!',
        'icon': Icons.security,
        'color': Colors.green,
      },
      {
        'title': '📞 Fake Call Alert',
        'msg': 'Numbers starting with +92 are fake customer care',
        'icon': Icons.phone,
        'color': Colors.red,
      },
    ];
    
    final random = alerts[DateTime.now().millisecond % alerts.length];
    
    addNotification(
      random['title']!.toString(),
      random['msg']!.toString(),
      icon: random['icon'] as IconData,
      color: random['color'] as Color,
      type: 'auto',
    );
    
    // Schedule next notification
    Future.delayed(const Duration(minutes: 2), () {
      _addRandomNotification();
    });
  }

  void addNotification(String title, String message,
      {IconData? icon, Color? color, String type = 'general'}) {
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'message': message,
      'time': DateTime.now(),
      'icon': icon ?? Icons.info,
      'color': color ?? Colors.blue,
      'read': false,
      'type': type,
    });
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => n['read'] == false).length;
    notifyListeners();
  }

  void markAsRead(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications[index]['read'] = true;
      _updateUnreadCount();
    }
  }

  void markAllAsRead() {
    for (var notif in _notifications) {
      notif['read'] = true;
    }
    _updateUnreadCount();
  }

  void deleteNotification(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications.removeAt(index);
      _updateUnreadCount();
    }
  }

  void clearAll() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }

  List<Map<String, dynamic>> getUnreadNotifications() {
    return _notifications.where((n) => n['read'] == false).toList();
  }

  List<Map<String, dynamic>> getNotificationsByType(String type) {
    return _notifications.where((n) => n['type'] == type).toList();
  }
}