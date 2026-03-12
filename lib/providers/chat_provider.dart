import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../screens/complaint_screen.dart';
import '../screens/emergency_screen.dart';
import '../screens/resources_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatProvider with ChangeNotifier {
  List<Message> _messages = [];
  bool _isTyping = false;
  String _currentLanguage = 'hi';
  int _unreadCount = 0;
  User? _currentUser;
  BuildContext? _context;
  
  // AI Memory - yaad rakhne ke liye
  Map<String, dynamic> _conversationMemory = {};
  List<String> _lastTopics = [];

  List<Message> get messages => _messages;
  bool get isTyping => _isTyping;
  String get currentLanguage => _currentLanguage;
  int get unreadCount => _unreadCount;
  User? get currentUser => _currentUser;

  void setContext(BuildContext context) {
    _context = context;
  }

  // ===== ADVANCED QUICK REPLIES WITH MULTIPLE ACTIONS =====
  final List<Map<String, dynamic>> quickReplies = [
    {'icon': '💰', 'en': 'UPI fraud', 'hi': 'UPI ठगी', 'desc': 'Money sent to wrong number', 'action': 'upi', 'priority': 'high'},
    {'icon': '📱', 'en': 'Facebook hack', 'hi': 'फेसबुक हैक', 'desc': 'Account hacked', 'action': 'hack', 'priority': 'medium'},
    {'icon': '🏦', 'en': 'Bank fraud', 'hi': 'बैंक धोखाधड़ी', 'desc': 'OTP/Card fraud', 'action': 'bank', 'priority': 'high'},
    {'icon': '🔗', 'en': 'Phishing', 'hi': 'फिशिंग', 'desc': 'Fake links/messages', 'action': 'phishing', 'priority': 'medium'},
    {'icon': '⚠️', 'en': 'Blackmail', 'hi': 'ब्लैकमेल', 'desc': 'Threats/leaks', 'action': 'blackmail', 'priority': 'high'},
    {'icon': '📞', 'en': 'Fake call', 'hi': 'फर्जी कॉल', 'desc': 'Fake customer care', 'action': 'fakecall', 'priority': 'medium'},
    {'icon': '🔐', 'en': 'Lost OTP', 'hi': 'OTP खो गया', 'desc': 'Shared OTP by mistake', 'action': 'otp', 'priority': 'high'},
    {'icon': '👤', 'en': 'Identity theft', 'hi': 'पहचान चोरी', 'desc': 'Someone using my ID', 'action': 'identity', 'priority': 'high'},
  ];

  // ===== KEYWORDS FOR DETECTION (SIMPLE LIST) =====
  final Map<String, List<String>> _keywords = {
    'greetings': ['hi', 'hello', 'hey', 'hii', 'hiii', 'helo', 'hai', 'नमस्ते', 'namaste', 'good morning', 'good afternoon', 'good evening', 'gm', 'gn'],
    'thanks': ['thanks', 'thank', 'thanku', 'thnks', 'धन्यवाद', 'शुक्रिया', 'thank you'],
    'emergency': [
      'paise chale gaye', 'पैसे चले गए', 'money lost', 'money gone',
      'otp de diya', 'ओटीपी दे दिया', 'shared otp',
      'blackmail', 'ब्लैकमेल', 'धमकी', 'threat',
      'photo leak', 'video leak', 'account empty', 'zero balance',
      'urgent', 'immediate', 'emergency', 'help me'
    ],
    'upi': ['upi', 'gpay', 'phonepe', 'paytm', 'paise bhej', 'money send', 'wrong number', 'galat number'],
    'hack': ['hack', 'हैक', 'facebook', 'fb', 'instagram', 'ig', 'whatsapp', 'wa', 'account', 'password'],
    'phishing': ['link', 'लिंक', 'click', 'message', 'kyc', 'update', 'bank block', 'atm block'],
    'bank': ['bank', 'बैंक', 'otp', 'card', 'sbi', 'hdfc', 'icici', 'axis', 'pnb'],
    'blackmail': ['blackmail', 'ब्लैकमेल', 'धमकी', 'threat', 'photo leak', 'video leak'],
    'fakecall': ['call', 'कॉल', 'customer care', 'fake', 'फर्जी', 'fedex', 'courier', 'dhl'],
    'otp': ['otp', 'ओटीपी', 'shared otp', 'otp de diya'],
    'identity': ['identity', 'पहचान', 'id theft', 'fake id', 'impersonation'],
    'complaint': ['complaint', 'शिकायत', 'file complaint', 'report'],
    'helpline': ['helpline', 'हेल्पलाइन', 'number', 'नंबर', 'contact'],
  };

  ChatProvider() {
    loadData();
  }

  Future<void> loadData() async {
    await _loadLanguage();
    await _loadChatHistory();
    await _loadUser();
    _addWelcomeMessage();
  }

  // ===== LANGUAGE =====
  Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', language);
    _messages.clear();
    _addWelcomeMessage();
    notifyListeners();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('app_language') ?? 'hi';
  }

  String _t(String en, String hi) => _currentLanguage == 'hi' ? hi : en;

  // ===== USER =====
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      _currentUser = User.fromJson(jsonDecode(userData));
    } else {
      _currentUser = User.guest();
    }
  }

  Future<void> updateUser(User user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    notifyListeners();
  }

  // ===== AI-POWERED WELCOME MESSAGE =====
  void _addWelcomeMessage() {
    final hour = DateTime.now().hour;
    String greeting;
    
    if (hour < 12) greeting = _t('Good Morning!', 'सुप्रभात!');
    else if (hour < 17) greeting = _t('Good Afternoon!', 'नमस्ते!');
    else greeting = _t('Good Evening!', 'शुभ संध्या!');

    String name = _currentUser?.name ?? '';
    if (name != 'Guest User' && name.isNotEmpty) {
      greeting = '$greeting $name';
    }

    String welcomeMsg = _currentLanguage == 'hi'
        ? 'मैं आपका **AI साइबर सहायक** हूँ। 🤖\n\n'
          'मैं समझता हूँ:\n'
          '• UPI ठगी, बैंक फ्रॉड\n'
          '• सोशल मीडिया हैकिंग\n'
          '• फिशिंग, ब्लैकमेल\n'
          '• फर्जी कॉल, OTP स्कैम\n\n'
          'बस अपनी समस्या बताइए - मैं तुरंत मदद करूंगा!\n'
          'Example: "UPI fraud ho gaya" या "Facebook hack"'
        : 'I am your **AI Cyber Assistant**! 🤖\n\n'
          'I understand:\n'
          '• UPI fraud, Bank fraud\n'
          '• Social media hacking\n'
          '• Phishing, Blackmail\n'
          '• Fake calls, OTP scams\n\n'
          'Just tell me your problem - I\'ll help immediately!\n'
          'Example: "UPI fraud happened" or "Facebook hacked"';

    _messages.add(Message.bot(
      '$greeting 👋\n\n$welcomeMsg',
      priority: MessagePriority.low,
    ));
  }

  // ===== SEND MESSAGE WITH AI PROCESSING =====
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(Message.user(text));
    if (_currentUser != null) {
      _currentUser!.totalChats++;
      updateUser(_currentUser!);
    }
    notifyListeners();

    _isTyping = true;
    notifyListeners();

    // AI thinking time - message length ke hisaab se
    await Future.delayed(Duration(milliseconds: 300 + (text.length * 5)));

    final response = await _processMessageWithAI(text);
    
    _messages.add(response);
    _isTyping = false;
    
    _saveChatHistory();
    notifyListeners();
  }

  // ===== AI MESSAGE PROCESSOR =====
  Future<Message> _processMessageWithAI(String text) async {
    final lowerText = text.toLowerCase().trim();
    
    // Store in memory for context
    _conversationMemory['lastMessage'] = text;
    _updateTopics(lowerText);
    
    // Check each category directly
    for (var entry in _keywords.entries) {
      if (entry.value.any((keyword) => lowerText.contains(keyword))) {
        switch (entry.key) {
          case 'greetings': return _getGreetingResponse(text);
          case 'thanks': return _getThanksResponse(text);
          case 'emergency': return _getEmergencyResponse(text);
          case 'upi': return _getUpiFraudResponse(text);
          case 'hack': return _getHackingResponse(text);
          case 'phishing': return _getPhishingResponse(text);
          case 'bank': return _getBankFraudResponse(text);
          case 'blackmail': return _getBlackmailResponse(text);
          case 'fakecall': return _getFakeCallResponse(text);
          case 'otp': return _getOTPResponse(text);
          case 'identity': return _getIdentityTheftResponse(text);
          case 'complaint': return _getComplaintGuidance(text);
          case 'helpline': return _getHelplineInfo(text);
        }
      }
    }
    
    // Check for single words
    if (lowerText.length < 5) {
      if (lowerText.contains('h') || lowerText.contains('he') || lowerText.contains('hi')) {
        return _getGreetingResponse(text);
      }
    }
    
    // Context-aware response
    if (_lastTopics.isNotEmpty) {
      return _getContextAwareResponse(text);
    }
    
    return _getDefaultResponse(text);
  }

  void _updateTopics(String message) {
    for (var entry in _keywords.entries) {
      if (entry.value.any((k) => message.contains(k))) {
        _lastTopics.add(entry.key);
        if (_lastTopics.length > 3) _lastTopics.removeAt(0);
        break;
      }
    }
  }

  Message _getContextAwareResponse(String text) {
    String lastTopic = _lastTopics.isNotEmpty ? _lastTopics.last : '';
    
    if (lastTopic.isNotEmpty) {
      return Message.bot(
        _t(
          'I see you were asking about $lastTopic. Could you provide more details?',
          'मैं देख रहा हूँ आप $lastTopic के बारे में पूछ रहे थे। कृपया और जानकारी दें?'
        ),
        priority: MessagePriority.low,
      );
    }
    
    return _getDefaultResponse(text);
  }

  // ===== AI RESPONSES WITH MULTIPLE ACTIONS =====
  Message _getGreetingResponse(String userText) {
    if (userText.contains('hii') || userText.contains('hiii')) {
      return Message.bot(_t(
        'Hiiii! 👋 How are you doing today? Need any help?',
        'हाइiii! 👋 आप कैसे हैं आज? कोई मदद चाहिए?'
      ));
    }
    if (userText.contains('good morning') || userText.contains('gm')) {
      return Message.bot(_t(
        'Good Morning! ☀️ Have a great day! How can I assist?',
        'सुप्रभात! ☀️ आपका दिन शुभ हो! कैसे मदद कर सकता हूँ?'
      ));
    }
    if (userText.contains('good night') || userText.contains('gn')) {
      return Message.bot(_t(
        'Good Night! 😴 Sleep well! Remember, I\'m here 24/7 if you need help.',
        'शुभ रात्रि! 😴 मीठे सपने! याद रखें, मैं 24/7 हूँ अगर मदद चाहिए।'
      ));
    }
    return Message.bot(_t(
      'Hello! 👋 How can I assist you today with cyber security?',
      'नमस्ते! 👋 आज मैं साइबर सुरक्षा में कैसे मदद कर सकता हूँ?'
    ));
  }

  Message _getThanksResponse(String userText) {
    return Message.bot(_t(
      'You\'re welcome! 😊 Stay safe and secure! Always here to help.\n\nWould you like to learn some safety tips?',
      'आपका स्वागत है! 😊 सुरक्षित रहें! हमेशा मदद के लिए तैयार।\n\nक्या आप कुछ सुरक्षा टिप्स सीखना चाहेंगे?'
    ), actionType: 'safety_tips');
  }

  Message _getEmergencyResponse(String userText) {
    return Message.emergency(
      _t(
        '🚨 **EMERGENCY DETECTED!** 🚨\n\n'
        '**IMMEDIATE ACTIONS REQUIRED:**\n\n'
        '1️⃣ Call **1930** NOW - National Cyber Helpline (24x7)\n'
        '2️⃣ Call your bank immediately to block transactions\n'
        '3️⃣ Save all screenshots and evidence\n'
        '4️⃣ File complaint at cybercrime.gov.in\n\n'
        '💰 For financial fraud: Note Transaction ID\n'
        '🔐 For hacking: Change passwords immediately\n'
        '📞 For fake calls: Block the number\n\n'
        'Don\'t panic! I\'m here to help. Click buttons below for quick action!',
        
        '🚨 **आपातकाल का पता चला!** 🚨\n\n'
        '**तुरंत ये करें:**\n\n'
        '1️⃣ **1930** पर अभी कॉल करें - राष्ट्रीय साइबर हेल्पलाइन (24x7)\n'
        '2️⃣ अपने बैंक को तुरंत कॉल करें\n'
        '3️⃣ सभी सबूत सेव करें (स्क्रीनशॉट)\n'
        '4️⃣ cybercrime.gov.in पर शिकायत करें\n\n'
        '💰 UPI ठगी के लिए: Transaction ID नोट करें\n'
        '🔐 हैकिंग के लिए: अभी पासवर्ड बदलें\n'
        '📞 फर्जी कॉल के लिए: नंबर ब्लॉक करें\n\n'
        'घबराएँ नहीं! मैं यहाँ हूँ। तुरंत कार्रवाई के लिए नीचे बटन दबाएँ!'
      ),
      actionType: 'emergency',
    );
  }

  Message _getUpiFraudResponse(String userText) {
    return Message.bot(
      _t(
        '💰 **UPI FRAUD DETECTED!**\n\n'
        '**Immediate Action Plan:**\n\n'
        '1️⃣ Call **1930** immediately - 24x7 Cyber Helpline\n'
        '2️⃣ Call your bank\'s helpline\n'
        '3️⃣ Note Transaction ID & amount lost\n'
        '4️⃣ Take screenshots of the transaction\n'
        '5️⃣ File complaint online\n\n'
        '📋 **Information to collect:**\n'
        '• Transaction ID\n'
        '• Amount lost\n'
        '• Date & time\n'
        '• UPI ID / Phone number\n\n'
        'Quick action can save your money! Click the button below to file complaint.',
        
        '💰 **UPI ठगी का पता चला!**\n\n'
        '**तुरंत करें:**\n\n'
        '1️⃣ **1930** पर तुरंत कॉल करें - 24x7 साइबर हेल्पलाइन\n'
        '2️⃣ अपने बैंक को कॉल करें\n'
        '3️⃣ Transaction ID और राशि नोट करें\n'
        '4️⃣ पेमेंट के स्क्रीनशॉट लें\n'
        '5️⃣ ऑनलाइन शिकायत करें\n\n'
        '📋 **यह जानकारी इकट्ठा करें:**\n'
        '• Transaction ID\n'
        '• खोई हुई राशि\n'
        '• तारीख और समय\n'
        '• UPI ID / फोन नंबर\n\n'
        'त्वरित कार्रवाई से पैसे बच सकते हैं! शिकायत दर्ज करने के लिए नीचे बटन दबाएँ।'
      ),
      priority: MessagePriority.high,
      actionType: 'upi',
    );
  }

  Message _getBlackmailResponse(String userText) {
    return Message.bot(
      _t(
        '⚠️ **BLACKMAIL DETECTED!**\n\n'
        '**CRITICAL - DO NOT PANIC:**\n\n'
        '1️⃣ **DO NOT** pay any money - EVER!\n'
        '2️⃣ **BLOCK** the person immediately\n'
        '3️⃣ **SAVE** all evidence (screenshots, recordings)\n'
        '4️⃣ **CALL** 1930 or 112 immediately\n'
        '5️⃣ **FILE** complaint online\n\n'
        '🛡️ **Remember:**\n'
        '• Paying doesn\'t guarantee safety\n'
        '• Police can trace the criminals\n'
        '• You are not alone - we are here\n\n'
        'Click the button below to file complaint with evidence.',
        
        '⚠️ **ब्लैकमेल का पता चला!**\n\n'
        '**महत्वपूर्ण - घबराएँ नहीं:**\n\n'
        '1️⃣ **पैसे न दें** - कभी न दें!\n'
        '2️⃣ **ब्लॉक करें** उस व्यक्ति को तुरंत\n'
        '3️⃣ **सबूत सेव करें** (स्क्रीनशॉट, रिकॉर्डिंग)\n'
        '4️⃣ **कॉल करें** 1930 या 112 पर तुरंत\n'
        '5️⃣ **शिकायत दर्ज करें** ऑनलाइन\n\n'
        '🛡️ **याद रखें:**\n'
        '• पैसे देने से सुरक्षा नहीं मिलती\n'
        '• पुलिस अपराधियों को ट्रैक कर सकती है\n'
        '• आप अकेले नहीं हैं - हम हैं\n\n'
        'सबूत के साथ शिकायत दर्ज करने के लिए नीचे बटन दबाएँ।'
      ),
      priority: MessagePriority.high,
      actionType: 'blackmail',
    );
  }

  Message _getOTPResponse(String userText) {
    return Message.bot(
      _t(
        '🔐 **OTP SHARED - URGENT!**\n\n'
        '**Immediate Steps:**\n\n'
        '1️⃣ Call bank helpline NOW\n'
        '2️⃣ Block your card/account immediately\n'
        '3️⃣ Call **1930**\n'
        '4️⃣ Check for unauthorized transactions\n'
        '5️⃣ File complaint online\n\n'
        '⚠️ **Never share OTP with anyone!**\n'
        'Banks never ask for OTP.',
        
        '🔐 **OTP शेयर हो गया - तुरंत करें!**\n\n'
        '**तुरंत ये करें:**\n\n'
        '1️⃣ बैंक हेल्पलाइन पर अभी कॉल करें\n'
        '2️⃣ अपना कार्ड/अकाउंट तुरंत ब्लॉक करें\n'
        '3️⃣ **1930** पर कॉल करें\n'
        '4️⃣ अनधिकृत ट्रांजेक्शन चेक करें\n'
        '5️⃣ ऑनलाइन शिकायत करें\n\n'
        '⚠️ **कभी भी OTP न बताएँ!**\n'
        'बैंक कभी OTP नहीं मांगते।'
      ),
      priority: MessagePriority.high,
      actionType: 'otp',
    );
  }

  Message _getHackingResponse(String userText) {
    String platform = 'Account';
    if (userText.contains('facebook') || userText.contains('fb')) platform = 'Facebook';
    else if (userText.contains('instagram') || userText.contains('ig')) platform = 'Instagram';
    else if (userText.contains('whatsapp') || userText.contains('wa')) platform = 'WhatsApp';
    
    return Message.bot(
      _t(
        '🔐 **$platform HACKED - Recovery Steps:**\n\n'
        '1️⃣ Go to $platform login page\n'
        '2️⃣ Click "Forgot Password"\n'
        '3️⃣ Follow recovery process\n'
        '4️⃣ Enable Two-Factor Authentication (2FA)\n'
        '5️⃣ Check connected apps and remove unknown\n'
        '6️⃣ Alert your friends about the hack\n\n'
        '**Password Tips:**\n'
        '• Use 12+ characters\n'
        '• Mix letters, numbers, symbols\n'
        '• Don\'t reuse passwords\n\n'
        'Need help recovering? Click the button below!',
        
        '🔐 **$platform हैक - रिकवरी स्टेप्स:**\n\n'
        '1️⃣ $platform लॉगिन पेज पर जाएँ\n'
        '2️⃣ "Forgot Password" पर क्लिक करें\n'
        '3️⃣ रिकवरी प्रक्रिया पूरी करें\n'
        '4️⃣ Two-Factor Authentication (2FA) ऑन करें\n'
        '5️⃣ कनेक्टेड ऐप्स चेक करें\n'
        '6️⃣ दोस्तों को अलर्ट करें\n\n'
        '**पासवर्ड टिप्स:**\n'
        '• 12+ अक्षरों का प्रयोग करें\n'
        '• अक्षर, संख्या, चिन्ह मिलाएँ\n'
        '• पासवर्ड दोबारा ना इस्तेमाल करें\n\n'
        'रिकवरी में मदद चाहिए? नीचे बटन दबाएँ!'
      ),
      priority: MessagePriority.medium,
      actionType: 'hack',
    );
  }

  Message _getPhishingResponse(String userText) {
    return Message.bot(
      _t(
        '🎣 **PHISHING DETECTED!**\n\n'
        '**DON\'T:**\n'
        '❌ Click any links\n'
        '❌ Share OTP/CVV/PIN\n'
        '❌ Share personal info\n\n'
        '**DO THIS:**\n'
        '1️⃣ Forward suspicious message to **1930**\n'
        '2️⃣ Report at cybercrime.gov.in\n'
        '3️⃣ Block the sender\n'
        '4️⃣ Delete the message\n\n'
        '🔍 **How to identify phishing:**\n'
        '• Urgent/threatening language\n'
        '• Spelling/grammar mistakes\n'
        '• Suspicious sender address\n'
        '• Requests for OTP/password\n\n'
        'Stay alert! 🛡️',
        
        '🎣 **फिशिंग का पता चला!**\n\n'
        '**न करें:**\n'
        '❌ किसी लिंक पर क्लिक न करें\n'
        '❌ OTP/CVV/PIN न बताएँ\n'
        '❌ निजी जानकारी न दें\n\n'
        '**ये करें:**\n'
        '1️⃣ संदिग्ध मैसेज **1930** पर फॉरवर्ड करें\n'
        '2️⃣ cybercrime.gov.in पर रिपोर्ट करें\n'
        '3️⃣ भेजने वाले को ब्लॉक करें\n'
        '4️⃣ मैसेज डिलीट करें\n\n'
        '🔍 **फिशिंग की पहचान:**\n'
        '• जल्दबाजी/धमकी भरी भाषा\n'
        '• स्पेलिंग/व्याकरण की गलतियाँ\n'
        '• संदिग्ध भेजने वाला\n'
        '• OTP/पासवर्ड की मांग\n\n'
        'सतर्क रहें! 🛡️'
      ),
      priority: MessagePriority.medium,
      actionType: 'phishing',
    );
  }

  Message _getBankFraudResponse(String userText) {
    return Message.bot(
      _t(
        '🏦 **BANK FRAUD - Immediate Actions:**\n\n'
        '1️⃣ Call bank helpline NOW\n'
        '2️⃣ Block your card/account immediately\n'
        '3️⃣ Call **1930**\n'
        '4️⃣ File complaint online\n\n'
        '📞 **Major Bank Helplines:**\n'
        '• SBI: 1800 1234\n'
        '• HDFC: 1800 2583\n'
        '• ICICI: 1800 1080\n'
        '• Axis Bank: 1800 2090\n'
        '• PNB: 1800 1800\n\n'
        '⚠️ **Remember:**\n'
        '• Bank never asks for OTP\n'
        '• Never share CVV\n'
        '• Never share PIN',
        
        '🏦 **बैंक फ्रॉड - तुरंत करें:**\n\n'
        '1️⃣ बैंक हेल्पलाइन पर अभी कॉल करें\n'
        '2️⃣ अपना कार्ड/अकाउंट तुरंत ब्लॉक करें\n'
        '3️⃣ **1930** पर कॉल करें\n'
        '4️⃣ ऑनलाइन शिकायत करें\n\n'
        '📞 **मुख्य बैंक हेल्पलाइन:**\n'
        '• SBI: 1800 1234\n'
        '• HDFC: 1800 2583\n'
        '• ICICI: 1800 1080\n'
        '• Axis Bank: 1800 2090\n'
        '• PNB: 1800 1800\n\n'
        '⚠️ **याद रखें:**\n'
        '• बैंक OTP नहीं मांगता\n'
        '• CVV कभी ना बताएँ\n'
        '• PIN कभी ना बताएँ'
      ),
      priority: MessagePriority.high,
      actionType: 'bank',
    );
  }

  Message _getFakeCallResponse(String userText) {
    return Message.bot(
      _t(
        '📞 **FAKE CALL SCAM - Stay Safe:**\n\n'
        '**Never share:**\n'
        '❌ OTP\n'
        '❌ CVV\n'
        '❌ ATM PIN\n'
        '❌ Bank details\n\n'
        '**DO THIS:**\n'
        '1️⃣ Hang up immediately\n'
        '2️⃣ Block the number\n'
        '3️⃣ Report at cybercrime.gov.in\n'
        '4️⃣ Forward number to 1930\n\n'
        '🔍 **Common fake call scenarios:**\n'
        '• "Your courier is stuck"\n'
        '• "KYC update required"\n'
        '• "Bank account will close"\n'
        '• "You won a lottery"\n'
        '• "FedEx/DHL parcel issue"\n\n'
        'Real companies never ask for OTP!',
        
        '📞 **फर्जी कॉल - सुरक्षित रहें:**\n\n'
        '**कभी ना बताएँ:**\n'
        '❌ OTP\n'
        '❌ CVV\n'
        '❌ ATM PIN\n'
        '❌ बैंक डिटेल्स\n\n'
        '**ये करें:**\n'
        '1️⃣ तुरंत कॉल काटें\n'
        '2️⃣ नंबर ब्लॉक करें\n'
        '3️⃣ cybercrime.gov.in पर रिपोर्ट करें\n'
        '4️⃣ नंबर 1930 पर फॉरवर्ड करें\n\n'
        '🔍 **आम फर्जी कॉल:**\n'
        '• "आपका कूरियर फंस गया"\n'
        '• "KYC अपडेट करें"\n'
        '• "बैंक अकाउंट बंद होगा"\n'
        '• "लॉटरी लगी है"\n'
        '• "FedEx/DHL पार्सल"\n\n'
        'असली कंपनियां OTP नहीं मांगती!'
      ),
      priority: MessagePriority.medium,
      actionType: 'fakecall',
    );
  }

  Message _getIdentityTheftResponse(String userText) {
    return Message.bot(
      _t(
        '👤 **IDENTITY THEFT - Action Plan:**\n\n'
        '1️⃣ File police complaint immediately\n'
        '2️⃣ Call 1930 and report\n'
        '3️⃣ Check credit reports\n'
        '4️⃣ Inform your bank\n'
        '5️⃣ Change all passwords\n\n'
        '📋 **Document everything:**\n'
        '• Keep all evidence\n'
        '• Note dates and times\n'
        '• Save emails/messages\n\n'
        'File complaint online now!',
        
        '👤 **पहचान चोरी - कार्य योजना:**\n\n'
        '1️⃣ तुरंत पुलिस में शिकायत दर्ज करें\n'
        '2️⃣ 1930 पर कॉल करें\n'
        '3️⃣ क्रेडिट रिपोर्ट चेक करें\n'
        '4️⃣ बैंक को सूचित करें\n'
        '5️⃣ सभी पासवर्ड बदलें\n\n'
        '📋 **सबूत इकट्ठा करें:**\n'
        '• सभी सबूत सेव करें\n'
        '• तारीख और समय नोट करें\n'
        '• ईमेल/मैसेज सेव करें\n\n'
        'अभी ऑनलाइन शिकायत करें!'
      ),
      priority: MessagePriority.high,
      actionType: 'identity',
    );
  }

  Message _getComplaintGuidance(String userText) {
    return Message.bot(
      _t(
        '📝 **How to File a Complaint:**\n\n'
        '**Online:**\n'
        '1️⃣ Go to cybercrime.gov.in\n'
        '2️⃣ Click "File Complaint"\n'
        '3️⃣ Fill your details\n'
        '4️⃣ Describe the incident\n'
        '5️⃣ Upload evidence\n'
        '6️⃣ Submit and get complaint number\n\n'
        '**By Phone:**\n'
        '• Call 1930 (24x7)\n\n'
        'Would you like me to help you file a complaint?',
        
        '📝 **शिकायत कैसे दर्ज करें:**\n\n'
        '**ऑनलाइन:**\n'
        '1️⃣ cybercrime.gov.in पर जाएँ\n'
        '2️⃣ "File Complaint" पर क्लिक करें\n'
        '3️⃣ अपनी जानकारी भरें\n'
        '4️⃣ घटना का विवरण दें\n'
        '5️⃣ सबूत अपलोड करें\n'
        '6️⃣ सबमिट करें और complaint number लें\n\n'
        '**फोन द्वारा:**\n'
        '• 1930 पर कॉल करें (24x7)\n\n'
        'क्या आप चाहेंगे मैं शिकायत दर्ज करने में मदद करूँ?'
      ),
      priority: MessagePriority.medium,
      actionType: 'complaint',
    );
  }

  Message _getHelplineInfo(String userText) {
    return Message.bot(
      _t(
        '📞 **Important Helplines:**\n\n'
        '• Cyber Crime: **1930** (24x7)\n'
        '• Police: **112** (Emergency)\n'
        '• Women Helpline: **181**\n'
        '• Child Helpline: **1098**\n'
        '• Ambulance: **108**\n\n'
        '**Bank Helplines:**\n'
        '• SBI: 1800 1234\n'
        '• HDFC: 1800 2583\n'
        '• ICICI: 1800 1080\n'
        '• Axis: 1800 2090\n'
        '• PNB: 1800 1800\n\n'
        'All helplines are FREE 24x7!',
        
        '📞 **महत्वपूर्ण हेल्पलाइन:**\n\n'
        '• साइबर क्राइम: **1930** (24x7)\n'
        '• पुलिस: **112** (आपातकाल)\n'
        '• महिला हेल्पलाइन: **181**\n'
        '• बाल हेल्पलाइन: **1098**\n'
        '• एम्बुलेंस: **108**\n\n'
        '**बैंक हेल्पलाइन:**\n'
        '• SBI: 1800 1234\n'
        '• HDFC: 1800 2583\n'
        '• ICICI: 1800 1080\n'
        '• Axis: 1800 2090\n'
        '• PNB: 1800 1800\n\n'
        'सभी हेल्पलाइन 24x7 मुफ्त हैं!'
      ),
      priority: MessagePriority.low,
      actionType: 'helpline',
    );
  }

  Message _getDefaultResponse(String text) {
    return Message.bot(
      _t(
        'I understand you wrote: **"$text"**\n\n'
        'I want to help you with cyber security issues. Please tell me:\n\n'
        '• "UPI fraud" - for payment issues\n'
        '• "Facebook hack" - for hacked accounts\n'
        '• "Blackmail" - for threats\n'
        '• "Bank fraud" - for banking issues\n'
        '• "Fake call" - for scam calls\n\n'
        'Or choose from the options below 👇',
        
        'आपने लिखा: **"$text"**\n\n'
        'मैं साइबर सुरक्षा में मदद कर सकता हूँ। कृपया बताएँ:\n\n'
        '• "UPI ठगी" - भुगतान की समस्या के लिए\n'
        '• "फेसबुक हैक" - हैक अकाउंट के लिए\n'
        '• "ब्लैकमेल" - धमकी के लिए\n'
        '• "बैंक फ्रॉड" - बैंकिंग समस्या के लिए\n'
        '• "फर्जी कॉल" - स्कैम कॉल के लिए\n\n'
        'या नीचे दिए विकल्पों में से चुनें 👇'
      ),
      priority: MessagePriority.low,
    );
  }

  // ===== SUPER SMART ACTION HANDLER =====
  Future<void> handleAction(BuildContext context, String actionType) async {
    switch (actionType) {
      case 'call:1930':
      case 'emergency':
        _makePhoneCall('1930');
        break;
        
      case 'complaint':
      case 'upi':
      case 'blackmail':
      case 'bank':
      case 'hack':
      case 'phishing':
      case 'fakecall':
      case 'otp':
      case 'identity':
        _navigateToComplaint(context, actionType);
        break;
        
      case 'safety_tips':
        _navigateToResources(context);
        break;
        
      case 'helpline':
        _navigateToEmergency(context);
        break;
        
      case 'expert':
        _connectToExpert(context);
        break;
        
      case 'recover':
        _showAccountRecovery(context);
        break;
        
      case 'help':
        _showHelp(context);
        break;
        
      default:
        _showMessage(context, 'Processing...');
    }
  }

  void _navigateToComplaint(BuildContext context, String crimeType) {
    String complaintType = _getComplaintType(crimeType);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComplaintScreen(
          initialType: complaintType,
        ),
      ),
    ).then((_) {
      _showMessage(context, _t(
        'Thanks for filing complaint! Stay safe.',
        'शिकायत दर्ज करने के लिए धन्यवाद! सुरक्षित रहें।'
      ));
    });
  }

  void _navigateToResources(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResourcesScreen()),
    );
  }

  void _navigateToEmergency(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmergencyScreen()),
    );
  }

  String _getComplaintType(String actionType) {
    switch (actionType) {
      case 'upi': return 'UPI/Payment Fraud';
      case 'blackmail': return 'Blackmail/Extortion';
      case 'bank': return 'Bank Fraud';
      case 'hack': return 'Social Media Hacking';
      case 'phishing': return 'Phishing Attack';
      case 'fakecall': return 'Fake Customer Care';
      case 'otp': return 'OTP Fraud';
      case 'identity': return 'Identity Theft';
      case 'complaint': return 'Other';
      default: return 'Other';
    }
  }

  void _makePhoneCall(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (_context != null) {
        _showMessage(_context!, _t(
          'Cannot make call. Please dial $number manually.',
          'कॉल नहीं कर सकते। कृपया $number डायल करें।'
        ));
      }
    }
  }

  void _connectToExpert(BuildContext context) {
    _showDialog(
      context,
      _t('Connect to Expert', 'एक्सपर्ट से कनेक्ट'),
      _t(
        'Connecting you to a cyber security expert...\n\nMeanwhile, you can call 1930 for immediate help.',
        'आपको साइबर सुरक्षा एक्सपर्ट से कनेक्ट किया जा रहा है...\n\nइस बीच, तुरंत मदद के लिए 1930 पर कॉल कर सकते हैं।'
      ),
    );
  }

  void _showAccountRecovery(BuildContext context) {
    _showDialog(
      context,
      _t('Account Recovery', 'अकाउंट रिकवरी'),
      _t(
        'Opening account recovery guide...\n\nFollow the steps shown to recover your account.',
        'अकाउंट रिकवरी गाइड खुल रही है...\n\nअपना अकाउंट रिकवर करने के लिए दिए गए स्टेप्स फॉलो करें।'
      ),
    );
  }

  void _showHelp(BuildContext context) {
    _showDialog(
      context,
      _t('Help', 'मदद'),
      _t(
        'I can help you with:\n\n'
        '• UPI fraud\n'
        '• Hacked accounts\n'
        '• Phishing\n'
        '• Blackmail\n'
        '• Bank fraud\n'
        '• Fake calls\n\n'
        'Just type your problem and I\'ll guide you!',
        
        'मैं इनमें मदद कर सकता हूँ:\n\n'
        '• UPI ठगी\n'
        '• हैक अकाउंट\n'
        '• फिशिंग\n'
        '• ब्लैकमेल\n'
        '• बैंक फ्रॉड\n'
        '• फर्जी कॉल\n\n'
        'बस अपनी समस्या लिखें और मैं गाइड करूँगा!'
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ===== UTILITY FUNCTIONS =====
  String getQuickReplyText(Map<String, dynamic> reply) {
    return _currentLanguage == 'hi' ? reply['hi']! : reply['en']!;
  }

  String getQuickReplyAction(Map<String, dynamic> reply) {
    return reply['action'] ?? '';
  }

  String getQuickReplyPriority(Map<String, dynamic> reply) {
    return reply['priority'] ?? 'low';
  }
  
  String getQuickReplyDesc(Map<String, dynamic> reply) {
    return reply['desc'] ?? '';
  }

  void clearChat() {
    _messages.clear();
    _addWelcomeMessage();
    _saveChatHistory();
    _conversationMemory.clear();
    _lastTopics.clear();
    notifyListeners();
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = _messages.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList('chat_history', messagesJson);
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getStringList('chat_history');
    if (messagesJson != null) {
      _messages = messagesJson
          .map((m) => Message.fromJson(jsonDecode(m)))
          .toList();
    }
  }

  void incrementUnread() {
    _unreadCount++;
    notifyListeners();
  }

  void resetUnread() {
    _unreadCount = 0;
    notifyListeners();
  }
}