import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_theme.dart';
import 'home_screen.dart';
import 'tamil_letters_screen.dart';
import 'games_hub_screen.dart';
import 'stories_screen.dart';
import 'profile_screen.dart';

class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  State<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TamilLettersScreen(),
    GamesHubScreen(),
    StoriesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      // Use Stack to position the custom floating bottom navigation bar
      body: Stack(
        children: [
          // Current Active Screen
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),

          // Premium Floating Glassmorphic Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.secondary.withOpacity(0.96), // Premium Deep Black background
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.24), // Glowing logo-red border outline
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_rounded, 'Home'),
                    _buildNavItem(1, Icons.translate_rounded, 'Letters'),
                    _buildNavItem(2, Icons.sports_esports_rounded, 'Games'),
                    _buildNavItem(3, Icons.auto_stories_rounded, 'Stories'),
                    _buildNavItem(4, Icons.person_rounded, 'Profile'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final accentColor = AppTheme.primary; // Vibrant logo-inspired red

    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 72,
        width: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Slide and fade indicator
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              top: isSelected ? 8 : -20,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.5),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Icon and Text container
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: isSelected
                      ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
                      : EdgeInsets.zero,
                  decoration: isSelected
                      ? BoxDecoration(
                          color: accentColor.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(16),
                        )
                      : null,
                  child: Icon(
                    icon,
                    color: isSelected ? accentColor : AppTheme.white.withOpacity(0.6),
                    size: isSelected ? 24 : 22,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    color: isSelected ? accentColor : AppTheme.white.withOpacity(0.6),
                    letterSpacing: 0.5,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
