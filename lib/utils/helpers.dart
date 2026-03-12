import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Helpers {
  // Format date
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }
  
  // Format time ago
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
  
  // Format time ago in Hindi
  static String timeAgoHi(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} साल पहले';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} महीने पहले';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} दिन पहले';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} घंटे पहले';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} मिनट पहले';
    } else {
      return 'अभी अभी';
    }
  }
  
  // Format phone number
  static String formatPhoneNumber(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    return phone;
  }
  
  // Mask sensitive data
  static String maskString(String input, {int visibleChars = 4}) {
    if (input.length <= visibleChars) return input;
    return '*' * (input.length - visibleChars) + input.substring(input.length - visibleChars);
  }
  
  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  // Validate phone (India)
  static bool isValidPhone(String phone) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
  }
  
  // Get crime type from message
  static String getCrimeType(String message) {
    final lowerMsg = message.toLowerCase();
    
    if (lowerMsg.contains('upi') || lowerMsg.contains('gpay') || 
        lowerMsg.contains('phonepe') || lowerMsg.contains('paytm')) {
      return 'UPI Fraud';
    } else if (lowerMsg.contains('facebook') || lowerMsg.contains('instagram') ||
               lowerMsg.contains('whatsapp')) {
      return 'Social Media Hacking';
    } else if (lowerMsg.contains('link') || lowerMsg.contains('phishing') ||
               lowerMsg.contains('फिशिंग')) {
      return 'Phishing';
    } else if (lowerMsg.contains('blackmail') || lowerMsg.contains('धमकी')) {
      return 'Blackmail';
    } else if (lowerMsg.contains('bank') || lowerMsg.contains('otp')) {
      return 'Bank Fraud';
    } else if (lowerMsg.contains('call') || lowerMsg.contains('कॉल')) {
      return 'Fake Call';
    }
    
    return 'Other';
  }
  
  // Get priority from message
  static String getPriority(String message) {
    final lowerMsg = message.toLowerCase();
    
    if (lowerMsg.contains('paise chale gaye') || 
        lowerMsg.contains('money lost') ||
        lowerMsg.contains('otp de diya') ||
        lowerMsg.contains('blackmail')) {
      return 'High';
    } else if (lowerMsg.contains('hack') || 
               lowerMsg.contains('phishing') ||
               lowerMsg.contains('suspicious')) {
      return 'Medium';
    }
    
    return 'Low';
  }
  
  // Extract amount from message
  static String? extractAmount(String message) {
    final RegExp amountRegex = RegExp(r'[₹]?\s*(\d+,?\d*\.?\d*)');
    final match = amountRegex.firstMatch(message);
    if (match != null) {
      return match.group(1)?.replaceAll(',', '');
    }
    return null;
  }
  
  // Extract transaction ID from message
  static String? extractTransactionId(String message) {
    final RegExp txnRegex = RegExp(r'(TXN|Transaction|ID)[:\s]*([A-Z0-9]+)', caseSensitive: false);
    final match = txnRegex.firstMatch(message);
    if (match != null) {
      return match.group(2);
    }
    return null;
  }
  
  // Show snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
  
  // Show dialog
  static Future<void> showDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (onConfirm != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: Text(confirmText ?? 'OK'),
            ),
        ],
      ),
    );
  }
  
  // Format size
  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  
  // Get initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
  
  // Generate random color from string
  static Color getColorFromString(String input) {
    final hash = input.hashCode.abs();
    return Colors.primaries[hash % Colors.primaries.length];
  }
}