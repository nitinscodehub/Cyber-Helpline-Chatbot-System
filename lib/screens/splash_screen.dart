import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/user_provider.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );
    
    _rotateAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    _controller.forward();
  }

  Future<void> _initializeApp() async {
    // Initialize providers - FIXED: using public methods now
    await Future.wait([
      Provider.of<ChatProvider>(context, listen: false).loadData(),  // ← FIXED: _loadData → loadData
      Provider.of<ThemeProvider>(context, listen: false).loadTheme(),  // ← FIXED: _loadTheme → loadTheme
      Provider.of<NotificationProvider>(context, listen: false).loadNotifications(),  // ← FIXED: _loadNotifications → loadNotifications
      Provider.of<UserProvider>(context, listen: false).loadUser(),
    ]);

    // Check first launch
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('onboarding_completed') != true;

    // Navigate after delay
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    if (isFirstLaunch) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const OnboardingScreen(),
          transitionsBuilder: (_, a, __, c) => 
              FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } else {
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
              Colors.blue.shade500,
              Colors.blue.shade300,
            ],
            stops: const [0.1, 0.3, 0.7, 0.9],
          ),
        ),
        child: Stack(
          children: [
            // Animated background circles
            ..._buildBackgroundCircles(size),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with complex animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(51),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: Colors.blue.shade200.withAlpha(102),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Rotating outer ring
                            RotationTransition(
                              turns: _rotateAnimation,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.blue.shade300,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                            // Main icon
                            SpinPerfect(
                              infinite: true,
                              duration: const Duration(seconds: 10),
                              child: Icon(
                                Icons.security_rounded,
                                size: 70,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            // Pulse effect
                            Pulse(
                              infinite: true,
                              duration: const Duration(seconds: 2),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withAlpha(77),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // App name with gradient
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Colors.white, Colors.blue.shade100],
                      ).createShader(bounds),
                      child: Text(
                        'Cyber Helpline',
                        style: GoogleFonts.poppins(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withAlpha(51),
                              blurRadius: 10,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tagline
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(26),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withAlpha(77),
                        ),
                      ),
                      child: Text(
                        'आपकी 24/7 साइबर सुरक्षा साथी',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Loading indicator
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer circle
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: const Duration(seconds: 2),
                                curve: Curves.linear,
                                builder: (context, double value, child) {
                                  return CustomPaint(
                                    size: const Size(50, 50),
                                    painter: _CirclePainter(
                                      progress: value,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                              // Inner dot
                              Pulse(
                                infinite: true,
                                duration: const Duration(seconds: 1),
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withAlpha(179),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Loading text with dots animation
                        TweenAnimationBuilder(
                          tween: Tween<int>(begin: 0, end: 3),
                          duration: const Duration(seconds: 2),
                          builder: (context, int dots, child) {
                            return Text(
                              'सुरक्षित कनेक्शन स्थापित हो रहा है${'.' * dots}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withAlpha(230),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Version number at bottom
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'v1.0.0 | सुरक्षित • भरोसेमंद • तेज',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withAlpha(179),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundCircles(Size size) {
    return [
      Positioned(
        top: -size.width * 0.3,
        right: -size.width * 0.2,
        child: Container(
          width: size.width * 0.8,
          height: size.width * 0.8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withAlpha(13),
          ),
        ),
      ),
      Positioned(
        bottom: -size.width * 0.3,
        left: -size.width * 0.2,
        child: Container(
          width: size.width * 0.8,
          height: size.width * 0.8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withAlpha(26),
          ),
        ),
      ),
      Positioned(
        top: size.height * 0.2,
        left: -30,
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(seconds: 3),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(26),
                ),
              ),
            );
          },
        ),
      ),
      Positioned(
        bottom: size.height * 0.3,
        right: -20,
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(seconds: 3),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(26),
                ),
              ),
            );
          },
        ),
      ),
    ];
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  _CirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(51)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw background circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    // Draw progress circle
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ),
      -90 * (3.14159 / 180),
      360 * progress * (3.14159 / 180),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}