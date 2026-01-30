import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artiq_flutter/src/services/auth_service.dart';
import 'package:provider/provider.dart' as provider_pkg;
import '../providers/subscription_provider.dart';
import '../providers/demo_mode_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _promoCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showPromoField = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (user != null) {
        // Success! Auth state will be handled by AuthWrapper
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!'), backgroundColor: Colors.green),
        );
      } else {
        // Login failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: \$e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithGoogle();

      if (!mounted) return;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google sign-in cancelled or failed'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: \$e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (user != null) {
        // Promo code functionality temporarily disabled
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create account. Email may already be in use.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Dark slate
              Color(0xFF020617), // Darker slate
            ],
          ),
        ),
        child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/logo/artiq_logo.png',
                  width: 150,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome to ARTIQ',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Design made simple. Create stunning graphics in minutes.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '✨ Free forever • No design skills needed',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                // Product Hunt Badge
                GestureDetector(
                  onTap: () {
                    // Open Product Hunt page
                    // You can use url_launcher package here
                  },
                  child: Image.network(
                    'https://api.producthunt.com/widgets/embed-image/v1/featured.svg?post_id=artiq&theme=light',
                    width: 250,
                    height: 54,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Promo code section
                if (_showPromoField)
                  Column(
                    children: [
                      TextFormField(
                        controller: _promoCodeController,
                        decoration: InputDecoration(
                          labelText: 'Promo Code (Optional)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.local_offer),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _showPromoField = false;
                                _promoCodeController.clear();
                              });
                            },
                          ),
                        ),
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '🎉 Product Hunt users: Use code PRODUCTHUNT for 3 months Pro free!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                if (!_showPromoField)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showPromoField = true;
                      });
                    },
                    icon: const Icon(Icons.local_offer, size: 16),
                    label: const Text('Have a promo code?'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                const SizedBox(height: 24),
                // Try Demo Button - PRIMARY CTA
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFF6B35).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () {
                      final demoProvider = provider_pkg.Provider.of<DemoModeProvider>(context, listen: false);
                      demoProvider.enableDemoMode();
                    },
                    icon: const Icon(Icons.play_circle_filled, size: 28, color: Colors.white),
                    label: const Text(
                      'Try Demo - No Sign Up Required',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '✨ Explore ARTIQ instantly - no account needed',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Divider(height: 32),
                const Text(
                  'Or sign in with your account',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleLogin,
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: const Text('Sign in with Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _isLoading ? null : _handleSignup,
                  child: const Text('Don\'t have an account? Sign up'),
                ),
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
