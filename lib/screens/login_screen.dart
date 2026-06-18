import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_theme.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/validation_service.dart';
import '../providers/enhanced_progress_provider.dart';
import 'main_navigation_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGender = 'boy'; // 'boy' or 'girl'
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();
      final age = int.tryParse(_ageController.text.trim()) ?? 6;
      final avatarEmoji = _selectedGender == 'boy' ? '👦' : '👧';

      final authService = Provider.of<AuthService>(context, listen: false);
      final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);

      // Generate the password based on age (padded to 6 characters minimum required by Firebase)
      final password = age.toString().padLeft(6, '0');

      // Attempt to register/login using Username (Name) and Password (Age)
      // First try to sign in
      String? error = await authService.signInWithUsername(name, password);
      
      // If sign-in fails, attempt to register
      if (error != null) {
        final regError = await authService.registerWithUsername(name, age, password);
        if (regError != null) {
          // If registration fails because username is taken, they entered the wrong age
          if (regError.toLowerCase().contains('taken') || 
              regError.toLowerCase().contains('already-in-use') || 
              regError.toLowerCase().contains('already-exists') || 
              regError.toLowerCase().contains('email-already-in-use')) {
            error = 'Incorrect age for this name! Please enter the correct age.';
          } else {
            error = regError;
          }
        } else {
          // Registration succeeded! Clear the error
          error = null;
        }
      }

      if (error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              backgroundColor: AppTheme.error,
            ),
          );
        }
        return;
      }

      // Save credentials in SharedPreferences for auto-login on next app startup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auto_login_username', name);
      await prefs.setInt('auto_login_age', age);
      await prefs.setString('auto_login_gender', _selectedGender);

      // Initialize the student's progress and profile data using their unique UID
      await progress.initializeProgress(uid: authService.user?.uid);
      await progress.updateAvatar(avatarEmoji); // update avatar locally/cloud

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationContainer()),
        );
      }
    } catch (e) {
      debugPrint('Error saving user profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.secondary,
              AppTheme.primaryDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Container(
                width: screenWidth * 0.9 < 420.0 ? screenWidth * 0.9 : 420.0,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                  border: Border.all(color: AppTheme.topoSilver.withOpacity(0.5), width: 1.5),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        'Choose Your Character!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.secondary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Let\'s build your profile to start learning',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppTheme.textGray,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Gender/Character Selector (Boy / Girl)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Boy card
                          _buildCharacterCard(
                            gender: 'boy',
                            imagePath: 'assets/images/avatar_boy.png',
                            label: 'Boy',
                            accentColor: const Color(0xFF42A5F5),
                          ),
                          const SizedBox(width: 16),
                          // Girl card
                          _buildCharacterCard(
                            gender: 'girl',
                            imagePath: 'assets/images/avatar_girl.png',
                            label: 'Girl',
                            accentColor: const Color(0xFFEC407A),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Name Input
                      TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.secondary),
                        decoration: InputDecoration(
                          hintText: 'Your Name',
                          hintStyle: GoogleFonts.outfit(color: AppTheme.textGray),
                          prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppTheme.textGray),
                          filled: true,
                          fillColor: AppTheme.topoLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        ),
                        validator: (val) => ValidationService.validateName(val),
                      ),
                      const SizedBox(height: 14),

                      // Age Input
                      TextFormField(
                        controller: _ageController,
                        style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.secondary),
                        decoration: InputDecoration(
                          hintText: 'Your Age',
                          hintStyle: GoogleFonts.outfit(color: AppTheme.textGray),
                          prefixIcon: const Icon(Icons.cake_outlined, size: 20, color: AppTheme.textGray),
                          filled: true,
                          fillColor: AppTheme.topoLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          final age = int.tryParse(val ?? '');
                          return ValidationService.validateAge(age);
                        },
                      ),
                      const SizedBox(height: 28),

                      // Let's Go Button
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 4,
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                              : Text(
                                  'LET\'S GO!',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterCard({
    required String gender,
    required String imagePath,
    required String label,
    required Color accentColor,
  }) {
    final isSelected = _selectedGender == gender;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = gender;
          });
        },
        child: AnimatedScale(
          scale: isSelected ? 1.05 : 0.95,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? accentColor.withOpacity(0.08) : AppTheme.topoLight,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isSelected ? accentColor : AppTheme.topoSilver,
                width: isSelected ? 3.0 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accentColor.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                // Illustration
                Container(
                  height: 100,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                // Label
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isSelected ? accentColor : AppTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
