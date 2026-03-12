import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Cyber Helpline';
  static const String appVersion = '1.0.0';
  
  // Helpline Numbers
  static const String cyberHelpline = '1930';
  static const String policeHelpline = '112';
  static const String womenHelpline = '181';
  static const String childHelpline = '1098';
  static const String ambulanceHelpline = '108';
  
  // Colors
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color emergencyColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color infoColor = Color(0xFF1976D2);
  
  // API Endpoints
  static const String baseUrl = 'https://api.cyberhelpline.com';
  static const String chatEndpoint = '$baseUrl/chat';
  static const String complaintEndpoint = '$baseUrl/complaints';
  static const String statisticsEndpoint = '$baseUrl/statistics';
  
  // Shared Preferences Keys
  static const String prefChatHistory = 'chat_history';
  static const String prefUserData = 'user_data';
  static const String prefThemeMode = 'theme_mode';
  static const String prefLanguage = 'language';
  static const String prefFirstLaunch = 'first_launch';
  static const String prefNotifications = 'notifications';
  
  // Crime Categories
  static const List<Map<String, String>> crimeCategories = [
    {'icon': '💰', 'en': 'UPI Fraud', 'hi': 'UPI ठगी', 'desc': 'गलत नंबर पर पैसे चले गए'},
    {'icon': '📱', 'en': 'Hacked Account', 'hi': 'हैक अकाउंट', 'desc': 'सोशल मीडिया हैक'},
    {'icon': '🎣', 'en': 'Phishing', 'hi': 'फिशिंग', 'desc': 'फर्जी लिंक/मैसेज'},
    {'icon': '⚠️', 'en': 'Blackmail', 'hi': 'ब्लैकमेल', 'desc': 'ब्लैकमेल/धमकी'},
    {'icon': '🏦', 'en': 'Bank Fraud', 'hi': 'बैंक फ्रॉड', 'desc': 'बैंक से जुड़ी ठगी'},
    {'icon': '📞', 'en': 'Fake Call', 'hi': 'फर्जी कॉल', 'desc': 'फर्जी कॉल/स्कैम'},
  ];
  
  // Quick Replies
  static const List<Map<String, String>> quickReplies = [
    {'icon': '💰', 'en': 'UPI fraud', 'hi': 'UPI ठगी', 'desc': 'Money sent to wrong number'},
    {'icon': '📱', 'en': 'Facebook hack', 'hi': 'फेसबुक हैक', 'desc': 'Account hacked'},
    {'icon': '🔗', 'en': 'Phishing', 'hi': 'फिशिंग', 'desc': 'Fake links/messages'},
    {'icon': '💬', 'en': 'OTP share', 'hi': 'OTP शेयर', 'desc': 'Shared OTP by mistake'},
    {'icon': '⚠️', 'en': 'Blackmail', 'hi': 'ब्लैकमेल', 'desc': 'Threats/blackmail'},
    {'icon': '📞', 'en': 'Fake call', 'hi': 'फर्जी कॉल', 'desc': 'Fake customer care'},
  ];
  
  // Safety Tips
  static const List<Map<String, String>> safetyTips = [
    {'tip': 'Never share OTP', 'icon': '🔐', 'color': 'purple'},
    {'tip': 'Use strong passwords', 'icon': '🔒', 'color': 'green'},
    {'tip': 'Enable 2FA', 'icon': '🛡️', 'color': 'blue'},
    {'tip': 'Avoid public Wi-Fi', 'icon': '📱', 'color': 'orange'},
    {'tip': 'Verify before paying', 'icon': '💰', 'color': 'red'},
  ];
  
  // Bank Helplines
  static const List<Map<String, String>> bankHelplines = [
    {'bank': 'SBI', 'number': '1800 1234'},
    {'bank': 'HDFC', 'number': '1800 2583'},
    {'bank': 'ICICI', 'number': '1800 1080'},
    {'bank': 'Axis', 'number': '1800 2090'},
    {'bank': 'PNB', 'number': '1800 1800'},
    {'bank': 'Canara', 'number': '1800 1234'},
    {'bank': 'BoB', 'number': '1800 2583'},
  ];
}

class AppStrings {
  // Common
  static const String appName = 'Cyber Helpline';
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String loading = 'Loading...';
  
  // Errors
  static const String errorGeneral = 'Something went wrong';
  static const String errorNetwork = 'Network error. Check connection';
  static const String errorServer = 'Server error. Try again later';
  
  // Success
  static const String successComplaint = 'Complaint filed successfully';
  static const String successProfile = 'Profile updated successfully';
}

class AppAssets {
  // Images
  static const String logo = 'assets/images/logo.png';
  static const String logoWhite = 'assets/images/logo_white.png';
  static const String splashLogo = 'assets/images/splash_logo.png';
  static const String chatBg = 'assets/images/chat_bg.png';
  static const String placeholder = 'assets/images/placeholder.png';
  
  // Icons
  static const String appIcon = 'assets/icons/ic_launcher.png';
  
  // Animations
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String successAnimation = 'assets/animations/success.json';
  
  // Fonts
  static const String poppinsRegular = 'assets/fonts/Poppins-Regular.ttf';
  static const String poppinsBold = 'assets/fonts/Poppins-Bold.ttf';
}