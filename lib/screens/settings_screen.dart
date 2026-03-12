import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/user_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isHindi = chatProvider.currentLanguage == 'hi';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isHindi ? 'सेटिंग्स' : 'Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance
          _buildSection(
            context,
            isHindi ? 'दिखावट' : 'Appearance',
            [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.blue,
                  ),
                ),
                title: Text(isHindi ? 'डार्क मोड' : 'Dark Mode'),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.color_lens, color: Colors.green),
                ),
                title: Text(isHindi ? 'थीम कलर' : 'Theme Color'),
                subtitle: Text(_getColorName(themeProvider.primaryColor, isHindi)),
                trailing: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: themeProvider.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: () {
                  _showColorPicker(context, themeProvider, isHindi);
                },
              ),
              SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.design_services, color: Colors.purple), // ← FIXED: Icons.material → Icons.design_services
                ),
                title: Text(isHindi ? 'Material 3' : 'Material 3 Design'),
                value: themeProvider.useMaterial3,
                onChanged: (value) {
                  themeProvider.toggleMaterial3();
                },
              ),
            ],
          ),

          // Language
          _buildSection(
            context,
            isHindi ? 'भाषा' : 'Language',
            [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.language, color: Colors.orange),
                ),
                title: Text(isHindi ? 'भाषा' : 'Language'),
                subtitle: Text(chatProvider.currentLanguage == 'hi' ? 'हिंदी' : 'English'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showLanguageDialog(context, chatProvider, isHindi);
                },
              ),
            ],
          ),

          // Notifications
          _buildSection(
            context,
            isHindi ? 'सूचनाएं' : 'Notifications',
            [
              SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.notifications, color: Colors.purple),
                ),
                title: Text(isHindi ? 'पुश नोटिफिकेशन' : 'Push Notifications'),
                value: true,
                onChanged: (value) {},
              ),
              SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.warning, color: Colors.red),
                ),
                title: Text(isHindi ? 'आपातकालीन अलर्ट' : 'Emergency Alerts'),
                value: true,
                onChanged: (value) {},
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.cyan.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.history, color: Colors.cyan),
                ),
                title: Text(isHindi ? 'नोटिफिकेशन इतिहास' : 'Notification History'),
                trailing: Text(
                  '${notificationProvider.notifications.length}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  // Show notification history
                },
              ),
            ],
          ),

          // Privacy
          _buildSection(
            context,
            isHindi ? 'गोपनीयता' : 'Privacy',
            [
              SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.history, color: Colors.teal),
                ),
                title: Text(isHindi ? 'चैट हिस्ट्री सेव करें' : 'Save Chat History'),
                value: true,
                onChanged: (value) {},
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                title: Text(isHindi ? 'डेटा मिटाएं' : 'Delete Data'),
                subtitle: Text(isHindi ? 'सारी हिस्ट्री डिलीट करें' : 'Delete all history'),
                onTap: () {
                  _showDeleteDialog(context, isHindi);
                },
              ),
            ],
          ),

          // Support
          _buildSection(
            context,
            isHindi ? 'सहायता' : 'Support',
            [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.help, color: Colors.indigo),
                ),
                title: Text(isHindi ? 'सहायता केंद्र' : 'Help Center'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.feedback, color: Colors.amber),
                ),
                title: Text(isHindi ? 'सुझाव दें' : 'Give Feedback'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.star, color: Colors.green),
                ),
                title: Text(isHindi ? 'रेट करें' : 'Rate Us'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ],
          ),

          // About
          _buildSection(
            context,
            isHindi ? 'जानकारी' : 'About',
            [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.info, color: Colors.blueGrey),
                ),
                title: Text(isHindi ? 'ऐप वर्जन' : 'App Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.security, color: Colors.pink),
                ),
                title: Text(isHindi ? 'सुरक्षा नीति' : 'Privacy Policy'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.description, color: Colors.deepPurple),
                ),
                title: Text(isHindi ? 'नियम और शर्तें' : 'Terms & Conditions'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ],
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(children: children),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  String _getColorName(Color color, bool isHindi) {
    if (color == Colors.blue) return isHindi ? 'नीला' : 'Blue';
    if (color == Colors.green) return isHindi ? 'हरा' : 'Green';
    if (color == Colors.orange) return isHindi ? 'नारंगी' : 'Orange';
    if (color == Colors.purple) return isHindi ? 'बैंगनी' : 'Purple';
    if (color == Colors.red) return isHindi ? 'लाल' : 'Red';
    if (color == Colors.teal) return isHindi ? 'टील' : 'Teal';
    return isHindi ? 'नीला' : 'Blue';
  }

  void _showColorPicker(BuildContext context, ThemeProvider themeProvider, bool isHindi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isHindi ? 'थीम कलर चुनें' : 'Choose Theme Color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildColorOption(context, themeProvider, Colors.blue, isHindi ? 'नीला' : 'Blue'),
            _buildColorOption(context, themeProvider, Colors.green, isHindi ? 'हरा' : 'Green'),
            _buildColorOption(context, themeProvider, Colors.orange, isHindi ? 'नारंगी' : 'Orange'),
            _buildColorOption(context, themeProvider, Colors.purple, isHindi ? 'बैंगनी' : 'Purple'),
            _buildColorOption(context, themeProvider, Colors.red, isHindi ? 'लाल' : 'Red'),
            _buildColorOption(context, themeProvider, Colors.teal, isHindi ? 'टील' : 'Teal'),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(BuildContext context, ThemeProvider themeProvider, Color color, String name) {
    return InkWell(
      onTap: () {
        themeProvider.setPrimaryColor(color);
        Navigator.pop(context);
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: themeProvider.primaryColor == color ? Colors.white : Colors.transparent,
            width: 3,
          ),
        ),
        child: Center(
          child: Text(
            name[0],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, ChatProvider chatProvider, bool isHindi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isHindi ? 'भाषा चुनें' : 'Select Language'),
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

  void _showDeleteDialog(BuildContext context, bool isHindi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isHindi ? 'डेटा मिटाएं' : 'Delete Data'),
        content: Text(isHindi 
            ? 'क्या आप सारा डेटा डिलीट करना चाहते हैं? यह क्रिया वापस नहीं की जा सकती।'
            : 'Are you sure you want to delete all data? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Delete data logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isHindi ? 'डेटा मिटा दिया गया' : 'Data deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              isHindi ? 'मिटाएं' : 'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}