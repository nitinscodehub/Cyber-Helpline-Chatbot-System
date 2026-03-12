import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/theme_provider.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  bool _isEditing = false;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser != null) {
      _nameController.text = userProvider.currentUser!.name;
      _phoneController.text = userProvider.currentUser!.phone;
      _emailController.text = userProvider.currentUser!.email;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  void _saveProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser != null) {
      final updatedUser = userProvider.currentUser!.copyWith(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
      );
      await userProvider.updateUser(updatedUser);
    }
    
    setState(() {
      _isEditing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile updated successfully!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showImagePickerDialog() {
    final isHindi = Provider.of<ChatProvider>(context, listen: false).currentLanguage == 'hi';
    
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
              leading: const Icon(Icons.photo_library),
              title: Text(isHindi ? 'गैलरी से चुनें' : 'Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(isHindi ? 'कैमरा से लें' : 'Take from Camera'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isHindi = chatProvider.currentLanguage == 'hi';
    final user = userProvider.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isHindi ? 'प्रोफाइल' : 'Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile header
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? Text(
                              user?.name.isNotEmpty == true
                                  ? user!.name[0].toUpperCase()
                                  : 'U',
                              style: GoogleFonts.poppins(
                                fontSize: 40,
                                color: Colors.blue,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          onPressed: _showImagePickerDialog,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (!_isEditing)
                  Text(
                    user?.name ?? 'User',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (!_isEditing)
                  Text(
                    user?.email ?? 'user@example.com',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            children: [
              _buildStatCard(
                Icons.shield,
                '${user?.safetyScore ?? 100}',
                isHindi ? 'सुरक्षा स्कोर' : 'Safety Score',
                Colors.green,
              ),
              _buildStatCard(
                Icons.chat,
                '${user?.totalChats ?? 0}',
                isHindi ? 'चैट' : 'Chats',
                Colors.blue,
              ),
              _buildStatCard(
                Icons.description,
                '${user?.totalComplaints ?? 0}',
                isHindi ? 'शिकायतें' : 'Complaints',
                Colors.orange,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Profile info
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHindi ? 'व्यक्तिगत जानकारी' : 'Personal Information',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_isEditing) ...[
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: isHindi ? 'नाम' : 'Name',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: isHindi ? 'फोन' : 'Phone',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ] else ...[
                    _buildInfoRow(Icons.person, isHindi ? 'नाम' : 'Name', user?.name ?? 'User'),
                    _buildInfoRow(Icons.phone, isHindi ? 'फोन' : 'Phone', user?.phone ?? '+91 98765 43210'),
                    _buildInfoRow(Icons.email, 'Email', user?.email ?? 'user@example.com'),
                    _buildInfoRow(Icons.calendar_today, isHindi ? 'सदस्य since' : 'Member since', 
                        _formatDate(user?.createdAt ?? DateTime.now())),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Account stats
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHindi ? 'खाता जानकारी' : 'Account Info',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(Icons.history, isHindi ? 'कुल चैट' : 'Total chats', '${user?.totalChats ?? 0}'),
                  _buildStatRow(Icons.warning, isHindi ? 'शिकायतें' : 'Complaints', '${user?.totalComplaints ?? 0}'),
                  _buildStatRow(Icons.notifications, isHindi ? 'नोटिफिकेशन' : 'Notifications', 
                      '${notificationProvider.unreadCount} ${isHindi ? 'नए' : 'new'}'),
                  _buildStatRow(Icons.shield, isHindi ? 'सुरक्षा स्कोर' : 'Safety Score', '${user?.safetyScore ?? 100}%'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Security settings
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHindi ? 'सुरक्षा सेटिंग्स' : 'Security',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Two-Factor Authentication'),
                    value: true,
                    onChanged: (value) {},
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.lock, color: Colors.green.shade700),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Biometric Login'),
                    value: false,
                    onChanged: (value) {},
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.fingerprint, color: Colors.blue.shade700),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.password, color: Colors.orange.shade700),
                    ),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      _showChangePasswordDialog(context, isHindi);
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // App settings
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHindi ? 'ऐप सेटिंग्स' : 'App Settings',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.language, color: Colors.purple.shade700),
                    ),
                    title: Text(isHindi ? 'भाषा' : 'Language'),
                    subtitle: Text(isHindi ? 'हिंदी' : 'English'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      _showLanguageDialog(context, chatProvider);
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? Colors.grey.shade800
                            : Colors.amber.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.amber.shade700,
                      ),
                    ),
                    title: Text(isHindi ? 'थीम' : 'Theme'),
                    subtitle: Text(
                      themeProvider.isDarkMode
                          ? (isHindi ? 'डार्क' : 'Dark')
                          : (isHindi ? 'लाइट' : 'Light'),
                    ),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme(value);
                      },
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Logout button
          OutlinedButton.icon(
            onPressed: () {
              _showLogoutDialog(context, isHindi);
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: Text(
              isHindi ? 'लॉग आउट' : 'Logout',
              style: const TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: color.withAlpha(179),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 16),
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showChangePasswordDialog(BuildContext context, bool isHindi) {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isHindi ? 'पासवर्ड बदलें' : 'Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassController,
              decoration: InputDecoration(
                labelText: isHindi ? 'पुराना पासवर्ड' : 'Current Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassController,
              decoration: InputDecoration(
                labelText: isHindi ? 'नया पासवर्ड' : 'New Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPassController,
              decoration: InputDecoration(
                labelText: isHindi ? 'पुष्टि करें' : 'Confirm Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isHindi ? 'पासवर्ड बदल दिया गया' : 'Password changed'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              isHindi ? 'बदलें' : 'Change',
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, ChatProvider chatProvider) {
    final isHindi = chatProvider.currentLanguage == 'hi';
    
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

  void _showLogoutDialog(BuildContext context, bool isHindi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isHindi ? 'लॉग आउट' : 'Logout'),
        content: Text(isHindi ? 'क्या आप लॉग आउट करना चाहते हैं?' : 'Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              await userProvider.logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
            child: Text(
              isHindi ? 'लॉग आउट' : 'Logout',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}