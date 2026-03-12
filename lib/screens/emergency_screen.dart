import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/chat_provider.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final List<String> _recentNumbers = [];

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
        setState(() {
          if (!_recentNumbers.contains(phoneNumber)) {
            _recentNumbers.insert(0, phoneNumber);
            if (_recentNumbers.length > 5) _recentNumbers.removeLast();
          }
        });
      } else {
        _showErrorDialog('Cannot make call', 'Please dial $phoneNumber manually');
      }
    } catch (e) {
      _showErrorDialog('Error', 'Could not make the call');
    }
  }

  void _showErrorDialog(String title, String message) {
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

  void _copyToClipboard(String text) {
    // Copy to clipboard implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $text'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final isHindi = chatProvider.currentLanguage == 'hi';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isHindi ? 'आपातकालीन संपर्क' : 'Emergency Contacts',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade700,
              Colors.red.shade600,
              Colors.red.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Emergency Header
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withAlpha(77),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 60,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isHindi ? 'आपातकाल' : 'EMERGENCY',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isHindi
                              ? 'तुरंत कॉल करें - 24x7 मुफ्त सेवा'
                              : 'Call immediately - 24x7 Free Service',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withAlpha(230),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Main Emergency Numbers
                _buildEmergencyCard(
                  number: '1930',
                  title: isHindi ? 'साइबर क्राइम हेल्पलाइन' : 'Cyber Crime Helpline',
                  description: isHindi ? '24x7 राष्ट्रीय हेल्पलाइन' : '24x7 National Helpline',
                  icon: Icons.security,
                  color: Colors.blue,
                  gradient: const [Color(0xFF2196F3), Color(0xFF1976D2)],
                ),
                
                const SizedBox(height: 12),
                
                _buildEmergencyCard(
                  number: '112',
                  title: isHindi ? 'राष्ट्रीय आपातकालीन नंबर' : 'National Emergency Number',
                  description: isHindi ? 'पुलिस, एम्बुलेंस, फायर' : 'Police, Ambulance, Fire',
                  icon: Icons.local_police,
                  color: Colors.red,
                  gradient: const [Color(0xFFF44336), Color(0xFFD32F2F)],
                ),
                
                const SizedBox(height: 12),
                
                _buildEmergencyCard(
                  number: '181',
                  title: isHindi ? 'महिला हेल्पलाइन' : 'Women Helpline',
                  description: isHindi ? 'महिला सुरक्षा हेल्पलाइन' : 'Women Safety Helpline',
                  icon: Icons.female,
                  color: Colors.purple,
                  gradient: const [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                ),
                
                const SizedBox(height: 12),
                
                _buildEmergencyCard(
                  number: '1098',
                  title: isHindi ? 'बाल हेल्पलाइन' : 'Child Helpline',
                  description: isHindi ? 'बाल संरक्षण हेल्पलाइन' : 'Child Protection Helpline',
                  icon: Icons.child_care,
                  color: Colors.green,
                  gradient: const [Color(0xFF4CAF50), Color(0xFF388E3C)],
                ),
                
                const SizedBox(height: 12),
                
                _buildEmergencyCard(
                  number: '108',
                  title: isHindi ? 'एम्बुलेंस सेवा' : 'Ambulance Service',
                  description: isHindi ? 'आपातकालीन एम्बुलेंस' : 'Emergency Ambulance',
                  icon: Icons.local_hospital,
                  color: Colors.orange,
                  gradient: const [Color(0xFFFF9800), Color(0xFFF57C00)],
                ),
                
                const SizedBox(height: 24),
                
                // Bank Helplines Section
                _buildSectionHeader(context, isHindi ? 'बैंक हेल्पलाइन' : 'Bank Helplines'),
                
                const SizedBox(height: 12),
                
                _buildBankHelpline('State Bank of India', '1800 1234'),
                _buildBankHelpline('HDFC Bank', '1800 2583'),
                _buildBankHelpline('ICICI Bank', '1800 1080'),
                _buildBankHelpline('Axis Bank', '1800 2090'),
                _buildBankHelpline('Punjab National Bank', '1800 1800'),
                
                const SizedBox(height: 24),
                
                // Recent Calls Section
                if (_recentNumbers.isNotEmpty) ...[
                  _buildSectionHeader(context, isHindi ? 'हालिया कॉल' : 'Recent Calls'),
                  const SizedBox(height: 12),
                  ..._recentNumbers.map((number) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.history, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          number,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.call, color: Colors.white),
                          onPressed: () => _makePhoneCall(number),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),
                ],
                
                // Emergency Steps
                _buildEmergencySteps(context, isHindi),
                
                const SizedBox(height: 24),
                
                // Important Note
                _buildImportantNote(context, isHindi),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyCard({
    required String number,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(77),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _makePhoneCall(number),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                
                const SizedBox(width: 16),
                
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            number,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(51),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'FREE',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withAlpha(230),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Call button
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBankHelpline(String bankName, String number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white.withAlpha(51),
          child: const Icon(Icons.account_balance, color: Colors.white),
        ),
        title: Text(
          bankName,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          number,
          style: GoogleFonts.poppins(
            color: Colors.white.withAlpha(230),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.white),
              onPressed: () => _copyToClipboard(number),
            ),
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.white),
              onPressed: () => _makePhoneCall(number.replaceAll(' ', '')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEmergencySteps(BuildContext context, bool isHindi) {
    final steps = isHindi
        ? [
            'शांत रहें और घबराएँ नहीं',
            'तुरंत 1930 या 112 पर कॉल करें',
            'सारे सबूत सुरक्षित रखें',
            'बैंक को तुरंत सूचित करें',
            'परिवार या दोस्तों को बताएँ',
          ]
        : [
            'Stay calm and don\'t panic',
            'Call 1930 or 112 immediately',
            'Save all evidence',
            'Inform your bank immediately',
            'Tell family or friends',
          ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                isHindi ? 'आपातकाल में क्या करें?' : 'What to do in emergency?',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    steps[index],
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildImportantNote(BuildContext context, bool isHindi) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withAlpha(102)),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.amber.shade300),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isHindi
                  ? 'यह सेवा पूरी तरह मुफ्त है। किसी भी तरह का भुगतान न करें।'
                  : 'This service is completely free. Do not make any payment.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.amber.shade100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}