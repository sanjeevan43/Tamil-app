import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../constants/app_theme.dart';
import '../providers/enhanced_progress_provider.dart';
import 'enhanced_home_screen.dart';
import 'admin_control_screen.dart';
import 'teacher_dashboard_screen.dart';
import 'parent_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;
  String _selectedRole = 'student';
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (rememberMe && savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
      // Auto-login
      Future.delayed(const Duration(milliseconds: 500), _handleSubmit);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
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
        nextScreen = const EnhancedHomeScreen();
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
      error = await authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      error = await authService.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        role: _selectedRole,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppTheme.error),
        );
      } else {
        // Save credentials if Remember Me is checked
        if (_rememberMe && _isLogin) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_email', _emailController.text.trim());
          await prefs.setString('saved_password', _passwordController.text.trim());
          await prefs.setBool('remember_me', true);
        }
        _navigateToRoleBasedScreen(authService);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final error = await authService.signInWithGoogle();

    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null && error != "Sign in cancelled") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppTheme.error),
        );
      } else if (error == null) {
        _navigateToRoleBasedScreen(authService);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(16),
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.4),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/29099e40-2686-49d2-af50-5d939b785f80.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 50,
                            offset: const Offset(0, 25),
                          ),
                        ],
                      ),
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

                              // Email
                              TextFormField(
                                controller: _emailController,
                                style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.secondary),
                                decoration: InputDecoration(
                                  hintText: 'Email Address',
                                  hintStyle: GoogleFonts.outfit(color: AppTheme.textGray),
                                  prefixIcon: Icon(Icons.email_outlined, size: 20, color: AppTheme.textGray),
                                  filled: true,
                                  fillColor: AppTheme.topoLight,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.trim().contains('@')) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Password
                              TextFormField(
                                controller: _passwordController,
                                style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.secondary),
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: GoogleFonts.outfit(color: AppTheme.textGray),
                                  prefixIcon: Icon(Icons.lock_outline, size: 20, color: AppTheme.textGray),
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
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Role Selector (Register only)
                              if (!_isLogin) ...{
                                DropdownButtonFormField<String>(
                                  value: _selectedRole,
                                  style: GoogleFonts.outfit(fontSize: 15, color: AppTheme.secondary),
                                  decoration: InputDecoration(
                                    hintText: 'I am a...',
                                    hintStyle: GoogleFonts.outfit(color: AppTheme.textGray),
                                    prefixIcon: Icon(Icons.person_outline, size: 20, color: AppTheme.textGray),
                                    filled: true,
                                    fillColor: AppTheme.topoLight,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                  ),
                                  items: ['student', 'teacher', 'parent', 'admin'].map((role) {
                                    return DropdownMenuItem(
                                      value: role,
                                      child: Text(role[0].toUpperCase() + role.substring(1)),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => _selectedRole = val!),
                                ),
                                const SizedBox(height: 14),
                              },

                              // Remember Me Checkbox (Login only)
                              if (_isLogin)
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (val) => setState(() => _rememberMe = val ?? false),
                                      activeColor: AppTheme.primary,
                                      side: BorderSide(color: AppTheme.textGray, width: 1.5),
                                    ),
                                    Text(
                                      'Remember me',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        color: AppTheme.textGray,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 8),

                              // Submit Button or Loading
                              if (_isLoading)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                                  ),
                                )
                              else ...{
                                SizedBox(
                                  width: double.infinity,
                                  height: 58,
                                  child: ElevatedButton(
                                    onPressed: _handleSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
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

                                // OR divider
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: Colors.grey.shade300)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'OR',
                                        style: GoogleFonts.outfit(
                                          color: AppTheme.textGray,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Divider(color: Colors.grey.shade300)),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Google Sign In
                                SizedBox(
                                  width: double.infinity,
                                  height: 58,
                                  child: OutlinedButton.icon(
                                    onPressed: _handleGoogleSignIn,
                                    icon: const Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                                    label: Text(
                                      'Continue with Google',
                                      style: GoogleFonts.outfit(
                                        color: AppTheme.secondary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
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
                                              : "Already have an account? ",
                                        ),
                                        TextSpan(
                                          text: _isLogin ? "Sign Up" : "Login",
                                          style: GoogleFonts.outfit(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              },
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
