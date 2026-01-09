import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null && mounted) {
        // Check if user has a couple
        final userData = await _authService.getCurrentUserData();
        if (userData?.coupleId != null) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          Navigator.of(context).pushReplacementNamed('/couple-setup');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: $e')),
        );
      }
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Heart icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.lightPink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 40,
                  color: AppTheme.primaryPink,
                ),
              ),

              const SizedBox(height: 48),

              // Title
              Text(
                'Welcome to your\nshared space',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Building a life together, one task\nand triumph at a time.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.mediumGray,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 64),

              // Google Sign In Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.darkText,
                    side: const BorderSide(color: AppTheme.mediumGray),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Image.network(
                          'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                          width: 24,
                          height: 24,
                        ),
                  label: Text(_isLoading
                      ? 'Signing in...'
                      : 'Continue with Google'),
                ),
              ),

              const SizedBox(height: 16),

              // Apple Sign In Button (placeholder)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Apple Sign In not implemented yet
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Apple Sign In coming soon!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.apple),
                  label: const Text('Continue with Apple'),
                ),
              ),

              const SizedBox(height: 32),

              // Terms text
              Text(
                'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
