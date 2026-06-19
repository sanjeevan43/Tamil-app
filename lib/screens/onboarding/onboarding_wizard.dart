import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/validation_service.dart';
import '../../providers/enhanced_progress_provider.dart';
import '../../services/audio_feedback_service.dart';
import '../main_navigation_container.dart';

class OnboardingWizard extends StatefulWidget {
  const OnboardingWizard({super.key});

  @override
  State<OnboardingWizard> createState() => _OnboardingWizardState();
}

class _OnboardingWizardState extends State<OnboardingWizard> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  
  int _currentStep = 0;
  String _selectedGender = 'boy'; // 'boy' or 'girl'
  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    AudioFeedbackService.playTap();
    if (_currentStep == 2 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your name!', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    if (_currentStep == 3) {
      final age = int.tryParse(_ageController.text.trim());
      final validationError = ValidationService.validateAge(age);
      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
    setState(() {
      _currentStep++;
    });
  }

  void _previousPage() {
    AudioFeedbackService.playTap();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
    setState(() {
      _currentStep--;
    });
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isSaving = true);
    AudioFeedbackService.playSparkle();

    try {
      final name = _nameController.text.trim();
      final age = int.tryParse(_ageController.text.trim()) ?? 6;
      final avatarEmoji = _selectedGender == 'boy' ? '👦' : '👧';

      final authService = Provider.of<AuthService>(context, listen: false);
      final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);

      final password = age.toString().padLeft(6, '0');

      // Attempt to register/login
      String? error = await authService.signInWithUsername(name, password);
      
      if (error != null) {
        final regError = await authService.registerWithUsername(name, age, password);
        if (regError != null) {
          if (regError.toLowerCase().contains('taken') || 
              regError.toLowerCase().contains('already-in-use') || 
              regError.toLowerCase().contains('already-exists') || 
              regError.toLowerCase().contains('email-already-in-use')) {
            error = 'Incorrect age for this name! Please enter the correct age.';
          } else {
            error = regError;
          }
        } else {
          error = null;
        }
      }

      if (error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error!, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              backgroundColor: AppTheme.error,
            ),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auto_login_username', name);
      await prefs.setInt('auto_login_age', age);
      await prefs.setString('auto_login_gender', _selectedGender);

      await progress.initializeProgress(uid: authService.user?.uid);
      await progress.updateAvatar(avatarEmoji);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationContainer()),
        );
      }
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator at the top
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primary),
                      onPressed: _previousPage,
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_currentStep + 1) / 5,
                        minHeight: 10,
                        backgroundColor: AppTheme.topoSilver.withOpacity(0.5),
                        valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomePage(),
                  _buildAvatarPage(),
                  _buildNamePage(),
                  _buildAgePage(),
                  _buildReadyPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👋', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          Text(
            'Welcome to Tamil Kids Park!',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Explore lessons, play fun games, and master Tamil words in your daily adventure.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: AppTheme.textSlate,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          _buildNextButton('START ADVENTURE', _nextPage),
        ],
      ),
    );
  }

  Widget _buildAvatarPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Choose Your Character',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the companion you like best!',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.textGray),
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAvatarOption('boy', 'assets/images/avatar_boy.png', '👦', 'Boy', const Color(0xFF42A5F5)),
              const SizedBox(width: 16),
              _buildAvatarOption('girl', 'assets/images/avatar_girl.png', '👧', 'Girl', const Color(0xFFEC407A)),
            ],
          ),
          const SizedBox(height: 48),
          _buildNextButton('CONTINUE', _nextPage),
        ],
      ),
    );
  }

  Widget _buildAvatarOption(String type, String imageAsset, String emoji, String label, Color accentColor) {
    final isSelected = _selectedGender == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          AudioFeedbackService.playPop();
          setState(() {
            _selectedGender = type;
          });
        },
        child: AnimatedScale(
          scale: isSelected ? 1.05 : 0.95,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? accentColor.withOpacity(0.08) : AppTheme.topoLight,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isSelected ? accentColor : AppTheme.topoSilver,
                width: isSelected ? 3.0 : 1.5,
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  child: Image.asset(imageAsset, fit: BoxFit.contain),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isSelected ? accentColor : AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✏️', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 24),
          Text(
            'What is your name?',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            style: GoogleFonts.outfit(fontSize: 18, color: AppTheme.textDark, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: GoogleFonts.outfit(color: AppTheme.textGray),
              prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primary),
              filled: true,
              fillColor: AppTheme.topoLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            ),
          ),
          const SizedBox(height: 48),
          _buildNextButton('CONTINUE', _nextPage),
        ],
      ),
    );
  }

  Widget _buildAgePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎂', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 24),
          Text(
            'How old are you?',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.outfit(fontSize: 18, color: AppTheme.textDark, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Enter your age',
              hintStyle: GoogleFonts.outfit(color: AppTheme.textGray),
              prefixIcon: const Icon(Icons.cake_outlined, color: AppTheme.primary),
              filled: true,
              fillColor: AppTheme.topoLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            ),
          ),
          const SizedBox(height: 48),
          _buildNextButton('CONTINUE', _nextPage),
        ],
      ),
    );
  }

  Widget _buildReadyPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🚀', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          Text(
            'Ready to Begin!',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your account is configured and your Tamil adventure is set to begin!',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: AppTheme.textSlate,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          _buildNextButton('LET\'S GO!', _completeOnboarding),
        ],
      ),
    );
  }

  Widget _buildNextButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _isSaving
            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
            : Text(
                text,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}
