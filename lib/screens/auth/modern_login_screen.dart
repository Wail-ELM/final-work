import 'package:flutter/material.dart' hide ButtonStyle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system.dart';
import '../../providers/auth_provider.dart';

class ModernLoginScreen extends ConsumerStatefulWidget {
  const ModernLoginScreen({super.key});

  @override
  ConsumerState<ModernLoginScreen> createState() => _ModernLoginScreenState();
}

class _ModernLoginScreenState extends ConsumerState<ModernLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Démarrer les animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesignSystem.borderRadiusLarge,
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppDesignSystem.error),
            const SizedBox(width: AppDesignSystem.space12),
            const Text('Oeps!'),
          ],
        ),
        content: Text(error),
        actions: [
          ModernButton(
            text: 'Sluiten',
            style: ButtonStyle.secondary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesignSystem.primaryGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
              padding: const EdgeInsets.all(AppDesignSystem.space24),
              child: Column(
                children: [
                  // Header avec animation
                  Expanded(
                    flex: 2,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo/Icon animé
                          Container(
                            padding:
                                const EdgeInsets.all(AppDesignSystem.space20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(
                                  AppDesignSystem.radiusXLarge),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.psychology_outlined,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppDesignSystem.space24),
                          Text(
                            'Welkom Terug! 👋',
                            style: AppDesignSystem.heading1.copyWith(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDesignSystem.space8),
                          Text(
                            'Log in bij Social Balans om je voortgang voort te zetten',
                            style: AppDesignSystem.body1.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Formulaire avec animation
                  Expanded(
                    flex: 3,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ModernCard(
                          color: Colors.white,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Inloggen',
                                  style: AppDesignSystem.heading2,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppDesignSystem.space32),

                                // Email Field moderne
                                _buildModernTextField(
                                  controller: _emailController,
                                  label: 'E-mailadres',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Voer je e-mailadres in';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Voer een geldig e-mailadres in';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: AppDesignSystem.space20),

                                // Password Field moderne
                                _buildModernTextField(
                                  controller: _passwordController,
                                  label: 'Wachtwoord',
                                  icon: Icons.lock_outline,
                                  obscureText: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: AppDesignSystem.neutral500,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Voer je wachtwoord in';
                                    }
                                    if (value.length < 6) {
                                      return 'Wachtwoord moet minimaal 6 tekens bevatten';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: AppDesignSystem.space32),

                                // Modern Login Button
                                ModernButton(
                                  text: 'Inloggen',
                                  icon: Icons.login,
                                  isLoading: _isLoading,
                                  onPressed: _signIn,
                                ),

                                const SizedBox(height: AppDesignSystem.space20),

                                // Forgot Password
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/forgot-password');
                                    },
                                    child: Text(
                                      'Wachtwoord vergeten?',
                                      style: AppDesignSystem.body2.copyWith(
                                        color: AppDesignSystem.primaryGreen,
                                        fontWeight: FontWeight.w600,
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

                  // Bottom section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Nog geen account?',
                          style: AppDesignSystem.body2.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text(
                            'Registreren',
                            style: AppDesignSystem.body2.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppDesignSystem.neutral50,
        borderRadius: AppDesignSystem.borderRadiusMedium,
        border: Border.all(
          color: AppDesignSystem.neutral200,
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: AppDesignSystem.body1,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppDesignSystem.body2.copyWith(
            color: AppDesignSystem.neutral500,
          ),
          prefixIcon: Icon(
            icon,
            color: AppDesignSystem.neutral500,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppDesignSystem.space16),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppDesignSystem.borderRadiusMedium,
            borderSide: BorderSide(
              color: AppDesignSystem.primaryGreen,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppDesignSystem.borderRadiusMedium,
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppDesignSystem.borderRadiusMedium,
            borderSide: BorderSide(
              color: AppDesignSystem.error,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
