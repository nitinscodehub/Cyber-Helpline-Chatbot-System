import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/user_provider.dart';
import '../screens/emergency_screen.dart';
import '../screens/complaint_screen.dart';
import '../screens/resources_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/chat_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, a, __, c) => 
            FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isHindi = chatProvider.currentLanguage == 'hi';
    final user = userProvider.currentUser;
    
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            // Header with user info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade800,
                    Colors.blue.shade600,
                    Colors.blue.shade400,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withAlpha(77),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo and title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(26),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.security_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cyber Helpline',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                isHindi 
                                    ? 'आपकी सुरक्षा हमारी जिम्मेदारी'
                                    : 'Your safety is our responsibility',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.white.withAlpha(230),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // User info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          child: Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : 'U',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Guest User',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                user?.email ?? 'guest@example.com',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withAlpha(230),
                                ),
                                overflow: TextOverflow.ellipsis,
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
                            color: Colors.green.withAlpha(51),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.green.withAlpha(102),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.favorite,
                                color: Colors.green,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${user?.safetyScore ?? 100}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 8),
                  
                  // Main Menu
                  _buildDrawerSection(isHindi ? 'मुख्य मेनू' : 'MAIN MENU'),
                  
                  _buildDrawerItem(
                    icon: Icons.home_rounded,
                    title: isHindi ? 'होम' : 'Home',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.chat_rounded,
                    title: isHindi ? 'चैट' : 'Chat',
                    onTap: () => _navigateTo(context, const ChatScreen()),
                  ),
                  _buildDrawerItem(
                    icon: Icons.warning_rounded,
                    title: isHindi ? 'आपातकाल' : 'Emergency',
                    color: Colors.red,
                    badge: true,
                    onTap: () => _navigateTo(context, const EmergencyScreen()),
                  ),
                  _buildDrawerItem(
                    icon: Icons.description_rounded,
                    title: isHindi ? 'शिकायत दर्ज करें' : 'File Complaint',
                    onTap: () => _navigateTo(context, const ComplaintScreen()),
                  ),
                  _buildDrawerItem(
                    icon: Icons.school_rounded,
                    title: isHindi ? 'सुरक्षा संसाधन' : 'Resources',
                    onTap: () => _navigateTo(context, const ResourcesScreen()),
                  ),
                  
                  const Divider(height: 32),
                  
                  // Account
                  _buildDrawerSection(isHindi ? 'खाता' : 'ACCOUNT'),
                  
                  _buildDrawerItem(
                    icon: Icons.person_rounded,
                    title: isHindi ? 'प्रोफाइल' : 'Profile',
                    onTap: () => _navigateTo(context, const ProfileScreen()),
                  ),
                  _buildDrawerItem(
                    icon: themeProvider.isDarkMode 
                        ? Icons.light_mode_rounded 
                        : Icons.dark_mode_rounded,
                    title: themeProvider.isDarkMode 
                        ? (isHindi ? 'लाइट मोड' : 'Light Mode')
                        : (isHindi ? 'डार्क मोड' : 'Dark Mode'),
                    onTap: () {
                      themeProvider.toggleTheme(!themeProvider.isDarkMode);
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings_rounded,
                    title: isHindi ? 'सेटिंग्स' : 'Settings',
                    onTap: () => _navigateTo(context, const SettingsScreen()),
                  ),
                  _buildDrawerItem(
                    icon: Icons.notifications_rounded,
                    title: isHindi ? 'नोटिफिकेशन' : 'Notifications',
                    badgeCount: notificationProvider.unreadCount,
                    onTap: () {
                      Navigator.pop(context);
                      _showNotificationsDialog(context);
                    },
                  ),
                  
                  const Divider(height: 32),
                  
                  // Support
                  _buildDrawerSection(isHindi ? 'सहायता' : 'SUPPORT'),
                  
                  _buildDrawerItem(
                    icon: Icons.share_rounded,
                    title: isHindi ? 'शेयर करें' : 'Share App',
                    onTap: () {
                      Navigator.pop(context);
                      _showShareDialog(context, isHindi);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.star_rounded,
                    title: isHindi ? 'रेट करें' : 'Rate Us',
                    onTap: () {
                      Navigator.pop(context);
                      _showMessage(context, isHindi ? 'धन्यवाद! ⭐' : 'Thank you! ⭐');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.info_rounded,
                    title: isHindi ? 'हमारे बारे में' : 'About Us',
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog(context, isHindi);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.help_rounded,
                    title: isHindi ? 'मदद' : 'Help',
                    onTap: () {
                      Navigator.pop(context);
                      _showHelpDialog(context, isHindi);
                    },
                  ),
                ],
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    isHindi ? 'आपातकालीन हेल्पलाइन' : 'Emergency Helpline',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _navigateTo(context, const EmergencyScreen()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.phone, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '1930',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
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

  Widget _buildDrawerSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
    bool badge = false,
    int badgeCount = 0,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? Colors.blue).withAlpha(13),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color ?? Colors.blue,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: badgeCount > 0
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : badge
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final isHindi = Provider.of<ChatProvider>(context, listen: false).currentLanguage == 'hi';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isHindi ? '🔔 सूचनाएं' : '🔔 Notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.done_all),
                      onPressed: () {
                        notificationProvider.markAllAsRead();
                        Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep),
                      onPressed: () {
                        notificationProvider.clearAll();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: notificationProvider.notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_rounded,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isHindi ? 'कोई सूचना नहीं' : 'No notifications',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: notificationProvider.notifications.length,
                      itemBuilder: (context, index) {
                        final notif = notificationProvider.notifications[index];
                        return Dismissible(
                          key: Key(notif['id']),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            notificationProvider.deleteNotification(index);
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: (notif['color'] as Color).withAlpha(26),
                                child: Icon(
                                  notif['icon'] as IconData,
                                  color: notif['color'],
                                ),
                              ),
                              title: Text(
                                notif['title'],
                                style: GoogleFonts.poppins(
                                  fontWeight: notif['read'] == true 
                                      ? FontWeight.normal 
                                      : FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(notif['message']),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(notif['time']),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: notif['read'] == true 
                                  ? null 
                                  : Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                              onTap: () {
                                notificationProvider.markAsRead(index);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }

  void _showShareDialog(BuildContext context, bool isHindi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isHindi ? 'शेयर करें' : 'Share'),
        content: Text(
          isHindi 
              ? 'साइबर हेल्पलाइन ऐप शेयर करें अपने दोस्तों के साथ'
              : 'Share Cyber Helpline app with your friends',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isHindi ? 'बंद करें' : 'Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showMessage(context, isHindi ? 'शेयर विकल्प खुल रहा है...' : 'Opening share options...');
            },
            child: Text(isHindi ? 'शेयर करें' : 'Share'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isHindi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.security_rounded,
                size: 40,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isHindi ? 'हमारे बारे में' : 'About Us',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cyber Helpline Chatbot',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isHindi
                  ? 'आपका 24/7 AI-पावर्ड साइबर सुरक्षा सहायक। साइबर अपराध रिपोर्ट करें, तुरंत मदद पाएं, और ऑनलाइन सुरक्षित रहें।'
                  : 'Your 24/7 AI-powered cyber security assistant. Report cyber crimes, get instant help, and stay safe online.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isHindi ? 'ठीक है' : 'OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context, bool isHindi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isHindi ? '🆘 मदद' : '🆘 Help'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isHindi ? 'त्वरित सहायता:' : 'Quick Help:',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildHelpItem('📞', isHindi ? 'आपातकाल: 1930' : 'Emergency: 1930'),
            _buildHelpItem('💬', isHindi ? 'चैट से मदद लें' : 'Chat for help'),
            _buildHelpItem('📝', isHindi ? 'शिकायत दर्ज करें' : 'File complaint'),
            _buildHelpItem('📚', isHindi ? 'सुरक्षा गाइड पढ़ें' : 'Read safety guides'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isHindi ? 'बंद करें' : 'Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(emoji),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}