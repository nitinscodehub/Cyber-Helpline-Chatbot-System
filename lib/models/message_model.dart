import 'package:flutter/material.dart';

class Message {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;
  final MessagePriority priority;
  final String? actionType;
  final List<ActionButton>? buttons;  // Multiple buttons ke liye
  final String? imageUrl;              // Evidence images ke liye
  final Map<String, dynamic>? metadata; // Extra data ke liye
  final bool isRead;
  final bool isError;
  final int? crimeId;                  // Complaint tracking ke liye

  Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.normal,
    this.priority = MessagePriority.low,
    this.actionType,
    this.buttons,
    this.imageUrl,
    this.metadata,
    this.isRead = false,
    this.isError = false,
    this.crimeId,
  });

  // ===== SMART FACTORY METHODS =====

  /// User message banane ke liye
  factory Message.user(String text, {String? imageUrl}) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
    );
  }

  /// Bot message with multiple actions
  factory Message.bot(
    String text, {
    MessagePriority priority = MessagePriority.low,
    String? actionType,
    List<ActionButton>? buttons,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      priority: priority,
      actionType: actionType,
      buttons: buttons,
      metadata: metadata,
    );
  }

  /// Emergency message with predefined buttons
  factory Message.emergency(String text, {String? actionType}) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.emergency,
      priority: MessagePriority.high,
      actionType: actionType ?? 'emergency',
      buttons: [
        ActionButton(
          label: '📞 Call 1930',
          action: 'call:1930',
          color: 'red',
          icon: Icons.phone,
          priority: 1,
        ),
        ActionButton(
          label: '📝 File Complaint',
          action: 'complaint',
          color: 'orange',
          icon: Icons.description,
          priority: 2,
        ),
        ActionButton(
          label: '👮 Expert',
          action: 'expert',
          color: 'blue',
          icon: Icons.support_agent,
          priority: 3,
        ),
      ],
    );
  }

  /// UPI Fraud specific message
  factory Message.upiFraud(String text, {String? transactionId, double? amount}) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.fraud,
      priority: MessagePriority.high,
      actionType: 'upi',
      buttons: [
        ActionButton(
          label: '📞 Call 1930',
          action: 'call:1930',
          color: 'red',
          icon: Icons.phone,
        ),
        ActionButton(
          label: '📝 File Complaint',
          action: 'complaint',
          color: 'orange',
          icon: Icons.description,
        ),
        ActionButton(
          label: '🏦 Call Bank',
          action: 'bank',
          color: 'green',
          icon: Icons.account_balance,
        ),
      ],
      metadata: {
        'transactionId': transactionId,
        'amount': amount,
        'crimeType': 'UPI Fraud',
      },
    );
  }

  /// Blackmail specific message
  factory Message.blackmail(String text) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.crime,
      priority: MessagePriority.high,
      actionType: 'blackmail',
      buttons: [
        ActionButton(
          label: '🚨 Call 112',
          action: 'call:112',
          color: 'red',
          icon: Icons.local_police,
        ),
        ActionButton(
          label: '📞 Call 1930',
          action: 'call:1930',
          color: 'orange',
          icon: Icons.phone,
        ),
        ActionButton(
          label: '📝 File Complaint',
          action: 'complaint',
          color: 'blue',
          icon: Icons.description,
        ),
        ActionButton(
          label: '🔒 Block',
          action: 'block',
          color: 'purple',
          icon: Icons.block,
        ),
      ],
    );
  }

  /// Hacked account specific message
  factory Message.hacked(String text, {String platform = 'account'}) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.crime,
      priority: MessagePriority.medium,
      actionType: 'hack',
      buttons: [
        ActionButton(
          label: '🔐 Recover Now',
          action: 'recover',
          color: 'blue',
          icon: Icons.lock_open,
        ),
        ActionButton(
          label: '📞 Need Help',
          action: 'help',
          color: 'green',
          icon: Icons.help,
        ),
        ActionButton(
          label: '📝 Report',
          action: 'complaint',
          color: 'orange',
          icon: Icons.description,
        ),
      ],
      metadata: {
        'platform': platform,
      },
    );
  }

  /// Info/Tip message
  factory Message.tip(String text, {String? category}) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.info,
      priority: MessagePriority.low,
      actionType: category,
    );
  }

  /// System message (status updates, etc.)
  factory Message.system(String text, {bool isError = false}) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.system,
      priority: MessagePriority.low,
      isError: isError,
    );
  }

  // ===== JSON SERIALIZATION =====
  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'type': type.index,
    'priority': priority.index,
    'actionType': actionType,
    'buttons': buttons?.map((b) => b.toJson()).toList(),
    'imageUrl': imageUrl,
    'metadata': metadata,
    'isRead': isRead,
    'isError': isError,
    'crimeId': crimeId,
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    text: json['text'],
    isUser: json['isUser'],
    timestamp: DateTime.parse(json['timestamp']),
    type: MessageType.values[json['type']],
    priority: MessagePriority.values[json['priority']],
    actionType: json['actionType'],
    buttons: json['buttons'] != null
        ? (json['buttons'] as List)
            .map((b) => ActionButton.fromJson(b))
            .toList()
        : null,
    imageUrl: json['imageUrl'],
    metadata: json['metadata'],
    isRead: json['isRead'] ?? false,
    isError: json['isError'] ?? false,
    crimeId: json['crimeId'],
  );

  // ===== UTILITY METHODS =====
  
  /// Copy with modifications
  Message copyWith({
    String? text,
    bool? isRead,
    int? crimeId,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id,
      text: text ?? this.text,
      isUser: isUser,
      timestamp: timestamp,
      type: type,
      priority: priority,
      actionType: actionType,
      buttons: buttons,
      imageUrl: imageUrl,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      isError: isError,
      crimeId: crimeId ?? this.crimeId,
    );
  }

  /// Check if message is from today
  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
           timestamp.month == now.month &&
           timestamp.day == now.day;
  }

  /// Get formatted time
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted date
  String get formattedDate {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  /// Check if message has actions
  bool get hasActions => buttons != null && buttons!.isNotEmpty;

  /// Get primary action button (highest priority)
  ActionButton? get primaryAction {
    if (buttons == null || buttons!.isEmpty) return null;
    return buttons!.reduce((a, b) => 
      (a.priority ?? 999) < (b.priority ?? 999) ? a : b
    );
  }

  /// Get crime type from metadata
  String? get crimeType => metadata?['crimeType'];

  /// Get transaction ID if exists
  String? get transactionId => metadata?['transactionId'];

  /// Get amount if exists
  double? get amount => metadata?['amount'];
}

// ===== ACTION BUTTON CLASS =====
class ActionButton {
  final String label;
  final String action;
  final String? color;
  final IconData? icon;
  final int? priority;  // Lower number = higher priority
  final bool? isDanger;
  final Map<String, dynamic>? params;

  ActionButton({
    required this.label,
    required this.action,
    this.color,
    this.icon,
    this.priority,
    this.isDanger,
    this.params,
  });

  // Predefined danger button
  factory ActionButton.danger({
    required String label,
    required String action,
    IconData? icon,
  }) {
    return ActionButton(
      label: label,
      action: action,
      color: 'red',
      icon: icon ?? Icons.warning,
      priority: 0,
      isDanger: true,
    );
  }

  // Predefined primary button
  factory ActionButton.primary({
    required String label,
    required String action,
    IconData? icon,
  }) {
    return ActionButton(
      label: label,
      action: action,
      color: 'blue',
      icon: icon ?? Icons.arrow_forward,
      priority: 1,
    );
  }

  // Predefined secondary button
  factory ActionButton.secondary({
    required String label,
    required String action,
    IconData? icon,
  }) {
    return ActionButton(
      label: label,
      action: action,
      color: 'grey',
      icon: icon,
      priority: 2,
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'action': action,
    'color': color,
    'priority': priority,
    'isDanger': isDanger,
    'params': params,
  };

  factory ActionButton.fromJson(Map<String, dynamic> json) => ActionButton(
    label: json['label'],
    action: json['action'],
    color: json['color'],
    priority: json['priority'],
    isDanger: json['isDanger'],
    params: json['params'],
  );

  /// Get color from string
  Color getButtonColor() {
    switch (color) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'grey':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}

// ===== ENUMS =====
enum MessageType {
  normal,     // Normal chat message
  emergency,  // Emergency alert
  crime,      // Crime report
  fraud,      // Fraud specific
  info,       // Information/Tip
  system,     // System message
  action,     // Action message
}

enum MessagePriority {
  low,    // 🟢 General info, tips
  medium, // 🟡 Urgent but not critical
  high,   // 🔴 Emergency - immediate action needed
}

// ===== EXTENSION METHODS =====
extension MessageExtension on Message {
  /// Check if message is high priority
  bool get isHighPriority => priority == MessagePriority.high;

  /// Check if message is medium priority
  bool get isMediumPriority => priority == MessagePriority.medium;

  /// Check if message is emergency
  bool get isEmergency => type == MessageType.emergency;

  /// Check if message is crime related
  bool get isCrime => type == MessageType.crime || type == MessageType.fraud;

  /// Get icon based on message type
  IconData get icon {
    if (isUser) return Icons.person;
    if (isEmergency) return Icons.warning;
    if (type == MessageType.crime) return Icons.gavel;
    if (type == MessageType.fraud) return Icons.money_off;
    if (type == MessageType.info) return Icons.info;
    if (type == MessageType.system) return Icons.settings;
    return Icons.support_agent;
  }

  /// Get color based on priority
  Color getColor(BuildContext context) {
    if (isUser) return Colors.blue.shade500;
    if (isEmergency) return Colors.red.shade50;
    switch (priority) {
      case MessagePriority.high:
        return Colors.orange.shade50;
      case MessagePriority.medium:
        return Colors.yellow.shade50;
      case MessagePriority.low:
        return Colors.grey.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  /// Get border color based on priority
  Color? getBorderColor() {
    if (isEmergency) return Colors.red;
    switch (priority) {
      case MessagePriority.high:
        return Colors.orange;
      case MessagePriority.medium:
        return Colors.yellow;
      default:
        return null;
    }
  }
}