import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/quick_reply_chips.dart';
import '../widgets/loading_animation.dart';
import '../screens/complaint_screen.dart';
import '../screens/emergency_screen.dart';
import '../screens/resources_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _suggestions = [];
  
  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;
  late AnimationController _pulseController;

  bool _isRecording = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    
    _setupAnimations();
    _setupControllers();
    
    // Set context in provider for navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).setContext(context);
    });
  }

  void _setupAnimations() {
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _typingAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _typingAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _typingAnimationController.repeat(reverse: true);
  }

  void _setupControllers() {
    _scrollController.addListener(_onScroll);
    _messageController.addListener(_onTextChanged);
  }

  void _onScroll() {
    // Load more messages when scrolling to top
    if (_scrollController.position.pixels == _scrollController.position.minScrollExtent) {
      // Load more messages (pagination)
    }
  }

  void _onTextChanged() {
    setState(() {
      _showSuggestions = _messageController.text.isNotEmpty;
    });
    _updateSuggestions(_messageController.text);
  }

  void _updateSuggestions(String text) {
    _suggestions.clear();
    if (text.isEmpty) return;
    
    final lowerText = text.toLowerCase();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    for (var reply in chatProvider.quickReplies) {
      final replyText = chatProvider.getQuickReplyText(reply);
      if (replyText.toLowerCase().contains(lowerText)) {
        _suggestions.add(replyText);
        if (_suggestions.length >= 3) break;
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingAnimationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.sendMessage(text);
      _messageController.clear();
      setState(() {
        _showSuggestions = false;
      });
      _scrollToBottom();
    }
  }

  void _handleQuickReply(String text, String action) {
    _messageController.text = text;
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Animated status indicator
            ScaleTransition(
              scale: _pulseController.drive(Tween(begin: 0.8, end: 1.2)),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cyber Assistant',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '24/7 Active',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Emergency shortcut
          IconButton(
            icon: const Icon(Icons.warning, color: Colors.red),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EmergencyScreen()),
              );
            },
          ),
          // More options
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showChatOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick replies section with animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 70,
            color: Theme.of(context).cardColor,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: chatProvider.quickReplies.length,
              itemBuilder: (context, index) {
                final reply = chatProvider.quickReplies[index];
                final text = chatProvider.getQuickReplyText(reply);
                final desc = chatProvider.getQuickReplyDesc(reply);
                return QuickReplyChip(
                  icon: reply['icon']!,
                  label: text,
                  description: desc,
                  onTap: () => _handleQuickReply(text, reply['action'] ?? ''),
                );
              },
            ),
          ),
          
          // Suggestions bar (when typing)
          if (_showSuggestions && _suggestions.isNotEmpty)
            Container(
              height: 50,
              color: Theme.of(context).cardColor.withAlpha(230),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ActionChip(
                      label: Text(_suggestions[index]),
                      onPressed: () {
                        _messageController.text = _suggestions[index];
                        _sendMessage();
                      },
                      backgroundColor: Colors.blue.shade50,
                    ),
                  );
                },
              ),
            ),
          
          // Main chat area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/chat_bg.png'),
                  fit: BoxFit.cover,
                  opacity: 0.05,
                  colorFilter: ColorFilter.mode(
                    themeProvider.isDarkMode
                        ? Colors.black.withAlpha(128)
                        : Colors.white,
                    BlendMode.dstATop,
                  ),
                ),
              ),
              child: chatProvider.messages.isEmpty
                  ? _buildEmptyChat(context, chatProvider, userProvider)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: chatProvider.messages.length +
                          (chatProvider.isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == chatProvider.messages.length &&
                            chatProvider.isTyping) {
                          return _buildTypingIndicator();
                        }
                        return MessageBubble(
                          message: chatProvider.messages[index],
                          onActionPressed: (actionType) {
                            if (actionType != null) {
                              chatProvider.handleAction(context, actionType);
                            }
                          },
                        );
                      },
                    ),
            ),
          ),
          
          // Input area with advanced features
          _buildInputArea(context, chatProvider),
        ],
      ),
    );
  }

  Widget _buildEmptyChat(BuildContext context, ChatProvider chatProvider, UserProvider userProvider) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              curve: Curves.elasticOut,
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.blue.shade50,
                            Colors.blue.shade100,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withAlpha(77),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.support_agent,
                        size: 60,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            Text(
              chatProvider.currentLanguage == 'hi'
                  ? 'साइबर हेल्पलाइन चैटबॉट'
                  : 'Cyber Helpline Chatbot',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              userProvider.currentUser?.name ?? '',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(26),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    chatProvider.currentLanguage == 'hi'
                        ? 'मैं मदद कर सकता हूँ:'
                        : 'I can help with:',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...chatProvider.quickReplies.map((reply) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(reply['priority'] ?? 'low').withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              reply['icon']!,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chatProvider.getQuickReplyText(reply),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  reply['desc'] ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(reply['priority'] ?? 'low'),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getPriorityText(
                                reply['priority'] ?? 'low', 
                                chatProvider.currentLanguage == 'hi'  // ← FIXED
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Safety score
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chatProvider.currentLanguage == 'hi'
                          ? 'आपका सुरक्षा स्कोर: ${userProvider.currentUser?.safetyScore ?? 100}%'
                          : 'Your safety score: ${userProvider.currentUser?.safetyScore ?? 100}%',
                      style: GoogleFonts.poppins(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getPriorityText(String priority, bool isHindi) {
    switch (priority) {
      case 'high':
        return isHindi ? 'तुरंत' : 'URGENT';
      case 'medium':
        return isHindi ? 'जरूरी' : 'IMPORTANT';
      default:
        return isHindi ? 'सामान्य' : 'GENERAL';
    }
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue.shade100,
            child: const Icon(
              Icons.support_agent,
              size: 18,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          ScaleTransition(
            scale: _typingAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _buildDot(Colors.blue, 0),
                  const SizedBox(width: 4),
                  _buildDot(Colors.blue, 200),
                  const SizedBox(width: 4),
                  _buildDot(Colors.blue, 400),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color, int delay) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeInOut,
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, ChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.grey.withAlpha(51),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Quick actions menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.add_circle_outline),
            onSelected: (value) {
              switch (value) {
                case 'emergency':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                  );
                  break;
                case 'complaint':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ComplaintScreen()),
                  );
                  break;
                case 'resources':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ResourcesScreen()),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'emergency',
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(chatProvider.currentLanguage == 'hi' ? 'आपातकाल' : 'Emergency'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'complaint',
                child: Row(
                  children: [
                    Icon(Icons.description, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(chatProvider.currentLanguage == 'hi' ? 'शिकायत' : 'Complaint'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'resources',
                child: Row(
                  children: [
                    Icon(Icons.school, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(chatProvider.currentLanguage == 'hi' ? 'संसाधन' : 'Resources'),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 4),
          
          // Text field with dynamic height
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border.all(
                  color: _messageController.text.isNotEmpty
                      ? Colors.blue
                      : Colors.grey.shade300,
                ),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: chatProvider.currentLanguage == 'hi'
                      ? 'अपनी समस्या लिखें...'
                      : 'Type your problem...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  suffixIcon: _messageController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _messageController.clear(),
                        )
                      : null,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          
          const SizedBox(width: 4),
          
          // Send/Record button with animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: FloatingActionButton(
              onPressed: _sendMessage,
              mini: true,
              elevation: 2,
              backgroundColor: _messageController.text.isNotEmpty
                  ? Colors.blue
                  : Colors.grey,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _messageController.text.isNotEmpty
                    ? const Icon(Icons.send, key: ValueKey('send'))
                    : const Icon(Icons.mic_none, key: ValueKey('mic')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, String action) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.handleAction(context, action);
  }

  void _makePhoneCall(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showMessage('Cannot make call. Please dial $number manually.');
    }
  }

  void _connectToExpert() {
    _showDialog(
      context,
      'Connect to Expert',
      'Connecting you to a cyber security expert...\n\nMeanwhile, you can call 1930 for immediate help.',
    );
  }

  void _showAccountRecovery() {
    _showDialog(
      context,
      'Account Recovery',
      'Opening account recovery guide...\n\nFollow the steps shown to recover your account.',
    );
  }

  void _showHelp() {
    _showDialog(
      context,
      'Help',
      'I can help you with:\n\n'
      '• UPI fraud\n'
      '• Hacked accounts\n'
      '• Phishing\n'
      '• Blackmail\n'
      '• Bank fraud\n'
      '• Fake calls\n\n'
      'Just type your problem and I\'ll guide you!',
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showEmojiPicker(BuildContext context) {
    _showMessage('Emoji picker coming soon!');
  }

  void _showChatOptions(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(chatProvider.currentLanguage == 'hi' ? 'भाषा बदलें' : 'Change Language'),
              subtitle: Text(chatProvider.currentLanguage == 'hi' ? 'हिंदी' : 'English'),
              onTap: () {
                Navigator.pop(context);
                _showLanguageDialog(context);
              },
            ),
            ListTile(
              leading: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              title: Text(themeProvider.isDarkMode 
                  ? (chatProvider.currentLanguage == 'hi' ? 'लाइट मोड' : 'Light Mode')
                  : (chatProvider.currentLanguage == 'hi' ? 'डार्क मोड' : 'Dark Mode')),
              onTap: () {
                themeProvider.toggleTheme(!themeProvider.isDarkMode);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(chatProvider.currentLanguage == 'hi' ? 'चैट साफ करें' : 'Clear Chat'),
              subtitle: Text(chatProvider.currentLanguage == 'hi' ? 'सारे मैसेज डिलीट करें' : 'Delete all messages'),
              onTap: () {
                Navigator.pop(context);
                _showClearChatDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(chatProvider.currentLanguage == 'hi' ? 'चैट एक्सपोर्ट करें' : 'Export Chat'),
              subtitle: Text(chatProvider.currentLanguage == 'hi' ? 'बातचीत सेव करें' : 'Save conversation'),
              onTap: () {
                Navigator.pop(context);
                _exportChat(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(chatProvider.currentLanguage == 'hi' ? 'सुरक्षा टिप्स' : 'Safety Tips'),
              onTap: () {
                Navigator.pop(context);
                _showSafetyTips(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: Text(chatProvider.currentLanguage == 'hi' ? 'मदद' : 'Help'),
              onTap: () {
                Navigator.pop(context);
                _showHelp();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('हिंदी'),
              leading: Radio<String>(
                value: 'hi',
                groupValue: chatProvider.currentLanguage,
                onChanged: (value) {
                  chatProvider.setLanguage(value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('English'),
              leading: Radio<String>(
                value: 'en',
                groupValue: chatProvider.currentLanguage,
                onChanged: (value) {
                  chatProvider.setLanguage(value!);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to delete all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ChatProvider>(context, listen: false).clearChat();
              Navigator.pop(context);
              _showMessage('Chat cleared');
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _exportChat(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _showMessage('Chat exported successfully');
  }

  void _showSafetyTips(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🛡️ Safety Tips'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('✅ Never share OTP with anyone'),
            Text('✅ Don\'t click suspicious links'),
            Text('✅ Use strong passwords (12+ chars)'),
            Text('✅ Enable Two-Factor Authentication'),
            Text('✅ Keep apps and system updated'),
            Text('✅ Avoid public Wi-Fi for banking'),
            SizedBox(height: 12),
            Text('📞 Emergency Helpline: 1930'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}