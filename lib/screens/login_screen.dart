import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/validation_service.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';
import 'admin_control_screen.dart';
import 'teacher_dashboard_screen.dart';
import 'parent_dashboard_screen.dart';
import 'main_navigation_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _navigateToRoleBasedScreen(AuthService authService) async {
    if (!mounted) return;

    final progress = Provider.of<EnhancedProgressProvider>(context, listen: false);
    await progress.initializeProgress(uid: authService.user?.uid);

    if (!mounted) return;

    final role = authService.userRole;
    Widget nextScreen;

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

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => nextScreen),
        (route) => false,
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    String? error;
    if (_isLogin) {
      error = await authService.signInWithUsername(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      final int age = int.tryParse(_ageController.text.trim()) ?? 0;
      error = await authService.registerWithUsername(
        _usernameController.text.trim(),
        age,
        _passwordController.text.trim(),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppTheme.error),
        );
      } else {
        _navigateToRoleBasedScreen(authService);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.secondary, AppTheme.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: screenHeight * 0.02),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth * 0.9 < 400.0 ? screenWidth * 0.9 : 400.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      height: screenWidth * 0.3 < 120.0 ? screenWidth * 0.3 : 120.0,
                      width: screenWidth * 0.3 < 120.0 ? screenWidth * 0.3 : 120.0,
                      decoration: AppTheme.whiteCard(),
                      child: Image.asset(
                        'assets/images/29099e40-2686-49d2-af50-5d939b785f80.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Form Card
                    Container(
                      decoration: AppTheme.whiteCard(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isLogin ? 'Welcome Back' : 'Create Account',
                                style: GoogleFonts.outfit(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.secondary,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isLogin
                                    ? 'Login to continue your journey'
                                    : 'Join our Tamil learning community',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: AppTheme.textGray,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Username
                              TextFormField(
                                controller: _usernameController,
                                style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.secondary),
                                decoration: InputDecoration(
                                  hintText: 'Username',
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
                                validator: (value) => ValidationService.validateUsername(value),
                              ),
                              const SizedBox(height: 14),

                              // Age (Register only)
                              if (!_isLogin) ...[
                                TextFormField(
                                  controller: _ageController,
                                  style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.secondary),
                                  decoration: InputDecoration(
                                    hintText: 'Age',
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
                                  validator: (value) {
                                    final val = int.tryParse(value ?? '');
                                    return ValidationService.validateAge(val);
                                  },
                                ),
                                const SizedBox(height: 14),
                              ],

                              // Password
                              TextFormField(
                                controller: _passwordController,
                                style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.secondary),
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: GoogleFonts.outfit(color: AppTheme.textGray),
                                  prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppTheme.textGray),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      size: 20,
                                      color: AppTheme.textGray,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  filled: true,
                                  fillColor: AppTheme.topoLight,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                ),
                                obscureText: _obscurePassword,
                                validator: (value) => ValidationService.validatePassword(value),
                              ),
                              const SizedBox(height: 14),

                              // Submit Button or Loading
                              if (_isLoading)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                                  ),
                                )
                              else ...[
                                SizedBox(
                                  width: double.infinity,
                                  height: screenHeight * 0.07 < 58.0 ? screenHeight * 0.07 : 58.0,
                                  child: ElevatedButton(
                                    onPressed: _handleSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      foregroundColor: AppTheme.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: Text(
                                      _isLogin ? 'LOGIN' : 'CREATE ACCOUNT',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Toggle Login/Register
                                TextButton(
                                  onPressed: () => setState(() => _isLogin = !_isLogin),
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.outfit(
                                        color: AppTheme.textGray,
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: _isLogin
                                              ? "Don't have an account? "
                                              : 'Already have an account? ',
                                        ),
                                        TextSpan(
                                          text: _isLogin ? 'Sign Up' : 'Login',
                                          style: GoogleFonts.outfit(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
