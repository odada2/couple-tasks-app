import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';

class CoupleSetupScreen extends StatefulWidget {
  const CoupleSetupScreen({super.key});

  @override
  State<CoupleSetupScreen> createState() => _CoupleSetupScreenState();
}

class _CoupleSetupScreenState extends State<CoupleSetupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  Future<void> _linkCouple() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your partner\'s email')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('Not logged in');
      }

      // Find partner by email
      final partner =
          await _firestoreService.getUserByEmail(_emailController.text.trim());

      if (partner == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Partner not found. They need to sign up first!'),
            ),
          );
        }
        return;
      }

      if (partner.id == currentUser.uid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('You cannot link with yourself!')),
          );
        }
        return;
      }

      // Create couple
      await _firestoreService.createCouple(
        currentUser.uid,
        partner.id,
        coupleName: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : null,
      );

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error linking couple: $e')),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Link with Partner'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.softPeach,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Text(
                      '👫',
                      style: TextStyle(fontSize: 60),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Connect with your partner',
                style: Theme.of(context).textTheme.displaySmall,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'Enter your partner\'s email to start collaborating on tasks together.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.mediumGray,
                      height: 1.5,
                    ),
              ),

              const SizedBox(height: 32),

              // Couple name field
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Couple Name (Optional)',
                  hintText: 'e.g., Alex & Jordan',
                  prefixIcon: Icon(Icons.favorite_outline),
                ),
              ),

              const SizedBox(height: 16),

              // Partner email field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Partner\'s Email',
                  hintText: 'partner@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),

              const SizedBox(height: 32),

              // Link button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _linkCouple,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Link Together'),
                ),
              ),

              const SizedBox(height: 16),

              // Info text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightPink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryPink,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your partner needs to sign up first before you can link together.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.darkText,
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
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
