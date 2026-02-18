import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_theme.dart';
import 'enhanced_home_screen.dart';

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
      duration: const Duration(seconds: 2), // Loop duration
      vsync: this,
    )..repeat(reverse: true);
    
    // Navigate after delay
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const EnhancedHomeScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1000),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF0000), Color(0xFFDC2626), Color(0xFF8B0000)], // vibrant-red to deep-red
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Shapes
            Positioned(
              top: -80,
              left: -80,
              child: _PulseCircle(
                width: 320,
                height: 320,
                controller: _controller,
                delay: 0.0,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 2,
              right: -128,
              child: const _GlassCircle(width: 384, height: 384, opacity: 0.5),
            ),
            Positioned(
              bottom: -40,
              left: MediaQuery.of(context).size.width / 4,
              child: _PulseCircle(
                width: 256,
                height: 256,
                controller: _controller,
                delay: 0.5,
              ),
            ),
            
            // Content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Branding
                  Padding(
                    padding: const EdgeInsets.only(top: 48.0),
                    child: Text(
                      'POWERED BY HOPE3 SERVICES',
                      style: GoogleFonts.openSans(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 10,
                        letterSpacing: 3.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  // Main Logo Section
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Glass Overlay Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'தமிழ்',
                                  style: GoogleFonts.notoSansTamil(
                                    fontSize: 96,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.0,
                                    shadows: [
                                      Shadow(color: Colors.white.withOpacity(0.4), blurRadius: 20),
                                      Shadow(color: Colors.black.withOpacity(0.3), offset: const Offset(0, 4), blurRadius: 10),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  height: 6,
                                  width: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'LEARNING REIMAGINED',
                        style: GoogleFonts.openSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                  
                  // Empty container to balance spacing
                  Container(height: 80),
                ],
              ),
            ),
            
            // Bottom Gradient Light
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height / 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.2)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}

class _GlassCircle extends StatelessWidget {
  final double width;
  final double height;
  final double opacity;

  const _GlassCircle({
    required this.width,
    required this.height,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.3 * opacity),
            Colors.white.withOpacity(0.05 * opacity),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.15 * opacity)),
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}

class _PulseCircle extends StatelessWidget {
  final double width;
  final double height;
  final AnimationController controller;
  final double delay;

  const _PulseCircle({
    required this.width,
    required this.height,
    required this.controller,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final val = controller.value; 
        return Transform.scale(
          scale: 1.0 + (0.05 * val),
          child: Opacity(
            opacity: 0.6 + (0.2 * val),
            child: child,
          ),
        );
      },
      child: _GlassCircle(width: width, height: height, opacity: 1.0),
    );
  }
}
