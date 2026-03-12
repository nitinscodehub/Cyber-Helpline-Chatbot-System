import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      icon: Icons.security_rounded,
      title: 'साइबर सुरक्षा आपकी मुट्ठी में',
      description: '24/7 साइबर हेल्पलाइन चैटबॉट से जुड़ें और सुरक्षित रहें। कोई भी समस्या हो, हम हैं आपके साथ।',
      color: Colors.blue,
      image: '🔒',
    ),
    OnboardingItem(
      icon: Icons.chat_rounded,
      title: 'तुरंत मदद पाएं',
      description: 'अपनी समस्या हिंदी, इंग्लिश या हिंग्लिश में बताएं। हमारा AI चैटबॉट तुरंत समाधान देगा।',
      color: Colors.green,
      image: '💬',
    ),
    OnboardingItem(
      icon: Icons.warning_amber_rounded,
      title: 'आपातकालीन सहायता',
      description: 'गंभीर मामलों में तुरंत 1930 पर कॉल करें। 24/7 इमरजेंसी हेल्पलाइन उपलब्ध।',
      color: Colors.red,
      image: '🚨',
    ),
    OnboardingItem(
      icon: Icons.description_rounded,
      title: 'शिकायत दर्ज करें',
      description: 'साइबर क्राइम की शिकायत ऑनलाइन दर्ज करें। फोटो, स्क्रीनशॉट अटैच करें।',
      color: Colors.orange,
      image: '📝',
    ),
    OnboardingItem(
      icon: Icons.workspace_premium_rounded,
      title: 'सुरक्षित रहें, जागरूक रहें',
      description: 'साइबर फ्रॉड से बचने के टिप्स, नए अलर्ट और सुरक्षा गाइड पाएं।',
      color: Colors.purple,
      image: '🏆',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.white,
                ],
              ),
            ),
          ),
          
          // PageView
          PageView.builder(
            controller: _pageController,
            itemCount: _items.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _buildOnboardingPage(_items[index], index);
            },
          ),

          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child: FadeInDown(
              delay: const Duration(milliseconds: 500),
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  'Skip',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Bottom section
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Page indicators
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _items.length,
                      (index) => _buildPageIndicator(index),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Next/Get Started button
                FadeInUp(
                  delay: const Duration(milliseconds: 700),
                  child: ElevatedButton(
                    onPressed: _currentPage == _items.length - 1
                        ? _completeOnboarding
                        : _nextPage,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: _items[_currentPage].color,
                      foregroundColor: Colors.white,
                      elevation: 5,
                    ),
                    child: Text(
                      _currentPage == _items.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Already have account
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      GestureDetector(
                        onTap: _completeOnboarding,
                        child: Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item, int index) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large emoji/image
          BounceInDown(
            delay: Duration(milliseconds: 100 * index),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: item.color.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Text(
                item.image,
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Title
          BounceInLeft(
            delay: Duration(milliseconds: 200 * index),
            child: Text(
              item.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: item.color,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Description
          BounceInRight(
            delay: Duration(milliseconds: 300 * index),
            child: Text(
              item.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Feature list
          if (index == 0) _buildFeatureList(),
          if (index == 1) _buildChatFeature(),
          if (index == 2) _buildEmergencyFeature(),
          if (index == 3) _buildComplaintFeature(),
          if (index == 4) _buildSafetyFeature(),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    return Column(
      children: [
        _buildFeatureChip('UPI Fraud Help', Icons.payment, Colors.blue),
        const SizedBox(height: 10),
        _buildFeatureChip('Hacked Account Recovery', Icons.lock, Colors.green),
        const SizedBox(height: 10),
        _buildFeatureChip('Phishing Alerts', Icons.warning, Colors.orange),
      ],
    );
  }

  Widget _buildChatFeature() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(26),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.translate, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            'हिंदी • English • Hinglish',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyFeature() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(26),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, color: Colors.red),
          const SizedBox(width: 8),
          Text(
            '24/7 Emergency Support',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintFeature() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(26),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.attach_file, color: Colors.orange),
          const SizedBox(width: 8),
          Text(
            'Attach Screenshots & Evidence',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyFeature() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.purple.withAlpha(26),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_active, color: Colors.purple),
          const SizedBox(width: 8),
          Text(
            'Real-time Cyber Alerts',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Colors.purple.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: _currentPage == index
            ? _items[index].color
            : Colors.grey.withAlpha(102),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, a, __, c) => 
            FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }
}

class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String image;

  OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.image,
  });
}