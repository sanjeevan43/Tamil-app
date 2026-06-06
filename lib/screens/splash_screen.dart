
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../services/auth_service.dart';
import '../providers/enhanced_progress_provider.dart';
import 'login_screen.dart';
import 'admin_control_screen.dart';
import 'teacher_dashboard_screen.dart';
import 'parent_dashboard_screen.dart';
import 'main_navigation_container.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    // Start initialization immediately
    _initialize();
  }

  Future<void> _initialize() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);

    // Run heavy initialization tasks in parallel with a safety timeout
    debugPrint('SplashScreen: Starting initialization...');
    try {
      await Future.wait([
        if (authService.isAuthenticated)
          progress.initializeProgress(uid: authService.user?.uid).then((_) => debugPrint('SplashScreen: Progress initialized')).catchError((e) => debugPrint('SplashScreen: Progress error: $e')),
        // Ensure at least 2 seconds for branding
        Future.delayed(const Duration(milliseconds: 2000)),
      ]).timeout(const Duration(seconds: 8)); // Safety timeout of 8 seconds
      debugPrint('SplashScreen: Initialization complete or timed out');
    } catch (e) {
      debugPrint('SplashScreen: Error during initialization: $e');
    }

    if (!mounted) return;

    Widget nextScreen;
    if (authService.isAuthenticated) {
      final role = authService.userRole;
      switch (role) {
        case 'admin':
          nextScreen = const AdminControlScreen();
          break;
        case 'teacher':
          nextScreen = TeacherDashboardScreen();
          break;
        case 'parent':
          nextScreen = const ParentDashboardScreen();
          break;
        default:
          nextScreen = const MainNavigationContainer();
      }
    } else {
      nextScreen = const LoginScreen();
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => nextScreen,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
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
    return Scaffold(
      body: Stack(
        children: [
          // Premium Gradient Background (Black to Deep Red)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.secondary, 
                    AppTheme.primaryDark,
                    AppTheme.primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          
          // Subtly Animated Topographic Elements (Abstract)
          ...List.generate(3, (index) => Positioned(
            top: index * 200.0 - 100,
            right: index.isEven ? -100 : null,
            left: index.isOdd ? -100 : null,
            child: _PulseCircle(
              width: 400,
              height: 400,
              controller: _controller,
              color: index == 0 ? AppTheme.white.withOpacity(0.05) : AppTheme.primary.withOpacity(0.08),
            ),
          )),

          // Main Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Container with Glass Effect
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_controller.value * 0.05),
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      width: 250,
                      height: 250,
                      decoration: AppTheme.whiteCard(radius: 60).copyWith(
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.textDark.withOpacity(0.4),
                            blurRadius: 50,
                            offset: const Offset(0, 25),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/29099e40-2686-49d2-af50-5d939b785f80.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  
                  // Text Branding
                  Text(
                    'அகரவளம்',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 3,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'TAMIL LEARNING EXCELLENCE',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.white.withOpacity(0.7),
                      letterSpacing: 4.0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer Branding
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white.withOpacity(0.24)),
                    strokeWidth: 2,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'POWERED BY HOPE3 SERVICES',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.white.withOpacity(0.4),
                      letterSpacing: 3.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseCircle extends StatelessWidget {
  final double width;
  final double height;
  final AnimationController controller;
  final Color color;

  const _PulseCircle({
    required this.width,
    required this.height,
    required this.controller,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (controller.value * 0.1),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        );
      },
    );
  }
}
